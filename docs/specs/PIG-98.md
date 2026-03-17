# PIG-98: Create Todo Feature

## Summary

Build a personal todo list with add, delete, check (toggle complete), and filter functionality. Use StimulusJS for JavaScript interaction and Turbo morphing where possible to minimize full-page reloads.

## Technical Approach

### Stack

- **Backend:** Rails controller + model for Todo items
- **Frontend:** StimulusJS controllers for interactive behavior
- **Updates:** Turbo Streams with morphing for DOM updates

### Data Model

```ruby
# db/migrate/xxx_create_todos.rb
class CreateTodos < ActiveRecord::Migration[7.1]
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
end
```

### Controller

```ruby
# app/controllers/todos_controller.rb
class TodosController < ApplicationController
  def index
    @todos = filter_todos(Todo.all.order(created_at: :desc))
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to todos_path(filter: params[:filter]), status: :see_other
    else
      @todos = filter_todos(Todo.all.order(created_at: :desc))
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @todo = Todo.find(params[:id])
    @todo.update!(todo_params)
    redirect_to todos_path(filter: params[:filter]), status: :see_other
  end

  def destroy
    Todo.find(params[:id]).destroy!
    redirect_to todos_path(filter: params[:filter]), status: :see_other
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end

  def filter_todos(scope)
    case params[:filter]
    when "active" then scope.active
    when "completed" then scope.completed
    else scope
    end
  end
end
```

### Routes

```ruby
# config/routes.rb
resources :todos, only: [:index, :create, :update, :destroy]
root "todos#index"
```

### View with Turbo Morphing

```erb
<%# app/views/todos/index.html.erb %>
<%= turbo_refreshes_with method: :morph, scroll: :preserve %>

<div class="todos-container" data-controller="todos">
  <h1>Todos</h1>

  <%= form_with model: Todo.new, url: todos_path, class: "todo-form" do |f| %>
    <%= f.text_field :title, placeholder: "What needs to be done?",
        autofocus: true, required: true,
        data: { action: "keydown.enter->todos#submitForm" } %>
    <%= f.submit "Add" %>
  <% end %>

  <nav class="todo-filters" data-controller="filter">
    <%= link_to "All", todos_path,
        class: "filter-link #{'active' if params[:filter].blank?}" %>
    <%= link_to "Active", todos_path(filter: "active"),
        class: "filter-link #{'active' if params[:filter] == 'active'}" %>
    <%= link_to "Completed", todos_path(filter: "completed"),
        class: "filter-link #{'active' if params[:filter] == 'completed'}" %>
  </nav>

  <ul class="todo-list" id="todo-list">
    <% @todos.each do |todo| %>
      <li id="<%= dom_id(todo) %>" class="todo-item <%= 'completed' if todo.completed? %>">
        <%= button_to todos_path(todo, filter: params[:filter]),
            method: :patch, class: "todo-toggle",
            params: { todo: { completed: !todo.completed? } } do %>
          <span class="checkbox"><%= todo.completed? ? "☑" : "☐" %></span>
        <% end %>

        <span class="todo-title"><%= todo.title %></span>

        <%= button_to todo_path(todo, filter: params[:filter]),
            method: :delete, class: "todo-delete" do %>
          ✕
        <% end %>
      </li>
    <% end %>
  </ul>

  <div class="todo-footer">
    <span><%= @todos.count %> item(s)</span>
  </div>
</div>
```

### Stimulus Controller

```javascript
// app/javascript/controllers/todos_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitForm(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      event.target.closest("form").requestSubmit()
    }
  }
}
```

### Turbo Morphing Setup

Enable morphing in `app/views/layouts/application.html.erb`:

```erb
<head>
  <meta name="turbo-refresh-method" content="morph">
  <meta name="turbo-refresh-scroll" content="preserve">
</head>
```

This allows Turbo to morph the DOM on page refreshes instead of replacing the entire body, keeping focus state and scroll position intact.

## Step-by-Step Implementation

1. **Generate the Todo model and migration**
   - `rails generate model Todo title:string completed:boolean`
   - Edit migration to add `null: false` on title and `default: false` on completed
   - `rails db:migrate`

2. **Add model validations and scopes**
   - Add `validates :title, presence: true`
   - Add `scope :completed` and `scope :active`

3. **Create the TodosController**
   - Implement `index`, `create`, `update`, `destroy` actions
   - Add private `filter_todos` helper

4. **Set up routes**
   - Add `resources :todos, only: [:index, :create, :update, :destroy]`
   - Set `root "todos#index"`

5. **Create the view**
   - Build `app/views/todos/index.html.erb` with form, filter nav, and todo list
   - Add `turbo_refreshes_with method: :morph, scroll: :preserve`

6. **Add the Stimulus controller**
   - Create `app/javascript/controllers/todos_controller.js`
   - Wire up `data-controller` and `data-action` attributes in the view

7. **Add basic CSS**
   - Style the todo list, form, filters, and toggle/delete buttons

8. **Enable Turbo morphing in layout**
   - Add meta tags for `turbo-refresh-method` and `turbo-refresh-scroll`

## Test Plan

### Model Tests
- Todo requires a title (blank title is invalid)
- Todo defaults `completed` to `false`
- `completed` and `active` scopes return correct records

### Controller / Integration Tests
- `GET /todos` renders the todo list
- `POST /todos` with valid title creates a todo and redirects
- `POST /todos` with blank title re-renders with errors
- `PATCH /todos/:id` toggles completed status
- `DELETE /todos/:id` removes the todo
- Filter param (`active`, `completed`, blank) returns correct subset

### System Tests (Capybara)
- User can add a todo via the form
- User can mark a todo as completed
- User can delete a todo
- Filter links show correct todos
- Page preserves scroll position on updates (morphing)

## Acceptance Criteria

- [ ] User can add a new todo item with a title
- [ ] User can mark a todo as completed (toggle checkbox)
- [ ] User can delete a todo
- [ ] User can filter todos by All / Active / Completed
- [ ] Page updates use Turbo morphing (no full page reload flash)
- [ ] Empty title submission is rejected with validation feedback
- [ ] Todo list displays item count
- [ ] Stimulus controller handles keyboard submit (Enter key)
