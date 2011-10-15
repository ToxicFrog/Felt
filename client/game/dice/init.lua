local field = new "felt.Field" {
	name = "Dice";
	w = 100, h = 20;
}
felt.game:addField(field)

field:add(new "felt.Die" {
	faces = { "modules/dice/1.png", "modules/dice/2.png" };
	facenames = { "first", "second" };
	name = "test die";
},0,0)
