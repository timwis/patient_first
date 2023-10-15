defmodule PatientFirstWeb.ClerkingLive.Show do
  use PatientFirstWeb, :live_view

  alias PatientFirst.Responses
  alias PatientFirst.Summaries

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :show, %{"id" => id}) do
    questions = Responses.get_questions(:clerking)
    response = Responses.get_response(:clerking, id)
    summary = Summaries.generate_summary(questions, response.answers, response.response_id)

    socket
    |> assign(:page_title, "Showing Clerking response")
    |> assign(:questions, questions)
    |> assign(:response, response)
    |> assign(:answers, response.answers)
    |> assign(:summary, summary)
  end
end
