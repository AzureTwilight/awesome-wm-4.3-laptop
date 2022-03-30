-- Offer functions related to pakcage
local screen = screen
local gears         = require("gears")
local client        = client
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain    = require("lain")
local os = os
local next = next
local math = math
local table = table

local M = {}
local notiWidth = 600

local setAllClientsOpacityHelper = function (input_opacity)
   for s in screen do
      for _, c in ipairs(s.all_clients) do
         c.opacity = input_opacity
      end
      -- TODO should we set the transparency of wibar as well?
   end
end

local setAllClientsOpacity = function()
   awful.prompt.run{
      prompt       = '<b>Opacity: </b>',
      bg_cursor    = '#ff0000',
      -- To use the default rc.lua prompt:
      textbox      = mouse.screen.mypromptbox.widget,
      exe_callback = function(input)
         if input then
            local input_opacity = tonumber(input) or 0.97
            setAllClientsOpacityHelper(input_opacity)
         end
      end
   }
end


local wallpaperFunction = {
   fit=gears.wallpaper.fit,
   centered=gears.wallpaper.centered,
   max=gears.wallpaper.maximized,
   tile=gears.wallpaper.tiled
}

M.init = function()
   M.filelist = {}
   M.showDesktopStatus = false
   M.showDesktopBuffer = {}
   M.lastFocusedScreenIndex = 1
   M.lastFocusedClient = nil
   M.wallpaperMode = "max"
   M.currentTag = 'n/a'
   M.filelistCMD = nil
   M.quiteMode = false
   M.currentIdx = nil
   M.shuffleMode = false
   math.randomseed(os.time())

   local modeMenu = {}
   for key, val in pairs(wallpaperFunction) do
      table.insert(modeMenu, {'mode ' .. key, function() M.changeWallpaperMode(key) end})
   end
   
   local toggleMenu = {}
   if type(beautiful.wallpaper) == "table" then
      for idx, val in ipairs(beautiful.wallpaper) do
         table.insert(toggleMenu,
                      {"[Gallery] " .. val.name, function() M.toggleGallery(idx) end})
      end
      M.wallpaperPath = beautiful.wallpaper[1].path
      M.wallpaperMode = beautiful.wallpaper[1].mode
   else
      M.wallpaperPath = beautiful.wallpaper
   end -- if type(beautiful.wallpaper)

   local wallpaperActionMenu = {
      { "Show Wallpaper Info", function() M.showWallpaperInfo(awful.screen.focused()) end},
      { "Copied Current MD5", function() M.copyMD5(awful.screen.focused()) end},
      { "Ignore Current Wallpaper", function() M.ignoreCurrentWallpaper(awful.screen.focused()) end},
      { "Accept Current Wallpaper", function() M.ignoreCurrentWallpaper(awful.screen.focused(), true) end}
   }
   local galleryActionMenu = {
      { "Toggle Quite Mode", function() M.toggleQuiteMode() end},
      { "Change Wallpaper Mode", modeMenu},
      { "Update Wallpaper Files", function() M.updateFilelist() end},
      { "Change Wallpaper Interval", function() M.changeWallpaperInterval() end},
      { "[DB Only] Set Tag", function() M.setTag() end}
   }
   
   M.menu = {
      { "Refresh Wallpaper", function() M.refresh() end},
      { "Set Clients Opacity", function() setAllClientsOpacity() end},
      { "Wallpaper Actions", wallpaperActionMenu},
      { "Gallery Actions", galleryActionMenu},
      { "Switch Wallpaper Gallery", toggleMenu},
   }

   M.updateFilelist(true)
   M.timer = gears.timer {
      timeout = 900,
      call_now = false,
      autostart = false,
      callback = function() M.refresh() end}
   M.timer:start()

end -- M.init

M.toggleQuiteMode = function()

   M.quiteMode = not M.quiteMode
   local quiteMode
   if M.quiteMode then
      quiteMode = 'on'
   else
      quiteMode = 'off'
   end

   naughty.notify({ title = "Wallpaper Quite Mode Changed to " .. quiteMode,
                    position = "bottom_middle",
                    icon  = beautiful.refreshed, icon_size = 64,
                    width = notiWidth})

end -- M.toggleQuiteMode

