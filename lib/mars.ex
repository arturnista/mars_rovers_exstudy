defmodule Mars do

    def execute(action_string) do
        [ plateauData | rovers ] = String.split(action_string, "\n")

        [ px, py ] = String.split(plateauData, [" "])
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(fn({ i, _n }) -> i end)
        { px, py }

    end

    def execute_actions(rover, [ ac | actions ], plateau) do
        rover = Mars.action(ac, rover, plateau)
        case length(actions) do
            0 -> rover
            _ -> Mars.execute_actions(rover, actions, plateau)
        end
    end

    def action("L", %Mars.Rover{ direction: "N" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "E" }
    end
    def action("L", %Mars.Rover{ direction: "E" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "S" }
    end
    def action("L", %Mars.Rover{ direction: "S" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "W" }
    end
    def action("L", %Mars.Rover{ direction: "W" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "N" }
    end

    def action("R", %Mars.Rover{ direction: "N" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "W" }
    end
    def action("R", %Mars.Rover{ direction: "W" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "S" }
    end
    def action("R", %Mars.Rover{ direction: "S" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "E" }
    end
    def action("R", %Mars.Rover{ direction: "E" } = rover, _plateau) do
        %Mars.Rover{ rover | direction: "N" }
    end

    def action("M", %Mars.Rover{ position: { x, y }, direction: "N" } = rover, { _px, py } = _plateau) do
        %Mars.Rover{ rover | position: { x, min(py, y + 1) } }
    end
    def action("M", %Mars.Rover{ position: { x, y }, direction: "S" } = rover, _plateau) do
        %Mars.Rover{ rover | position: { x, max(0, y - 1) } }
    end
    def action("M", %Mars.Rover{ position: { x, y }, direction: "E" } = rover, { px, _py } = _plateau) do
        %Mars.Rover{ rover | position: { min(px, x + 1), y } }
    end
    def action("M", %Mars.Rover{ position: { x, y }, direction: "W" } = rover, _plateau) do
        %Mars.Rover{ rover | position: { max(0, x - 1), y } }
    end

end
