local mylib = { }


-----------------------------------------------------------------------------------------
-- coordinate transformation funcitons
-----------------------------------------------------------------------------------------


function mylib.k2rc(k)
    local row = 1 + math.floor((k-1) / 3)
    local col = 1 + (k-1)%3
    return row, col
end


function mylib.rc2k(row, col)
    return (row-1)*3 + (col-1) + 1
end


-----------------------------------------------------------------------------------------
-- game logic functions
-----------------------------------------------------------------------------------------


function mylib.isRowWin(board)
	for r = 0,2 do
		if board[r*3+1]~=0 and board[r*3+1]==board[r*3+2] and board[r*3+2]==board[r*3+3] then
            return r+1
		end
	end
	return 0
end


function mylib.isColWin(board)
	for c = 1, 3 do
		if board[c]~=0 and board[c]==board[3+c] and board[3+c]==board[6+c] then
            return c
		end
	end
	return 0
end


function mylib.isDiagonalWin(board)
	return board[1]~=0 and board[1]==board[5] and board[5]==board[9]
end


function mylib.isAntiDiagonalWin(board)
	return board[3]~=0 and board[3]==board[5] and board[5]==board[7]
end


function mylib.isWin(board)
	return mylib.isRowWin(board)>0 or mylib.isColWin(board)>0 or mylib.isDiagonalWin(board) or mylib.isAntiDiagonalWin(board)
end


function mylib.isTie(board)
    for k = 1, 9 do
        if board[k]==0 then
            return false
        end
    end
    return true
end


return mylib