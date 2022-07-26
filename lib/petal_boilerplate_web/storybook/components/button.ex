defmodule PetalBoilerplateWeb.Storybook.Components.Button do
  alias PetalComponents.Button
  use PhxLiveStorybook.Entry, :component
  def component, do: Button
  def function, do: &Button.button/1
  def description, do: "A simple generic button."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          label: "A button",
          to: "/"
        }
      },
    ]
  end
end
