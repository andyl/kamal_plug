# KamalPlug

Kamal HealthCheck (/up) for Phoenix apps

This supports [Kamal V2 Healthcheck](https://kamal-deploy.org/docs/configuration/proxy/#healthcheck)

## How It Works

KamalPlug adds a `/up` endpoint to your Phoenix app that returns a `200 OK` response.
This endpoint is used by [Kamal's](https://kamal-deploy.org) proxy to verify your app is
healthy. The plug is placed early in the endpoint pipeline so health checks bypass logging
and request parsing.

## Installation

Add the dependency to `mix.exs` in your Phoenix app, then run `mix do deps.get, compile`

```elixir
def deps do
  [
    {:igniter, "~> 0.6", only: [:dev, :test]},
    {:kamal_plug, [github: "andyl/kamal_plug", override: true]},
  ]
end
```

Then add `plug KamalPlug.HealthCheck` to your endpoint module before `Plug.RequestId`:

```bash 
> mix kamal_plug.install
```

## Testing 

```
# in terminal 1
> mix deps.get
> mix ecto.create && mix ecto.migrate # if needed...
> mix phx.server
# in terminal 2
> curl -s -w "%{http_code}\n" http://localhost:4000/up
# returns "ok200"
```

## Related Info & Repos

| Type        | Desc            | Link                                                                                          |
|-------------|-----------------|-----------------------------------------------------------------------------------------------|
| Github Repo | Kamal Mix Tasks | [Kamal Ops](https://github.com/vkryukov/kamal_ops)                                            |
| Blog Post   | Phoenix/Kamal   | [HealthCheckPlug](https://mrdotb.com/posts/deploy-phoenix-with-kamal#writing-healthcheckplug) |
| Kamal Doc   | Healthcheck     | [Proxy Config](https://kamal-deploy.org/docs/configuration/proxy/#healthcheck)                |
