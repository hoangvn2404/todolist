# PIG-99: Generate New Rails App

## Summary

Generate a new Ruby on Rails 8 application configured with Tailwind CSS for styling and SQLite as the database. The app is a **Todolist** application (per the existing README). This sets up the foundational project structure including Rails 8 defaults (Solid Queue, Solid Cache, Solid Cable, Kamal, Thruster) with Tailwind CSS integrated via the `tailwindcss-rails` gem.

## Technical Approach

### Rails 8 App Generation

Generate the app in the current repository directory using Rails 8 with SQLite (default) and Tailwind CSS:

```bash
rails new . --css=tailwind --database=sqlite3 --skip-git
```

Key flags:
- `.` — generate into the current directory (existing repo)
- `--css=tailwind` — integrate Tailwind CSS via `tailwindcss-rails` gem
- `--database=sqlite3` — use SQLite (Rails 8 default)
- `--skip-git` — skip `git init` since the repo already exists

Rails 8 defaults that come included:
- **Solid Queue** for background jobs (replacing Redis-backed Active Job adapters)
- **Solid Cache** for caching
- **Solid Cable** for Action Cable (WebSocket) support
- **Kamal** for deployment
- **Thruster** as the asset-serving HTTP proxy
- **Propshaft** as the asset pipeline

### Tailwind CSS Configuration

The `tailwindcss-rails` gem bundles a standalone Tailwind CLI. After generation:

```ruby
# Gemfile (auto-added by generator)
gem "tailwindcss-rails"
```

Tailwind config and application stylesheet will be generated at:
- `app/assets/stylesheets/application.tailwind.css`
- `config/tailwind.config.js` (if applicable for Rails 8 + tailwindcss-rails v3)

### SQLite Configuration

Rails 8 uses SQLite by default with separate databases:

```yaml
# config/database.yml (auto-generated)
development:
  adapter: sqlite3
  database: storage/development.sqlite3

test:
  adapter: sqlite3
  database: storage/test.sqlite3

production:
  adapter: sqlite3
  database: storage/production.sqlite3
```

### Post-Generation Cleanup

- Update `README.md` to reflect the Todolist application purpose
- Ensure `.gitignore` covers Rails-specific files (auto-generated)
- Verify `bin/dev` uses Foreman/Procfile.dev to run both Rails server and Tailwind watcher

## Step-by-Step Implementation Instructions

### Step 1: Verify Prerequisites

```bash
ruby --version    # Ensure Ruby 3.2+ is installed
rails --version   # Ensure Rails 8.0+ is installed
```

If Rails 8 is not installed:

```bash
gem install rails -v "~> 8.0"
```

### Step 2: Generate the Rails Application

```bash
cd /Users/hoang/code/symphony-workspaces/PIG-99
rails new . --css=tailwind --database=sqlite3 --skip-git --force
```

The `--force` flag will overwrite the existing `README.md` with Rails' default. We will update it afterward.

### Step 3: Install Dependencies

```bash
bundle install
```

### Step 4: Setup the Database

```bash
bin/rails db:prepare
```

### Step 5: Update README.md

Replace the generated README with project-specific content describing the Todolist application.

### Step 6: Verify Tailwind Integration

```bash
# Check that Tailwind build works
bin/rails tailwindcss:build
```

### Step 7: Verify the Application Boots

```bash
bin/rails server &
sleep 3
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
# Should return 200
kill %1
```

### Step 8: Run the Test Suite

```bash
bin/rails test
```

## Test Plan

1. **Application boots successfully** — `bin/rails server` starts without errors
2. **Database is created** — `bin/rails db:prepare` completes; `storage/development.sqlite3` exists
3. **Tailwind CSS compiles** — `bin/rails tailwindcss:build` runs without errors; CSS output contains Tailwind utilities
4. **Default test suite passes** — `bin/rails test` exits with 0 failures
5. **Asset pipeline works** — visiting `http://localhost:3000` returns a 200 response with styled content
6. **Procfile.dev exists** — `bin/dev` starts both Rails server and Tailwind watcher concurrently

## Acceptance Criteria

- [ ] Rails 8.x application is generated in the repository root
- [ ] SQLite is configured as the database adapter for all environments
- [ ] Tailwind CSS is installed and integrated via `tailwindcss-rails`
- [ ] `bin/dev` starts both the Rails server and Tailwind CSS watcher
- [ ] `bin/rails test` passes with no failures
- [ ] `bin/rails tailwindcss:build` compiles without errors
- [ ] Application serves a styled welcome page at `http://localhost:3000`
- [ ] All Rails 8 defaults are present (Solid Queue, Solid Cache, Solid Cable, Kamal)
