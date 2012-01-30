local game = server.game()

game:addField("Captured Pieces")

local field = game:addField("Chess")

local board = new "game.chess.Board" {
    name = "chessboard";
}

field:add(board, 10, 10)

for r,colour in ipairs { "white", "black" } do
    -- create the ranks of pawns
    local pawn_y = colour == "black" and 55 or 280
    local y = colour == "black" and 10 or 325

    for x=10,360,45 do
        board:add(new "game.chess.Piece" { name = colour .. " pawn"; }
            ,x
            ,pawn_y)
    end

    -- and the officers
    for i=0,1 do
        board:add(new "game.chess.Piece" { name = colour .. " rook"; }
            ,10 + (7*45)*i
            ,y)
        
        board:add(new "game.chess.Piece" { name = colour .. " knight"; }
            ,55 + (5*45)*i
            ,y)
        
        board:add(new "game.chess.Piece" { name = colour .. " bishop"; }
            ,100 + (3*45)*i
            ,y)
    end

    board:add(new "game.chess.Piece" { name = colour .. " queen"; }
        ,10 + 3 * 45
        ,y)

    board:add(new "game.chess.Piece" { name = colour .. " king"; }
        ,10 + 4 * 45
        ,y)
end
