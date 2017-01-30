defmodule Vindinium.Bots.Edward do

  @obastacle "##"
  @tavern "[]"
  @neutral_mine "$-"

  def get_map(tiles, size) do
      tiles
      |> String.to_charlist
      |> Enum.chunk(2 * size) # each tile is represented by 2 chars
  end

  def generate_coords(map) do
      Enum.map(map, &(
        &1 |> to_charlist |> Enum.chunk(2)
      ))
  end

  def show_map(%{"size" => size, "tiles" => tiles}) do
      "-"
      |> String.duplicate(2 * size - 1) # well, there's a dot
      |> IO.puts

      get_map(tiles, size)
      |> Enum.map(&(IO.puts &1))

      "-"
      |> String.duplicate(2 * size)
      |> IO.puts
  end

  def move(state) do
    show_map(state["game"]["board"])

    Enum.take_random(["Stay", "North", "South", "East", "West"], 1) |> List.first
  end

end
