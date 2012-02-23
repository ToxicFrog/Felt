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

function event(self, ename, x, y)
    if self.actions[ename] then
        self:send(self.actions[ename][2], x, y)
        return true
    end
    return false
end

function initGraphics(self)
    -- the server is meant to associate two fields with each object, a "game" and a "face"
    -- the game tells us which game box the piece came from; the face is a hint as to what it should look like
    -- together, these tell us how it should be rendered, by default - share/<game>/<face>.png
    -- if game is unset, or if there is no such file, we fall back to eye-searing magenta.
    local path = "share/" .. (self.game or "") .. "/" .. (self.face or self.name or "") .. ".png"

    if not self.game or not io.exists(path) then
        print("Can't find", path, "using default graphics")
        self.qgraphics = QGraphicsRectItem(self.x, self.y, self.w, self.h)
        self.qgraphics:setBrush(QBrush(QColor(255, 0, 255)))
    else
        self.qgraphics = QGraphicsPixmapItem(QPixmap(path))
        self.qgraphics:setPos(self.x, self.y)
    end

    self.qgraphics:setCacheMode("ItemCoordinateCache")
end

function initActionsMenu(self)
    if #self.actions > 0 then
        -- create context menu for actions
        self.qmenu = QMenu(tostring(self))

        -- each action gets an entry in the context menu
        for _,action in ipairs(self.actions) do
            -- set up the reverse map of action names
            for i=3,#action do
                self.actions[action[i]] = action
            end

            -- if the action has a human-readable name, add it to the menu as well
            if action[1] then
                local qaction = self.qmenu:addAction(action[1])
                qaction:setData(QVariant(action[2]))
            end
        end

        -- and then when an entry in the menu is selected, we grab the method name from
        -- the associated action and tell the server to call that method
        self.qmenu:connect(Qt.SIGNAL "triggered(QAction*)", function(menu, action)
            self:send(action:data():toString():toUtf8(), QCursor.pos():x(), QCursor.pos():y())
        end)

        return self.qmenu
    end
end

function initActions(self)
    if self:initActionsMenu() then
        function self.qgraphics.contextMenuEvent(e)
            self.qmenu:popup(QCursor.pos())
        end
    end

    self.qgraphics:setAcceptHoverEvents(true)
    self.qgraphics:setFlag(QGraphicsItem.GraphicsItemFlag.ItemIsFocusable, true)

    for k,f in pairs(self.events) do
        self.qgraphics[k] = function(...) return f(self, ...) end
    end
end

function show(self, parent)
    if parent then self.qgraphics:setParentItem(parent) end
    self:showChildren(self.qgraphics)
end

function showChildren(self, field)
    for child in self:childrenBTF() do
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

function add(self, child)
    child.parent = self
    table.insert(self.children, child)
    self.qgraphics:scene():addItem(child.qgraphics)
    child.qgraphics:setParentItem(self.qgraphics)
end

function remove(self, child)
    child.parent = nil
    for i=1,#self.children do
        if self.children[i] == child then
            table.remove(self.children, i)
            return
        end
    end
end

-- relocate an entity
function moveto(self, parent, x, y)
    if parent and self.parent and self.parent ~= parent then
        self.parent:remove(self)
    end

    self.x = x or self.x
    self.y = y or self.y
    self.qgraphics:setPos(self.x, self.y)

    if parent and self.parent ~= parent then
        parent:add(self)
    end

    self.parent = parent
end

-- called to remove the object from the game. By the time this is called, the object and all
-- of its children have already been deleted from the server, and the object has been removed
-- from the scene; we just need to remove the Qt half of it.
function delete(self)
    assert(self.parent == nil)

    if self.qgraphics:scene() then
        self.qgraphics:scene():removeItem(self.qgraphics)
    end
end

events = {}

function events.hoverEnterEvent(self, item, evt)
    item:setFocus()
    self:event("hover_enter", 0, 0)
    evt:accept()
end

function events.hoverLeaveEvent(self, item, evt)
    item:clearFocus()
    self:event("hover_leave", 0, 0)
    evt:accept()
end

function events.keyPressEvent(self, item, evt)
    local ename = "key_" .. evt:text():toUtf8() .. Qt.modString(evt:modifiers())
    if self:event(ename, 0, 0) then
        evt:accept()
    end
end

function events.mousePressEvent(self, item, evt)
    -- if it's a left click AND we are holding an item, emit a drop event instead
    local ename
    if evt:button() == "LeftButton" and client.me().held then
        ename = "drop" .. Qt.modString(evt:modifiers())
    else
        ename = "mouse_" .. Qt.buttonString(evt:button()) .. Qt.modString(evt:modifiers())
    end
    if self:event(ename, evt:pos():x(), evt:pos():y()) then
        evt:accept()
    end
end

function events.mouseDoubleClickEvent(self, item, evt)
    local ename = "mouse_double_" .. Qt.buttonString(evt:button()) .. Qt.modString(evt:modifiers())
    if self:event(ename, evt:pos():x(), evt:pos():y()) then
        evt:accept()
    end
end
