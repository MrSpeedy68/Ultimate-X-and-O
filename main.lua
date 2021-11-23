-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local rng = require("rng")
local colors = require("colorsRGB")
local mylib = require("mylib")
--local ai =
    -- require("first_space_player")
    -- require("random_impact_player")
    --require("minimax_player")

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local board = {} -- logic representation of game board
local subBoards = {}
local squares = {} -- game board buttons to deal with UI
local players = {
    {name="X", human=true, value=1, wins=0},
    {name="O", human=true, value=-1, wins=0},
}
local player = 1
local gameCount = 0
local state -- 'waiting', 'thinking' 'over'
local firstTap = true
local currentBoard

local gap = 6 -- gap between cells and margins
local size = (math.min(display.contentWidth, display.contentHeight) - 4*gap) / 3
local subsize = size /3.5

-- place background and center it
local bg = display.newImageRect(backGroup,"assets/images/background.png", 444, 794)
bg.x = display.contentCenterX
bg.y = display.contentCenterY

-- screen elements
local turnText -- display name of current player
local titleText --
local statsText
local gameOverBackground, gameOverText
local resetBoard, move, checkMove, checkSubMove


-----------------------------------------------------------------------------------------
-- audio setup
-----------------------------------------------------------------------------------------
local tapSound, winSound, buttonSound

audio.reserveChannels( 3 )

-- Reduce the overall volume of the channel
local bgMusic = audio.loadStream( "assets/audio/bgMusic.mp3" )

audio.setVolume( 0.4, { channel=1 } )
audio.setVolume( 0.8, { channel=2 } )
audio.setVolume( 0.9, { channel=3 } )
-- audio.play( bgMusic, { channel=1, loops=-1 } )


-----------------------------------------------------------------------------------------
-- game ui and playing functions
-----------------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)


-- function to draw a line from (x1,y2) to (x2,y2) using center as origin
-- with color `color` (default black) and line width `width` (default 8)
local function drawLine(x1, y1, x2, y2, color, width)
    --print("Line from (".. x1..","..y1..") to (".. x2..","..y2..")")
	local line = display.newLine(backGroup, 
		display.contentCenterX + x1*size,  display.contentCenterY + y1*size, 
		display.contentCenterX + x2*size,  display.contentCenterY + y2*size 
	)

    color = color or "black"
	line:setStrokeColor(colors.RGB(color))

    width = width or 8
    line.strokeWidth = width
end


local function displayMessage(message)
	gameOverBackground = display.newRect(mainGroup, 0, 0, display.actualContentWidth, display.actualContentHeight)
    gameOverBackground.x = display.contentCenterX
    gameOverBackground.y = display.contentCenterY
    gameOverBackground:setFillColor(0)
    gameOverBackground.alpha = 0.5

    gameOverText = display.newText(mainGroup, message, 100, 200, "assets/fonts/Bangers.ttf", 40)
    gameOverText.x = display.contentCenterX
    gameOverText.y = display.contentCenterY - size
    gameOverText:setFillColor(colors.RGB("white"))
    timer.performWithDelay( 2500, resetBoard )
end


local function nextPlayer(value)

    player = value or (player%2 + 1)

    turnText.text = players[player].name .. "'s Turn"
    turnText.x = display.contentCenterX + (player*2-3)*size

    state = players[player].human and 'waiting' or 'thinking'

    if state == 'thinking' then
        local result = ai.move(board, players, player)
        move(result)
    end
end


move = function(k, kk)
    -- get square linked to current event
    local square = squares[k]
    local subSquare = squares[k][kk]

    local filename = "assets/images/"..players[player].name..".png"
    local symbol = display.newImageRect(mainGroup, filename, subsize-4*gap *2, subsize-4*gap *2)

    local subX, subY = mylib.k2xy(kk) 
    print("sub X: " .. subX)
    print("sub Y: " .. subY)
    symbol.x = square.rect.x + (subX * 30)
    symbol.y = square.rect.y + (subY * 30)
    square.symbol = symbol
    board[k] = players[player].value

    -- if mylib.isWin(board) then
    --     state = "over"
    --     gameCount = gameCount + 1
    --     players[player].wins = players[player].wins + 1
    --     displayMessage("Player "..players[player].name.." Wins")
    --     audio.play( winSound, { channel=3} )
    -- elseif mylib.isTie(board) then
    --     state = "over"
    --     gameCount = gameCount + 1
    --     displayMessage("Game Tied")
    -- else
        nextPlayer()
    -- end
end

local function makeSmallBoards(event) 

end

local function checkMainBoard(event)
    print(players[player].name .."'s move at square " .. event.target.k)

    --local row, col = mylib.k2rc(squares[event.target.k][4].kk)

    if not firstTap and event.target.k == currentBoard then -- Check that the current move was done on the appropriate subboard
        checkSubMove(event)
    end
    if firstTap then
        currentBoard = event.target.k
        firstTap = false
    end


end

checkSubMove = function(event) 
    print(players[player].name .."'s move at MainBoard " .. event.target.k)

    local x = math.floor((event.x-event.target.x) / (size/3) +0.5) + 2
    --print ("X : "..x )
    local y = math.floor((event.y-event.target.y) / (size/3) +0.5) + 2
    --print ("Y : "..y )
    local kk = mylib.rc2k(y,x)
    print(players[player].name .."'s move at SubBoard " .. kk)

    -- return if current square is not-empty
    if board[event.target.k] ~= 0 and board[event.target.k][kk] ~= 0 then
        print("\t cannot move to non-empty square")
        return false
    end

    -- return if current player is non-human
    if state ~= 'waiting' then
        print("\t computer playing")
        return
    end

    audio.play( tapSound, { channel=2})

    -- place valid move
    currentBoard = kk
    move(event.target.k, kk)
