local super = class(..., "game.felt.Object")

-- coordinates, RELATIVE TO PARENT, of this object. Z is height: lower values are further "down".
x,y,z = 0,0,0

-- width and height of the object
w,h = 16,16

-- object name - used for pickup messages and the like
name = "(FIXME - nameless object)"

if not _DEBUG then
    function __tostring(self)
        if self.concealed and self.__tostring_concealed then
            return self:__tostring_concealed()
        end
        return self.name
    end
end

function __init(self, ...)
    super.__init(self, ...)

    for child in self:childrenBTF() do
        child.parent = self
    end
    
    self:initGraphics()
    self:initActions()
end

function initGraphics(self)
    self.qgraphics = QGraphicsRectItem(self.x, self.y, self.w, self.h)
    self.qgraphics:setBrush(QBrush(QColor(255, 0, 0)))
    self.qgraphics:setCacheMode("ItemCoordinateCache")
end

function initActions(self)
    if #self.actions > 0 then
        -- create context menu for actions
        self.qmenu = QMenu(tostring(self))

        -- each action gets an entry in the context menu
        for _,action in ipairs(self.actions) do
            -- set up the reverse map of action names
            self.actions[action[3]] = action

            -- if the action has a human-readable name, add it to the menu as well
            if action[1] then
                local qaction = self.qmenu:addAction(action[1])
                qaction:setData(QVariant(action[2]))
            end
        end

        -- and then when an entry in the menu is selected, we grab the method name from
        -- the associated action and tell the server to call that method
        self.qmenu:connect(Qt.SIGNAL "triggered(QAction*)", function(menu, action)
            print(menu, action, action:data():toString():toUtf8())
            self:send(action:data():toString():toUtf8(), QCursor.pos():x(), QCursor.pos():y())
        end)

        function self.qgraphics.contextMenuEvent(e)
            self.qmenu:popup(QCursor.pos())
        end
    end

    self.qgraphics:setAcceptHoverEvents(true)
    self.qgraphics:setFlag(QGraphicsItem.GraphicsItemFlag.ItemIsFocusable, true)

    local function buttonString(button)
        return button:match("(.*)Button"):lower()
    end

    local function modString(modifiers)
        table.sort(modifiers)
        if #modifiers == 1 then -- NoModifier
            return ""
        end

        return "_"..(table.concat(modifiers):gsub("NoModifier", ""):gsub("%l+Modifier", ""))
    end

    local function event(evt, ename)
        print(self, evt, ename)
        do return end
        if self.actions[ename] then
            print("", "sending")
            self:send(self.actions[ename][2], evt:pos():x(), evt:pos():y())
            evt:accept()
        elseif self.parent:isInstanceOf("game.felt.Field") or self == client.getHeld() then
            print("", "forwarding to background")
            if self.parent.actions[ename] then
                local pos = self.qgraphics:mapToScene(evt:pos())
                self.parent:send(self.parent.actions[ename][2], pos():x(), pos():y())
            end
        else
            print("", "ignoring")
            evt:ignore()
        end
    end

    function self.qgraphics.hoverEnterEvent(item, e)
        self.qgraphics:setFocus()
        event(e, "hover_enter")
        e:accept()
    end

    function self.qgraphics.hoverLeaveEvent(item, e)
        self.qgraphics:clearFocus()
        event(e, "hover_leave")
        e:accept()
    end

    function self.qgraphics.keyPressEvent(item, e)
        local ename = "key_" .. e:text():toUtf8() .. modString(e:modifiers())
        event(e, ename)
    end

    function self.qgraphics.mousePressEvent(item, e)
        -- if it's a left click AND we are holding an item, emit a drop event instead
        local ename
        if client.getHeld() and e:button() == "LeftButton" then
            ename = "drop" .. modString(e:modifiers())
        else
            ename = "mouse_" .. buttonString(e:button()) .. modString(e:modifiers())
        end
        event(e, ename)
    end

    function self.qgraphics.mouseDoubleClickEvent(item, e)
        local ename = "mouse_double_" .. buttonString(e:button()) .. modString(e:modifiers())
        event(e, ename)
    end
end

function show(self, parent)
    print("game::felt::Entity:show", self, parent)

    if parent then self.qgraphics:setParentItem(parent) end
    self:showChildren(self.qgraphics)
end

function showChildren(self, field)
    for child in self:childrenBTF() do
        print("", "game::felt::Entity:showChildren", child)
        child:show(self.qgraphics)
    end
end

--- returns an iterator over the children of this widget in back to front order
function childrenBTF(self)
    return coroutine.wrap(function()
        for i=#self.children,1,-1 do
            coroutine.yield(self.children[i])
        end
    end)
end
