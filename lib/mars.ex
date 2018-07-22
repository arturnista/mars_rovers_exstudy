defmodule Mars do

    def execute(action_string) do
        [ plateauData | roversData ] = String.split(action_string, "\n")

        case Mars.create_plateau(plateauData) do
            { :error, message } -> message
            { :ok, plateau } -> 
                rovers = roversData
                |> Enum.chunk(2)
                |> Enum.map(&Mars.create_rover/1)

                case Enum.find(rovers, fn(rd) -> match?(rd, { :error, "" }) end) do
                    { :error, message } -> message
                    _ -> 
                        rovers = Enum.map(rovers, fn({ _st, r }) -> r end)
                        Enum.map(rovers, fn(rover) -> Mars.execute_actions(rover, Enum.filter(rovers, fn(r) -> r != rover end), plateau) end)
                end
        end
    end

    def execute_with_image(action_string) do
        [ plateauData | roversData ] = String.split(action_string, "\n")

        case Mars.create_plateau(plateauData) do
            { :error, message } -> message
            { :ok, plateau } -> 
                rovers = roversData
                |> Enum.chunk(2)
                |> Enum.map(&Mars.create_rover/1)

                image = Mars.create_image(plateau)

                case Enum.find(rovers, fn(rd) -> match?(rd, { :error, "" }) end) do
                    { :error, message } -> message
                    _ -> 
                        rovers = Enum.map(rovers, fn({ _st, r }) -> r end)
                        |> Enum.map(fn(r) -> Mars.initial_position_image(r, image, plateau) end)
                        Enum.map(rovers, fn(rover) -> Mars.execute_actions(rover, Enum.filter(rovers, fn(r) -> r != rover end), plateau, image) end)
                end

                Mars.save_image(image)
        end
    end

    def create_plateau(data) do
        pos = String.split(data, [" "])
        |> Enum.map(&Integer.parse/1)

        case pos do
            [ { px, sx }, { py, sy } ] when px > 0 and py > 0 and sx == "" and sy == "" -> { :ok, { px, py } }
            _ -> { :error, "Plateau position must be two positive integers {x, y}" }
        end
    end

    def create_rover([ posDir, actions ]) do
        case String.split(posDir, [" "]) do
            [ xStr, yStr, direction ] ->
                case { Integer.parse(xStr), Integer.parse(yStr) } do
                    { { x, sx }, { y, sy } } when x >= 0 and y >= 0 and sx == "" and sy == "" ->
                        actions = String.split(actions, "")
                        |> Enum.filter(fn(x) -> String.length(x) > 0 end)
                        { :ok, %Mars.Rover{ position: { x, y }, direction: direction, actions: actions } }
                    _ -> { :error, "Rover position must be two positive integers {x, y} and a direction" }
                end
            _ -> { :error, "Rover position must be two positive integers {x, y} and a direction" }
        end
    end

    def create_rover(_wrongData), do: { :error, "Rover should be a position and a list of actions" }


    def execute_actions(%Mars.Rover{ actions: [] } = rover, _rovers, plateau, image) do
        rover
        |> Mars.final_position_image(image, plateau)
    end
    def execute_actions(rover, rovers, plateau, image) do
        Mars.action(rover, rovers, plateau)
        |> Mars.path_image(rover, image, plateau)
        |> Mars.execute_actions(rovers, plateau, image)
    end

    def create_image(size) do
        { x, y } = size
        image = :egd.create((x + 1) * 50, (y + 1) * 50)
        xArr = 0..x
        yArr = 0..y
        fill_color = :egd.color({ 0, 0, 0 })
        for xp <- xArr, yp <- yArr do
            :egd.rectangle(image, { xp * 50, yp * 50 }, { xp * 50 + 50, yp * 50 + 50 }, fill_color)
        end
        image
    end

    def save_image(image) do
        File.write("rover.png", :egd.render(image))            
    end

    def path_image(nRover, rover, image, plateau) do
        fill_color = :egd.color({ 255, 150, 0 })
        { _px, py } = plateau
        { x1, y1 } = rover.position
        { x2, y2 } = nRover.position
        :egd.line(image, { x1 * 50 + 25, (py - y1) * 50 + 25 } , { x2 * 50 + 25, (py - y2) * 50 + 25 }, fill_color)
        nRover
    end

    def initial_position_image(rover, image, plateau) do
        fill_color = :egd.color({ 0, 200, 0 })
        { _px, py } = plateau
        { x1, y1 } = rover.position
        :egd.rectangle(image, { x1 * 50 + 22, (py - y1) * 50 + 22 } , { x1 * 50 + 28, (py - y1) * 50 + 28 }, fill_color)
        rover
    end

    def final_position_image(rover, image, plateau) do
        fill_color = :egd.color({ 200, 0, 0 })
        { _px, py } = plateau
        { x1, y1 } = rover.position
        :egd.rectangle(image, { x1 * 50 + 20, (py - y1) * 50 + 20 } , { x1 * 50 + 30, (py - y1) * 50 + 30 }, fill_color)
        rover
    end

    def execute_actions(%Mars.Rover{ actions: [] } = rover, _rovers, _plateau) do
        rover
    end
    def execute_actions(rover, rovers, plateau) do
        Mars.execute_actions(Mars.action(rover, rovers, plateau), rovers, plateau)
    end

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

    # def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "N" } = rover, rovers, { _px, py } = _plateau) do
    #     %Mars.Rover{ rover | actions: actions, position: { x, min(py, y + 1) } }
    # end
    # def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "S" } = rover, rovers, _plateau) do
    #     %Mars.Rover{ rover | actions: actions, position: { x, max(0, y - 1) } }
    # end
    # def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "E" } = rover, rovers, { px, _py } = _plateau) do
    #     %Mars.Rover{ rover | actions: actions, position: { min(px, x + 1), y } }
    # end
    # def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: "W" } = rover, rovers, _plateau) do
    #     %Mars.Rover{ rover | actions: actions, position: { max(0, x - 1), y } }
    # end

    def action(%Mars.Rover{ actions: [ "M" | actions ], position: { x, y }, direction: direction } = rover, rovers, { px, py } = _plateau) do
        movePosition = case direction do
            "N" -> { x, min(py, y + 1) }
            "S" -> { x, max(0, y - 1) }
            "E" -> { min(px, x + 1), y }
            "W" -> { max(0, x - 1), y }
        end

        case Mars.position_available?(movePosition, rovers) do
            { :ok, position } -> %Mars.Rover{ rover | actions: actions, position: position }
            { :error, _pos } -> %Mars.Rover{ rover | actions: actions }
        end
    end

    def position_available?({ x, y } = position, rovers) do
        case Enum.find(rovers, fn(%Mars.Rover{ position: { rx, ry } }) -> x == rx && ry == y end) do
            nil -> { :ok, position }
            _ -> { :error, position }
        end
    end

end
