local ai = { }

local rng = require("rng")
local mylib = require("mylib")

WON = 100

-- visible to game so that it modified by user
ai.maxDepth = 11

-- compute a score for current game state
function ai.eval(board)
    return 0
end


-- recursive function to perform minimax search
-- returns score,move
function ai.search(board, players, player, depth)

    local debug = false
    local bestScore = -math.huge
    local bestMove = 1

    depth = depth or 1
    local indent = string.rep("  ", depth)

    if debug then print(indent .. "SEARCHING at depth "..depth .." as PLAYER "..players[player].name) end

    -- check if win
    if mylib.isWin(board) then
        return 100
    end

    -- check if tie
    if mylib.isTie(board) then
        return 0
    end
    -- check if search reached max depth
    if depth == ai.maxDepth then
        return 0
    end

    -- iterate over all possible move
    for k = 1, 9 do
        -- place piece 
        if board[k] == 0 then 
            board[k] = players[player].value 
        -- get score from recursive call to ai.search, switching players
            score,_ = ai.search(board, players, player%2+1, depth+1)
        -- remove piece
            board[k] = 0
        -- if score better than found to date update best score and best move
            if score > bestScore then
                bestScore = score
                bestMove = k
            end
        end
    end

    if debug then print(indent .. "OPTIMAL MOVE "..bestMove .. " with score " ..bestScore) end

    -- return best score and best move
    return -bestScore, bestMove
end


-- public interface to minimax search function
ai.move = function(board, players, player)

    local _, move = ai.search(board, players, player)

    return move
end

return ai