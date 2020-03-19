--[[

     Awesome WM configuration template
     github.com/lcpz

--]]

-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local wallpaper = require("wallpaper")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart windowless processes
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        findme = cmd
        firstspace = cmd:find(" ")
        if firstspace then
            findme = cmd:sub(0, firstspace-1)
        end
        awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
    end
end

run_once({ "unclutter -root -idle 10" }) -- entries must be comma-separated
-- }}}

-- {{{ Variable definitions

local modkey       = "Mod4"
local hyperkey     = "Mod3"
local altkey       = "Mod1"
local terminal     = "x-terminal-emulator"
local editor       = os.getenv("EDITOR") or "vim"
local browser      = "google-chrome"
local guieditor    = "emacsclient -c -n"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
awful.layout.layouts = {
    awful.layout.suit.tile,
    lain.layout.termfair,
    lain.layout.termfair.center,
    lain.layout.centerwork,
    awful.layout.suit.floating,
    lain.layout.cascade,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.tile.top,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    --lain.layout.cascade.tile,
    --lain.layout.centerwork.horizontal,
}
awful.util.taglist_buttons = awful.util.table.join(
   awful.button({ }, 1, function(t) t:view_only() end),
   awful.button({ modkey }, 1, function(t)
         if client.focus then
            client.focus:move_to_tag(t)
         end
   end),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ modkey }, 3, function(t)
         if client.focus then
            client.focus:toggle_tag(t)
         end
   end),
   awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

awful.util.tasklist_buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
         if c == client.focus then
            c.minimized = true
         else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
               c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
         end
   end),
   awful.button({ }, 3, function()
         local instance = nil
         
         return function ()
            if instance and instance.wibox.visible then
               instance:hide()
               instance = nil
            else
               instance = awful.menu.clients({ theme = { width = 250 } })
            end
         end
   end),
   awful.button({ }, 4, function ()
         awful.client.focus.byidx(1)
   end),
   awful.button({ }, 5, function ()
         awful.client.focus.byidx(-1)
end))

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

local theme_path = string.format(
   "%s/.config/awesome/themes/holo/theme.lua", os.getenv("HOME"))
beautiful.init(theme_path)
-- }}}

