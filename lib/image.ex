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

    def save(filename, image) do
        File.write("#{filename}.png", :egd.render(image))            
    end

    def draw_path(image, position1, position2, plateau) do
        fill_color = :egd.color({ 255, 150, 0 })
        { _px, py } = plateau
        { x1, y1 } = position1
        { x2, y2 } = position2
        :egd.line(image, { x1 * 50 + 25, (py - y1) * 50 + 25 } , { x2 * 50 + 25, (py - y2) * 50 + 25 }, fill_color)
        image
    end

    def draw_initial_position(image, position, plateau) do
        fill_color = :egd.color({ 0, 200, 0 })
        { _px, py } = plateau
        { x1, y1 } = position
        :egd.rectangle(image, { x1 * 50 + 22, (py - y1) * 50 + 22 } , { x1 * 50 + 28, (py - y1) * 50 + 28 }, fill_color)
        image
    end

    def draw_final_position(image, position, plateau) do
        fill_color = :egd.color({ 200, 0, 0 })
        { _px, py } = plateau
        { x1, y1 } = position
        :egd.rectangle(image, { x1 * 50 + 20, (py - y1) * 50 + 20 } , { x1 * 50 + 30, (py - y1) * 50 + 30 }, fill_color)
        image
    end
end