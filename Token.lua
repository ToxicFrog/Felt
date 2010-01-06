local Token = require("Widget"):subclass "Token"

Token:defaults {
    name = "token";
}

function Token:click_left()
    felt.pickup(self)
    return true
end

function Token:dropped(x, y)
    felt.screen:event("drop", x, y, self)
end

return Token

