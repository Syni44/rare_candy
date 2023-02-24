defmodule RareCandy.Api do
  @moduledoc """
  Interfaces with PokeApi (https://pokeapi.co/) to fetch info about Pokemon.

  Liberties were taken to extract json data from PokeApi into a cleaner,
  more accessible struct format:

      iex(1)> RareCandy.Api.get_pokemon_by_id(250)
      {:ok,
        %Pokemon{
          abilities: ["pressure", "regenerator"],
          forms: ["ho-oh"],
          height: 38,
          id: 250,
          img: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/250.png",
          moves: ["gust", "whirlwind", "fly", "double-edge", "roar", "flamethrower",
            "hyper-beam", "strength", "solar-beam", "thunderbolt", "thunder-wave",
            "thunder", "earthquake", "toxic", "psychic", "mimic", "double-team",
            "recover", "light-screen", "reflect", "fire-blast", "swift", "dream-eater",
            "sky-attack", "flash", "rest", "substitute", "nightmare", "snore", "curse",
            "protect", "mud-slap", "zap-cannon", "detect", "sandstorm", "giga-drain",
            "endure", "swagger", "steel-wing", "sleep-talk", "return", "frustration",
            "safeguard", ...],
          name: "ho-oh",
          stats: %{
            "attack" => 130,
            "defense" => 90,
            "hp" => 106,
            "special-attack" => 110,
            "special-defense" => 154,
            "speed" => 90
          },
          types: ["fire", "flying"],
          weight: 1990
          }
        }

  **Examples**

        {_, pkmn} = RareCandy.Api.get_pokemon_by_id(510)
        # {:ok,
        #   %Pokemon{
        #     abilities: ["limber", "unburden", "prankster"],
        #     forms: ["liepard"],
        #     height: 11,
        #     id: 510
        #   ...
        IO.puts(String.capitalize(pkmn.name) <> " was caught!")
        # Liepard was caught!
        # :ok

        RareCandy.Api.find_pokemon("fossrass")
        # {:ok,
        #  %Pokemon{
        #    abilities: ["snow-cloak", "cursed-body"],
        #    forms: ["froslass"],
        #    height: 13,
        #    id: 478,
        #  ...
  """

  require Logger

  @type json :: String.t()

  @spec get_pokemon_by_id(integer) :: {:ok, map}
  @doc ~S"""
  Fetches data from PokeApi using the desired Pokemon's dex no as an argument.
  """
  def get_pokemon_by_id(id) do
    ("https://pokeapi.co/api/v2/pokemon/" <> Integer.to_string(id))
    |> HTTPoison.get!()
    |> get_pokemon
  end

  @spec find_pokemon(any) :: {:ok, map}
  @doc ~S"""
  Will return the Pokemon struct that's name is nearest to the string input query.

  Utilizes String.jaro_distance.
  """
  def find_pokemon(query) do
    Enum.map(get_list_of_names(), fn str ->
      String.jaro_distance(query, str)
    end)
    |> Enum.with_index(1)
    |> Enum.max()
    |> elem(1)
    |> get_pokemon_by_id
  end

  # TODO: too slow -- wip
  # def get_pokemon_with_move(move) do
  #   for pkmn <- get_list_of_names(), into: [] do
  #     {_, p} = find_pokemon(pkmn)
  #     if (move in p.moves) do pkmn end
  #   end
  # end

  # should be modified to account for species -> name: pokemon like "pumpkaboo" and "zygarde" break
  defp get_list_of_names() do
    json = HTTPoison.get!("https://pokeapi.co/api/v2/pokemon?limit=9999&offset=0")
    map = Poison.decode!(json.body)
    Enum.map(map["results"], fn pkmn -> pkmn["name"] end)
  end

  # TODO: clarify name via %species{"name"} rather than "name" implication
  defp get_pokemon(json) do
    {status, _} = Poison.decode(json.body, as: %Pokemon{})

    case status do
      :ok ->
        pkmn = Poison.decode!(json.body, as: %Pokemon{})
        # get strictly type names into list
        |> Map.update!(:types, fn ts ->
          for types <- ts, do: types["type"]["name"]
        end)
        # moves
        |> Map.update!(:moves, fn mov ->
          for moves <- mov, do: moves["move"]["name"]
        end)
        # abilities
        |> Map.update!(:abilities, fn abs ->
          for abilities <- abs, do: abilities["ability"]["name"]
        end)
        # forms
        |> Map.update!(:forms, fn fms ->
          for forms <- fms, do: forms["name"]
        end)
        # stats: format into map
        |> Map.update!(:stats, fn sts ->
          for stats <- sts, into: %{}, do: {stats["stat"]["name"], stats["base_stat"]}
        end)
        # image url. requires throwaway parameter?
        |> Map.update!(:img, fn _ ->
          Poison.decode!(json.body)
          |> Map.fetch!("sprites")
          |> Map.fetch!("other")
          |> Map.fetch!("official-artwork")
          |> Map.fetch!("front_default")
        end)
        # species name over "name"
        |> Map.update!(:name, fn _ ->
          Poison.decode!(json.body)
          |> Map.fetch!("species")
          |> Map.fetch!("name")
        end)

        {:ok, pkmn}
      _ ->
        {status, %Pokemon{}}
    end
  end
end
