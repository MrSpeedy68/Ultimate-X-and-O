local ai = {}

local mylib = require("mylib")

ai.move = function(board, players, player)
    for k = 1, 9 do
        if board[k] == 0 then
            return k
        end
    end
end

return ai