# Recipe Generator Backend

This is a Ruby on Rails backend application with Groq AI integration for generating recipes based on provided ingredients.

## System Requirements

* Ruby version: 3.3.6 
* Rails version: 8.0.0 
* Redis: Latest stable version

## Setup

1. Clone the repository.
2. Install dependencies:
- ```bash
  bundle install
3. Add provided **master.key** into **config/** folder.
4. Start the Redis server.
5. Start the Rails server:
- ```bash
  bundle exec rails s

## Test suite
1. Run Rspec for running specs:
- ```bash
  bundle exec rspec