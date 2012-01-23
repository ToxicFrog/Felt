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
    
    print("new Entity")
end

function show(self, parent)
    print("game::felt::Entity:show", self, parent)
    
    self.qgraphics = QGraphicsRectItem(self.x, self.y, self.w, self.h)
    self.qgraphics:setBrush(QBrush(QColor(255, 0, 0)))
    
    if #self.actions > 0 then
        -- create context menu for actions
        self.qmenu = QMenu(tostring(self))
        
        for _,action in ipairs(self.actions) do
            local qaction = self.qmenu:addAction(action[1])
            qaction:setData(QVariant(action[2]))
            function qaction:clicked(...) print(self, ...) end
            print(qaction, qaction.clicked)
        end
        self.qmenu:connect(Qt.SIGNAL "triggered(QAction*)", function(menu, action)
            print(menu, action, action:data():toString():toUtf8())
            self:send(action:data():toString():toUtf8())
        end)
        --self.qmenu:connect(Qt.SIGNAL "triggered(QAction*)", self.qaction, Qt.SLOT "print()")
    end
    
    function self.qgraphics.mousePressEvent(e)
        print("game::felt::Entity:mousePressEvent", self, e)
        if self.qmenu then self.qmenu:popup(QCursor.pos()) end
    end
    
    self:showChildren(self.qgraphics)
end

function showChildren(self, field)
    for child in self:childrenBTF() do
        child:show(self.qgraphics)
        child.qgraphics:setParentItem(self.qgraphics)
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
