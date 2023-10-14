defmodule PatientFirstWeb.ClerkingLive.Index do
  use PatientFirstWeb, :live_view

  alias PatientFirst.Responses

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
    |> assign(:questions, Responses.questions())
    |> assign(:responses, Responses.get_clerking_responses())
  end
end
