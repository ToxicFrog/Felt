local super = class(..., "game.felt.Entity")

zoom = 1

function initGraphics(self)
    self.qscene = QGraphicsScene()
    self.qview = QGraphicsView(self.qscene)
    self.qview:setBackgroundBrush(QBrush(QColor(0, 128, 0)))
    self.qview:setHorizontalScrollBarPolicy("ScrollBarAlwaysOff")
    self.qview:setVerticalScrollBarPolicy("ScrollBarAlwaysOff")
    self.qview:setMouseTracking(true)

    -- add all objects contained in this field
    self:showChildren()
    
    self.qview:show()
end

function initActions(self)
    if self:initActionsMenu() then
        function self.qview.contextMenuEvent(e)
            self.qmenu:popup(QCursor.pos())
        end
    end

    for k,f in pairs(self.events) do
        self.qscene[k] = function(...) return f(self, ...) end
    end
end

function showChildren(self)
    for child in self:childrenBTF() do
        self.qscene:addItem(child.qgraphics)
        child:show(nil)
    end
end

function trackHeldItem(self, enable)
    self.qview:setMouseTracking(enable)
end

function add(self, child)
    child.parent = self
    table.insert(self.children, child)
    self.qscene:addItem(child.qgraphics)
end

events = {}

-- on receiving a mouse event, we need to forward it to our contained
-- objects if we have any - we only handle it ourself if the user clicked
-- on the background.
function events.mousePressEvent(self, scene, evt)
    if scene:itemAt(evt:scenePos()) then
        return Qt.super()
    end

    -- we have to override super.events.mousePressEvent in its entirety rather than just forwarding to it
    -- because for some reason evt:pos() is always (0,0) in this case; we need evt:scenePos()
    -- if it's a left click AND we are holding an item, emit a drop event instead
    local ename
    if evt:button() == "LeftButton" and client.me().held then
        ename = "drop" .. Qt.modString(evt:modifiers())
    else
        ename = "mouse_" .. Qt.buttonString(evt:button()) .. Qt.modString(evt:modifiers())
    end
    if self:event(ename, evt:scenePos():x(), evt:scenePos():y()) then
        evt:accept()
    end
end

function events.wheelEvent(self, scene, evt)
    self.qview:scale(1/self.zoom, 1/self.zoom)
    if e:delta() > 0 then
        self.zoom = math.min(8/1, self.zoom*(2^0.5))
    else
        self.zoom = math.max(1/8, self.zoom/(2^0.5))
    end
    self.qview:scale(self.zoom, self.zoom)
end

function events.keyPressEvent(self, scene, evt)
    if scene:focusItem() then
        return Qt.super()
    else
        return super.events.keyPressEvent(self, scene, evt)
    end
end
