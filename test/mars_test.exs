defmodule MarsTest do
    use ExUnit.Case
    doctest Mars

    test "execute with 5 5\n0 0 N\nM should return rovers in 0, 1 N" do
        assert Mars.execute("5 5\n0 0 N\nM") == [
            %Mars.Rover{actions: [], direction: "N", position: {0, 1}, past_positions: [{0, 0}]}
        ]
    end

    test "execute with 5 5\n0 0 N\nM\n0 1 N\nM\n0 2 N\nM should return rovers in 0, 1 N, 0, 1 N and 0, 3 N" do
        assert Mars.execute("5 5\n0 0 N\nM\n0 1 N\nM\n0 2 N\nM") == [
            %Mars.Rover{actions: [], direction: "N", position: {0, 0}, past_positions: []},
            %Mars.Rover{actions: [], direction: "N", position: {0, 1}, past_positions: []},
            %Mars.Rover{actions: [], direction: "N", position: {0, 3}, past_positions: [{0, 2}]}
        ]
    end

    test "execute with 10 10\n0 3 N\nMMMRMMMRMMM\n0 2 N\nMMMMRMMMRMMM\n0 1 N\nMMMMMRMMMRMMM should return rovers in 5, 7 S, 4, 7 S and 3, 7 S" do
        assert Mars.execute("10 10\n0 3 N\nMMMRMMMRMMM\n0 2 N\nMMMMRMMMRMMM\n0 1 N\nMMMMMRMMMRMMM") == [
            %Mars.Rover{actions: [], direction: "S", position: {3, 3}, past_positions: [{0, 3}, {0, 4}, {0, 5}, {0, 6}, {1, 6}, {2, 6}, {3, 6}, {3, 5}, {3, 4}]},
            %Mars.Rover{actions: [], direction: "S", position: {3, 4}, past_positions: [{0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}, {1, 6}, {2, 6}, {3, 6}, {3, 5}]},
            %Mars.Rover{actions: [], direction: "S", position: {3, 5}, past_positions: [{0, 1}, {0, 2}, {0, 3}, {0, 4}, {0, 5}, {0, 6}, {1, 6}, {2, 6}, {3, 6}]}
        ]
    end

    test "execute with 5 5\n0 2 N\nMMM\n0 0 N\nMMM should return rovers in 0, 5 N and 0, 3 N" do
        assert Mars.execute("5 5\n0 2 N\nMMM\n0 0 N\nMMM") == [
            %Mars.Rover{actions: [], direction: "N", position: {0, 5}, past_positions: [{0, 2}, {0, 3}, {0, 4}]},
            %Mars.Rover{actions: [], direction: "N", position: {0, 3}, past_positions: [{0, 0}, {0, 1}, {0, 2}]}
        ]
    end

    test "execute with 5 5\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM should return rovers in 1, 3 N and 5, 1, E" do
        assert Mars.execute("5 5\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM") == [
            %Mars.Rover{actions: [], direction: "N", position: {1, 3}, past_positions: [{1, 2}, {0, 2}, {0, 1}, {1, 1}, {1, 2}]},
            %Mars.Rover{actions: [], direction: "E", position: {5, 1}, past_positions: [{3, 3}, {4, 3}, {5, 3}, {5, 2}, {5, 1}, {4, 1}]}
        ]
    end

    test "execute with 0 0\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM should return an error" do
        assert Mars.execute("0 0\n1 2 N\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM") == "Plateau position must be two positive integers {x, y}"
    end

    test "execute with 5 5\n1 2\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM should return an error" do
        assert Mars.execute("5 5\n1 2\nLMLMLMLMM\n3 3 E\nMMRMMRMRRM") == "Rover position must be two positive integers {x, y} and a direction"
    end

    test "create plateau with 5 5 should return { 5, 5 }" do
        assert Mars.create_plateau("5 5") == { :ok, { 5, 5 } }
    end

    test "create plateau with 100 100 should return { 100, 100 }" do
        assert Mars.create_plateau("100 100") == { :ok, { 100, 100 } }
    end

    test "create plateau with -5 100 should return :error" do
        assert Mars.create_plateau("-5 100") == { :error, "Plateau position must be two positive integers {x, y}" }
    end

    test "create plateau with 0 100 should return :error" do
        assert Mars.create_plateau("0 100") == { :error, "Plateau position must be two positive integers {x, y}" }
    end

    test "create plateau with abc 100 should return :error" do
        assert Mars.create_plateau("abc 100") == { :error, "Plateau position must be two positive integers {x, y}" }
    end

    test "create plateau with 1abc 100 should return :error" do
        assert Mars.create_plateau("1abc 100") == { :error, "Plateau position must be two positive integers {x, y}" }
    end


    test "create rover with 1 2 N and LMLMLMLMM should return a rover with position 1, 2, direction N and actions as a list" do
        assert Mars.create_rover(["1 2 N", "LMLMLMLMM"]) == {
            :ok,
            %Mars.Rover{ position: { 1, 2 }, direction: "N", actions: ["L", "M", "L", "M", "L", "M", "L", "M", "M" ], past_positions: [] }
        }
    end

    test "create rover without actions should return an error" do
        assert Mars.create_rover(["1 2 N"]) == {
            :error, "Rover should be a position and a list of actions"
        }
    end

    test "create rover with three items should return an error" do
        assert Mars.create_rover(["1 2 N", "MMM", "M"]) == {
            :error, "Rover should be a position and a list of actions"
        }
    end

    test "create rover with negative position must should an error" do
        assert Mars.create_rover(["1 -2 N", "MMM"]) == {
            :error, "Rover position must be two positive integers {x, y} and a direction"
        }
    end

    test "create rover with string position must should an error" do
        assert Mars.create_rover(["1 abc N", "MMM"]) == {
            :error, "Rover position must be two positive integers {x, y} and a direction"
        }
    end

    test "create rover with number+string position must should an error" do
        assert Mars.create_rover(["1 123abc N", "MMM"]) == {
            :error, "Rover position must be two positive integers {x, y} and a direction"
        }
    end

    test "create rover without direction should return an error" do
        assert Mars.create_rover(["1 2", "MMM"]) == {
            :error, "Rover position must be two positive integers {x, y} and a direction"
        }
    end

    test "create rover with actions being ABC should return an error" do
        assert Mars.create_rover(["1 2 N", "ABC"]) == {
            :error, "Rover actions should be M (move), R (turn right) or L (turn left)"
        }
    end

    test "create rover with actions being MMRARLL should return an error" do
        assert Mars.create_rover(["1 2 N", "MMRARLL"]) == {
            :error, "Rover actions should be M (move), R (turn right) or L (turn left)"
        }
    end

    test "rover in position 1, 2 and direction N should finish at 1, 3 and N" do
        assert Mars.execute_actions(%Mars.Rover{ position: { 1, 2 }, direction: "N", actions: ["L", "M", "L", "M", "L", "M", "L", "M", "M" ] }, [], {5, 5}) == 
        %Mars.Rover{ position: { 1, 3 }, direction: "N", actions: [], past_positions: [{1, 2}, {0, 2}, {0, 1}, {1, 1}, {1, 2}] }
    end

    test "rover in position 3, 3 and direction E should finish at 5, 1 and E" do
        assert Mars.execute_actions(%Mars.Rover{ position: { 3, 3 }, direction: "E", actions: [ "M", "M", "R", "M", "M", "R", "M", "R", "R", "M" ] }, [], {5, 5}) == 
        %Mars.Rover{ position: { 5, 1 }, direction: "E", actions: [], past_positions: [{3, 3}, {4, 3}, {5, 3}, {5, 2}, {5, 1}, {4, 1}] }
    end


    test "turn R with N should return E" do
        assert Mars.action(%Mars.Rover{ actions: ["R"], position: { 1, 1 }, direction: "N" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "E" }
    end

    test "turn R with E should return S" do
        assert Mars.action(%Mars.Rover{ actions: ["R"], position: { 1, 1 }, direction: "E" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "S" }
    end

    test "turn R with S should return W" do
        assert Mars.action(%Mars.Rover{ actions: ["R"], position: { 1, 1 }, direction: "S" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "W" }
    end

    test "turn R with W should return N" do
        assert Mars.action(%Mars.Rover{ actions: ["R"], position: { 1, 1 }, direction: "W" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "N" }
    end


    test "turn L with N should return W" do
        assert Mars.action(%Mars.Rover{ actions: ["L"], position: { 1, 1 }, direction: "N" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "W" }
    end

    test "turn L with W should return S" do
        assert Mars.action(%Mars.Rover{ actions: ["L"], position: { 1, 1 }, direction: "W" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "S" }
    end

    test "turn L with S should return E" do
        assert Mars.action(%Mars.Rover{ actions: ["L"], position: { 1, 1 }, direction: "S" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "E" }
    end

    test "turn L with E should return N" do
        assert Mars.action(%Mars.Rover{ actions: ["L"], position: { 1, 1 }, direction: "E" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "N" }
    end


    test "move 1, 1 to north should return 1, 2" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 1, 1 }, direction: "N" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 2 }, direction: "N", past_positions: [{1, 1}] }
    end

    test "move 1, 1 to south should return 1, 0" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 1, 1 }, direction: "S" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 0 }, direction: "S", past_positions: [{1, 1}] }
    end

    test "move 1, 1 to east should return 2, 1" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 1, 1 }, direction: "E" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 2, 1 }, direction: "E", past_positions: [{1, 1}] }
    end

    test "move 1, 1 to west should return 0, 1" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 1, 1 }, direction: "W" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 0, 1 }, direction: "W", past_positions: [{1, 1}] }
    end

    test "move 5, 5 to north should return 5, 5 with plateau boundaries being 5, 5" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 5, 5 }, direction: "N" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 5, 5 }, direction: "N", past_positions: [{5, 5}] }
    end

    test "move 5, 5 to east should return 5, 5 with plateau boundaries being 5, 5" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 5, 5 }, direction: "E" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 5, 5 }, direction: "E", past_positions: [{5, 5}] }
    end

    test "move 0, 0 to south should return 0, 0" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 0, 0 }, direction: "S" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 0, 0 }, direction: "S", past_positions: [{ 0, 0 }] }
    end

    test "move 0, 0 to west should return 0, 0" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 0, 0 }, direction: "W" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 0, 0 }, direction: "W", past_positions: [{ 0, 0 }] }
    end

    test "move 1, 1 to N should return 1, 2 if there's another rover in the position" do
        assert Mars.action(%Mars.Rover{ actions: ["M"], position: { 1, 1 }, direction: "N" }, [%Mars.Rover{ position: { 1, 2 } }], { 5, 5 }) == 
        %Mars.Rover{ actions: [], position: { 1, 1 }, direction: "N", past_positions: []  }
    end

    test "action should remove the first action" do
        assert Mars.action(%Mars.Rover{ actions: ["M", "L"], position: { 1, 1 }, direction: "N" }, [], { 5, 5 }) == 
        %Mars.Rover{ actions: ["L"], position: { 1, 2 }, direction: "N", past_positions: [{1, 1}] }
    end

    test "position_available? should return :ok if the position is available" do
        assert Mars.position_available?({ 1, 2 }, [%Mars.Rover{ position: { 1, 1 } }]) == { :ok, { 1, 2 } }
    end

    test "position_available? should return :error if the position is available" do
        assert Mars.position_available?({ 1, 1 }, [%Mars.Rover{ position: { 1, 1 } }]) == { :error, { 1, 1 } }
    end

    test "create_images should return rovers" do
        assert Mars.create_images([%Mars.Rover{}, %Mars.Rover{}], {0, 0}) == [%Mars.Rover{}, %Mars.Rover{}]
    end

end
