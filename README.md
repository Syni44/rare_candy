![Hex version](https://img.shields.io/hexpm/v/rare_candy "Hex version")
# RareCandy

A library for fetching Pokemon data in Elixir. This library is **still heavily a work in progress.**

## Installation

The package can be installed by adding `rare_candy` to your
list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rare_candy, "~> 0.1.3"}
  ]
end
```

## Documentation

> [https://hexdocs.pm/rare_candy](https://hexdocs.pm/rare_candy)

## Examples

```elixir
iex(1)> {:ok, pkmn} = RareCandy.Api.get_pokemon_by_id(490)
{:ok,
 %Pokemon{
   abilities: ["hydration"],
   forms: ["manaphy"],
   height: 3,
   id: 490,
   img: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/490.png",
   moves: ["supersonic", "surf", "ice-beam", "blizzard", "bubble-beam",
    "hyper-beam", "toxic", "psychic", "double-team", "light-screen", "reflect",
    "waterfall", "swift", "bubble", "flash", "acid-armor", "rest", "substitute",
    "snore", "protect", "mud-slap", "icy-wind", "endure", "charm", "swagger",
    "sleep-talk", "heal-bell", "return", "frustration", "safeguard",
    "hidden-power", "rain-dance", "psych-up", "ancient-power", "shadow-ball",
    "whirlpool", "uproar", "hail", "facade", "helping-hand", "knock-off",
    "skill-swap", "secret-power", ...],
   name: "manaphy",
   stats: %{
     "attack" => 100,
     "defense" => 100,
     "hp" => 100,
     "special-attack" => 100,
     "special-defense" => 100,
     "speed" => 100
   },
   types: ["water"],
   weight: 14
 }}
iex(2)> pkmn.name
"manaphy"
iex(3)> "u-turn" in pkmn.moves
true
```
