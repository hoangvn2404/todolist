# PIG-93: Generate Rails App with Tailwind and SQLite

## Summary

Generate a new Rails 8 application in the repository root with Tailwind CSS for styling, SQLite as the database, and a welcome page at the root path displaying the app name. The app should boot cleanly with `bin/rails server`, and the database schema should be committed.

## Technical Approach

### 1. Generate the Rails 8 Application

Use the Rails generator with the appropriate flags to scaffold the app in-place within the existing repository:

```bash
rails new . --database=sqlite3 --css=tailwind --skip-git --force
```

Key flags:
- `--database=sqlite3` — use SQLite (Rails 8 default, but explicit for clarity)
- `--css=tailwind` — install Tailwind CSS via the `tailwindcss-rails` gem
- `--skip-git` — do not reinitialise git (repo already exists)
- `--force` — overwrite existing files (README.md, .gitignore) with Rails defaults

### 2. Set Up the Welcome Page

Create a `PagesController` with a `home` action and set it as the root route:

```bash
bin/rails generate controller Pages home --skip-routes
```

Configure the root route in `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  root "pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
end
```

Design the welcome page view at `app/views/pages/home.html.erb` using Tailwind CSS:

```erb
<div class="flex items-center justify-center min-h-screen bg-gray-100">
  <div class="text-center">
    <h1 class="text-5xl font-bold text-gray-900 mb-4"><%= Rails.application.class.module_parent_name %></h1>
    <p class="text-xl text-gray-600">Welcome to your new Rails application</p>
  </div>
</div>
```

### 3. Run Database Migrations and Commit Schema

```bash
bin/rails db:migrate
```

This creates `db/schema.rb` which must be committed to source control.

### 4. Update .gitignore

Ensure the `.gitignore` includes Rails defaults and excludes:
- `db/*.sqlite3` and `db/*.sqlite3-*` (database files)
- `log/`
- `tmp/`
- `storage/`
- `node_modules/` (if present)

## Step-by-Step Implementation Instructions

1. **Verify prerequisites**: Ensure Ruby >= 3.2 and Rails >= 8.0 are installed.
   ```bash
   ruby --version
   rails --version
   ```

2. **Generate the Rails app** in the current directory:
   ```bash
   rails new . --database=sqlite3 --css=tailwind --skip-git --force
   ```

3. **Install dependencies**:
   ```bash
   bundle install
   ```

4. **Generate the Pages controller**:
   ```bash
   bin/rails generate controller Pages home --skip-routes
   ```

5. **Set the root route** in `config/routes.rb`:
   ```ruby
   Rails.application.routes.draw do
     root "pages#home"
     get "up" => "rails/health#show", as: :rails_health_check
   end
   ```

6. **Create the welcome page** at `app/views/pages/home.html.erb`:
   ```erb
   <div class="flex items-center justify-center min-h-screen bg-gray-100">
     <div class="text-center">
       <h1 class="text-5xl font-bold text-gray-900 mb-4"><%= Rails.application.class.module_parent_name %></h1>
       <p class="text-xl text-gray-600">Welcome to your new Rails application</p>
     </div>
   </div>
   ```

7. **Run database migrations**:
   ```bash
   bin/rails db:migrate
   ```

8. **Verify the app boots**:
   ```bash
   bin/rails server
   ```
   Visit `http://localhost:3000` and confirm the welcome page renders.

9. **Update .gitignore** to include Rails defaults and add all generated files to git.

10. **Commit all files** including `db/schema.rb`.

## Test Plan

- [ ] `ruby --version` returns >= 3.2
- [ ] `rails --version` returns >= 8.0
- [ ] `bundle exec rails server` starts without errors
- [ ] Visiting `http://localhost:3000` shows the welcome page with the app name
- [ ] `bin/rails db:migrate:status` shows all migrations as `up`
- [ ] `db/schema.rb` exists and is committed
- [ ] `bin/rails test` passes (default generated tests)
- [ ] Tailwind CSS classes render correctly on the welcome page (styled heading, centred layout)

## Acceptance Criteria

1. A Rails 8 application exists in the repository root
2. Tailwind CSS is configured and functional for styling
3. SQLite is the configured database adapter
4. A welcome page is served at the root path (`/`) displaying the application name
5. Database migrations have been run and `db/schema.rb` is committed
6. The application boots successfully with `bin/rails server`
7. The `.gitignore` properly excludes SQLite database files, logs, and temp files
