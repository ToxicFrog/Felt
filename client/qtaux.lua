-- aux functions for Qt

function Qt.SIGNAL(name)
    return "2"..name
end

function Qt.SLOT(name)
    return "1"..name
end

function Qt.super()
    error(SUPER)
end

function Qt.buttonString(button)
    return button:match("(.*)Button"):lower()
end

function Qt.modString(modifiers)
    table.sort(modifiers)
    if #modifiers == 1 then -- NoModifier
        return ""
    end

    return "_"..(table.concat(modifiers):gsub("NoModifier", ""):gsub("%l+Modifier", ""))
end
