local game = server.game()

local field = game:addField("Go")

local board =

field:add(new "game.go.Board" {}, 0, 0)

field:add(new "game.felt.Pile" {
    name = "white bowl";
    game = "go";
    x = -87, y = 0;
    type = "game.go.Piece";
    ctor = {
        name = "white stone";
    };
})

field:add(new "game.felt.Pile" {
    name = "black bowl";
    game = "go";
    x = 480, y = 480 - 75;
    type = "game.go.Piece";
    ctor = {
        name = "black stone";
    };
})
