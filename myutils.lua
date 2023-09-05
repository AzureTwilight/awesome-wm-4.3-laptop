
local screen = screen
local awful         = require("awful")
local naughty       = require("naughty")

local M = {}

M.reportMonitor = function (s)
   title = string.format("Monitor %s", s.index)
   monitorProps = string.format(
      "x: %s, y: %s\nh: %s, w: %s",
      s.geometry.x, s.geometry.y,
      s.geometry.height, s.geometry.width)
    naughty.notify({title = title,
                    text = monitorProps,
                    screen = s})
end

M.updateFocusWidget = function()
    for s in screen do
        s.focuswidget.checked = (s == awful.screen.focused())
    end
end


M.updateScreenList = function () 
   -- translate the physical index to build in index
   local myScreenIdx = {}
   -- translate built-in index to physical index
   local myScreenIdxReverse = {}

   local idxTable = {}
   local sortTable = {}
   for s in screen do
      sortTable[#sortTable+1] = s.geometry.x
      idxTable[s.geometry.x] = s.index
   end
   table.sort(sortTable)
   for k, v in pairs(sortTable) do
     myScreenIdx[k] = idxTable[v]
     myScreenIdxReverse[idxTable[v]] = k
   end

   -- Fill in the rest of monitors in case
   for k = #myScreenIdx + 1, 9 do
     myScreenIdx[k] = k
     myScreenIdxReverse[k] = k
   end

   for s in screen do
      M.reportMonitor(s)
   end

   for k, v in pairs(myScreenIdx) do
      monitorProps = string.format(
         "%d: %d",
         k, v)
   end

   return myScreenIdx, myScreenIdxReverse
   
end


return M
