-- Compile webide files
if file.exists("httpserver-compile.lc") then
   dofile("httpserver-compile.lc")
else
   dofile("httpserver-compile.lua")
end

if file.exists("startup.lua") then
   dofile("startup.lua")
end

-- Run httpserver
if file.exists("httpserver-start.lc") then
   dofile("httpserver-start.lc")
else
   dofile("httpserver-start.lua")
end