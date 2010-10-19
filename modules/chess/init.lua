
felt.game:addField(new "felt.Field" {
	name = "captured pieces";
	w = 100, h = 100;
})

local field = new "felt.Field" {
	name = "Chess";
	w = 400, h = 400;
}
felt.game:addField(field)

local board = new "felt.Board" {
	face = "modules/chess/board.png";
	name = "chessboard";
	z = -1;
	grid = {
		x = 10, y = 10;
		w = 45, h = 45;
	};
}

field:add(board, 10, 10)

for r,colour in ipairs { "w", "b" } do
    local function img(name)
        return "modules/chess/"..colour..name..".png"
    end
    local function name(name)
        return (colour == "b" and "black " or "white ")..name
    end
    
    -- create the ranks of pawns
    for x=10,360,45 do
        board:add(new "felt.ImageToken" {
                face = img "pawn";
                name = name "pawn";
            }
            , x
            , colour == "b" and 55 or 280)
    end

    -- and the officers
    for i=0,1 do
        board:add(new "felt.ImageToken" {
            face = img "rook";
            name = name "rook";
        }
        , 10 + (7*45)*i
        , colour == "b" and 10 or 325)
        
        board:add(new "felt.ImageToken" {
            face = img "knight";
            name = name "knight";
        }
        , 55 + (5*45)*i
        , colour == "b" and 10 or 325)
        
        board:add(new "felt.ImageToken" {
            face = img "bishop";
            name = name "bishop";
        }
        , 100 + (3*45)*i
        , colour == "b" and 10 or 325)
    end
    
    board:add(new "felt.ImageToken" {
        face = img "queen";
        name = name "queen";
    }
    , 10 + 3 * 45
    , colour == "b" and 10 or 325)
        
    board:add(new "felt.ImageToken" {
        face = img "king";
        name = name "king";
    }
    , 10 + 4 * 45
    , colour == "b" and 10 or 325)
end

