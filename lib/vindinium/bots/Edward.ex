defmodule Vindinium.Bots.Edward do

  @obastacle "##"
  @tavern "[]"
  @neutral_mine "$-"

  def neighbors({x, y}) do
      [
          {x, y + 1},
          {x, y - 1},
          {x + 1, y},
          {x - 1, y}
      ]
  end

  def h({x1, y1}, {x2, y2}) do
      abs(x1 - x2) + abs(y1 - y2)
  end

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

    env = {&neighbors/1, fn (_, _) -> 2 end, &h/2}
    hero_pos = {state["hero"]["pos"]["x"], state["hero"]["pos"]["y"]}
    goal = {5, 8}

    {current_x, current_y} = hero_pos
    {next_x, next_y} = Astar.astar(env, hero_pos, goal) |> List.first

    next_step = {current_x - next_x, current_y - next_y}

    case next_step do
        {0, 1} -> "North"
        {0, -1} -> "South"
        {1, 0} -> "West"
        {-1, 0} -> "East"
        _ -> "Stay"
    end

    # Enum.take_random(["Stay", "North", "South", "East", "West"], 1) |> List.first
  end

end
