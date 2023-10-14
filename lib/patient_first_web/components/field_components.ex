defmodule PatientFirstWeb.FieldComponents do
  use Phoenix.Component

  @datetime_format "%d/%m/%y %H:%M"
  @date_format "%d/%m/%y"

  attr :value, :string, required: true

  def datetime(assigns) do
    {:ok, value, _} = DateTime.from_iso8601(assigns.value)
    formatted = Calendar.strftime(value, @datetime_format)

    ~H"""
    <time datetime={@value}><%= formatted %></time>
    """
  end

  attr :value, :string, required: true

  def date(assigns) do
    {:ok, value, _} = DateTime.from_iso8601(assigns.value)
    formatted = Calendar.strftime(value, @date_format)

    ~H"""
    <time datetime={@value}><%= formatted %></time>
    """
  end
end
