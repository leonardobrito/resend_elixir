defmodule ResendTest do
  use ExUnit.Case, async: true
  # doctest Resend
  alias Resend.Email

  setup do
    put_application_env_for_test(:resend, :resend_api_key, "SECRET_KEY")

    email = %Email{
      attachments: "attachments",
      bcc: "bcc",
      cc: "cc",
      from: "from",
      html: "html",
      reply_to: "reply_to",
      subject: "subject",
      text: "text",
      to: "to"
    }

    resend_api_key = Application.get_env(:resend, :resend_api_key)

    %{
      email: email,
      resend_api_key: resend_api_key
    }
  end

  test "sendEmail/1 raise error when API_KEY is not passed", %{email: email} do
    put_application_env_for_test(:resend, :resend_api_key, nil)
    resend_api_key = Application.get_env(:resend, :resend_api_key)

    assert_raise(RuntimeError, "Missing API key. Pass it to the constructor.", fn ->
      Resend.sendEmail(email, resend_api_key)
    end)
  end

  test "sendEmail/1 should success call api endpoint", %{
    email: email,
    resend_api_key: resend_api_key
  } do
    expected_body = %{
      "id" => "530bf349-8e2e-4a08-b30c-b7e3a9c33712",
      "from" => "onboarding@resend.dev",
      "to" => "f.leobrito@gmail.com"
    }

    Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
      {:ok, %Tesla.Env{env | status: 200, body: expected_body}}
    end)

    assert {:ok, env} = Resend.sendEmail(email, resend_api_key)
    assert env.status == 200
    assert env.body == expected_body
  end

  defp put_application_env_for_test(app, key, value) do
    previous_value = Application.get_env(app, key)
    Application.put_env(app, key, value)
    on_exit(fn -> Application.put_env(app, key, previous_value) end)
  end
end
