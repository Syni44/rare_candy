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
  @type pokemon :: Pokemon.t()

  @spec get_pokemon_by_id(integer) :: {:ok, pokemon} | {:error, any}
  @doc ~S"""
  Fetches data from PokeApi using the desired Pokemon's dex no as an argument.
  """
  def get_pokemon_by_id(id) do
    url = "https://pokeapi.co/api/v2/pokemon/#{id}"

    case HTTPoison.get(url, []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_pokemon_data(body)

      {:ok, response} ->
        Logger.error("HTTP Error: #{response.status_code}")
        {:error, "HTTP Error: #{response.status_code}"}

      {:error, reason} ->
        Logger.error("HTTPoison Error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @spec find_pokemon(any) :: {:ok, pokemon} | {:error, any}
  @doc ~S"""
  Will return the Pokemon struct that's name is nearest to the string input query.

  Utilizes String.jaro_distance.
  """
  def find_pokemon(query) do
    case get_list_of_names() do
      {:ok, names} ->
        names
        |> Enum.map(fn name -> {name, String.jaro_distance(query, name)} end)
        |> Enum.max_by(fn {_name, score} -> score end)
        |> elem(0)
        |> get_pokemon_by_name()

      error ->
        error
    end
  end

  # TODO: too slow -- wip
  # def get_pokemon_with_move(move) do
  #   for pkmn <- get_list_of_names(), into: [] do
  #     {_, p} = find_pokemon(pkmn)
  #     if (move in p.moves) do pkmn end
  #   end
  # end

  defp get_pokemon_by_name(name) do
    url = "https://pokeapi.co/api/v2/pokemon/#{name}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_pokemon_data(body)

      {:ok, response} ->
        {:error, "HTTP Error: #{response.status_code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_list_of_names() do
    case HTTPoison.get("https://pokeapi.co/api/v2/pokemon?limit=9999&offset=0") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Jason.decode!() |> Map.get("results", []) |> Enum.map(& &1["name"])}

      {:ok, response} ->
        {:error, "HTTP Error: #{response.status_code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_pokemon_data(body) do
    case Jason.decode(body) do
      {:ok, json_map} ->
        pokemon = %Pokemon{
          id: json_map["id"],
          name: json_map["name"],
          types: parse_types(json_map["types"]),
          moves: parse_moves(json_map["moves"]),
          abilities: parse_abilities(json_map["abilities"]),
          forms: parse_forms(json_map["forms"]),
          stats: parse_stats(json_map["stats"]),
          img: get_image_url(json_map),
          height: json_map["height"],
          weight: json_map["weight"]
        }

        {:ok, pokemon}

      {:error, error} ->
        {:error, error}
    end
  end

  # Helper functions for parsing nested data
  defp parse_types(types), do: Enum.map(types, & &1["type"]["name"])
  defp parse_moves(moves), do: Enum.map(moves, & &1["move"]["name"])
  defp parse_abilities(abilities), do: Enum.map(abilities, & &1["ability"]["name"])
  defp parse_forms(forms), do: Enum.map(forms, & &1["name"])

  defp parse_stats(stats) do
    Enum.reduce(stats, %{}, fn stat, acc ->
      stat_name = stat["stat"]["name"]
      base_stat = stat["base_stat"]
      Map.put(acc, stat_name, base_stat)
    end)
  end

  defp get_image_url(json_map) do
    json_map
    |> Map.get("sprites", %{})
    |> Map.get("other", %{})
    |> Map.get("official-artwork", %{})
    |> Map.get("front_default")
  end
end
