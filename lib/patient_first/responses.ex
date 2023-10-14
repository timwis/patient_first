defmodule PatientFirst.Responses do
  @moduledoc """
  The Responses context.
  """

  def get_clerking_responses() do
    clerking_form_id = forms_config(:clerking).id

    with {:ok, http_response} <- Typeform.responses(clerking_form_id),
         %Tesla.Env{status: 200, body: http_response_body} <- http_response,
         %{"items" => responses} = http_response_body do
      Enum.map(responses, fn response ->
        Map.update!(response, "answers", fn answers ->
          Enum.reduce(answers, %{}, fn answer, accum ->
            Map.put(accum, answer["field"]["ref"], answer)
          end)
        end)
      end)
    end
  end

  def get_clerking_response(id) do
    clerking_form_id = forms_config(:clerking).id

    with {:ok, http_response} <- Typeform.response(clerking_form_id, id),
         %Tesla.Env{status: 200, body: http_response_body} <- http_response,
         %{"items" => responses} = http_response_body do
      responses
      |> hd()
      |> Map.update!("answers", fn answers ->
        Enum.reduce(answers, %{}, fn answer, accum ->
          Map.put(accum, answer["field"]["ref"], answer)
        end)
      end)
    end
  end

  def forms_config(form) do
    Application.fetch_env!(:patient_first, Forms)
    |> Keyword.get(form)
    |> Enum.into(%{})
    |> Map.update!(:questions, &Enum.into(&1, %{}))
  end
end
