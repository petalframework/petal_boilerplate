# Petal Boilerplate

A clean install of the Phoenix 1.7 (RC) along with:
- Alpine JS - using a CDN to avoid needing `node_modules`
- 🌺 [Petal Components Library](https://github.com/petalframework/petal_components)
- Maintained and sponsored by [Petal Framework](https://petal.build)

## Get up and running

Optionally change your database name in `dev.exs`.

1. Setup the project with `mix setup`
2. Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
3. Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Phoenix 1.7 generators

The CRUD generators (eg. `mix phx.gen.live`) will produce code that doesn't quite work. Basically, they will use components defined in `core_components.ex` that we have renamed due to naming clashes with Petal Components.
To fix, simply do a find and replace in the generated code:

```
Replace `.modal` with `.phx_modal`
Replace `.table` with `.phx_table`
Replace `.button` with `.phx_button`
```

This should make it work but it'll be using a different style of buttons/tables/modal to Petal Components. To work with Petal Components you will need to replace all buttons/tables/modal with the Petal Component versions.

Petal Pro currently comes with a generator to build CRUD interfaces with Petal Components. You can purchase it [here](https://petal.build/pro).

## Renaming your project

Run `mix rename PetalBoilerplate YourNewName` to rename your project. You can then remove `{:rename_project, "~> 0.1.0", only: :dev}` from your `mix.exs` file.


