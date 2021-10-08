defmodule RareCandy.Api.ApiFetchingTest do
  use ExUnit.Case, async: true

  test "pokemon stats directly into map" do
    expected = %{
      "attack" => 80,
      "defense" => 70,
      "hp" => 85,
      "special-attack" => 135,
      "special-defense" => 75,
      "speed" => 90
    }

    {_, pkmn} = RareCandy.Api.get_pokemon_by_id(474)
    result = Map.get(pkmn, :stats)

    assert result == expected
  end

  test "single or multi type" do
    expected = %{
      "pkmn1.name" => "slugma",
      "pkmn1.types" => ["fire"],
      "pkmn2.name" => "magcargo",
      "pkmn2.types" => ["fire", "rock"]
    }

    {_, pkmn1} = RareCandy.Api.get_pokemon_by_id(218)
    {_, pkmn2} = RareCandy.Api.get_pokemon_by_id(219)
    result = %{
      "pkmn1.name" => pkmn1.name,
      "pkmn1.types" => pkmn1.types,
      "pkmn2.name" => pkmn2.name,
      "pkmn2.types" => pkmn2.types
    }

    assert result == expected
  end
end
