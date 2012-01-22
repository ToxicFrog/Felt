local super = class(..., "game.felt.Object")

-- coordinates, RELATIVE TO PARENT, of this object. Z is height: lower values are further "down".
x,y,z = 0,0,0

-- width and height of the object
w,h = 16,16

-- object name - used for pickup messages and the like
name = "(FIXME - nameless object)"

_CLASS._DEBUG = true

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
        self.qaction = QObject()
        self.qaction:__addmethod("print()", function(...) print("sig", ...) end)
        for _,action in ipairs(self.actions) do
            --[[
            local qaction = QAction(action[1], self.qmenu)
            self.qmenu:addAction(qaction)
            qaction:connect(Qt.SIGNAL "triggered()",
                function(...)
                    print(...)
                end)
            --]]
            --function self.qmenu:triggered(...) print(...) end
            self.qmenu:addAction(action[1])
        end
        self.qmenu:connect(Qt.SIGNAL "triggered(QAction*)", print)
        --self.qmenu:connect(Qt.SIGNAL "triggered(QAction*)", self.qaction, Qt.SLOT "print()")
    end
    
    function self.qgraphics.mousePressEvent(e)
        print("game::felt::Entity:mousePressEvent", self, e)
        print(debug.traceback())
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
