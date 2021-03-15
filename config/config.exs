# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :phx_snowpack_demo, PhxSnowpackDemoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h/r/RQKe32wv4K+3GSZi1cpaKuAK6u8f4l7TjTJ3JqMJ2pOUu4apXeDbLuBfulps",
  render_errors: [view: PhxSnowpackDemoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PhxSnowpackDemo.PubSub,
  live_view: [signing_salt: "4XkuBNGn"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
