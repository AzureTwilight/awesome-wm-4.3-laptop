-- Offer functions related to pakcage
local M = {}

local screen = screen
local gears         = require("gears")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lfs = require("lfs")
local os = os

M.showDesktopHiddedTags = {}
M.showDesktopStatus = false
M.alternativeMode = false
M.wallpath = beautiful.wallpaper

M.wallpaper_refresh = function(s, automode)

    if (M.wallpath:sub(-1) == "/" or
        lfs.attributes(M.wallpath, "mode") == "directory") then
       s.wallpaper = M.wallpath .. M.filelist[math.random(#M.filelist)]
       naughty.notify({ title = "Wallpaper Refreshed",
                        text  = " Filename:" .. s.wallpaper,
                        icon  = icon, icon_size = 64,
                        screen = s})
    elseif M.wallpath == "function" then
       s.wallpaper = M.wallpath(s)
    else
       s.wallpaper = M.wallpath
    end

    if automode then
       awful.spawn.easy_async_with_shell(
          "identify " .. s.wallpaper,
          function(out)
             local imgw, imgh = string.match(out, " (%d+)x(%d+) ")
             
             local imgratio = imgw / imgh
             local ratio = s.geometry.width / s.geometry.height

             local setWallpaper
             
             if math.abs( (imgratio / ratio) - 1) > 0.4 then
                setWallpaper = gears.wallpaper.fit
             else
                setWallpaper = gears.wallpaper.maximized
             end
             setWallpaper(s.wallpaper, s)
       end)
    else
       gears.wallpaper.maximized(s.wallpaper, s)
    end
end

local function getFilelist(path)
   local filelist = {}
   for file in lfs.dir(path) do
      if file ~= "." and file ~= ".." then
         filelist[#filelist+1] = file
      end
   end
   return filelist
end

M.refresh = function(automode)

   local automode = automode or false

   math.randomseed(os.time())
   M.filelist = {}
   if M.alternativeMode then
      M.wallpath = beautiful.wallpaper_alter
   else
      M.wallpath = beautiful.wallpaper
   end
      
   if (M.wallpath:sub(-1) == "/" or
       lfs.attributes(M.wallpath, "mode") == "directory") then
      M.filelist = getFilelist(M.wallpath)
   end
   
   local icon = beautiful.refreshed
   -- naughty.notify({ title = "Wallpaper Refreshed.",
   --                  text  = "Fresh Wallpaper, Fresh Mood!",
   --                  icon  = icon, icon_size = 64})
   for s in screen do
      M.wallpaper_refresh(s, automode)
   end
   M.filelist = {}
end

M.toggleMode = function()
   M.alternativeMode = not M.alternativeMode
   local text
   if M.alternativeMode then
      text = "ALTERNATIVE"
   else
      text = "NORMAL"
   end
   naughty.notify({ title = "Wallpaper Mode Changed",
                    text  = "Mode: " .. text,
                    icon  = icon, icon_size = 64})
   M.refresh(false)
end

M.toggleShowDesktop = function()

   if M.showDesktopStatus then

      -- Do this at first in case I am confused about what mode I am in
      for s in screen do
         for _, t in ipairs(s.selected_tags) do
            t.selected = false
         end
      end

      for _, t in ipairs(M.showDesktopHiddedTags) do
         t.selected = true
      end

      M.showDesktopHiddedTags = {}
   else  -- not showing desktop
      for s in screen do
         for _, t in ipairs(s.selected_tags) do
            t.selected = false
            table.insert(M.showDesktopHiddedTags, t)
         end
      end
   end

   M.showDesktopStatus = not M.showDesktopStatus

end

return M
