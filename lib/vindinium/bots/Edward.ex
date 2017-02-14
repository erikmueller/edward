defmodule Vindinium.Bots.Edward do
  @direct_neighbors [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
  @free "  "
  @obastacle "##"
  @tavern "[]"
  @mine ~r/$[\d|-]/
  @hero ~r/@\d/

  defp is_free(map) do
    fn pos ->
        Enum.find_value(map, &(Map.get(&1, pos))) === :free
    end
  end

  defp manhatten({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def neighbors(map, size) do
    fn ({x, y}) ->
        for {nx, ny} <- @direct_neighbors do
            {tx, ty} = {x + nx, y + ny}

            if (tx < size
                && tx > -1
                && ty < size
                && ty > -1
                && is_free(map).({tx, ty})
                # && !Enum.member?(visited, {tx, ty})
            ) do
                {tx, ty}
            end
        end |> Enum.filter(&is_tuple/1)
    end
  end

  def dist(map) do
    fn (_start, goal) ->
      if is_free(map).(goal), do: 1, else: 4
    end
  end

  def h(pos1, pos2), do: manhatten(pos1, pos2)

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
        String.match?(tile, @mine) -> :mine
        String.match?(tile, @hero) -> :hero
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

    coord_map = generate_coords(state["game"]["board"])
    size = state["game"]["board"]["size"]

    env = {neighbors(coord_map, size), dist(coord_map), &h/2}
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
  end
end
