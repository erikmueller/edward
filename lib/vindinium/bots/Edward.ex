defmodule Vindinium.Bots.Edward do

  @free "  "
  @obastacle "##"
  @tavern "[]"
  @neutral_mine "$-"
  @hero ~r/@\d/
  @hero_mine ~r/$\d/

  def neighbors({x, y}) do
    # TODO check if neighbor !== :free
    [
      {x, y + 1},
      {x, y - 1},
      {x + 1, y},
      {x - 1, y}
    ]
  end

  def dist({x1, y1}, {x2, y2}) do
    # TODO if neighbor not free, increase distance (or check how dist/2 uses neighbor/2)
    # maybe the lib is smart enough. For now return 2
    2
  end

  def h({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def generate_coords(%{"size" => size, "tiles" => tiles}) do
    split_tiles = tiles
      |> String.split("")
      |> Enum.chunk(2)
      |> Enum.map(&to_string/1)

    coord_map = for x <- 0..(size - 1), y <- 0..(size - 1) do
      tile = Enum.at(split_tiles, x + size * y)
      type = cond do
        tile == @free -> :free
        tile == @obastacle -> :obstacle
        tile == @tavern -> :tavern
        tile == @neutral_mine -> :mine
        String.match?(tile, @hero) -> :hero
        String.match?(tile, @hero_mine) -> :hero_mine
        true -> :other
      end

      %{{x, y} => type}
    end
  end

  def show_map(%{"size" => size, "tiles" => tiles}) do
    "-"
      |> String.duplicate(2 * size - 1) # well, there's a dot
      |> IO.puts

    tiles
      |> String.split("")
      |> Enum.chunk(2 * size) # each tile is represented by 2 chars
      |> Enum.each(&IO.puts/1)

    "-"
      |> String.duplicate(2 * size)
      |> IO.puts
  end

  def move(state) do
    show_map(state["game"]["board"])

    env = {&neighbors/1, &dist/2, &h/2}
    hero_pos = {state["hero"]["pos"]["x"], state["hero"]["pos"]["y"]}
    goal = {5, 8}

    state["game"]["board"] |> generate_coords |> IO.inspect

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
  end
end
