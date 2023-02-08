defmodule Resend do
  @moduledoc """
  Documentation for `Resend`.
  """
  alias Resend.{Api, Email}

  def sendEmail(email, api_key \\ Application.get_env(:resend, :resend_api_key))

  def sendEmail(%Email{} = _email, nil) do
    raise("Missing API key. Pass it to the constructor.")
  end

  def sendEmail(%Email{} = email, api_key) do
    client = Api.client(api_key)
    {:ok, response} = Api.handle_send_email(client, "/email", email)

    {:ok, response}
  end
end
