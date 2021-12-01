local ai = { }

local rng = require("rng")

local mylib = require("mylib")

ai.move = function(subBoard, currentBoardVal, board, firstTap, players, player)

    -- try to win if possible ...
    for k = 1, 9 do
        if subBoard[currentBoardVal][k] ==0 then
            subBoard[currentBoardVal][k] = players[player].value 
            if mylib.isWin(subBoard[currentBoardVal]) then
                subBoard[currentBoardVal][k] = 0
                return currentBoardVal , k
            end
            subBoard[currentBoardVal][k] = 0
        end
    end

    -- try to block a win if possible ...
        -- try to win if possible ...
    for k = 1, 9 do
        if subBoard[currentBoardVal][k] ==0 then
            subBoard[currentBoardVal][k] = players[player%2+1].value 
            if mylib.isWin(subBoard[currentBoardVal]) then
                subBoard[currentBoardVal][k] = 0
                return currentBoardVal, k
            end
            subBoard[currentBoardVal][k] = 0
        end
    end

    -- try to place in the center cell . . .
    -- center space (is on 4 possible winning lines) so always pick that if free
    if subBoard[currentBoardVal][5] == 0 then return currentBoardVal, 5 end

    -- try to place in a corner cell . . .
    -- corner space (is on 3 possible winning lines)
    local options  = {}
    for _, k in ipairs( {1,3,7,9} ) do
        if subBoard[currentBoardVal][k] == 0 then
            options[#options+1] = k
        end
    end

    if #options > 1 then
        return options[rng.random(#options)]
    end

    -- otherwise, place in a side cell (at random) ... at least one must be free
    options  = {}
    for _, k in ipairs( {2,4,6,8} ) do
        if subBoard[currentBoardVal][k] == 0 then
            options[#options+1] = k
        end
    end

    if #options > 1 then
        return options[rng.random(#options)]

    else
        print("WHF")
    end
end

return ai