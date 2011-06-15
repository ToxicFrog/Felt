suits = { "Clubs", "Diamonds", "Spades", "Hearts" }
names = { "Ace", "Two", "Three", "Four", "Five", "Six", "Seven",
    "Eight", "Nine", "Ten", "Jack", "Queen", "King" }

local deck = new "cards.Deck" {
	name = "Deck";
	w = 75;
	h = 107;
}

for _,suit in ipairs(suits) do
    for i,ord in ipairs(names) do
        name = ord.." of "..suit
        img = string.format("modules/cards/images/%s-%s-75.png"
            , suit:lower()
            , i >= 2 and i <= 10 and tostring(i)
              or ord:sub(1,1):lower())
        
        deck:add(new "cards.Card" {
        	face = img;
        	back = "modules/cards/images/back-blue-75-1.png";
        	name = name;
        })
    end
end

local field = new "felt.Field" {
	name = "Deck";
	w = deck.w + 16;
	h = deck.h + 16;
}

field:add(deck, 8, 8)
felt.game:addField(field)

do return end

deck = new "felt.Deck" (deck)

t:add(deck, 10, 10)
return t