end


checkMove = function(event)

    print(players[player].name .."'s move at square " .. event.target.k)
    print("Event x coord"..event.x.."Event y coord"..event.y)

    -- return if current square is not-empty
    if board[event.target.k] ~= 0 then
        print("\t cannot move to non-empty square")
        return false
    end

    -- return if current player is non-human
    if state ~= 'waiting' then
        print("\t computer playing")
        return
    end

    audio.play( tapSound, { channel=2})

    -- place valid move
    move(event.target.k)

end


resetBoard = function()
    if gameOverBackground~=nil then
        display.remove(gameOverBackground)
        gameOverText.text = ""
        for _,square in ipairs(squares) do
            display.remove(square.symbol)
            square.symbol = nil
        end
    end

    local tieCount = gameCount - players[1].wins - players[2].wins
    local message = string.format("Games: %3d    %s: %d    %s: %d    tie: %d", gameCount, players[1].name, players[1].wins, players[2].name, players[2].wins, tieCount)
    statsText.text = message

    -- logic representation of game
    board = {}
    for k = 1, 9 do
        board[k] = 0
    end
    nextPlayer(1)
end

local function drawBoard() 
    --drawLine(x1, y1, x2, y2, color, width)

    --drawLine(-7/5, -7/5, -7/5, -3/5, "grey", 2)
    for x = -1, 1 do
        for y = -1, 1 do
            drawLine(-1/2 / 3.5 + x, -3/2 / 3.5 + y, -1/2 / 3.5 + x,  3/2 / 3.5 + y, "grey", 2)
            drawLine( 1/2 / 3.5 + x, -3/2 / 3.5 + y,  1/2 / 3.5 + x,  3/2 / 3.5 + y, "grey", 2)
            drawLine(-3/2 / 3.5 + x, -1/2 / 3.5 + y,  3/2 / 3.5 + x, -1/2 / 3.5 + y, "grey", 2)
            drawLine(-3/2 / 3.5 + x,  1/2 / 3.5 + y,  3/2 / 3.5 + x,  1/2 / 3.5 + y, "grey", 2)
        end
    end



    -- for k =1,9 do
    --     for j = 1, 9 do
    --         drawLine(-3/4 * k / 2, -3/2 * j / 2, -3/4 * k / 2,  3/2 * j /2, "grey", 2)
    --         drawLine(-1/2, -3/2, -1/2,  3/2)
    --     end
    -- end
end


local function createBoard()

    -- center the board vertically and maximum width

    drawLine(-1/2, -3/2, -1/2,  3/2)
    drawLine( 1/2, -3/2,  1/2,  3/2)
    drawLine(-3/2, -1/2,  3/2, -1/2)
    drawLine(-3/2,  1/2,  3/2,  1/2)

    drawBoard()

    squares = {}

    -- for k = 1, 9 do
    --     local row, col = mylib.k2rc(k)
    --     local x = display.contentCenterX + (col-4/2)*size
    --     local y = display.contentCenterY + (row-4/2)*size
    --     local rect = display.newRect( uiGroup, x, y, size - gap, size - gap)
    --     rect.k = k
    --     rect.alpha = 0.1
    --     rect:addEventListener( "tap", checkMove )
    --     squares[k] = {value=0, rect=rect}
    -- end

    for k = 1, 9 do
        local row, col = mylib.k2rc(k)
        local x = display.contentCenterX + (col-4/2)*size
        local y = display.contentCenterY + (row-4/2)*size
        local rect = display.newRect( uiGroup, x, y, size - gap, size - gap)
        rect.k = k
        rect.alpha = 0.1
        rect:addEventListener( "tap", checkMainBoard )
        squares[k] = {value=0, rect=rect}
        for j = 1,9 do
            squares[k][j] = {value=0, kk=j}
        end
        -- for j = 1,9 do
        --     for x = -99, 99, 99 do
        --         for y = -99, 99, 99 do
        --             local row, col = mylib.k2rc(j)
        --             local x = display.contentCenterX + (col-4/2)*subsize + x
        --             local y = display.contentCenterY + (row-4/2)*subsize + y
        --             local rect = display.newRect( uiGroup, x, y, subsize - gap, subsize - gap)
        --             rect.k = k
        --             rect.alpha = 0.1
        --             rect:addEventListener( "tap", checkMainBoard )
        --             squares[k] = {value=0, rect=rect}
        --             squares[k][j] = {value=0, kk=j}
        --         end
        --     end
        -- end
    end

    turnText = display.newText( mainGroup, "", 0, 0, "assets/fonts/Bangers.ttf", 24)
	turnText:setFillColor( 0, 0, 0 )
    turnText.x = display.contentCenterX - 90
    turnText.y = display.contentCenterY + 230

    titleText = display.newText( mainGroup, "X and O", 0, 0, "assets/fonts/Bangers.ttf", 40)
	titleText:setFillColor( 0, 0, 0 )
    titleText.x = display.contentCenterX
    titleText.y = 0

    statsText = display.newText( mainGroup, "", 0, 0, "assets/fonts/Bangers.ttf", 20)
	statsText:setFillColor( 0, 0, 0 )
    statsText.x = display.contentCenterX
    statsText.y = 0.5*size

    tapSound = audio.loadSound("assets/audio/tapSound.mp3")
    buttonSound = audio.loadSound("assets/audio/buttonSound.mp3")
    winSound = audio.loadSound("assets/audio/winSound.mp3")

    resetBoard()
end

createBoard()