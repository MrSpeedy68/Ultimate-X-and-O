local ai = {}

local mylib = require("mylib")

ai.move = function(subBoard, currentBoardVal, board, firstTap, players, player)
    if firstTap then
        for k = 1, 9 do
            if board[k] == 0 then
                for kk = 1, 9 do
                    if subBoard[k][kk] == 0 then
                        return k, kk
                    end
                end
            end
        end
    else
        for k = 1, 9 do
            if subBoard[currentBoardVal][k] == 0 then
                return currentBoardVal, k
            end
        end
    end
end

return ai