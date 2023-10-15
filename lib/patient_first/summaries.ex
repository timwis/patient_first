defmodule PatientFirst.Summaries do
  @moduledoc """
  The Summaries context.
  """

  @model "gpt-3.5-turbo"

  @question_keys [
    :are_you_in_any_physical_pain,
    :where_is_your_pain,
    :when_did_it_start,
    :what_does_it_feel_like,
    :does_the_pain_go_anywhere,
    :is_the_pain_associated_with_anything,
    :when_does_the_pain_occur,
    :what_makes_the_pain_better_or_worse,
    :how_bad_is_your_pain,
    :what_symptoms_are_you_experiencing,
    :what_has_caused_you_to_attend_the_hospital_today,
    :how_long_have_the_symptoms_been_affecting_you,
    :what_makes_the_symptoms_better,
    :what_makes_your_symptoms_worse,
    :do_your_symptoms_vary_throughout_the_day,
    :is_it_associated_with_any_other_symptoms,
    :do_you_have_any_medical_conditions,
    :any_recent_admissions_to_hospital,
    :have_you_had_any_previous_surgeries,
    # :the_four_general_questions,
    :have_you_experienced_any_of_these_common_symptoms,
    :what_medications_have_you_been_prescribed,
    :any_over_the_counter_medications,
    :are_you_allergic_to_anything,
    :family_medical_conditions,
    :have_you_ever_smoked,
    :how_many_cigarettes_do_you_smoke_on_a_typical_day,
    :how_many_cigarettes_did_you_smoke_a_day,
    :how_long_have_you_smoked_for,
    :do_you_drink_alcohol,
    :what_do_you_drink_in_a_typical_week,
    :what_did_you_used_to_drink_in_a_typical_week,
    :any_recreational_drugs,
    :what_recreational_drugs_do_you_consume,
    :any_foreign_travel_recently,
    :what_is_was_your_occupation,
    :who_do_you_live_with,
    :what_kind_of_support_do_you_need_around_the_house
  ]

  def generate_summary(questions, answers, response_id) do
    case Cachex.get(:patient_first, response_id) do
      {:ok, nil} ->
        IO.inspect("****Calling ChatGPT")
        prompt = build_prompt(questions, answers)
        IO.inspect(prompt)

        {:ok, summary} =
          OpenAI.chat_completion(
            [
              model: @model,
              messages: [
                %{role: "user", content: prompt}
              ]
            ],
            %OpenAI.Config{
              api_key: System.get_env("OPENAI_API_KEY"),
              http_options: [recv_timeout: 30_000]
            }
          )

        IO.inspect(summary)

        Cachex.put(:patient_first, response_id, summary)
        summary

      {:ok, summary} ->
        summary
    end
  end

  defp build_prompt(questions, answers) do
    merged_questions_answers =
      @question_keys
      |> Enum.filter(fn key -> Map.has_key?(answers, key) end)
      |> Enum.map(fn key -> "#{questions[key]}\n#{answer(answers[key])}" end)
      |> Enum.join("\n\n")

    """
    Based on the responses to this survey:

    #{merged_questions_answers}

    Summarise the responses under these subheadings:
    Presenting Complaint, History of presenting complaint, Past medical history, Medications, Allergies, Red flag symptoms, Symptoms overview
    """
  end

  defp answer(%{"type" => "text"} = field), do: field["text"]
  defp answer(%{"type" => "number"} = field), do: field["number"]
  defp answer(%{"type" => "choice"} = field), do: field["choice"]["label"]
  defp answer(%{"type" => "choices"} = field), do: Enum.join(field["choices"]["labels"], ", ")
end
