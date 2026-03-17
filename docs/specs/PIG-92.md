# PIG-92: Generate Rails App with Tailwind CSS and SQLite

## Summary

Generate a new Rails 8 application in the existing repository with Tailwind CSS for styling and SQLite as the database. The app must include a styled welcome page at the root displaying the app name, have all database migrations run with `schema.rb` committed, and boot successfully with `bin/rails server`.

## Prerequisites

- **Ruby:** 3.4.1 (installed via mise)
- **Rails:** 8.0.4
- **SQLite:** 3.51.0

## Technical Approach

### Step 1: Generate the Rails Application

Generate the Rails app in a temp directory to avoid conflicts with existing workspace files, then copy into the workspace.

```bash
cd /tmp
rails new todolist --database=sqlite3 --css=tailwind --skip-git
```

Then copy all generated files into the workspace:

```bash
rsync -av --exclude='.git' /tmp/todolist/ /Users/hoang/code/symphony-workspaces/PIG-92/
```

**Key flags:**
- `--database=sqlite3` — Use SQLite (Rails 8 default)
- `--css=tailwind` — Install Tailwind CSS via `tailwindcss-rails` gem
- `--skip-git` — Don't run `git init` (repo already exists)

### Step 2: Install Dependencies

```bash
bundle install
```

### Step 3: Create the Welcome Page

Generate a controller for the welcome page:

```bash
bin/rails generate controller Welcome index
```

#### `app/views/welcome/index.html.erb`

```erb
<div class="min-h-screen flex items-center justify-center bg-gray-50">
  <div class="text-center">
    <h1 class="text-5xl font-bold text-gray-900 mb-4">Todolist</h1>
    <p class="text-xl text-gray-600">Welcome to Todolist</p>
  </div>
</div>
```

#### `config/routes.rb` — Set root route

```ruby
Rails.application.routes.draw do
  root "welcome#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
```

### Step 4: Run Database Migrations

```bash
bin/rails db:create
bin/rails db:migrate
```

This generates `db/schema.rb` which must be committed.

### Step 5: Update `.gitignore`

Merge the Rails-generated `.gitignore` with the existing one. Ensure `opencode.json` remains ignored. Key entries to add:

```gitignore
# Rails
/log/*
/tmp/*
/storage/*
/db/*.sqlite3
/db/*.sqlite3-*
/public/assets
/node_modules
/.bundle

# Environment
.env
.env.*

# Project-specific
opencode.json
```

### Step 6: Verify the App Boots

```bash
bin/rails runner "puts 'App boots successfully'"
```

## Files to Create/Modify

| Action | File | Purpose |
|--------|------|---------|
| Create | `Gemfile` | Rails dependencies including `tailwindcss-rails` |
| Create | `Gemfile.lock` | Locked dependency versions |
| Create | `Rakefile` | Rails rake tasks |
| Create | `config.ru` | Rack config |
| Create | `bin/rails`, `bin/rake`, `bin/setup` | Rails binstubs |
| Create | `config/**` | Application configuration |
| Create | `app/controllers/welcome_controller.rb` | Welcome page controller |
| Create | `app/views/welcome/index.html.erb` | Welcome page view with Tailwind |
| Create | `app/views/layouts/application.html.erb` | Layout with Tailwind |
| Modify | `config/routes.rb` | Add `root "welcome#index"` |
| Create | `db/schema.rb` | Database schema (after migration) |
| Modify | `.gitignore` | Add Rails-specific ignores, keep `opencode.json` |
| Keep | `hello.txt`, `farewell.txt` | Existing files — do not remove |
| Keep | `README.md` | Keep existing |

## Step-by-Step Implementation Instructions

1. Generate Rails app in temp directory with `rails new todolist --database=sqlite3 --css=tailwind --skip-git`
2. Copy generated files to workspace with `rsync` (exclude `.git`)
3. Update `.gitignore` to include both Rails ignores and `opencode.json`
4. Run `bundle install` to install dependencies
5. Generate welcome controller: `bin/rails generate controller Welcome index`
6. Edit `app/views/welcome/index.html.erb` with Tailwind-styled welcome page showing "Todolist"
7. Edit `config/routes.rb` to set `root "welcome#index"`
8. Run `bin/rails db:create db:migrate` to set up database
9. Verify app boots: `bin/rails runner "puts 'Boot OK'"`
10. Verify welcome page renders with `curl http://localhost:3000` after starting server
11. Commit all files including `db/schema.rb`

## Test Plan

1. **Boot test:** `bin/rails server` starts without errors
2. **Root page test:** `curl http://localhost:3000` returns HTML containing "Todolist"
3. **Tailwind test:** Response HTML includes Tailwind CSS classes being applied
4. **Database test:** `db/schema.rb` exists and `bin/rails db:migrate:status` shows no pending migrations
5. **Health check:** `curl http://localhost:3000/up` returns 200
6. **SQLite test:** `bin/rails runner "puts ActiveRecord::Base.connection.adapter_name"` returns "SQLite"

## Acceptance Criteria

- [ ] Rails 8 application generated with SQLite database
- [ ] Tailwind CSS installed and configured via `tailwindcss-rails` gem
- [ ] Root route (`/`) renders a welcome page displaying "Todolist"
- [ ] Welcome page is styled with Tailwind CSS classes
- [ ] Database migrations have been run and `db/schema.rb` is committed
- [ ] `bin/rails server` boots successfully without errors
- [ ] `/up` health check endpoint returns 200
- [ ] Existing files (`hello.txt`, `farewell.txt`) are preserved
- [ ] `.gitignore` includes Rails-specific patterns and `opencode.json`
