defmodule Mars do
    @image Application.get_env(:mars, :image)

    @moduledoc """
    Mars rover's module to handle Rover's Deploy
    """

    @doc """
    Execute the actions, parsing the data as a string.\n
    The `actionString` argument represents the data, following the pattern:\n
        5 5
        0 0 N
        RLM
        5 5 S
        RLM
        * 5 5: Plateau size, as X and Y respectively
        * 0 0 N: Rover position and direction, X and Y as positions and N (north), E (east), S (south) and W (west) as the available directions
        * RLM: Rover actions, being R and L to turn the rover, Right and Left respectively and M to move foward
        * Your input do not have rovers amount limit \n
    Executing the rovers actions generate a image of each rover's path named **mars_rovers_UNIX.png**\n
    ## Example
        iex> Mars.execute("5 5\\n0 0 N\\nM")
        "0 1 N"

        iex> Mars.execute("5 5\\n1 2 N\\nLMLMLMLMM\\n3 3 E\\nMMRMMRMRRM")
        "1 3 N\\n5 1 E"
    """
    def execute(actionString)
    def execute(actionString) do
        [ plateauData | roversData ] = String.split(actionString, "\n")

        case Mars.create_plateau(plateauData) do
            { :error, message } -> message
            { :ok, plateau } -> 
                rovers = roversData
                |> Enum.chunk(2)
                |> Enum.map(&Mars.create_rover/1)

                case Enum.find(rovers, &match?(&1, { :error, "" })) do
                    { :error, message } -> message
                    _ -> 
                        Enum.map(rovers, fn({ _st, r }) -> r end)
                        |> Mars.execute(plateau)
                end
        end
    end

    def create_plateau(plateauData) do
        pos = String.split(plateauData, [" "])
        |> Enum.map(&Integer.parse/1)

        case pos do
            [ { px, sx }, { py, sy } ] when px > 0 and py > 0 and sx == "" and sy == "" -> { :ok, { px, py } }
            _ -> { :error, "Plateau position must be two positive integers {x, y}" }
        end
    end

    def create_rover([ posDir, actions ] = _roverData) do
        case String.split(posDir, [" "]) do
            # Check if the position data are a valid three item list (x, y, direction)
            [ xStr, yStr, direction ] ->
                case { Integer.parse(xStr), Integer.parse(yStr) } do
                    # Check if the positions values are valid
                    { { x, sx }, { y, sy } } when x >= 0 and y >= 0 and sx == "" and sy == "" ->
                        # Split the action string and remove useless actions
                        actions = String.split(actions, "")
                        |> Enum.filter(fn(x) -> String.length(x) > 0 end)

                        # Check if every action is valid
                        case Enum.find(actions, fn(ac) -> ac != "M" and ac != "L" and ac != "R" end) do
                            nil -> { :ok, %Mars.Rover{ position: { x, y }, direction: direction, actions: actions } }
                            _ -> { :error, "Rover actions should be M (move), R (turn right) or L (turn left)" }
                        end
                    _ -> { :error, "Rover position must be two positive integers {x, y} and a direction" }
                end
            _ -> { :error, "Rover position must be two positive integers {x, y} and a direction" }
        end
    end
    def create_rover(_wrongData), do: { :error, "Rover should be a position and a list of actions" }

    
    @doc """
    Execute the rovers actions.\n
    The `plateau` argument represents the plateau size, being `{ x, y }`\n
    The `rovers` argument represents the rovers data, being `%Mars.Rover{actions: [], direction: "N", position: {0, 0}, past_positions: []}`\n\n

    Executing the rovers actions generate a image of the rovers path named **mars_rovers_UNIX.png**\n
        
    ## Example
        iex> Mars.execute([ %Mars.Rover{actions: ["M"], direction: "N", position: {0, 0}} ], { 5, 5 })
        "0 1 N"

        iex> Mars.execute([ %Mars.Rover{actions: ["L", "M", "L", "M", "L", "M", "L", "M", "M"], direction: "N", position: {1, 2}}, %Mars.Rover{actions: ["M", "M", "R", "M", "M", "R", "M", "R", "R", "M"], direction: "E", position: {3, 3}} ], {5, 5})
        "1 3 N\\n5 1 E"
    """
    def execute(rovers, plateau, processedRovers \\ [])
    def execute([], plateau, processedRovers) do
        processedRovers
        |> Mars.create_images(plateau)
        |> Mars.parse_output
    end
    def execute([ rover | rovers ], plateau, processedRovers) do
        rover = Mars.execute_actions(rover, Enum.filter(rovers ++ processedRovers, fn(r) -> r != rover end), plateau)
        Mars.execute(rovers, plateau, processedRovers ++ [rover])
    end

    @doc """
    Execute the rovers actions.\n
    The `rover` argument represents the current rover being processed\n
    The `rovers` argument represents the rovers data, needed for collision detection\n
    The `plateau` argument represents the plateau size, being `{ x, y }`\n
    ## Example
        iex> Mars.execute_actions(%Mars.Rover{ position: { 1, 2 }, direction: "N", actions: [ "M" ] }, [], {5, 5})
        %Mars.Rover{ position: { 1, 3 }, direction: "N", actions: [], past_positions: [{1, 2}] }

        iex> Mars.execute_actions(%Mars.Rover{ position: { 1, 2 }, direction: "N", actions: [ "M", "R" ] }, [], {5, 5})
        %Mars.Rover{ position: { 1, 3 }, direction: "E", actions: [], past_positions: [{1, 2}] }

    """
    def execute_actions(%Mars.Rover{ actions: [] } = rover, _rovers, _plateau), do: rover
    def execute_actions(rover, rovers, plateau) do
        Mars.execute_actions(Mars.action(rover, rovers, plateau), rovers, plateau)
    end

    @doc """
    Execute a single action of a rover.\n
    The `rover` argument represents the current rover being processed\n
    The `rovers` argument represents the rovers data, needed for collision detection\n
    The `plateau` argument represents the plateau size, being `{ x, y }`\n
    ## Example
        iex> Mars.action(%Mars.Rover{ position: { 1, 2 }, direction: "N", actions: [ "M" ] }, [], {5, 5})
        %Mars.Rover{ position: { 1, 3 }, direction: "N", actions: [], past_positions: [{1, 2}] }

        iex> Mars.action(%Mars.Rover{ position: { 1, 2 }, direction: "N", actions: [ "M", "R" ] }, [], {5, 5})
        %Mars.Rover{ position: { 1, 3 }, direction: "N", actions: ["R"], past_positions: [{1, 2}] }
        
        iex> Mars.action(%Mars.Rover{ position: { 1, 3 }, direction: "N", actions: ["R"], past_positions: [{1, 2}] }, [], {5, 5})
        %Mars.Rover{ position: { 1, 3 }, direction: "E", actions: [], past_positions: [{1, 2}] }

    """
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "N" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "E" }
    end
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "E" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "S" }
    end
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "S" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "W" }
    end
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "W" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "N" }
    end

    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "N" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "W" }
    end
    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "W" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "S" }
    end
    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "S" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "E" }
    end
    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "E" } = rover, _rovers, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "N" }
    end

    def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: direction, past_positions: past_positions } = rover, rovers, { px, py } = _plateau) do
        movePosition = case direction do
            "N" -> { x, min(py, y + 1) }
            "S" -> { x, max(0, y - 1) }
            "E" -> { min(px, x + 1), y }
            "W" -> { max(0, x - 1), y }
        end
        case Mars.position_available?(movePosition, rovers) do
            { :ok, position } -> %Mars.Rover{ rover | actions: actions, position: position, past_positions: past_positions ++ [{ x, y }] }
            { :error, _pos } -> %Mars.Rover{ rover | actions: actions }
        end
    end

    @doc """
    Verify if the position do not collide with another rover.\n
    The `position` argument represents the position to compare\n
    The `rovers` argument represents the rovers data\n
    ## Example
        iex> Mars.position_available?({1, 1}, [ %Mars.Rover{ position: { 1, 2 } } ])
        { :ok, { 1, 1 } }

        iex> Mars.position_available?({2, 2}, [ %Mars.Rover{ position: { 0, 0 } }, %Mars.Rover{ position: { 1, 1 } }, %Mars.Rover{ position: { 2, 2 } }, %Mars.Rover{ position: { 3, 3 } } ])
        { :error, { 2, 2 } }
    """
    def position_available?({ x, y } = position, rovers) do
        case Enum.find(rovers, fn(%Mars.Rover{ position: { rx, ry } }) -> x == rx && ry == y end) do
            nil -> { :ok, position }
            _ -> { :error, position }
        end
    end

    def create_images(rovers, plateau) do
        image = @image.create(plateau)
        for rover <- rovers do
            case rover.past_positions do
                [ fp | _positions ] -> 
                    @image.draw_initial_position(image, fp, plateau)
                    Mars.draw_paths(image, rover.past_positions ++ [rover.position], plateau)
                    @image.draw_final_position(image, rover.position, plateau)
                [] -> :ok
            end
        end
        @image.save("mars_rovers_" <> Integer.to_string(DateTime.to_unix(DateTime.utc_now)), image)
        rovers
    end

    def draw_paths(_image, [ _pos ], _plateau), do: :ok
    def draw_paths(image, [ pos1, pos2 | positions ], plateau) do
        @image.draw_path(image, pos1, pos2, plateau)
        draw_paths(image, [pos2] ++ positions, plateau)
    end
    

    @doc """
    Parse the value, returning the rovers position and direction as a string
    The `rovers` argument represents the rovers to be parsed\n
    
    ## Example
        iex> Mars.parse_output([ %Mars.Rover{ direction: "N", position: { 1, 2 } } ])
        "1 2 N"

        iex> Mars.parse_output([ %Mars.Rover{ direction: "N", position: { 0, 0 } }, %Mars.Rover{ direction: "S", position: { 1, 1 } }, %Mars.Rover{ direction: "E", position: { 2, 2 } }, %Mars.Rover{ direction: "W", position: { 3, 3 } } ])
        "0 0 N\\n1 1 S\\n2 2 E\\n3 3 W"
    """
    def parse_output(rovers) do
        rovers
        |> Enum.map(fn(%Mars.Rover{ direction: d, position: { x, y }}) -> "#{x} #{y} #{d}" end)
        |> Enum.join("\n")
    end

end
