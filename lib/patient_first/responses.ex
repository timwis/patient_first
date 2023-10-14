defmodule PatientFirst.Responses do
  @moduledoc """
  The Responses context.
  """

  def get_clerking_responses() do
    clerking_form_id = form_ids().clerking

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

  defp form_ids() do
    Application.fetch_env!(:patient_first, Typeform)
    |> Keyword.get(:form_ids)
    |> Enum.into(%{})
  end
end
