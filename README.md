# Todolist

A modern task management application built with Ruby on Rails 8 and Tailwind CSS.

## Overview

Todolist is a Rails 8 application featuring:

- **Ruby on Rails 8** - Latest Rails with modern defaults
- **Tailwind CSS** - Utility-first CSS framework for modern styling
- **SQLite** - Default database for all environments
- **Rails 8 Defaults**:
  - **Solid Queue** - Background job processing
  - **Solid Cache** - Application caching
  - **Solid Cable** - WebSocket support
  - **Kamal** - Deployment automation
  - **Thruster** - Asset-serving HTTP proxy
  - **Propshaft** - Modern asset pipeline

## Prerequisites

- Ruby 3.2+
- Rails 8.0+
- SQLite3

## Getting Started

### Install dependencies

```bash
bundle install
```

### Setup database

```bash
bin/rails db:prepare
```

### Start the development server

```bash
bin/dev
```

This starts both the Rails server and the Tailwind CSS watcher concurrently.

### Run tests

```bash
bin/rails test
```

## Development

### Tailwind CSS

To compile Tailwind CSS manually:

```bash
bin/rails tailwindcss:build
```

To watch for changes during development:

```bash
bin/rails tailwindcss:watch
```

### Background Jobs

Start the Solid Queue worker:

```bash
bin/jobs
```

## Deployment

This application is configured for deployment with Kamal. See `config/deploy.yml` for configuration.

```bash
kamal setup
kamal deploy
```

## License

MIT
