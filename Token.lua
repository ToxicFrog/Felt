local Token = require("Widget"):subclass "Token"

Token:defaults {
    name = "token";
}

function Token:click_left()
    felt.pickup(self)
end

function Token:click_right()
    print("token clicked on", self)
end

return Token

