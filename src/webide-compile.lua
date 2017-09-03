-- webide-compile.lua
-- Based on nodemcu-httpserver httpserver-compile.lua

local compileAndRemoveIfNeeded = function(f)
   if file.open(f) then
      file.close()
      print('Compiling:', f)
      node.compile(f)
      file.remove(f)
      collectgarbage()
   end
end

local webideFiles = {
   'file-api.lua',
   'webide-compile.lua',
   'webide-websocket.lua',
}
for i, f in ipairs(webideFiles) do compileAndRemoveIfNeeded(f) end

compileAndRemoveIfNeeded = nil
webideFiles = nil
collectgarbage()
