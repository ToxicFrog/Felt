do
end
do
	foo.bar()
	foo:bar()
	foo[bar]
	foo [[asf]]
end
do
	-- do return end
	--[[if foo then adf else]]
	--[==[ asdf
	]]
	]==]
	
		bash
	end
	if foo then
		asfd
	else
		fdsa
	end
	if foo then
		asdf
	elseif bar then
		fdsa
	else
		adfasg
	end
	while true do
		asdf
	end
	repeat
		asdf
	until bar
	foo {
		fdsaadf
		adf
	}
end

nil true false

local t = felt.newtable { w = 400, h = 400, name = "Chess" }
local board = new "felt.ImageToken" {
    face = "modules/chess/board.png";
    z=-1;
    name = "Chessboard";
    mixins = {
        { "board" };
        { "grid", 45, 45, 10, 10 };
    };
}

t:add(board, 10, 10)

for r,colour in ipairs { "w", "b" } do
    local function img(name)
        return "modules/chess/"..colour..name..".png"
    end
    local function name(name)
        return (colour == "b" and "Black " or "White ")..name
    end
    
    for x=10,360,45 do
        board:add(new "felt.ImageToken" {
                face = img "pawn";
                name = name "Pawn";
            }
            , x
            , colour == "b" and 55 or 280)
    end

    for i=0,1 do
        board:add(new "felt.ImageToken" {
            face = img "rook";
            name = name "Rook";
        }
        , 10 + (7*45)*i
        , colour == "b" and 10 or 325)
        
        board:add(new "felt.ImageToken" {
            face = img "knight";
            name = name "Knight";
        }
        , 55 + (5*45)*i
        , colour == "b" and 10 or 325)
        
        board:add(new "felt.ImageToken" {
            face = img "bishop";
            name = name "Bishop";
        }
        , 100 + (3*45)*i
        , colour == "b" and 10 or 325)
    end
    
    board:add(new "felt.ImageToken" {
        face = img "queen";
        name = name "Queen";
    }
    , 10 + 3 * 45
    , colour == "b" and 10 or 325)
        
    board:add(new "felt.ImageToken" {
        face = img "king";
        name = name "King";
    }
    , 10 + 4 * 45
    , colour == "b" and 10 or 325)
end

