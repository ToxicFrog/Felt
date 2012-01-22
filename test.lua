require "qtcore"
require "qtgui"

local app = QApplication(1, arg)
local window = QTextEdit()

local menu = QMenu("test")
local action = QAction("test action", menu)
menu:addAction(action)

menu:connect("2triggered(QAction*)", print)

function window:mousePressEvent(e)
    menu:popup(QCursor.pos())
end

window:show()

while true do
    app.sendPostedEvents()
    app.processEvents()
end
