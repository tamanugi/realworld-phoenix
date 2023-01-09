# ![RealWorld Example App](logo.png)

> ### Elixir/Phoenix codebase containing real world examples (CRUD, auth, advanced patterns, etc) that adheres to the [RealWorld](https://github.com/gothinkster/realworld) spec and API.

### [Demo](https://github.com/gothinkster/realworld)&nbsp;&nbsp;&nbsp;&nbsp;[RealWorld](https://github.com/gothinkster/realworld)

This codebase was created to demonstrate a fully fledged fullstack application built with **Elixir/Phoenix** including CRUD operations, authentication, routing, pagination, and more.

We've gone to great lengths to adhere to the **Elixir/Phoenix** community styleguides & best practices.

For more information on how to this works with other frontends/backends, head over to the [RealWorld](https://github.com/gothinkster/realworld) repo.

# Getting started

## Prerequisites

- [Elixir](https://elixir-lang.org/)
- [docker](https://www.docker.com/) (option)
- [docker-compose](https://docs.docker.com/compose) (option)

## Run app

To get started, run the following commands in your project folder

```
# Start Database
$ docker-compose up -d

# Install dependencies
$ mix deps.get

# Create and migrate your database
$ mix ecto.setup

# Start Phoenix endpoint with `mix phx.server`
$ mix phx.server
```

# Test

```
$ mix test

or

$ mix phx.server

# open other terminal
$ cd run-api-test
$ APIURL=http://localhost:4000/api ./run-api-tests.sh
```