M.changeWallpaperInterval = function()
    awful.prompt.run {
        prompt       = '<b>Wallpaper Interval (sec): </b>',
        text         = tostring(M.timer.timeout),
        bg_cursor    = '#ff0000',
        -- To use the default rc.lua prompt:
        textbox      = mouse.screen.mypromptbox.widget,
        exe_callback = function(input)
            if not input or #input == 0 then input = 900 end
            naughty.notify{
               text = 'Set Wallpaper Interval: '.. input,
               position = "bottom_middle",
               width = notiWidth}
            M.timer.timeout = tonumber(input)
            M.timer:again()
        end
    }
end
local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function getMD5(path)
   local tmp = split(path, '_')
   if tmp then
      md5 = tmp[#tmp]:sub(1, 32)
   else
      md5 = false
   end
   return md5
end

M.setWallpaper = function(s, f)

   local f = f or nil
   
   s.wallpaper = nil
   if type(M.wallpaperPath) == "function" then
      s.wallpaper = M.wallpaperPath(s)
   else
      if (M.wallpaperPath:sub(-1) == "/" or M.wallpaperPath == "@combine") then
         if next(M.filelist) ~= nil then
            if M.currentIdx == #M.filelist then
               M.currentIdx = nil -- reset to the beginning
            end
            M.currentIdx, s.wallpaper = next(M.filelist, M.currentIdx)
            s.currentIdx = M.currentIdx
         end
      else
         s.wallpaper = M.wallpaperPath
      end
   end -- if type(beautiful.wallpaper)

   if f ~= nil then
      if s.wallpaper ~= nil then
         f:write("Screen " .. s.index .. ": " .. s.wallpaper)
      else
         f:write("Screen " .. s.index .. ": nil\n")
      end
   end
   
   if s.wallpaper ~= nil then

      if not M.quiteMode then
         M.showWallpaperInfo(s)
      end
      
      wallpaperFunction[M.wallpaperMode](s.wallpaper, s)

      if f ~= nil then
         f:write(" SET!\n")
      end

      local curIdx
      if s.currentIdx ~= nil then
         curIdx = s.currentIdx
      else
         curIdx = 0
      end
      local text = '  [' .. curIdx .. '/' .. #M.filelist .. ']  '
      s.wallText:set_markup(text)

   end -- if s.wallpaper ~= nil
end

M.changeWallpaperMode = function(mode)

   if mode == "fit" or mode == "max" or mode == "tile" or mode == "centered" then
      M.wallpaperMode = mode
      naughty.notify{
         text = 'Change wallpaper model to ' .. mode,
         position = "bottom_middle",
         width = notiWidth,
      }

      for s in screen do
         wallpaperFunction[mode](s.wallpaper, s) --, f)
      end

   else
      naughty.notify{
         text = 'Only support "fit", "max", "tile", "centered", input is ' .. mode,
         position = "bottom_middle",
         width = notiWidth,
      }
   end

end
M.setTag = function()
   awful.prompt.run {
      prompt       = '<b>Tag: </b>',
      -- text         = tostring(M.timer.timeout),
      bg_cursor    = '#ff0000',
      -- To use the default rc.lua prompt:
      textbox      = mouse.screen.mypromptbox.widget,
      exe_callback = function(input)
         if input then
            naughty.notify{
               text = 'Querying database for tag: '.. input,
               position = "bottom_middle",
               width = notiWidth
            }
            cmd = "sqlite3 " .. os.getenv("HOME") .. "/Pictures/database.db "
               .. "'select FilePath from MAIN_TBL where ID in "
               .. "(select ImgID from IMG_TO_TAG as A inner join TAG_TBL as B on A.TagID=B.ID "
               .. 'where TagName="' .. input .. '"' .. ") AND WALLPAPER=0' | shuf > /tmp/wall-list"
            
            awful.spawn.easy_async_with_shell(
               cmd .. "-new",
               function(out)
                  fh = io.open('/tmp/wall-list-new')
                  if fh:seek("end") ~= 0 then
                     fh:close()
                     M.filelistCMD = "mv /tmp/wall-list-new /tmp/wall-list"
                     if M.galleryName == "HCG-R18" then
                        M.updateFilelist(true)
                     else
                        M.toggleGallery(3, M.filelistCMD)
                     end
                     M.currentTag = input
                     M.filelistCMD = cmd
                  else
                     fh:close()
                     naughty.notify{
                        text = "Didn't find any wallpapers matching tag.\nCMD:" .. cmd,
                        position = "bottom_middle",
                        width = notiWidth}
                  end
            end)
            
         end
      end
   }
