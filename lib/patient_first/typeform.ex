defmodule Typeform do
  use Tesla

  plug Tesla.Middleware.BaseUrl, config().base_url
  plug Tesla.Middleware.BearerAuth, token: config().personal_access_token
  plug Tesla.Middleware.JSON

  def form(form_id) do
    get("/forms/#{form_id}")
  end

  def responses(form_id) do
    get("/forms/#{form_id}/responses")
  end

  def response(form_id, response_id) do
    get("/forms/#{form_id}/responses", query: [included_response_ids: response_id])
  end

  def config() do
    Application.fetch_env!(:patient_first, Typeform)
    |> Enum.into(%{})
  end
end
