local super = class(..., "game.felt.Entity")

function initGraphics(self)
    self.qscene = QGraphicsScene()
    self.qview = QGraphicsView(self.qscene)
    self.qview:setBackgroundBrush(QBrush(QColor(0, 128, 0)))

    -- add all objects contained in this field
    self:showChildren()
    
    self.qview:show()
end

function initActions(self)
    -- on receiving a mouse event, we need to forward it to our contained
    -- objects if we have any - we only handle it ourself if the user clicked
    -- on the background.
    -- FIXME: need to handle drop events!
    function self.qview.mousePressEvent(view, e)
        if view:itemAt(e:pos()) then
            error(SUPER) -- lqt special form to forward to superclass method
        end
        print("game::felt::Field:mousePressEvent", e)
    end

    self.qview:setMouseTracking(true)
    function self.qview.mouseMoveEvent(view, e)
        -- FIXME: display held object, if any

    end

end

function showChildren(self)
    print("felt::game::Field:showChildren")
    for child in self:childrenBTF() do
        self.qscene:addItem(child.qgraphics)
        child:show(nil)
    end
end
