defmodule Actions do
  @compassRose [%{mask: "N", value: 0}, %{mask: "E", value: 1}, %{mask: "S", value: 2}, %{mask: "W", value: 3}]
  def left(position) do
    # IO.inspect "Giras a la izquierda sobre la posicion, #{position.orientation}"
    value = find_value_compassRose(position.orientation)
    newPosition = if value === 0 do
      3
    else
      value - 1
    end
    mask = find_mask_compassRose(newPosition)
    # IO.inspect position, label: "last position"
    # IO.inspect "#{position.x} #{position.y} #{mask}", label: "Left new position"
    # "#{position.x} #{position.y} #{mask}"
    %{x: position.x, y: position.y, orientation: mask, lost: position.lost}
  end
  def right(position) do
    # IO.inspect "Giras a la derecha sobre la posicion, #{position.orientation}"
    value = find_value_compassRose(position.orientation)
    newPosition = if value === 3 do
      0
    else
      value + 1
    end

    mask = find_mask_compassRose(newPosition)
    # IO.inspect position, label: "last position"
    # IO.inspect "#{position.x} #{position.y} #{mask}", label: "Right new position"
    # "#{position.x} #{position.y} #{mask}"
    %{x: position.x, y: position.y, orientation: mask, lost: position.lost}
  end

  def forward(position, cuadrilla, acc) do
    # IO.inspect "Avanzamos"
    # IO.inspect position, label: "position"
    # IO.inspect cuadrilla, label: "cuadrilla forward"
    # IO.inspect acc, label: "acc forward"
    newPosition = case position.orientation do
      "N" ->
        operation = position.y + 1
        Map.put(position, :y, operation)
      "E" ->
        operation = position.x + 1
        Map.put(position, :x, operation)
      "S" ->
        operation = position.y - 1
        Map.put(position, :y, operation)
      "W" ->
        operation = position.x - 1
        Map.put(position, :x, operation)
    end
    # IO.inspect newPosition, label: "Forward newPosition"
    if validateGrid(newPosition, cuadrilla) do
      # "#{newPosition.x} #{newPosition.y} #{newPosition.orientation}"
      %{x: newPosition.x, y: newPosition.y, orientation: newPosition.orientation, lost: position.lost}
    else
      # "#{newPosition.x} #{newPosition.y} #{newPosition.orientation} LOST"
      %{x: newPosition.x, y: newPosition.y, orientation: newPosition.orientation, lost: true}
    end

  end

  def move(instruction, position, cuadrilla) do
    values = String.codepoints(instruction)
    # IO.inspect values, label: "values move"
    # IO.inspect position, label: "position move"
    # IO.inspect cuadrilla, label: "cuadrilla move"
    newPosition = String.split(position) |> format_position()
    # IO.inspect newPosition, label: "newPosition move"
    each(values, newPosition, "0 0 0", cuadrilla, [])
  end


  def each(elements, last_position, _actual_position, _cuadrilla, _acc) when length(elements) == 0  do
    last_position
  end

  def each([head | tail], last_position, actual_position, cuadrilla, acc) do
    # IO.inspect head
    # IO.inspect last_position, label: "last_position"
    # IO.inspect actual_position, label: "actual_position"
    # IO.inspect cuadrilla, label: "each cuadrilla"
    # actual_position = last_position
    # IO.inspect actual_position, label: "actual_position with last"
    # IO.inspect acc, label: "acc "

    # last = String.split(last_position) |> format_position()
    # act = String.split(actual_position) |> format_position()
    # IO.inspect last, label: "last"

    posicion = case head do
      "R" ->
        right(last_position)
      "L" ->
        left(last_position)
      "F" ->
        forward(last_position, cuadrilla, acc)
    end
    # IO.inspect tail
    # IO.inspect posicion, label: "posicion"
    # newAcc = if posicion.lost do
    #   posicion
    # end

    # List.insert_at(acc, 0, newAcc)
    # IO.inspect acc, label: "acc"
    if posicion.lost do
      # IO.inspect posicion, label: "evalue if"
      List.insert_at(acc, -1, posicion)
    end
    # IO.inspect newacc, label: "acc after"
    # IO.inspect posicion, label: "posicion"
    # IO.inspect last, label: "last"
    # IO.inspect act, label: "act"


    each(tail, posicion, actual_position, cuadrilla, acc)
  end

  def format_position(lista) when length(lista) == 0 do
    %{x: 0, y: 0, orientation: 0, lost: false}
  end

  def format_position(lista) do
    [x, y, o] = lista
    %{x: String.to_integer(x), y: String.to_integer(y), orientation: o, lost: false}
  end

  def find_value_compassRose(orientation) do
    Enum.find_value(@compassRose, fn x ->
      if x.mask == orientation do
        x.value
      end
    end)
  end
  def find_mask_compassRose(value) do
    Enum.find_value(@compassRose, fn x ->
      if x.value == value do
        x.mask
      end
    end)
  end

  def validateGrid(newPosition, grib) do
    if newPosition.x > grib.x  or newPosition.y > grib.y do
      false
    else
      true
    end
  end

end
