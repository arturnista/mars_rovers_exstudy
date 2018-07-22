defmodule Mars.Rover do
    @moduledoc """
    Rover struct
    * `position`: Rover's current position
    * `direction`: Rover's current direction
    * `actions`: Rover's current actions
    * `past_positions`: Rover's past positions
    """
    defstruct position: nil, direction: nil, actions: nil, past_positions: []
end