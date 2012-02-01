@ECHO OFF

set PATH=bin;%PATH%

set HOST=localhost
set PORT=8088
set NAME=player

bin\lua.exe client.lua host=%HOST% port=%PORT% name=%NAME%
pause
