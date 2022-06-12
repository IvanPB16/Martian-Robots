defmodule ReadFile do
  def read() do
    content = File.read!("/home/dante/Projects/nodejs/robot/instrucciones.txt")
    contentSplit = String.split(content, ~r{\n}, trim: true)
    # IO.inspect contentSplit
    if(length(contentSplit) == 0) do
      "No hay instrucciones"
    else
      contentSplit
    end
  end

  def process_content(content) when (content == 0), do: "Cuadrialla error"

  def process_content(content) do
    [cuadrilla | tail] = content
    [positionX , positionY | _tail] = String.split(cuadrilla)
    inst = listaformat(tail, [])
    px = String.to_integer(positionX)
    py = String.to_integer(positionY)
    if(validationXY(px,py)) do
      %{x: px, y: py, instrucciones: inst}
    else
      "The maximum value for any coordinate is 50"
    end
  end

  def listaformat(lista, instrucciones) when length(lista) == 0 do
    instrucciones
  end

  def listaformat([first, second | tail], instrucciones) do
    map = [%{posicion: first, inst: second}]
    instrucciones = instrucciones ++ map
    listaformat(tail, instrucciones)
  end

  def validationXY(x,y) do
    if(x < 50 or y < 50) do
      true
    else
      false
    end
  end
end
