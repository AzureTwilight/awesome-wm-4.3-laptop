-- Offer functions related to pakcage
local screen = screen
local gears         = require("gears")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
-- local lfs = require("lfs")
local os = os
local next = next
local math = math

local M = {
   filelist = {},
   showDesktopHiddedTags = {},
   showDesktopStatus = false,
   alternativeMode = false,
   wallpath = beautiful.wallpaper,
   icon = beautiful.refreshed,
   datebaseUpdateLastTime = os.time(),
   UPDATE_DATABASE_INTERVAL = 3600
}


-- M.filelist = {}
-- M.showDesktopHiddedTags = {}
-- M.showDesktopStatus = false
-- M.alternativeMode = false
-- M.wallpath = beautiful.wallpaper
-- M.icon = beautiful.refreshed
-- M.datebaseUpdateLastTime = os.time()
-- M.UPDATE_DATABASE_INTERVAL = 3600

M.wallpaper_refresh = function(s, automode)

    -- if (M.wallpath:sub(-1) == "/" or
    --     lfs.attributes(M.wallpath, "mode") == "directory") then
    if (M.wallpath:sub(-1) == "/") then

      if next(M.filelist) ~= nil then
         s.wallpaper = M.filelist[math.random(#M.filelist)]
         naughty.notify({ title = "Wallpaper Refreshed",
                          text  = " Filename:" .. s.wallpaper,
                          icon  = M.icon, icon_size = 64,
                          screen = s})
      end

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
	    if M.alternativeMode then
       		gears.wallpaper.fit(s.wallpaper, s)
	    else
       		gears.wallpaper.maximized(s.wallpaper, s)
	    end
    end
end

M.update_filelist = function(doRefresh)
   local doRefresh = doRefresh or true
   
   if M.alternativeMode then
      M.wallpath = beautiful.wallpaper_alter
   else
      M.wallpath = beautiful.wallpaper
   end

   if (M.wallpath:sub(-1) == "/") then
      M.filelist = {}
    naughty.notify({ title = "Updating wallpaper database",
                     text  = "Folder: " .. M.wallpath,
                     icon  = M.icon, icon_size = 64})

      
      awful.spawn.easy_async(
         "find -L " .. M.wallpath .. ' -iname "*.png" -or -iname "*.jpg"',
         function (out)
            for s in out:gmatch("[^\r\n]+") do
               M.filelist[#M.filelist+1] = s
            end

            naughty.notify({ title = "Wallpaper database updated",
                             text  = "Found: " .. #M.filelist .. " items",
                             icon  = M.icon, icon_size = 64})

            if doRefresh then
               for s in screen do
                  M.wallpaper_refresh(s, automode)
               end
            end
      end)
   end


end -- end of M.update_filelist

M.refresh = function(automode, forceUpdate)
   local automode = automode or false
   local forceUpdate = forceUpdate or false

   if M.alternativeMode then
      M.wallpath = beautiful.wallpaper_alter
   else
      M.wallpath = beautiful.wallpaper
   end

   math.randomseed(os.time())

   if forceUpdate then 
      M.update_filelist()
   else
      if (M.wallpath:sub(-1) == "/") then
         if next(M.filelist) == nil then
            M.update_filelist()
         else
            if os.time() - M.datebaseUpdateLastTime > M.UPDATE_DATABASE_INTERVAL then
               M.update_filelist()
               M.datebaseUpdateLastTime = os.time()
            end
         end
      end
   end

    for s in screen do
        M.wallpaper_refresh(s, automode)
    end
      
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
                    icon  = M.icon, icon_size = 64})
   M.refresh(false, true)
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
