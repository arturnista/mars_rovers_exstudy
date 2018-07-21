defmodule MarsTest do
    use ExUnit.Case
    doctest Mars

    test "execute actions" do
        assert Mars.execute_actions(%Mars.Rover{ position: { 1, 2 }, direction: "N" }, ["L", "M", "L", "M", "L", "M", "L", "M", "M" ], {5, 5}) == %Mars.Rover{ position: { 1, 3 }, direction: "N" }
    end

    test "execute actions 2" do
        assert Mars.execute_actions(%Mars.Rover{ position: { 3, 3 }, direction: "E" }, [ "M", "M", "R", "M", "M", "R", "M", "R", "R", "M" ], {5, 5}) == %Mars.Rover{ position: { 5, 1 }, direction: "E" }
    end

    test "turn R with N should return E" do
        assert Mars.action("R", %Mars.Rover{ position: { 1, 1 }, direction: "N" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "E" }
    end

    test "turn R with E should return S" do
        assert Mars.action("R", %Mars.Rover{ position: { 1, 1 }, direction: "E" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "S" }
    end

    test "turn R with S should return W" do
        assert Mars.action("R", %Mars.Rover{ position: { 1, 1 }, direction: "S" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "W" }
    end

    test "turn R with W should return N" do
        assert Mars.action("R", %Mars.Rover{ position: { 1, 1 }, direction: "W" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "N" }
    end


    test "turn L with N should return W" do
        assert Mars.action("L", %Mars.Rover{ position: { 1, 1 }, direction: "N" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "W" }
    end

    test "turn L with W should return S" do
        assert Mars.action("L", %Mars.Rover{ position: { 1, 1 }, direction: "W" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "S" }
    end

    test "turn L with S should return E" do
        assert Mars.action("L", %Mars.Rover{ position: { 1, 1 }, direction: "S" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "E" }
    end

    test "turn L with E should return N" do
        assert Mars.action("L", %Mars.Rover{ position: { 1, 1 }, direction: "E" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 1 }, direction: "N" }
    end


    test "move 1, 1 to north should return 1, 2" do
        assert Mars.action("M", %Mars.Rover{ position: { 1, 1 }, direction: "N" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 2 }, direction: "N" }
    end

    test "move 1, 1 to south should return 1, 0" do
        assert Mars.action("M", %Mars.Rover{ position: { 1, 1 }, direction: "S" }, { 5, 5 }) == %Mars.Rover{ position: { 1, 0 }, direction: "S" }
    end

    test "move 1, 1 to east should return 2, 1" do
        assert Mars.action("M", %Mars.Rover{ position: { 1, 1 }, direction: "E" }, { 5, 5 }) == %Mars.Rover{ position: { 2, 1 }, direction: "E" }
    end

    test "move 1, 1 to west should return 0, 1" do
        assert Mars.action("M", %Mars.Rover{ position: { 1, 1 }, direction: "W" }, { 5, 5 }) == %Mars.Rover{ position: { 0, 1 }, direction: "W" }
    end

    test "move 5, 5 to north should return 5, 5" do
        assert Mars.action("M", %Mars.Rover{ position: { 5, 5 }, direction: "N" }, { 5, 5 }) == %Mars.Rover{ position: { 5, 5 }, direction: "N" }
    end

    test "move 5, 5 to east should return 5, 5" do
        assert Mars.action("M", %Mars.Rover{ position: { 5, 5 }, direction: "E" }, { 5, 5 }) == %Mars.Rover{ position: { 5, 5 }, direction: "E" }
    end

    test "move 0, 0 to south should return 0, 0" do
        assert Mars.action("M", %Mars.Rover{ position: { 0, 0 }, direction: "S" }, { 5, 5 }) == %Mars.Rover{ position: { 0, 0 }, direction: "S" }
    end

    test "move 0, 0 to west should return 0, 0" do
        assert Mars.action("M", %Mars.Rover{ position: { 0, 0 }, direction: "W" }, { 5, 5 }) == %Mars.Rover{ position: { 0, 0 }, direction: "W" }
    end

end
