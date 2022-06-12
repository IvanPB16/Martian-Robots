defmodule Robot do
  @moduledoc """
  Documentation for `Robot`.
  """
  @lista []

  alias ReadFile
  alias Actions

  @doc """
  Hello world.

  ## Examples

      iex> Robot.hello()
      :world

  """
  def hello do
    :world
  end

  def init() do
    content = ReadFile.read()
    data = ReadFile.process_content(content)
    cuadrilla = %{x: data.x, y: data.y}
    Enum.map(data.instrucciones, fn x ->
      Actions.move(x.inst, x.posicion, cuadrilla)
    end)
  end

end
