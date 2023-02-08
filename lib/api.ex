defmodule Resend.Api do
  use Tesla, only: [:post], docs: false
  alias Resend.Email

  def handle_send_email(client, url, %Email{} = body) do
    Tesla.post(client, url, body)
  end

  def client(api_key, api_url \\ Application.get_env(:resend, :resend_base_url)) do
    middleware = [
      {Tesla.Middleware.BaseUrl, api_url},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"authorization", "Bearer: " <> api_key}]}
    ]

    Tesla.client(middleware)
  end
end
