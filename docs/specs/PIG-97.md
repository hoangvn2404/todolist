# PIG-97: Build Todo List

## Summary

Build a personal todo list feature for the Piggyme Rails 8 app with add, delete, check (toggle complete), and filter capabilities. Uses Stimulus for JavaScript interaction and Turbo Morphing for seamless DOM updates without full page reloads.

**Stack:** Rails 8.0.4, SQLite3, Turbo (morphing), Stimulus, Tailwind CSS v4, Importmap, Propshaft

---

## Technical Approach

### Data Model

A single `Todo` model with minimal fields:

```ruby
# db/migrate/XXXXXX_create_todos.rb
class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.string :title, null: false
      t.boolean :completed, default: false, null: false
      t.timestamps
    end
  end
end
```

```ruby
# app/models/todo.rb
class Todo < ApplicationRecord
  validates :title, presence: true

  scope :completed, -> { where(completed: true) }
  scope :active, -> { where(completed: false) }
  scope :by_filter, ->(filter) {
    case filter
    when "active" then active
    when "completed" then completed
    else all
    end
  }
end
```

### Controller

A resourceful `TodosController` that renders HTML responses. Turbo Morphing handles DOM diffing automatically on redirects — no turbo_stream format needed.

```ruby
# app/controllers/todos_controller.rb
class TodosController < ApplicationController
  before_action :set_todo, only: [:update, :destroy]

  def index
    @filter = params[:filter] || "all"
    @todos = Todo.by_filter(@filter).order(created_at: :desc)
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to todos_path(filter: params[:filter])
    else
      @filter = params[:filter] || "all"
      @todos = Todo.by_filter(@filter).order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @todo.update(todo_params)
    redirect_to todos_path(filter: params[:filter])
  end

  def destroy
    @todo.destroy
    redirect_to todos_path(filter: params[:filter])
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.expect(todo: [:title, :completed])
  end
end
```

### Turbo Morphing

Enable page-refresh morphing so redirects after create/update/destroy morph the existing DOM instead of replacing it. This preserves scroll position and input focus.

```erb
<%# app/views/layouts/application.html.erb — add inside <head> %>
<%= turbo_refreshes_with method: :morph, scroll: :preserve %>
```

### Routes

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :todos, only: [:index, :create, :update, :destroy]
  root "todos#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

### View — `app/views/todos/index.html.erb`

Single-page feel: form at top, filter tabs, todo list below.

```erb
<div class="w-full max-w-lg mx-auto" data-controller="todo-form">
  <h1 class="text-3xl font-bold mb-8">Todos</h1>

  <%# Add form %>
  <%= form_with model: @todo, url: todos_path(filter: @filter), class: "flex gap-2 mb-6" do |f| %>
    <%= f.text_field :title,
        placeholder: "What needs to be done?",
        class: "flex-1 rounded-lg border border-gray-300 px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500",
        autofocus: true,
        data: { todo_form_target: "input", action: "keydown.enter->todo-form#submit" } %>
    <%= f.submit "Add",
        class: "rounded-lg bg-blue-600 px-4 py-2 text-white hover:bg-blue-700 cursor-pointer" %>
  <% end %>

  <%# Filters %>
  <nav class="flex gap-4 mb-6 text-sm">
    <% %w[all active completed].each do |filter| %>
      <%= link_to filter.capitalize,
          todos_path(filter: filter),
          class: "px-3 py-1 rounded-full #{@filter == filter ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}" %>
    <% end %>
  </nav>

  <%# Todo list %>
  <% if @todos.any? %>
    <ul class="space-y-2">
      <% @todos.each do |todo| %>
        <li id="<%= dom_id(todo) %>" class="flex items-center gap-3 rounded-lg border border-gray-200 px-4 py-3 group">
          <%# Toggle completed %>
          <%= button_to todo_path(todo, filter: @filter),
              method: :patch,
              params: { todo: { completed: !todo.completed } },
              class: "flex items-center justify-center w-6 h-6 rounded-full border-2 #{todo.completed? ? 'border-green-500 bg-green-500' : 'border-gray-300 hover:border-green-400'} cursor-pointer" do %>
            <% if todo.completed? %>
              <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/>
              </svg>
            <% end %>
          <% end %>

          <span class="flex-1 <%= 'line-through text-gray-400' if todo.completed? %>">
            <%= todo.title %>
          </span>

          <%# Delete %>
          <%= button_to todo_path(todo, filter: @filter),
              method: :delete,
              class: "text-red-400 hover:text-red-600 opacity-0 group-hover:opacity-100 transition-opacity cursor-pointer",
              data: { turbo_confirm: "Delete this todo?" } do %>
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          <% end %>
        </li>
      <% end %>
    </ul>
  <% else %>
    <p class="text-gray-400 text-center py-8">No todos yet. Add one above!</p>
  <% end %>
</div>
```

