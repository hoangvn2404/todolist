# PIG-94: Generate Rails App with Tailwind and SQLite

## Summary

Generate a new Rails 8 application in the repository root with Tailwind CSS for styling, SQLite as the database, and a welcome page at the root path displaying the app name ("Todolist"). Database migrations must be run and `db/schema.rb` committed. The app must boot successfully with `bin/rails server`.

## Technical Approach

### 1. Generate the Rails 8 Application

Use the `rails new` command to scaffold the app directly into the current repository root. Rails 8 uses SQLite by default and supports Tailwind CSS via the `--css tailwind` flag.

```bash
# Generate Rails app in the current directory (.) to avoid creating a nested folder
rails new . --css tailwind --database=sqlite3 --skip-git --force
```

Key flags:
- `--css tailwind` — installs and configures Tailwind CSS via `tailwindcss-rails` gem
- `--database=sqlite3` — configures SQLite (Rails 8 default, but explicit for clarity)
- `--skip-git` — avoids reinitialising git since the repo already exists
- `--force` — overwrites existing files like README.md with Rails defaults

### 2. Configure the Welcome Page

Create a `PagesController` with a `home` action and set it as the root route.

```bash
bin/rails generate controller Pages home --skip-routes
```

Set the root route in `config/routes.rb`:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root "pages#home"
end
```

Create the welcome view at `app/views/pages/home.html.erb`:

```erb
<div class="min-h-screen flex items-center justify-center bg-gray-50">
  <div class="text-center">
    <h1 class="text-5xl font-bold text-gray-900 mb-4">Todolist</h1>
    <p class="text-xl text-gray-600">Welcome to your new Rails application</p>
  </div>
</div>
```

### 3. Run Database Migrations

```bash
bin/rails db:prepare
```

This creates the SQLite database files and generates `db/schema.rb`.

### 4. Update .gitignore

Ensure the `.gitignore` includes standard Rails ignores. The generated `.gitignore` from `rails new` should cover this, but verify these entries exist:

```
/log/*
/tmp/*
/storage/*
/db/*.sqlite3
/db/*.sqlite3-*
```

SQLite database files must NOT be committed — only `db/schema.rb`.

## Step-by-Step Implementation Instructions

1. **Prerequisites check** — Verify Ruby >= 3.2 and Rails >= 8.0 are installed:
   ```bash
   ruby -v
   rails -v
   ```

2. **Generate the Rails app** in the repo root:
   ```bash
   rails new . --css tailwind --database=sqlite3 --skip-git --force
   ```

3. **Generate the Pages controller**:
   ```bash
   bin/rails generate controller Pages home --skip-routes
   ```

4. **Set the root route** — Edit `config/routes.rb`:
   ```ruby
   Rails.application.routes.draw do
     root "pages#home"
   end
   ```

5. **Create the welcome view** — Edit `app/views/pages/home.html.erb`:
   ```erb
   <div class="min-h-screen flex items-center justify-center bg-gray-50">
     <div class="text-center">
       <h1 class="text-5xl font-bold text-gray-900 mb-4">Todolist</h1>
       <p class="text-xl text-gray-600">Welcome to your new Rails application</p>
     </div>
   </div>
   ```

6. **Prepare the database**:
   ```bash
   bin/rails db:prepare
   ```

7. **Verify the app boots**:
   ```bash
   bin/rails server
   ```
   Visit `http://localhost:3000` — should display the Todolist welcome page.

8. **Commit all generated files** including `db/schema.rb` but excluding `*.sqlite3` files.

## Test Plan

- [ ] `ruby -v` returns >= 3.2
- [ ] `rails -v` returns >= 8.0
- [ ] `bin/rails db:prepare` runs successfully and `db/schema.rb` exists
- [ ] `bin/rails server` starts without errors
- [ ] Visiting `http://localhost:3000` shows the Todolist welcome page
- [ ] The page is styled with Tailwind CSS (centered layout, proper typography)
- [ ] `bin/rails routes` shows root route pointing to `pages#home`
- [ ] No `*.sqlite3` files are tracked in git
- [ ] `db/schema.rb` is committed

## Acceptance Criteria

1. The repository contains a working Rails 8 application
2. Tailwind CSS is installed and configured for styling
3. SQLite is configured as the database adapter
4. A welcome page at the root path (`/`) displays "Todolist"
5. Database migrations have been run and `db/schema.rb` is committed
6. The app boots successfully with `bin/rails server`
7. No SQLite database files (`*.sqlite3`) are committed to version control
