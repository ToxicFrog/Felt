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
    do return end
    -- currently disabled while I work on other parts of the pickup/drop infra; mouse tracking can wait
    --super.initActions(self)

    -- on receiving a mouse event, we need to forward it to our contained
    -- objects if we have any - we only handle it ourself if the user clicked
    -- on the background.
    -- FIXME: need to handle drop events!
    function self.qview.mousePressEvent(view, e)
        -- handle drops - before/after forwarding to superclass? How do we drop on the background?
        if view:itemAt(e:pos()) then
            error(SUPER) -- lqt special form to forward to superclass method
        end
        print("game::felt::Field:mousePressEvent", e)
    end

    function self.qview.enterEvent(view, e)
        if client.getHeld() then
            self.qscene:addItem(client.getHeld().qgraphics)
            client.getHeld().qgraphics:setVisible(true)
        end
        error(SUPER)
    end

    function self.qview.leaveEvent(view, e)
        if client.getHeld() then
            client.getHeld().qgraphics:setVisible(false)
        end
        error(SUPER)
    end

    function self.qview.mouseMoveEvent(view, e)
        if client.getHeld() then
            client.getHeld().qgraphics:setPos(self.qview:mapToScene(e:pos()))
        end
        error(SUPER)
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
