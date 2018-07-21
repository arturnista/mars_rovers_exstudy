defmodule Mars do

    def execute(action_string) do
        [ plateauData | roversData ] = String.split(action_string, "\n")

        [ px, py ] = for pos <- String.split(plateauData, [" "]) do
            { i, _n } = Integer.parse(pos)
            i
        end

        plateau = { px, py }

        rovers = for roverData <- Enum.chunk(roversData, 2) do
            { _st, rover } = Mars.create_rover(roverData)
            Mars.execute_actions(rover, plateau)
        end
    end

    def create_rover([ posDir, actions ]) do
        [ xStr, yStr, direction ] = String.split(posDir, [" "])
        { x, _str } = Integer.parse(xStr)
        { y, _str } = Integer.parse(yStr)
        actions = String.split(actions, "")
        |> Enum.filter(fn(x) -> String.length(x) > 0 end)
        { :ok, %Mars.Rover{ position: { x, y }, direction: direction, actions: actions } }
    end

    def create_rover(_ac), do: { :error }

    def execute_actions(%Mars.Rover{ actions: actions } = rover, plateau) do
        case length(actions) do
            0 -> rover
            _ -> Mars.execute_actions(Mars.action(rover, plateau), plateau)
        end
    end

    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "N" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "E" }
    end
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "E" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "S" }
    end
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "S" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "W" }
    end
    def action(%Mars.Rover{ actions: [ "R" | actions ], direction: "W" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "N" }
    end

    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "N" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "W" }
    end
    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "W" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "S" }
    end
    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "S" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "E" }
    end
    def action(%Mars.Rover{ actions: [ "L" | actions ], direction: "E" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, direction: "N" }
    end

    def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "N" } = rover, { _px, py } = _plateau) do
        %Mars.Rover{ rover | actions: actions, position: { x, min(py, y + 1) } }
    end
    def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "S" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, position: { x, max(0, y - 1) } }
    end
    def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "E" } = rover, { px, _py } = _plateau) do
        %Mars.Rover{ rover | actions: actions, position: { min(px, x + 1), y } }
    end
    def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "W" } = rover, _plateau) do
        %Mars.Rover{ rover | actions: actions, position: { max(0, x - 1), y } }
    end

end
