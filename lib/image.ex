defmodule Image do    

    def create(size) do
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

    def save(image) do
        File.write("rover.png", :egd.render(image))            
    end

    def path(nRover, rover, image, plateau) do
        fill_color = :egd.color({ 255, 150, 0 })
        { _px, py } = plateau
        { x1, y1 } = rover.position
        { x2, y2 } = nRover.position
        :egd.line(image, { x1 * 50 + 25, (py - y1) * 50 + 25 } , { x2 * 50 + 25, (py - y2) * 50 + 25 }, fill_color)
        nRover
    end

    def initial_position(rover, image, plateau) do
        fill_color = :egd.color({ 0, 200, 0 })
        { _px, py } = plateau
        { x1, y1 } = rover.position
        :egd.rectangle(image, { x1 * 50 + 22, (py - y1) * 50 + 22 } , { x1 * 50 + 28, (py - y1) * 50 + 28 }, fill_color)
        rover
    end

    def final_position(rover, image, plateau) do
        fill_color = :egd.color({ 200, 0, 0 })
        { _px, py } = plateau
        { x1, y1 } = rover.position
        :egd.rectangle(image, { x1 * 50 + 20, (py - y1) * 50 + 20 } , { x1 * 50 + 30, (py - y1) * 50 + 30 }, fill_color)
        rover
    end
end