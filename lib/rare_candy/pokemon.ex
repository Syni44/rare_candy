defmodule Pokemon do
  defstruct id: nil,
            name: "",
            types: [],
            height: nil,
            weight: nil,
            moves: [],
            abilities: [],
            forms: [],
            stats: %{},
            img: ""

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t(),
          types: [String.t()],
          height: integer() | nil,
          weight: integer() | nil,
          moves: [String.t()],
          abilities: [String.t()],
          forms: [String.t()],
          stats: %{String.t() => integer()},
          img: String.t()
        }
end
