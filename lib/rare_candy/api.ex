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
  """

  require Logger

  @type json :: String.t()

  defp get_pokemon(json) do
    pkmn = Poison.decode!(json.body, as: %Pokemon{})
    |> Map.update!(:types, fn ts ->                 # get strictly type names into list
      for types <- ts, do: types["type"]["name"]
    end)
    |> Map.update!(:moves, fn mov ->                # moves
      for moves <- mov, do: moves["move"]["name"]
    end)
    |> Map.update!(:abilities, fn abs ->            # abilities
      for abilities <- abs, do: abilities["ability"]["name"]
    end)
    |> Map.update!(:forms, fn fms ->                # forms
      for forms <- fms, do: forms["name"]
    end)
    |> Map.update!(:stats, fn sts ->                # stats: format into map
      for stats <- sts, into: %{}, do: {stats["stat"]["name"], stats["base_stat"]}
    end)

    {:ok, pkmn}
  end

  @doc ~S"""
  Fetches data from PokeApi using the desired Pokemon's dex no as an argument.
  """
  @spec get_pokemon_by_id(integer() | String.t()) :: {:ok, %Pokemon{}}
  def get_pokemon_by_id(id) do
    "https://pokeapi.co/api/v2/pokemon/" <> Integer.to_string(id)
    |> HTTPoison.get!
    |> get_pokemon
  end
end