-- {{{ Screen
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(
   function(s) beautiful.at_screen_connect(s) end)

-- Setup Wallpaper Accordingly
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
wallpaper.init()
screen.connect_signal("property::geometry", function(s)
    if beautiful.wallpaper then
       wallpaper.refresh()
    end
end)

-- {{{ Menu
local function report_monitor(s)
   title = string.format("Monitor %s", s.index)
   monitorProps = string.format(
      "x: %s, y: %s\nh: %s, w: %s",
      s.geometry.x, s.geometry.y,
      s.geometry.height, s.geometry.width)
    naughty.notify({title = title,
                    text = monitorProps,
                    screen = s})
end
local updateFocusWidget = function () end
if screen:count() > 1 then
   updateFocusWidget = function()
      for s in screen do
         s.focuswidget.checked = (s == awful.screen.focused())
      end
   end
end

local myawesomemenu = {
   { "Hotkeys",
     function()
        return false, hotkeys_popup.show_help
     end 
   },
   -- { "Manual", terminal .. " -e man awesome" },
   { "Edit config",
     string.format("%s -e %s %s", terminal, guieditor, awesome.conffile) },
   { "Restart", awesome.restart },
   { "Quit", function() awesome.quit() end}
}
local displaymenu = {
   { "Lock",
     "xset dpms force off && xscreensaver-command -lock"},
   { "Turn off Monitor",
     'xset dpms force off'},
   { "Report Monitor Props",
     function()
        for s in screen do
           report_monitor(s)
        end
   end },
}

local servicemenu = {
   { "Restart Dropbox",
     -- if using the command directly, the dropbox will run but
     -- the systray will not show up
     function() awful.spawn.with_shell("dropbox stop && dropbox start") end,},
   { "Restart Emacs",
     "systemctl --user restart emacs.service"},
   { "Update VPN Widget",
     function() beautiful.vpnUpdate() end},
}

local mymainmenu = awful.menu{
   items = {
        { "Awesome", myawesomemenu},--, beautiful.awesome_icon },
        -- { "Wallpaper", wallpaper.menu},
        { "Display", displaymenu},
        { "Services", servicemenu},
        { "Sound Setting", terminal .. ' -e alsamixer'},
        { "Open terminal", terminal },
   }
}

local mywallpapermenu = awful.menu{
   items = wallpaper.menu
}

-- Set the Menubar terminal for applications that require it
-- menubar.utils.terminal = terminal 
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/lcpz/dots/blob/master/bin/screenshot
   awful.key(
      { modkey,  }, "F5",
      function()    wallpaper.refresh(true) end,
      {description = "Refresh wallpaper (next)", group = "wallpaper"}),
   awful.key(
      { modkey,  "Shift" }, "F5",
      function()    wallpaper.refresh(true, -1) end,
      {description = "Refresh wallpaper (prev)", group = "wallpaper"}),
   awful.key(
      { modkey,  }, "F1",
      function()    wallpaper.showWallpaperInfo(awful.screen.focused()) end,
      {description = "Show wallpaper info", group = "wallpaper"}),

   awful.key(
      { altkey, "Shift", "Control" }, "3",
      function() awful.spawn.with_shell("screenshot") end,
      {description = "take a screenshot", group = "hotkeys"}),

    -- Hotkeys
   awful.key(
      { modkey,           }, "s",
      hotkeys_popup.show_help,
      {description = "show help", group="awesome"}),
    -- Tag browsing
   awful.key(
      { "Control", "Shift" }, "q", awful.tag.viewprev,
      {description = "view previous", group = "tag"}),
   awful.key(
      { "Control", "Shift" }, "w",  awful.tag.viewnext,
      {description = "view next", group = "tag"}),
   awful.key(
      { modkey,           }, "Escape", awful.tag.history.restore,
      {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    -- awful.key({ "Control", "Shift" }, "q", function () lain.util.tag_view_nonempty(-1) end,
    --           {description = "view  previous nonempty", group = "tag"}),
    -- awful.key({ "Control", "Shift" }, "q",{ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
    --           {description = "view  previous nonempty", group = "tag"}),

    -- Default client focus
   awful.key(
      { modkey }, "j",
      function () awful.client.focus.byidx(-1) end,
      {description = "focus next by index", group = "client"}
   ),
   awful.key(
      { modkey,           }, "k",
      function () awful.client.focus.byidx( 1) end,
      {description = "focus previous by index", group = "client"}
    ),
    awful.key(
       { modkey,           }, "w",
       function () mymainmenu:show() end,
       {description = "show main menu", group = "awesome"}),
    awful.key(
       { modkey,           }, "d",
       function () mywallpapermenu:show() end,
       {description = "show wallpaper menu", group = "awesome"}),
    -- Layout manipulation
    awful.key(
       { modkey, "Shift"   }, "j",
       function () awful.client.swap.byidx( -1) end,
       {description = "swap with next client by index", group = "client"}),
    awful.key(
       { modkey, "Shift"   }, "k",
       function () awful.client.swap.byidx(  1) end,
       {description = "swap with previous client by index", group = "client"}),
    awful.key(
       { modkey,           }, "o",
       function ()
          awful.screen.focus_relative( 1)
          -- awful.screen.focus_bydirection( 'right')
          updateFocusWidget()
       end,
       {description = "focus the next screen", group = "screen"}),
    awful.key(
       { modkey, altkey   }, "o",
       function ()
          awful.screen.focus_relative(-1)
          -- awful.screen.focus_bydirection( 'left')
          updateFocusWidget()
       end,
       {description = "focus the prev screen", group = "screen"}),
    awful.key(
       { modkey,           }, "u",
       awful.client.urgent.jumpto,
       {description = "jump to urgent client", group = "client"}),

    awful.key(
       { modkey,           }, "Tab",
       function ()
          awful.client.focus.history.previous()
          if client.focus then
             client.focus:raise()
          end
       end,
       {description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key(
       { modkey }, "b",
       function ()
          for s in screen do
             s.mywibox.visible = not s.mywibox.visible
             if s.mybottomwibox then
                s.mybottomwibox.visible = not s.mybottomwibox.visible
             end
          end
       end,
       {description = "toggle wibox", group = "awesome"}),

    -- On the fly useless gaps change
    awful.key(
       { altkey, "Control" }, "+",
       function () lain.util.useless_gaps_resize(1) end,
       {description = "increment useless gaps", group = "tag"}),
    awful.key(
       { altkey, "Control" }, "-",
       function () lain.util.useless_gaps_resize(-1) end,
       {description = "decrement useless gaps", group = "tag"}),

    -- Dynamic tagging
    awful.key(
       { altkey, "Control", "Shift" }, "n",
       function () lain.util.add_tag() end,
       {description = "add new tag", group = "tag"}),
    awful.key(
       { altkey, "Control", "Shift" }, "r",
       function () lain.util.rename_tag() end,
       {description = "rename tag", group = "tag"}),
    awful.key(
       { altkey, "Control", "Shift" }, "q",
       function () lain.util.move_tag(-1) end,
       {description = "move tag to the left", group = "tag"}),
    awful.key(
       { altkey, "Control", "Shift" }, "w",
       function () lain.util.move_tag(1) end,
       {description = "move tag to the right", group = "tag"}),
    awful.key(
       { altkey, "Control", "Shift" }, "d",
       function () lain.util.delete_tag() end,
       {description = "delete tag", group = "tag"}),

    -- Standard program
    awful.key(
       { modkey,           }, "Return",
       function () awful.spawn(terminal) end,
       {description = "open a terminal", group = "launcher"}),
    awful.key(
       { modkey, "Control" }, "r", awesome.restart,
       {description = "reload awesome", group = "awesome"}),
    awful.key(
       { modkey, "Control" }, "d", wallpaper.toggleShowDesktop,
       {description = "Show Desktop", group = "awesome"}),

    -- layout adjustment
    awful.key(
       { modkey, }, "l",
       function () awful.tag.incmwfact( 0.05) end,
       {description = "increase master width factor", group = "layout"}),
    awful.key(
       { modkey, }, "h",
       function () awful.tag.incmwfact(-0.05) end,
       {description = "decrease master width factor", group = "layout"}),
    awful.key(
       { modkey, "Shift"   }, "l",
       function () awful.client.incwfact( 0.05) end,
       {description = "increase slave width factor", group = "layout"}),
    awful.key(
       { modkey, "Shift"   }, "h",
       function () awful.client.incwfact(-0.05) end,
       {description = "decrease slave width factor", group = "layout"}),
    awful.key(
       { modkey, "Shift"   }, "=",
       function () awful.tag.incnmaster( 1, nil, true) end,
       {description = "increase the number of master clients", group = "layout"}),
    awful.key(
       { modkey, "Shift"   }, "-",
       function () awful.tag.incnmaster(-1, nil, true) end,
       {description = "decrease the number of master clients", group = "layout"}),
    awful.key(
       { modkey, "Control" }, "h",
       function () awful.tag.incncol( 1, nil, true) end,
       {description = "increase the number of columns", group = "layout"}),
    awful.key(
       { modkey, "Control" }, "l",
       function () awful.tag.incncol(-1, nil, true) end,
       {description = "decrease the number of columns", group = "layout"}),
    -- layout change
    awful.key(
       { modkey,           }, "space",
       function () awful.layout.inc( 1) end,
       {description = "select next", group = "layout"}),
    awful.key(
       { modkey, "Shift"   }, "space",
       function () awful.layout.inc(-1) end,
       {description = "select previous", group = "layout"}),

    awful.key(
       { modkey, "Control" }, "n",
       function ()
          local c = awful.client.restore()
          -- Focus restored client
          if c then
             client.focus = c
             c:raise()
          end
       end,
       {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key(
       { modkey, }, "=",
       function () awful.screen.focused().quake:toggle() end,
       {description = "dropdown application", group = "launcher"}),

    -- Widgets popups
    -- -- Brightness
    awful.key({ }, "XF86MonBrightnessUp",
       function ()
          awful.util.spawn(beautiful.INC_BRIGHTNESS_CMD)
          beautiful.update_brightness_widget()
       end,
       {description = "+5%", group = "hotkeys"}),
    awful.key({ }, "XF86MonBrightnessDown",
       function ()
          awful.util.spawn(beautiful.DEC_BRIGHTNESS_CMD)
          beautiful.update_brightness_widget()
       end,
       {description = "-5%", group = "hotkeys"}),

    -- ALSA volume control
    awful.key(
       { "Shift" }, "XF86AudioRaiseVolume",
       function ()
          awful.spawn.with_shell(
             string.format("%s -q set %s 1%%+",
                           beautiful.volume.cmd,
                           beautiful.volume.channel))
          beautiful.volume.update()
       end,
       {description = "finer volume up", group = "hotkeys"}),
    awful.key(
       { "Shift" }, "XF86AudioLowerVolume",
       function ()
          awful.spawn.with_shell(
             string.format("%s -q set %s 1%%-",
                           beautiful.volume.cmd,
                           beautiful.volume.channel))
          beautiful.volume.update()
       end,
       {description = "finer volume down", group = "hotkeys"}),
    awful.key(
       { }, "XF86AudioRaiseVolume",
       function ()
          awful.spawn.with_shell(
             string.format("%s -q set %s 5%%+",
                           beautiful.volume.cmd,
                           beautiful.volume.channel))
          beautiful.volume.update()
       end,
       {description = "volume up", group = "hotkeys"}),
    awful.key(
       { }, "XF86AudioLowerVolume",
       function ()
          awful.spawn.with_shell(
             string.format("%s -q set %s 5%%-",
                           beautiful.volume.cmd,
                           beautiful.volume.channel))
          beautiful.volume.update()
       end,
       {description = "volume down", group = "hotkeys"}),
    awful.key(
       { }, "XF86AudioMute",
       function ()
          awful.spawn.with_shell(
             string.format(
                "%s -q set %s toggle",
                beautiful.volume.cmd,
                beautiful.volume.togglechannel or beautiful.volume.channel))
          beautiful.volume.update()
       end,
       {description = "toggle mute", group = "hotkeys"}),
    awful.key(
       { altkey }, "XF86AudioMute",
       function ()
          awful.spawn.with_shell(
             string.format("%s -q set %s 100%%",
                           beautiful.volume.cmd,
                           beautiful.volume.channel))
          beautiful.volume.update()
       end,
       {description = "volume 100%", group = "hotkeys"}),

	-- Cmus Control
	awful.key(
       { altkey, "Control" }, "w",
       function () awful.spawn.with_shell("cmus-remote -u") end,
	   {description = "Toggle Play of Cmus", group = "hotkeys"}),
	awful.key(
       { altkey, "Control" }, "f",
       function () awful.spawn.with_shell("cmus-remote -n") end,
	   {description = "Toggle Play of Cmus", group = "hotkeys"}),
	awful.key(
       { altkey, "Control" }, "q",
       function () awful.spawn.with_shell("cmus-remote -r") end,
	   {description = "Toggle Play of Cmus", group = "hotkeys"}),

    -- Copy primary to clipboard (terminals to gtk)
    awful.key(
       { modkey }, "c",
       function () awful.spawn("xsel | xsel -i -b") end,
       {description = "copy terminal to gtk", group = "hotkeys"}),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key(
       { modkey }, "v", function () awful.spawn("xsel -b | xsel") end,
       {description = "copy gtk to terminal", group = "hotkeys"}),

    -- {{{ User programs
    awful.key(
       { modkey, "Shift" }, "c", function () awful.spawn(browser) end,
       {description = "run browser", group = "launcher"}),
	-- Binding for =emacs-anywhere=
    awful.key(
       { modkey }, "a",
       function () awful.spawn("/home/yaqi/.emacs_anywhere/bin/run") end,
       {description = "Call emacs-anywhere", group = "launcher"}),

    -- Prompt
    awful.key(
       { modkey }, "r",
       function () awful.screen.focused().mypromptbox:run() end,
       {description = "run prompt", group = "launcher"}),
    awful.key(
       { modkey }, "x",
       function ()
          awful.prompt.run {
             prompt       = "Run Lua code: ",
             textbox      = awful.screen.focused().mypromptbox.widget,
             exe_callback = awful.util.eval,
             history_path = awful.util.get_cache_dir() .. "/history_eval"
          }
       end,
       {description = "lua execute prompt", group = "awesome"})
    --]]
) -- end of globalkey

local function opacity_adjust(c, delta)
   c.opacity = c.opacity + delta
   -- if c.class == "Google-chrome" then
   --    awful.spawn("transset-df -i " .. c.window .. " " .. c.opacity)
   -- end
end

clientkeys = awful.util.table.join(
    -- Opacity contrlo
   awful.key(
      { modkey, "Control" }, "=",
      function (c) opacity_adjust(c,  0.01) end,
      {description = "Fine Increase Client Opacity", group = "client"}),
   awful.key(
      { modkey, "Control" }, "-",
      function (c) opacity_adjust(c, -0.01) end,
      {description = "Fine Decrease Client Opacity", group = "client"}),
   awful.key(
      { modkey, "Shift", "Control" }, "=",
      function (c) opacity_adjust(c,  0.05) end,
      {description = "Increase Client Opacity", group = "client"}),
   awful.key(
      { modkey, "Shift", "Control" }, "-",
      function (c) opacity_adjust(c, -0.05) end,
      {description = "Decrease Client Opacity", group = "client"}),

    -- Size Control
    awful.key({ altkey, "Shift"   }, "m", lain.util.magnify_client,
              {description = "magnify client", group = "client"}),
    awful.key(
       { modkey,           }, "f",
       function (c)
          c.fullscreen = not c.fullscreen
          c:raise()
       end,
       {description = "toggle fullscreen", group = "client"}),

    awful.key(
       { modkey,           }, "q", function (c) c:kill() end,
       {description = "close", group = "client"}),
    awful.key(
       { modkey, "Control" }, "space",
       awful.client.floating.toggle,
       {description = "toggle floating", group = "client"}),
    awful.key(
       { modkey, "Control" }, "Return",
       function (c) c:swap(awful.client.getmaster()) end,
       {description = "move to master", group = "client"}),
    awful.key(
       { modkey, "Control"   }, "o",
       function (c) c:move_to_screen() end,
       {description = "move to screen", group = "client"}),
    awful.key(
       { modkey,           }, "t",
       function (c) c.ontop = not c.ontop end,
       {description = "toggle keep on top", group = "client"}),
    awful.key(
       { modkey, "Control"   }, "t", awful.titlebar.toggle,
       {description = "toggle titlebar", group = "client"}),
    awful.key(
       { modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
) -- End of Client Key

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
       descr_view = {
          description = "view tag #", group = "tag"}
       descr_toggle = {
          description = "toggle tag #", group = "tag"}
       descr_move = {
          description = "move focused client to tag #", group = "tag"}
       descr_toggle_focus = {
          description = "toggle focused client on tag #", group = "tag"}
    end
    globalkeys = awful.util.table.join(
       globalkeys,
       -- View tag only.
       awful.key({ modkey }, "#" .. i + 9,
          function ()
             local screen = awful.screen.focused()
             local tag = screen.tags[i]
             if tag then
                tag:view_only()
             end
          end,
          descr_view),
       -- Toggle tag display.
       awful.key({ modkey, "Control" }, "#" .. i + 9,
          function ()
             local screen = awful.screen.focused()
             local tag = screen.tags[i]
             if tag then
                awful.tag.viewtoggle(tag)
             end
          end,
          descr_toggle),
       -- Move client to tag.
       awful.key({ modkey, "Shift" }, "#" .. i + 9,
          function ()
             if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                   client.focus:move_to_tag(tag)
                end
             end
          end,
          descr_move),
       -- Toggle tag on focused client.
       awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
          function ()
             if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                   client.focus:toggle_tag(tag)
                end
             end
          end,
          descr_toggle_focus)
    )
end

for i = 1, screen:count() do
    local descr_view, descr_move
    if i == 1 or i == screen:count() then
       descr_view = {description = "view screen #", group = "screen"}
       descr_move = {description = "move focused client to screen #", group = "screen"}
    end
   globalkeys = awful.util.table.join(
      globalkeys,
      -- View tag only.
      awful.key({ hyperkey }, "#" .. i + 9,
         function ()
            awful.screen.focus(i)
            updateFocusWidget()
         end,
         descr_view),
      -- Toggle tag display.
      awful.key({ hyperkey, altkey }, "#" .. i + 9,
         function ()
            client.focus:move_to_screen(i)
         end,
         descr_move)
   )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

--custom key-bindings

globalkeys = awful.util.table.join(
   globalkeys,
   awful.key(
      { altkey, "Control" }, "e",
      function ()
         beautiful.app_menu("Emacs", "newem")
      end,
      {description = "Get a jump menu of all emacs client", group = "Application"}),
   awful.key(
      { altkey, "Control", "Shift" }, "c",
      function ()
         awful.spawn.with_shell("google-chrome")
      end,
      {description = "Open a New Chrome Client", group = "Application"}),
   awful.key(
      { altkey, "Control" }, "c",
      function ()
         beautiful.app_menu("Google-chrome", "google-chrome")
      end,
      {description = "Run or Raise Chrome", group = "Application"})
)
-- Custom Screen Focus Movement

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
         border_width = beautiful.border_width,
         border_color = beautiful.border_normal,
         focus = awful.client.focus.filter,
         raise = true,
         keys = clientkeys,
         buttons = clientbuttons,
         screen = awful.screen.preferred,
         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
         size_hints_honor = false
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = true } },

    -- Set Firefox to always map on the first tag on screen 1.
    { rule = { class = "Firefox" },
      properties = { screen = 1, tag = awful.util.tagnames[1] } },

    { rule_any = { class = {"Emacs", "Gnome-terminal"} },
      properties = { opacity = 0.90 }},

    { rule_any = { class = {"Google-chrome"} },
      properties = { opacity = 0.95 }},


	-- Set floating clients
    { rule_any = { class = {"feh", "Mathematica", "mpv", "vlc",
                            "libprs500", "Nautilus", "Envince",
                            "onscripter", "Xsane", "matplotlib",
                            "Eog", "Matplotlib", "org.jabref.JabRefMain" } },
      properties = { floating = true } },

	-- Set ontop clients
    { rule_any = { class = { "Matplotlib" } },
      properties = { ontop = true } },

	-- Set center clients
	{ rule_any = {class = {"feh", "vlc", "mpv", "libprs500",
                           "onscripter", "Steam", "stretchly", "Eog" }},
	  callback = function(c)
		 awful.placement.centered(c)
	  end
	},

    { rule = { name = "Picture in picture"},
      properties = { floating = true,
                     ontop = true,
                     titlebars_enabled = false}},

    { rule = { class = "Gimp", role = "gimp-image-window" },
      properties = { maximized = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }

	-- Hide the titlebar for non-floating only
	-- local l = awful.layout.get(c.screen)
	-- if not c.floating then
	   awful.titlebar.hide(c)
	-- end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
   "mouse::enter", function(c)
      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
         client.focus = c
      end
end)

-- Enable Auto Title bar when toggle floatinG
client.connect_signal(
   "property::floating", function (c)
      if c.floating and not c.maximized then
         awful.titlebar.show(c)
      else
         awful.titlebar.hide(c)
      end
end)

-- No border for maximized clients
client.connect_signal(
   "focus", function(c)
      if c.maximized then -- no borders if only 1 client visible
         c.border_width = 0
      elseif #awful.screen.focused().clients > 1 then
         c.border_width = beautiful.border_width
         c.border_color = beautiful.border_focus
      end
end)
client.connect_signal(
   "unfocus",
   function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Update the focus indicator
if screen:count() > 1 then
    client.connect_signal(
    "focus", function(c)
        updateFocusWidget()
    end)
    client.connect_signal(
    "property::screen", function(c)
        updateFocusWidget()
    end)
end

-- Run App at Startup
local autorun_path = string.format("%s/.config/awesome/autorun.sh", os.getenv("HOME"))
awful.spawn.easy_async(autorun_path, function(stdout, stderr, exitreason, exitcode) end)
