# KamalPlug

Kamal HealthCheck (/up) for Phoenix apps

This supports [Kamal V2 Healthcheck](https://kamal-deploy.org/docs/configuration/proxy/#healthcheck)

## How It Works

KamalPlug adds a `/up` endpoint to your Phoenix app that returns a `200 OK` response.
This endpoint is used by [Kamal's](https://kamal-deploy.org) proxy to verify your app is
healthy. The plug is placed early in the endpoint pipeline so health checks bypass logging
and request parsing.

## Installation

### Automated (with Igniter)

```bash
mix igniter.install kamal_plug@github:andyl/kamal_plug
```

This will add the dependency to `mix.exs` and insert `plug KamalPlug.HealthCheck` into your
endpoint pipeline automatically.

### Manual

1. Add the dependency to `mix.exs`, then run `mix do deps.get, compile`

```elixir
def deps do
  [
    {:kamal_plug, github: "andyl/kamal_plug"}
  ]
end
```

2. Run the install task to add the plug to your endpoint pipeline:

```bash
mix kamal_plug.install
```

Or manually add `plug KamalPlug.HealthCheck` to your endpoint module before `Plug.RequestId`:

```elixir
plug KamalPlug.HealthCheck
plug Plug.RequestId
plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
# ...
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
