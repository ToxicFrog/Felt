-- this file contains the routines for the initial windows that appear
-- when felt is started
-- in this state the user can choose whether to join or host a game, or quit
-- FIXME need some way to show/hide windows without destroying them

local mainmenu,joingame,hostgame
local show_mainmenu,show_joingame,show_hostgame

local function test()
	felt.background = new "Table" {
		name = "Background";
		z = -math.huge;
		x = 0, y = 0;
		w = love.graphics.getWidth(), h = love.graphics.getHeight();
		menu = felt.menu
	}
	
	felt.screen:add(felt.background)
	
	
	-- create the grasping hand
	felt.hand = new "Hand" {}
	felt.screen:add(felt.hand)
end


function show_mainmenu()
    mainmenu = new "PopupWindow" {
        buttons = {
            "Join Game", function() mainmenu:destroy(); show_joingame(); end;
            "Host Game", function() mainmenu:destroy(); show_hostgame(); end;
            "Quit", function() mainmenu:destroy(); love.quit(); end;
        };
    }
    felt.screen:add(mainmenu)
end

function show_joingame()
    joingame = new "PopupWindow" {
        'Host', 'localhost';
        'Port', '8008';
        'Password', '';
        buttons = {
            "Join Game", function(win)
                -- client.connect(...)
                print(win:get "Host", win:get "Port", win:get "Password")
                --win:destroy()
            end;
            "Cancel", function(win)
                win:destroy()
                show_mainmenu()
            end;
        };
    }
    felt.screen:add(joingame)
end

function show_hostgame()
    hostgame = new 'PopupWindow' {
        'Port', '8008';
        'Password', '';
        buttons = {
            "Host Game", function(win)
                -- server.start(tonumber(win:get "Port"), win:get "Password")
                -- client.connect("localhost", tonumber(win:get "Port"), win:get "Password")
                print(win:get "Port", win:get "Password")
                test()
                win:destroy()
            end;
            "Cancel", function(win)
                win:destroy()
                show_mainmenu()
            end;
        };
    }
    felt.screen:add(hostgame)
end

show_mainmenu()

