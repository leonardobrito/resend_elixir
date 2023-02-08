defmodule Resend.Email do
  @derive Jason.Encoder
  @enforce_keys [:from, :to, :subject]

  @type t :: %__MODULE__{
          attachments: File.t() | [File.t()],
          bcc: String.t(),
          cc: String.t(),
          from: String.t(),
          html: String.t(),
          reply_to: String.t(),
          subject: String.t(),
          text: String.t(),
          to: String.t()
        }

  defstruct [
    :attachments,
    :bcc,
    :cc,
    :from,
    :html,
    :reply_to,
    :subject,
    :text,
    :to
  ]
end
