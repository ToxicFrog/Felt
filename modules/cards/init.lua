suits = { "Clubs", "Diamonds", "Spades", "Hearts" }
names = { "Ace", "Two", "Three", "Four", "Five", "Six", "Seven",
    "Eight", "Nine", "Ten", "Jack", "Queen", "King" }

local t = new "Table" { w = 95, h = 127, name = "Cards" }

local deck = {
    name = "Deck";
}


for _,suit in ipairs(suits) do
    for i,ord in ipairs(names) do
        name = ord.." of "..suit
        img = string.format("modules/cards/images/%s-%s-75.png"
            , suit:lower()
            , i >= 2 and i <= 10 and tostring(i)
              or ord:sub(1,1):lower())
        
        table.insert(deck, new "felt.ImageToken" {
            face = img;
            back = "modules/cards/images/back-blue-75-1.png";
            name = name;
        })
    end
end

deck = new "felt.Deck" (deck)

t:add(deck, 10, 10)
return t


