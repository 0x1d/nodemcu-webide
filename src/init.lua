-- Compile webide files
if file.exists("webide-compile.lc") then
   dofile("webide-compile.lc")
else
   dofile("webide-compile.lua")
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