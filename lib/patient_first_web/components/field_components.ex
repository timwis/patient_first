defmodule PatientFirstWeb.FieldComponents do
  use Phoenix.Component

  alias PatientFirstWeb.CoreComponents

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

  def answer(%{value: %{"type" => "number"}} = assigns) do
    ~H"""
    <span><%= @value["number"] %></span>
    """
  end

  def answer(%{value: %{"type" => "choice"}} = assigns) do
    ~H"""
    <span><%= @value["choice"]["label"] %></span>
    """
  end

  def answer(%{value: %{"type" => "choices"}} = assigns) do
    ~H"""
    <ul>
      <li :for={label <- @value["choices"]["labels"]}><%= label %></li>
    </ul>
    """
  end

  def answer(assigns) do
    ~H"""
    <span>(Unsupported question type: <%= @value["type"] %>)</span>
    """
  end

  @doc """
  Renders an answer list.

  ## Examples
      <.answer_list questions={@questions} answers={@answers} />
        <:field key="date_of_birth" />
        <:field key="family_medical_conditions" />
      </.answer_list>
  """
  attr :questions, :map, required: true
  attr :answers, :map, required: true
  attr :title, :string, default: ""

  slot :field, required: true do
    attr :key, :string
    attr :title, :string
  end

  def answer_list(assigns) do
    unknown_keys =
      assigns.field
      |> Enum.filter(fn %{key: key} ->
        !Map.has_key?(assigns.questions, String.to_atom(key))
      end)
      |> Enum.map(fn field -> field.key end)

    assigns = assign(assigns, :unknown_keys, unknown_keys)

    ~H"""
    <h2 :if={@title} class="lg font-semibold leading-8 text-zinc-800 mt-8">
      <%= @title %>
    </h2>
    <ul :if={length(@unknown_keys) > 0}>
      <h3>Unmatched question keys</h3>
      <li :for={key <- @unknown_keys}><%= key %></li>
    </ul>
    <CoreComponents.list>
      <:item
        :for={field <- @field}
        :if={@answers[String.to_atom(field.key)]}
        title={Map.get(field, :title, @questions[String.to_atom(field.key)])}
      >
        <.answer value={@answers[String.to_atom(field.key)]} />
      </:item>
    </CoreComponents.list>
    """
  end
end
