defmodule PatientFirstWeb.ResponsesLive.Clerking do
  use PatientFirstWeb, :live_view

  alias PatientFirst.Responses

  @questions %{
    full_name: "0d775592-82ea-48e7-8f62-a9e56bb02e23",
    date_of_birth: "6e842e90-d8b5-471d-b996-1cd0fd14715b"
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Clerking responses")
    |> assign(:questions, @questions)
    |> assign(:responses, Responses.get_clerking_responses())
  end
end
