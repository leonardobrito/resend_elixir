import Config

config :resend, resend_api_key: System.get_env("RESEND_API_KEY")
config :resend, resend_base_url: System.get_env("RESEND_BASE_URL", "https://api.resend.com")

if config_env() == :test do
  config :tesla, adapter: Tesla.MockAdapter
end
