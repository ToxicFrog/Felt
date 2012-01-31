local super = class(..., "game.felt.Entity")

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

    -- on receiving a mouse event, we need to forward it to our contained
    -- objects if we have any - we only handle it ourself if the user clicked
    -- on the background.
    function self.qview.mousePressEvent(view, e)
        if view:itemAt(e:pos()) then
            error(SUPER) -- lqt special form to forward to superclass method
        end

        -- if it's a left click AND we are holding an item, emit a drop event instead
        local ename
        if e:button() == "LeftButton" and client.me().held then
            ename = "drop" .. modString(e:modifiers())
        else
            ename = "mouse_" .. buttonString(e:button()) .. modString(e:modifiers())
        end
        local pos = view:mapToScene(e:pos())
        self:event(e, ename, false, pos:x(), pos:y())
    end
end

function showChildren(self)
    print("felt::game::Field:showChildren")
    for child in self:childrenBTF() do
        self.qscene:addItem(child.qgraphics)
        child:show(nil)
    end
end

function trackHeldItem(self, enable)
    print(self, "tracking of held items is now", enable)
    self.qview:setMouseTracking(enable)
end

function add(self, child)
    child.parent = self
    table.insert(self.children, child)
    self.qscene:addItem(child.qgraphics)
    print("add child to background:", child, child.qgraphics, child.qgraphics:parentItem())
end

