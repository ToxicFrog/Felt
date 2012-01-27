coroutine.resume(coroutine.create(function()
    require "qtcore"
    require "qtgui"

    local app = QApplication(1, arg)
    
    local window
    window = QPushButton("click me")
    
    window:connect("2clicked()", print)
    window:show()
    
    app.exec()
end))
