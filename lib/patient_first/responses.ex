defmodule PatientFirst.Responses do
  @moduledoc """
  The Responses context.
  """

  def get_responses(form_key) do
    form = config(form_key)
    questions_by_id = invert(form.questions)

    with {:ok, http_response} <- Typeform.responses(form.id),
         %Tesla.Env{status: 200, body: http_response_body} <- http_response,
         %{"items" => responses} = http_response_body do
      Enum.map(responses, fn response ->
        %{
          response_id: response["response_id"],
          submitted_at: response["submitted_at"],
          answers:
            Enum.reduce(response["answers"], %{}, fn answer, accum ->
              key = Map.get(questions_by_id, answer["field"]["id"], answer["field"]["id"])
              Map.put(accum, key, answer)
            end)
        }
      end)
    end
  end

  defp invert(map) do
    Enum.reduce(map, %{}, fn {key, value}, accum ->
      Map.put(accum, value, key)
    end)
  end

  def get_response(form_key, response_id) do
    get_responses(form_key)
    |> Enum.find(fn response -> response.response_id == response_id end)
  end

  def config(form_key) do
    Application.fetch_env!(:patient_first, Forms)
    |> Keyword.get(form_key)
    |> Enum.into(%{})
    |> Map.update!(:questions, &Enum.into(&1, %{}))
  end
end
