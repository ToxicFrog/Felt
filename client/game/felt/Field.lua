local super = class(..., "game.felt.Entity")

function __init(self, ...)
    super.__init(self, ...)
    
    self:init_ui()
end

function init_ui(self)
    self.qscene = QGraphicsScene()
    self.qscene:setSceneRect(-100, -100, 200, 200)
    
    self.qview = QGraphicsView(self.qscene)
    self.qview:setBackgroundBrush(QBrush(QColor(0, 128, 0)))

    --[[    
    self.view:setMouseTracking(true)
    function self.view:mouseMoveEvent(e)
        --print("mme", e:x(), e:y())
    end
    --]]
    
    -- on receiving a mouse event, we need to forward it to our contained
    -- objects if we have any - we only handle it ourself if the user clicked
    -- on the background.
    function self.qview.mousePressEvent(view, e)
        if view:itemAt(e:pos()) then
            error(SUPER) -- lqt special form to forward to superclass method
        end
        print("game::felt::Field:mousePressEvent", e)
    end

    -- add all objects contained in this field
    self:showChildren()
    
    self.qview:show()
end

function showChildren(self)
    print("felt::game::Field:showChildren")
    for child in self:childrenBTF() do
        child:show(self.qscene)
        self.qscene:addItem(child.qgraphics)
    end
end