end

M.updateFilelist = function(doRefresh)
   local height = 100
   local width = 500
   local cmd
   
   M.currentIdx = nil
   M.filelist = {}

   if M.filelistCMD ~= nil then
      cmd = M.filelistCMD
   else
      if M.wallpaperPath ~= "@combine" then
         cmd =  "fd -L -i -t f -e png -e jpg -e jpeg . " .. M.wallpaperPath .. ' | shuf > /tmp/wall-list'
      end
   end

   naughty.notify(
      { title = "Updating wallpaper database",
        text  = "Folder: " .. M.wallpaperPath, -- .. '\nCMD: ' .. cmd,
        position = "bottom_middle",
        icon  = beautiful.refreshed, icon_size = 64,
        width = notiWidth})
   
   awful.spawn.easy_async_with_shell(
      cmd,
      function(out)
         fh = io.open('/tmp/wall-list', 'r')
         line = fh:read()
         if line ~= nil then
            M.filelist[#M.filelist+1] = line
            while true do
                line = fh:read()
                if line == nil then break end
                M.filelist[#M.filelist+1] = line
            end
         end
         fh:close()
         
         naughty.notify({ title = "Wallpaper database updated!",
                          text  = "Found: " .. #M.filelist .. " items",
                          position = "bottom_middle",
                          icon  = beautiful.refreshed, icon_size = 64,
                          width = notiWidth})
         
         if doRefresh then
            M.setAllWallpapers()
         end
   end)
   
end -- end of M.updateFilelist

M.setAllWallpapers = function()
   -- local f = io.open( "/tmp/awesome_wallpaper.log", 'a')
   -- f:write(os.date("[%Y-%m-%d %H:%M:%S]") .. "\n")
   for s in screen do
      M.setWallpaper(s) --, f)
   end
   -- f:close()
end 

M.refresh = function(resetTimer, shift)
   -- resetTimer is used when user initiate a refresh
   local resetTimer = resetTimer or false
   local shift = shift or 0

   if M.currentIdx ~= nil then
      -- twice as the currentIdx is now pointing to the next one
      M.currentIdx = M.currentIdx + 2 * shift * screen:count()
      if M.currentIdx < 1 then
         M.currentIdx = nil
      end
   end

   M.setAllWallpapers()

   if resetTimer then
      M.timer:again()
   end
end

M.shiftWallpaperForCurrentScreen = function(s, shift)
   M.currentIdx = M.currentIdx + 2 * shift
   if M.currentIdx < 1 then
      M.currentIdx = nil
   end
   M.setWallpaper(s)
end

local function notiOnIgnore(s, reverse, notiTextExtra)
   local curIdx
   if s.currentIdx ~= nil then
      curIdx = s.currentIdx
   else
      curIdx = 'n/a'
   end

   local notiText = "Filename: " .. s.wallpaper
      .. '\nIndex: ' .. curIdx

   if notiTextExtra then
      notiText = notiText .. notiTextExtra
   end

   local notiTitle
   local icon
   if reverse then
      -- color = "#32CD32"  -- green
      icon = beautiful.greencheck
      notiTitle = "Accepted"
   else
      -- color = "#B22222" -- red
      icon = beautiful.redx
      notiTitle = "Ignored"
      M.setWallpaper(s)
   end

   naughty.notify(
      { title  = "Wallpaper " .. notiTitle,
        text   = notiText,
        position = "bottom_middle",
        timeout = 5,
        -- shape = gears.shape.rectangle,
        -- border_width = 2,
        -- border_color = color,
        icon  = icon, icon_size = 64, screen = s,
        width = 1000})
end -- of function

M.ignoreCurrentWallpaper = function(s, reverse)


   if M.galleryName == "HCG-R18" then

      local md5 = getMD5(s.wallpaper)
      if md5 ~= false then

         local wall
         if reverse then
            wall = '0'
         else
            wall = '1'
         end
         
         cmd = "sqlite3 " .. os.getenv("HOME") .. "/Pictures/database.db "
            .. "'update MAIN_TBL set WALLPAPER=" .. wall .. ", CHECKED=1 where MD5="
            .. '"' .. md5 .. '"' .. ";'"
         awful.spawn.easy_async_with_shell(
            cmd,
            function (out)
                  local notiTextExtra = '\nMD5: ' .. md5
                  notiOnIgnore(s, reverse, notiTextExtra)
            end
         )
      end
   else -- for other folder w/o database
      if not reverse then
         os.rename(s.wallpaper, s.wallpaper .. ".ignore")
         if s.currentIdx ~= nil then
            M.filelist[s.currentIdx] = s.wallpaper .. ".ignore"
         end
      else
         -- now the wallpaper path is with .ignore suffix
         os.rename(s.wallpaper, s.wallpaper:sub(1, -8))
         if s.currentIdx ~= nil then
            M.filelist[s.currentIdx] = s.wallpaper:sub(1, -8)
         end
      end
      notiOnIgnore(s, reverse)
   end -- end of if gallery

end

M.copyMD5 = function(s)

   local md5 = getMD5(s.wallpaper)
   if md5 == nil then
      naughty.notify(
         { text   = "No MD5 Matched",
           position = "bottom_left",
           icon   = beautiful.refreshed,
           icon_size = 64, screen = s,
           width = notiWidth})
   else
      local cmd = "echo " .. '"' .. md5 .. '" ' .. " | xclip -selection c"
      awful.spawn.easy_async_with_shell(
         cmd,
         function (out)
            naughty.notify(
               { text   = "MD5 copied to clipboard",
                 position = "bottom_middle",
                 icon   = beautiful.refreshed,
                 icon_size = 64, screen = s,
                 width = notiWidth})
         end
      )
   end

end

M.showWallpaperInfo = function(s)

   local curIdx
   if s.currentIdx ~= nil then
      curIdx = s.currentIdx
   else
      curIdx = 'n/a'
   end

   local md5 = getMD5(s.wallpaper)
   if md5 == nil then
      md5 = "No matched"
   end

    naughty.notify(
        { title  = "Wallpaper Info",
          text   = "Filename: " .. s.wallpaper
             .. '\nPath:  ' .. M.wallpaperPath
             .. '\nIndex: ' .. curIdx .. " (" .. #M.filelist .. ")"
             .. '\nMD5: ' .. md5
             .. '\nTag: ' .. M.currentTag,
          position = "bottom_left",
          icon   = beautiful.refreshed, icon_size = 64, screen = s})
end

M.toggleGallery = function(idx, overrideCMD)
   M.wallpaperPath = beautiful.wallpaper[idx].path
   M.wallpaperMode = beautiful.wallpaper[idx].mode
   M.quiteMode     = beautiful.wallpaper[idx].quite or false
   M.shuffleMode   = beautiful.wallpaper[idx].shuffle or false
   M.filelistCMD   = beautiful.wallpaper[idx].cmd or nil
   M.galleryName   = beautiful.wallpaper[idx].name
   local interval  = beautiful.wallpaper[idx].interval or nil

   if overrideCMD ~= nil then
      M.filelistCMD = overrideCMD
   end

   local quiteMode
   if M.quiteMode then
      quiteMode = 'on'
   else
      quiteMode = 'off'
   end

   local intervalText
   if interval ~= nil then
      M.timer.timeout = interval
      intervalText = tostring(interval)
      M.timer:again()
   else
      intervalText = "n/a"
   end

   naughty.notify({ title = "Wallpaper Mode Changed",
                    text  = "Path: " .. M.wallpaperPath
                       .. '\nMode: ' .. M.wallpaperMode
                       .. '\nQuite: ' .. quiteMode
                       .. '\nInterval: ' .. intervalText,
                    position = "bottom_middle",
                    icon  = beautiful.refreshed, icon_size = 64,
                    width = notiWidth})
   if (M.wallpaperPath:sub(-1) == "/" or M.wallpaperPath == "@combine") then
      M.updateFilelist(true)
   end


end

M.toggleShowDesktop = function()
   local text
   
   M.showDesktopStatus = not M.showDesktopStatus

   if M.showDesktopStatus then  -- now in show desktop mode

      for s in screen do
         M.showDesktopBuffer[s] = s.selected_tags
         awful.tag.viewnone(s)
      end
      
   else  -- not showing desktop
      for s in screen do
         awful.tag.viewmore(M.showDesktopBuffer[s], s)
      end -- s in screen

      M.showDesktopBuffer = {}

    end

end -- M.toggleShowDesktop

return M