### Stimulus Controller — `app/javascript/controllers/todo_form_controller.js`

Lightweight controller to clear the input after form submission (morphing preserves the form element, so we clear it manually).

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  submit() {
    // Allow the form to submit normally, then clear after morph
    requestAnimationFrame(() => {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    })
  }

  // Clear input after successful Turbo navigation (morph)
  disconnect() {
    // No cleanup needed
  }
}
```

To properly clear the input after a morph-based page refresh, add a Turbo event listener approach:

```javascript
// app/javascript/controllers/todo_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.clearAfterMorph = this.clearInput.bind(this)
    document.addEventListener("turbo:morph", this.clearAfterMorph)
  }

  disconnect() {
    document.removeEventListener("turbo:morph", this.clearAfterMorph)
  }

  clearInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
  }
}
```

---

## Step-by-Step Implementation Instructions

### Step 1: Generate the Todo model and migration

```bash
bin/rails generate model Todo title:string completed:boolean
```

Edit the migration to add `null: false` on title and `default: false, null: false` on completed. Run:

```bash
bin/rails db:migrate
```

### Step 2: Add model validations and scopes

Edit `app/models/todo.rb` to add:
- `validates :title, presence: true`
- Scopes: `completed`, `active`, `by_filter`

### Step 3: Create the TodosController

Create `app/controllers/todos_controller.rb` with `index`, `create`, `update`, `destroy` actions as shown above.

### Step 4: Set up routes

Edit `config/routes.rb`:
- Add `resources :todos, only: [:index, :create, :update, :destroy]`
- Set `root "todos#index"`

### Step 5: Enable Turbo Morphing

Add `<%= turbo_refreshes_with method: :morph, scroll: :preserve %>` inside the `<head>` tag in `app/views/layouts/application.html.erb`.

### Step 6: Create the view

Create `app/views/todos/index.html.erb` with:
- New todo form at the top
- Filter navigation tabs (all / active / completed)
- Todo list with toggle-complete and delete buttons
- Tailwind CSS styling throughout

### Step 7: Create the Stimulus controller

Create `app/javascript/controllers/todo_form_controller.js` that listens for `turbo:morph` events to clear the input field after successful form submission.

### Step 8: Remove the hello_controller.js example

Delete `app/javascript/controllers/hello_controller.js` — it's the Rails scaffold example and not needed.

### Step 9: Add fixtures and tests

Create test fixtures and write:
- Model tests for validations and scopes
- Controller tests for CRUD actions and filtering
- System test for the full user flow

---

## Test Plan

### Model Tests (`test/models/todo_test.rb`)

- `test "valid with title"` — todo with title is valid
- `test "invalid without title"` — todo without title is invalid
- `test "completed defaults to false"` — new todo has `completed: false`
- `test "scope active"` — returns only incomplete todos
- `test "scope completed"` — returns only completed todos
- `test "scope by_filter all"` — returns all todos
- `test "scope by_filter active"` — returns only active todos
- `test "scope by_filter completed"` — returns only completed todos

### Controller Tests (`test/controllers/todos_controller_test.rb`)

- `test "GET index"` — returns 200, renders todos
- `test "GET index with filter"` — filters todos correctly
- `test "POST create with valid params"` — creates todo, redirects
- `test "POST create with blank title"` — re-renders index with errors
- `test "PATCH update toggles completed"` — updates completed status
- `test "DELETE destroy"` — removes todo, redirects

### System Tests (`test/system/todos_test.rb`)

- `test "add a todo"` — type title, click Add, see it in the list
- `test "complete a todo"` — click the circle, see line-through styling
- `test "delete a todo"` — hover, click X, confirm, todo disappears
- `test "filter todos"` — add mix of completed/active, click each filter tab, verify correct items shown

---

## Acceptance Criteria

1. **Add:** User can type a title and press Enter or click "Add" to create a todo. The input clears after submission.
2. **Check/Uncheck:** User can click the circle button to toggle a todo between active and completed. Completed todos show a green checkmark and strikethrough text.
3. **Delete:** User can hover over a todo and click the X button to delete it (with confirmation dialog).
4. **Filter:** User can click "All", "Active", or "Completed" tabs to filter the visible todos. The active filter is visually highlighted.
5. **Persistence:** Todos survive page reload (stored in SQLite via ActiveRecord).
6. **Morphing:** Page updates use Turbo Morphing — no full page flash on add/complete/delete. Scroll position is preserved.
7. **Stimulus:** The form input clearing is handled by a Stimulus controller listening for Turbo morph events.
8. **Responsive:** The UI is centered, max-width constrained, and works on mobile viewports.
9. **Tests pass:** All model, controller, and system tests pass.
