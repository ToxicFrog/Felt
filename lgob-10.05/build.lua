#! /usr/bin/env lua

-- Usage    : ./build [destdir [options]]
-- Example  : ./build /my/dir "AMD64=1 DEBUG=1"

local lfs = require('lfs')
local sf = string.format
local function ex(cmd,...) cmd = sf(cmd,...) print(cmd) os.execute(cmd) end
local function cd(dir) print('cd ' .. dir) lfs.chdir(dir) end

local dest      = arg[1] or '/usr/local'
local opts      = arg[2] or ''
local modules   = {
    'codegen', 'common', 'gobject', 'loader', 'cairo', 'gdk', 'gtk',
    'pango', 'pangocairo', 'vte', 'webkit', 'atk', 'gstreamer', 'gtkspell',
    'gtksourceview', 'goocanvas', 'poppler', 'clutter', 'cluttergtk'
}

for i, m in ipairs(modules) do
    print(sf('\n\n**** %s ****\n', m))
    cd(m)
    ex('make %s DESTDIR=%s', opts, dest)
    ex('make install %s DESTDIR=%s', opts, dest)
    ex('make clean')
    cd('..')
end
