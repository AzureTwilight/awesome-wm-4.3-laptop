-- Offer functions related to pakcage
local screen = screen
local gears         = require("gears")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local os = os
local next = next
local math = math
local table = table

local M = {}


M.init = function()
   M.filelist = {}
   M.showDesktopStatus = false
   M.wallpaperMode = "max"
   M.icon = beautiful.refreshed
   M.datebaseUpdateLastTime = os.time()
   M.UPDATE_DATABASE_INTERVAL = 43200 -- 12h
   math.randomseed(os.time())
   
   local toggleMenu = {}
   if type(beautiful.wallpaper) == "table" then
      for idx, val in ipairs(beautiful.wallpaper) do
         table.insert(toggleMenu,
                      {"[Gallery] " .. val[1], function() M.toggleMode(idx) end})
      end
      M.wallpaperPath = beautiful.wallpaper[1][2]
      M.wallpaperMode = beautiful.wallpaper[1][3]
   else
      M.wallpaperPath = beautiful.wallpaper
   end -- if type(beautiful.wallpaper)
   
   M.menu = {
      { "Refresh Wallpaper", function() M.refresh() end},
      { "Update Wallpaper Files", function() M.updateFilelist() end},
      { "Change Wallpaper Inteval", function() M.changeWallpaperInteval() end},
      { "Toggle Wallpaper Gallery", toggleMenu}}

   M.updateFilelist(true)
   M.timer = gears.timer {
      timeout = 900,
      call_now = false,
      autostart = false,
      callback = function() M.refresh() end}
   M.timer:start()

end -- M.init

M.changeWallpaperInteval = function()
    awful.prompt.run {
        prompt       = '<b>Wallpaper Inteval (sec): </b>',
        text         = tostring(M.timer.timeout),
        bg_cursor    = '#ff0000',
        -- To use the default rc.lua prompt:
        textbox      = mouse.screen.mypromptbox.widget,
        exe_callback = function(input)
            if not input or #input == 0 then input = 900 end
            naughty.notify{ text = 'Set Wallpaper Inteval: '.. input }
            M.timer.timeout = input
            M.timer:again()
        end
    }
end

M.setWallpaper = function(s)
   
   s.wallpaper = nil
   if type(M.wallpaperPath) == "function" then
      s.wallpaper = M.wallpaperPath(s)
   else
      if (M.wallpaperPath:sub(-1) == "/") then
         if next(M.filelist) ~= nil then
            s.wallpaper = M.filelist[math.random(#M.filelist)] 
         end
      else
         s.wallpaper = M.wallpaperPath
      end
   end -- if type(beautiful.wallpaper)
   
   if s.wallpaper ~= nil then
      
      naughty.notify(
         { title  = "Wallpaper Refreshed",
           text   = "Filename:" .. s.wallpaper .. '\nPath:' .. M.wallpaperPath,
           icon   = M.icon, icon_size = 64, screen = s})
      
      if M.wallpaperMode == "fit" then
         gears.wallpaper.fit(s.wallpaper, s)
      elseif M.wallpaperMode == "max" then
         gears.wallpaper.maximized(s.wallpaper, s)
      elseif M.wallpaperMode == "auto" then
         awful.spawn.easy_async_with_shell(
            "identify " .. s.wallpaper,
            function(out)
               local imgw, imgh = string.match(out, " (%d+)x(%d+) ")
               
               local imgratio = imgw / imgh
               local ratio = s.geometry.width / s.geometry.height
               
               local wallFunc
               
               if math.abs( (imgratio / ratio) - 1) > 0.4 then
                  wallFunc = gears.wallpaper.fit
               else
                  wallFunc = gears.wallpaper.maximized
               end
               wallFunc(s.wallpaper, s)
         end)
      end -- if M.wallpaperMode
      
   end
end

M.updateFilelist = function(doRefresh)
   
   naughty.notify({ title = "Updating wallpaper database",
                    text  = "Folder: " .. M.wallpaperPath,
                    icon  = M.icon, icon_size = 64})
   M.filelist = {}
   awful.spawn.easy_async(
      "find -L " .. M.wallpaperPath .. ' -iname "*.png" -or -iname "*.jpg" -or -iname "*.jpeg"',
      function (out)
         
         for s in out:gmatch("[^\r\n]+") do
            M.filelist[#M.filelist+1] = s
         end
         
         naughty.notify({ title = "Wallpaper database updated",
                          text  = "Found: " .. #M.filelist .. " items",
                          icon  = M.icon, icon_size = 64})
         
         if doRefresh then
            for s in screen do
               M.setWallpaper(s)
            end
         end
   end)
end -- end of M.updateFilelist

M.refresh = function()
   
   math.randomseed(os.time())
   if (M.wallpaperPath:sub(-1) == "/") then
      if os.time() - M.datebaseUpdateLastTime > M.UPDATE_DATABASE_INTERVAL then
         M.updateFilelist()
         M.datebaseUpdateLastTime = os.time()
      end
   end
   
   for s in screen do
      M.setWallpaper(s)
   end
   
end

M.toggleMode = function(idx)
   M.wallpaperPath = beautiful.wallpaper[idx][2]
   M.wallpaperMode = beautiful.wallpaper[idx][3]
   
   naughty.notify({ title = "Wallpaper Mode Changed",
                    text  = "Path: " .. M.wallpaperPath .. '\nMode: ' .. M.wallpaperMode,
                    icon  = M.icon, icon_size = 64})
   if (M.wallpaperPath:sub(-1) == "/") then
      M.updateFilelist(true)
   end
end

M.toggleShowDesktop = function()
   
   M.showDesktopStatus = not M.showDesktopStatus
   local text
   if M.showDesktopStatus then
      text = "on"
   else
      text = "off"
   end
   naughty.notify({ title = "ShowDesktop Mode Changed",
                    text  = "Show Desktop: " .. text,
                    icon  = M.icon, icon_size = 64})

   if M.showDesktopStatus then
      for s in screen do
         local wExist = false
         for _, t in ipairs(s.tags) do
            if t.name == "W" then
               t:view_only()
               wExist = true
               break
            end
         end -- tag in s.tags
         if not wExist then
            awful.tag.add("W", {screen = s}):view_only()
         end
      end
   else  -- not showing desktop
      for s in screen do
         for _, t in ipairs(s.tags) do
            if t.name == "W" then
               t:view_only()
               t:delete()
            end
         end -- tag in s.tags
      end -- s in screen
   end
end

return M
