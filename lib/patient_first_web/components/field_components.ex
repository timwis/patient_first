defmodule PatientFirstWeb.FieldComponents do
  use Phoenix.Component

  @datetime_format "%d/%m/%y %H:%M"
  @date_format "%d/%m/%y"

  attr :value, :string, required: true

  def datetime(assigns) do
    {:ok, datetime, _} = DateTime.from_iso8601(assigns.value)
    assigns = assign(assigns, :formatted_datetime, Calendar.strftime(datetime, @datetime_format))

    ~H"""
    <time datetime={@formatted_datetime}><%= @formatted_datetime %></time>
    """
  end

  attr :value, :string, required: true

  def date(assigns) do
    {:ok, datetime, _} = DateTime.from_iso8601(assigns.value)
    assigns = assign(assigns, :formatted_date, Calendar.strftime(datetime, @date_format))

    ~H"""
    <time datetime={@formatted_date}><%= @formatted_date %></time>
    """
  end

  @doc """
  Renders an answer.

  ## Examples

      <.answer value={@answers.first_name} />
  """
  attr :value, :map, required: true

  def answer(%{value: %{"type" => "text"}} = assigns) do
    ~H"""
    <span><%= @value["text"] %></span>
    """
  end

  def answer(%{value: %{"type" => "date"}} = assigns) do
    ~H"""
    <.date value={@value["date"]} />
    """
  end
end
