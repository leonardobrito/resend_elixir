defmodule Resend.ApiTest do
  use ExUnit.Case, async: false
  alias Resend.{Api, Email}

  setup %{} do
    client = Api.client("API_KEY")
    %{client: client}
  end

  describe "when only API_KEY is given" do
    test "returns a tesla client with default values", %{client: client} do
      expected_client = %Tesla.Client{
        adapter: nil,
        fun: nil,
        post: [],
        pre: [
          {Tesla.Middleware.BaseUrl, :call, ["https://api.resend.com"]},
          {Tesla.Middleware.JSON, :call, [[]]},
          {Tesla.Middleware.Headers, :call, [[{"authorization", "Bearer: API_KEY"}]]}
        ]
      }

      assert expected_client == client
    end
  end

  describe "when API_KEY and Endpoint is given" do
    test "returns a tesla client with custom endpoint" do
      expected_client = %Tesla.Client{
        adapter: nil,
        fun: nil,
        post: [],
        pre: [
          {Tesla.Middleware.BaseUrl, :call, ["https://custom.endpoint.com"]},
          {Tesla.Middleware.JSON, :call, [[]]},
          {Tesla.Middleware.Headers, :call, [[{"authorization", "Bearer: API_KEY"}]]}
        ]
      }

      client = Api.client("API_KEY", "https://custom.endpoint.com")
      assert expected_client == client
    end
  end

  describe "when a handle_send_email request is dispatch" do
    setup %{} do
      email = %Email{
        from: "onboarding@resend.dev",
        to: "f.leobrito@gmail.com",
        subject: "Hello World",
        html: "Congrats on sending your <strong>first email</strong>!"
      }

      %{email: email}
    end

    test "and have a success response", %{client: client, email: email} do
      expected_body = %{
        "id" => "530bf349-8e2e-4a08-b30c-b7e3a9c33712",
        "from" => "onboarding@resend.dev",
        "to" => "f.leobrito@gmail.com"
      }

      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {:ok, %Tesla.Env{env | status: 200, body: expected_body}}
      end)

      url = "/email"
      body = email

      assert {:ok, env} = Api.handle_send_email(client, url, body)
      assert env.status == 200
      assert env.body == expected_body
    end

    test "and API_KEY is invalid", %{client: client, email: email} do
      expected_body = %{
        "error" => %{
          "code" => 401,
          "message" => "Invalid API Key",
          "type" => "invalid_api_key"
        }
      }

      Mox.expect(Tesla.MockAdapter, :call, fn env, _opts ->
        {:ok, %Tesla.Env{env | body: expected_body, status: 401}}
      end)

      url = "/email"
      body = email
      response = Api.handle_send_email(client, url, body)

      assert {:ok, env} = response
      assert env.status == 401
      assert env.body == expected_body
      assert match?({:ok, _}, response)
    end
  end
end
