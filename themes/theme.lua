--[[
   
   My Awesome WM Theme 4.3

   based on 
   Holo Awesome WM theme 3.0
   github.com/lcpz
   
--]]

local screen  = screen
local gears   = require("gears")
local lain    = require("lain")
local awful   = require("awful")
local wibox   = require("wibox")
local naughty = require("naughty")
local helpers = require("lain.helpers")
local string  = string
local os      = os

local theme                                     = {}

theme.default_dir = require("awful.util").get_themes_dir() .. "default"
theme.icon_dir    = os.getenv("HOME") .. "/.config/awesome/themes/icons"
-- theme.wallpaper   = os.getenv("HOME") .. "/Pictures/wallpaper/"
-- theme.wallpaper_alter = os.getenv("HOME") .. "/Pictures/wallpaper-alter/"

theme.wallpaper = {
   {name="Normal",
    path=os.getenv("HOME") .. "/Pictures/wallpaper/",
    mode="max", quite=false, interval=900},
   {name="Fuli Girls",
    path=os.getenv("HOME") .. "/Pictures/wallpaper-alter/",
    mode="fit", quite=true, interval=30},
   {name="HCG-R18",
    path=os.getenv("HOME") .. "/Pictures/wallpaper-anime-r18/",
    mode="fit", quite=true, interval=30,
    cmd= os.getenv("HOME") .. "/Pictures/shuffle-filelist"}
}

theme.font     = "Roboto Bold 10"
theme.monofont = "Roboto Mono Bold 10"

local carolinaBlueWeb     = "#4B9CD3"
local transparency = "E6"
local transparency2 = "F6"
-- local widgetBackgroundShape = gears.shape.rectangle
local widgetBackgroundShape = gears.shape.rounded_bar

theme.fg_normal = "#FFFFFF"
theme.bg_normal = "#242424" .. transparency
-- theme.fg_focus  = "#0099CC"
theme.fg_focus  = "#FFFFFF"
theme.bg_focus_bare = "#404040" 
theme.bg_focus  = theme.bg_focus_bare.. transparency2
theme.fg_urgent = "#D87900"
theme.bg_urgent = "#303030" .. transparency2

theme.border_width  = 2
theme.border_normal = "#707C7C"
theme.border_focus  = "#4FAAD6"

theme.taglist_fg_focus = "#4FAAD6"
theme.taglist_bg_focus = theme.bg_focus
theme.taglist_fg_empty = "#505050"
theme.taglist_font     = "Roboto Mono Light 10"

theme.tasklist_fg_focus     = "#4FAAD6"
theme.tasklist_bg_focus     = "#505050" .. "CC" -- brighter
-- theme.tasklist_border_color = "#505050"
theme.tasklist_border_width = 0
theme.tasklist_border_color = nil
theme.tasklist_fg_minimize  = "#777777"
theme.tasklist_floating     = "[F]"
theme.tasklist_maximized    = "[M]"
theme.tasklist_ontop        = "[T]"
theme.tasklist_font         = "Roboto Mono 10"
theme.tasklist_font_focus   = "Roboto Mono Bold 10"
theme.tasklist_disable_icon = true

theme.systray_icon_spacing = 4
theme.bg_systray = theme.bg_focus_bare

theme.notification_icon_size = 64
theme.notification_opacity   = 0.9

theme.menu_height    = 40
theme.menu_width     = 320
theme.menu_icon_size = 32

theme.awesome_icon          = theme.icon_dir .. "/awesome_icon_white.png"
theme.awesome_icon_launcher = theme.icon_dir .. "/awesome_icon.png"
-- theme.spr_small             = theme.icon_dir .. "/spr_small.png"
-- theme.spr_very_small        = theme.icon_dir .. "/spr_very_small.png"
-- theme.spr_right             = theme.icon_dir .. "/spr_right.png"
-- theme.spr_bottom_right      = theme.icon_dir .. "/spr_bottom_right.png"
-- theme.spr_left              = theme.icon_dir .. "/spr_left.png"
-- theme.bar                   = theme.icon_dir .. "/bar.png"
-- theme.bottom_bar            = theme.icon_dir .. "/bottom_bar.png"
-- theme.mpdl                  = theme.icon_dir .. "/mpd.png"
-- theme.mpd_on                = theme.icon_dir .. "/mpd_on.png"
-- theme.prev                  = theme.icon_dir .. "/prev.png"
-- theme.nex                   = theme.icon_dir .. "/next.png"
-- theme.stop                  = theme.icon_dir .. "/stop.png"
-- theme.pause                 = theme.icon_dir .. "/pause.png"
-- theme.play                  = theme.icon_dir .. "/play.png"
theme.clock                 = theme.icon_dir .. "/myclock.png"
theme.calendar              = theme.icon_dir .. "/mycal.png"
theme.cpu                   = theme.icon_dir .. "/cpu.png"
theme.net_up                = theme.icon_dir .. "/net_up.png"
theme.net_down              = theme.icon_dir .. "/net_down.png"
-- theme.layout_tile           = theme.icon_dir .. "/tile.png"
-- theme.layout_tileleft       = theme.icon_dir .. "/tileleft.png"
-- theme.layout_tilebottom     = theme.icon_dir .. "/tilebottom.png"
-- theme.layout_tiletop        = theme.icon_dir .. "/tiletop.png"
-- theme.layout_fairv          = theme.icon_dir .. "/fairv.png"
-- theme.layout_fairh          = theme.icon_dir .. "/fairh.png"
-- theme.layout_spiral         = theme.icon_dir .. "/spiral.png"
-- theme.layout_dwindle        = theme.icon_dir .. "/dwindle.png"
-- theme.layout_max            = theme.icon_dir .. "/max.png"
-- theme.layout_fullscreen     = theme.icon_dir .. "/fullscreen.png"
-- theme.layout_magnifier      = theme.icon_dir .. "/magnifier.png"
-- theme.layout_floating       = theme.icon_dir .. "/floating.png"
theme.layout_tile           = theme.icon_dir .. "/mytile.png"
theme.layout_tiletop        = theme.icon_dir .. "/mytiletop.png"
theme.layout_floating       = theme.icon_dir .. "/myfloating.png"

theme.refreshed             = theme.icon_dir .. "/refreshed.png"
theme.warning               = theme.icon_dir .. "/warning.png"
theme.brightness            = theme.icon_dir .. "/brightness_icon.png"

theme.useless_gap              = 0

theme.titlebar_close_button_normal              = theme.default_dir.."/titlebar/close_normal.png"
theme.titlebar_close_button_focus               = theme.default_dir.."/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal           = theme.default_dir.."/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = theme.default_dir.."/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive     = theme.default_dir.."/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = theme.default_dir.."/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = theme.default_dir.."/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = theme.default_dir.."/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive    = theme.default_dir.."/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = theme.default_dir.."/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = theme.default_dir.."/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = theme.default_dir.."/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive  = theme.default_dir.."/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = theme.default_dir.."/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = theme.default_dir.."/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = theme.default_dir.."/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = theme.default_dir.."/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.default_dir.."/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = theme.default_dir.."/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = theme.default_dir.."/titlebar/maximized_focus_active.png"

theme.titlebar_bg_normal = theme.bg_normal .. transparency

theme.layout_termfair    = theme.icon_dir .. "/mytermfair.png"
theme.layout_centerfair  = theme.icon_dir .. "/mycenterfair.png"  -- termfair.center
theme.layout_cascade     = theme.icon_dir .. "/mycascade.png"
theme.layout_centerwork  = theme.icon_dir .. "/mycenterwork.png"

-- screen index translation
-- translate the physical index to build in index
theme.myScreenIdx = {}
-- translate built-in index to physical index
theme.myScreenIdxReverse = {}
local idxTable = {}
local sortTable = {}
for s in screen do
   sortTable[#sortTable+1] = s.geometry.x
   idxTable[s.geometry.x] = s.index
end
table.sort(sortTable)
for k, v in pairs(sortTable) do
   theme.myScreenIdx[k] = idxTable[v]
   theme.myScreenIdxReverse[idxTable[v]] = k
end

-- Create Jump Menu
theme.app_menu = function(appClass, newCmd)
   local items = {}
   local minimizedStatus = ""
   local header = ""
   
   for i, c in pairs(client.get()) do
      if awful.rules.match(c, {class = appClass}) then
         if c.minimized then
            minimized = "*"
         else
            minimized = " "
         end

        header = string.format(
            "%s[S%d-%d] %s",
            minimized, theme.myScreenIdxReverse[c.screen.index], c.first_tag.index, c.name)

         items[#items+1] =
            {header, function()
                c.first_tag:view_only()
                client.focus = c
             end, c.icon}
      end
   end
   items[#items+1] = {string.format("Create New %s Client", appClass), newCmd}

   local s = awful.screen.focused()
   local x = math.floor(s.geometry.x + s.geometry.width / 2 - theme.menu_width / 2)
   local y = math.floor(s.geometry.y + s.geometry.height / 2)
   
   awful.menu({items = items}):show({coords = {x = x, y = y}})
end

local markup = lain.util.markup
local blue   = "#80CCE6"
local space2 = markup.font(theme.font, "  ")
local space3 = markup.font(theme.font, "   ")

local bar = wibox.widget{
   widget = wibox.widget.separator,
   shape  = gears.shape.circle,
   -- color  = theme.bg_focus,
   visible = false,
   color  = nil,
   -- forced_width = 7,
}
local space2Widget = wibox.widget.textbox(space2)
local space4Widget = wibox.widget.textbox(space2 .. space2)

-----------------------------------------------------------------------------

-- VPN Indicator
local green = "#32CD32"
local red   = "#B22222"

local vpnOffMarkup = space2 .. markup.font(theme.font, "VPN: ")
   .. markup.font(theme.monofont, markup(red, "OFF")) .. space2
local vpntext = wibox.widget.textbox(vpnOffMarkup)
local vpntextwidget = wibox.container.background(
   vpntext, theme.bg_focus, widgetBackgroundShape)
vpntextwidget = wibox.container.margin(vpntextwidget, 0, 0, 5, 5)

theme.vpnUpdate = function()
   awful.spawn.easy_async_with_shell(
      "/usr/bin/purevpn -s",
      function(out)
         local conn = out:match("Not connected")
         if conn == nil then -- connected
            awful.spawn.easy_async_with_shell(
               "/usr/bin/purevpn -i",
               function(out)
                  local city = out:match("City:[ ]*([^\n]*)") or ""
                  local country = out:match("Country:[^%(]*%(([^%)]*)%)") or ""
                  local text = markup.font(theme.font,
                                           "VPN: " .. markup(green, "ON")
                                              .. " (" .. city .. ", " .. country
                                              .. ")")
                  vpntext:set_markup(text)
            end)
         else
            vpntext:set_markup(vpnOffMarkup)
         end
   end)
end
vpntextwidget:connect_signal(
   "mouse::enter", function() theme.vpnUpdate() end)

-- Clock
local mytextclock = wibox.widget.textclock(
   markup("#FFFFFF", space3 .. "%H:%M" .. space3))
mytextclock.font = theme.font
local clock_icon = wibox.widget.imagebox(theme.clock, true)
local clockbg = wibox.container.background(
   wibox.widget{
      layout=wibox.layout.fixed.horizontal,
      space2Widget,
      clock_icon,
      mytextclock
   },
   theme.bg_focus, widgetBackgroundShape)
local clockwidget = wibox.container.margin(clockbg, 0, 0, 5, 5)

-- Calendar
local mytextcalendar = wibox.widget.textclock(
   markup.fontfg(theme.font, "#FFFFFF", space3 .. "%a %b %d" .. space3))
local calendar_icon = wibox.widget.imagebox(theme.calendar)
local calbg = wibox.container.background(
   wibox.widget{
      layout=wibox.layout.fixed.horizontal,
      space2Widget,
      calendar_icon,
      mytextcalendar,
   },
   theme.bg_focus, widgetBackgroundShape)
local calendarwidget = wibox.container.margin(calbg, 0, 0, 5, 5)


local mycal = lain.widget.cal({
	  -- cal = "/usr/bin/cal -h",
      attach_to = { mytextclock, mytextcalendar },
      notification_preset = {
         fg = "#FFFFFF",
         bg = theme.bg_normal,
         position = "bottom_right",
         font = theme.monofont,
      }
})
-- Disable mouseover popup
mytextclock:disconnect_signal("mouse::enter", mycal.hover_on)
mytextcalendar:disconnect_signal("mouse::enter", mycal.hover_on)

-- MPD
-- local mpd_icon = wibox.widget.imagebox(theme.mpdl)

-- Battery
-- local bat = lain.widget.bat({
--       timeout = 15,
--       ac = "AC",
--       settings = function()
--          if bat_now.ac_status == 0 then
--             bat_header = " Bat "
--             header_color = "#F5C400"
--          else
--             bat_header = " AC "
--             header_color = "#4E9D2D"
--          end

--          if bat_now.status == "Full" then
--             bat_foot = "(Full) "
--          elseif bat_now.status == "Charging" then
--             bat_foot = "(Charging: " .. bat_now.time .. ") " 
--          elseif bat_now.status == "Discharging" then
--             bat_foot = "(Discharging: " .. bat_now.time .. ") " 
--          else
--             bat_foot = "(N/A) "
--          end
         
--          bat_p      = bat_now.perc .. "% " .. bat_foot
--          widget:set_markup(
--             markup.font(theme.font,
--                         markup(header_color, bat_header) .. bat_p))
--       end
-- })
-- local batbg = wibox.container.background(bat.widget, theme.bg_focus, widgetBackgroundShape)
-- local batwidget = wibox.container.margin(batbg, 0, 0, 5, 5)
-- batwidget:connect_signal("mouse::enter", function() end)

-- Brightness
-- local GET_BRIGHTNESS_CMD = "light -G"   -- "xbacklight -get"
-- theme.INC_BRIGHTNESS_CMD = "light -A 5" -- "xbacklight -inc 5"
-- theme.DEC_BRIGHTNESS_CMD = "light -U 5" -- "xbacklight -dec 5"

-- local brightness_icon = wibox.widget.imagebox(theme.brightness)
-- local brightness_text = wibox.widget.textbox()
-- local brightness_widget = wibox.widget {
--     brightness_icon,
--     brightness_text,
--     layout = wibox.layout.fixed.horizontal,
-- }

-- local brightness_bg = wibox.container.background(
--    brightness_widget, theme.bg_focus, widgetBackgroundShape)
-- local mybrightnesswidget = wibox.container.margin(brightness_bg, 0, 0, 5, 5)

-- function theme.update_brightness_widget()
--    awful.spawn.easy_async_with_shell(
--       GET_BRIGHTNESS_CMD,
--       function(stdout)
--          local brightness_level = tonumber(string.format("%.0f", stdout))
--          brightness_text:set_markup(
--             space3 ..
--                markup.font(
--                   theme.monofont,
--                   " BRT " .. brightness_level .. "% ") .. markup.font("Roboto 4", " "))
--    end)
-- end

-- brightness_text:connect_signal(
--    "button::press",
--    function(_,_,_,button)
--       if button == 4 then
--          awful.spawn(theme.INC_BRIGHTNESS_CMD, false)
--          theme.update_brightness_widget()
--       elseif button == 5 then
--          awful.spawn(theme.DEC_BRIGHTNESS_CMD, false)
--          theme.update_brightness_widget()
--       end
-- end)

-- ALSA volume bar
local volumeCmd = "amixer"
local volumeChannel = "PCM"
theme.volume = lain.widget.alsabar({
	  notification_preset = { font = theme.monofont, fg = "#FF00FF"},
	  --togglechannel = "IEC958,3",
      cmd = volumeCmd,
	  channel = volumeChannel,
	  width = 80, height = 10, border_width = 0,
	  colors = {
		 background = "#404040",
		 unmute     = carolinaBlueWeb,
		 mute       = "#FF9F9F"
	  },
})
theme.volume.bar.paddings = 0
theme.volume.bar.margins = 5
theme.volume.bar:buttons(
   awful.util.table.join(
    awful.button({}, 3, function() -- right click
          awful.spawn.with_shell(
             string.format(
                "%s set %s toggle",
                theme.volume.cmd,
                theme.volume.togglechannel or theme.volume.channel))
        theme.volume.update()
    end),
    awful.button({}, 4, function() -- scroll up
          awful.spawn.with_shell(
             string.format(
                "%s set %s 1%%+", theme.volume.cmd, theme.volume.channel))
        theme.volume.update()
    end),
    awful.button({}, 5, function() -- scroll down
          awful.spawn.with_shell(
             string.format(
                "%s set %s 1%%-", theme.volume.cmd, theme.volume.channel))
        theme.volume.update()
    end)
))

local volumewidget = wibox.container.background(
   theme.volume.bar, theme.bg_focus, widgetBackgroundShape)
volumewidget = wibox.container.margin(volumewidget, 0, 0, 5, 5)

-- GPU
local gputext = wibox.widget.textbox()
local gpuUpdate = function()
   local checkCmd = "gpustat --no-header | awk -F '|' '{print $2 $3}'"
   -- local checkCmd = 'gpustat --no-header'
   awful.spawn.easy_async_with_shell(
      checkCmd,
      function(out)
         gputext:set_markup(
            markup("#FFFFFF",
                   space2 
                      .. markup.font(theme.monofont, 'GPU:' .. out)))
   end)
end

local gpuwidget = wibox.container.margin(
   wibox.container.background(gputext, theme.bg_focus, widgetBackgroundShape),
   0, 0, 5, 5)
local gpuTimer = gears.timer {
   timeout = 2,
   call_now = true,
   autostart = false,
   callback = gpuUpdate}
gpuTimer:start()

-- CPU
local cpu_icon = wibox.widget.imagebox(theme.cpu)
local cpu = lain.widget.cpu({
      settings = function()
         widget:set_markup(
            space2
               .. markup.font(
                  theme.monofont,
                  "CPU " .. string.format("%2d", cpu_now.usage) .. "%")
               .. space2)
      end
})
local cpubg = wibox.container.background(
   cpu.widget, theme.bg_focus, widgetBackgroundShape)
local cpuwidget = wibox.container.margin(cpubg, 0, 0, 5, 5)

-- Mem
local mem = lain.widget.mem({
      settings = function()
         widget:set_markup(
            space2
               .. markup.font(
                  theme.monofont,
                  "MEM " .. string.format("%2d", mem_now.perc) .. "%")
               .. space2)
      end
})
local memWidgetBG = wibox.container.background(
   mem.widget, theme.bg_focus, widgetBackgroundShape)

local membg = wibox.container.background(
   mem.widget, theme.bg_focus, widgetBackgroundShape)
local memwidget = wibox.container.margin(membg, 0, 0, 5, 5)

-- Net
local net = lain.widget.net({
      settings = function()
         
         local function formatSpeed(input)
            local speedNameList = {'KB', 'MB', 'GB'}
            local base = math.log(input, 1024)
            
            if tonumber(input) < 1 then
               return string.format("%6.1f KB", tonumber(input))
            else
               return string.format(
                  "%6.1f %s",
                  math.pow(1024, base - math.floor(base)),
                  speedNameList[math.floor(base) + 1])
            end
         end -- of function
         
         widget:set_markup(
            "  ⬇ " .. markup.font(theme.monofont, formatSpeed(net_now.received))
               .. " - ⬆ " .. markup.font(theme.monofont, formatSpeed(net_now.sent)) .. "  ")
      end
})
local netbg = wibox.container.background(
   net.widget, theme.bg_focus, widgetBackgroundShape)
local networkwidget = wibox.container.margin(netbg, 0, 0, 5, 5)

-- Weather
local myweather = lain.widget.weather({
      city_id = 4460162, -- Chapel Hill
      units = "metric",
      notification_preset = {
         font = theme.monofont,
         bg = theme.bg_normal,
      },
      notification_text_fun = function(wn)
        -- time of data forecasted
        local day = os.date("%a %d", wn["dt"])
        -- weather condition
        local desc = wn["weather"][1]["description"]

        -- temperatures, units are defined above
        local tmin = math.floor(wn["temp"]["min"])   -- min daily
        local tmax = math.floor(wn["temp"]["max"])   -- max daily
        local tmor = math.floor(wn["temp"]["morn"])  -- morning
        local tday = math.floor(wn["temp"]["day"])   -- day
        local teve = math.floor(wn["temp"]["eve"])   -- evening
        local tnig = math.floor(wn["temp"]["night"]) -- night

        -- pressure, hPa
        local pres = math.floor(wn["pressure"])

        -- humidity, %
        local humi = math.floor(wn["humidity"])

        -- wind speed, miles/hour if units are imperial, meter/sec otherwise 
        local wspe = math.floor(wn["speed"])

        -- wind degrees, meteorological degrees
        local wdeg = math.floor(wn["deg"])

        -- cloudliness, %
        local clou = math.floor(wn["clouds"])

        -- format infos as you like, HTML text markup is allowed
        return string.format(
           "<br><b>%s</b>: %s<br>"
              .. "Temp:     min %d - max %d ℃<br>"
              .. "Wind:     %d mph at %d°<br>"
              .. "Cloud:    %d%%<br>"
              .. "Pressure: %d hPa<br>"
              .. "Humidity: %d%%<br>",
           day, desc,
           tmin, tmax,
           wspe, wdeg,
           clou,
           pres,
           humi)
    end,
    settings = function()
       if weather_now["main"]["temp"] then
          units = math.floor(weather_now["main"]["temp"])
       else
          units = "N/A"
       end
       widget:set_markup(
          markup("#FFFFFF",
                 space3
                    .. markup.font(theme.font, units  .. " ℃")))
    end
})

-- local weathertextbg = wibox.container.background(
--    myweather.widget, theme.bg_focus, widgetBackgroundShape)
-- local weathertextwidget = wibox.container.margin(weathertextbg, 0, 0, 5, 5)

-- local weathericonbg = wibox.container.background(
--    myweather.icon, theme.bg_focus, widgetBackgroundShape)
-- local weathericonwidget = wibox.container.margin(weathericonbg, 0, 0, 5, 5)

local weatherwidget = wibox.widget{
   layout=wibox.layout.fixed.horizontal,
   space2Widget,
   myweather.icon,
   myweather.widget,
   space2Widget
}

local myWeatherWidget = wibox.container.margin(
   wibox.container.background(
      weatherwidget, theme.bg_focus, widgetBackgroundShape),
   0, 0, 5, 5)

-- Launcher
-- local mylauncher = awful.widget.button({ image = theme.awesome_icon_launcher })
-- mylauncher:connect_signal(
--    "button::press", function() awful.util.mymainmenu:toggle() end)

-- Separators
-- local spr_small = wibox.widget.imagebox(theme.spr_small)
-- local spr_very_small = wibox.widget.imagebox(theme.spr_very_small)
-- local spr_right = wibox.widget.imagebox(theme.spr_right)
-- local spr_bottom_right = wibox.widget.imagebox(theme.spr_bottom_right)
-- local spr_left = wibox.widget.imagebox(theme.spr_left)
-- local bar = wibox.widget.imagebox(theme.bar)
-- local bottom_bar = wibox.widget.imagebox(theme.bottom_bar)

function theme.at_screen_connect(s)
   
   -- Setup according to Geometry
   local defaultLayout
   
    if s.geometry.width / s.geometry.height > 1 then
        defaultLayout = awful.layout.suit.tile
    else
        defaultLayout = awful.layout.suit.tile.top
    end

   -- Quake application
   s.quake = lain.util.quake({ app = "xterm", height = 0.35 })
   
   -- Tags
   awful.tag(awful.util.tagnames, s, defaultLayout)
   
   -- Create a promptbox for each screen
   s.mypromptbox = awful.widget.prompt{
      prompt = " Run: ",
      bg = theme.bg_focus}
   s.mypromptboxcontainer = wibox.container.margin(s.mypromptbox, 0, 0, 5, 5)

   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   s.mylayoutbox = awful.widget.layoutbox(s)
   s.mylayoutbox:buttons(
      awful.util.table.join(
         awful.button({ }, 1, function () awful.layout.inc( 1) end),
         awful.button({ }, 3, function () awful.layout.inc(-1) end),
         awful.button({ }, 4, function () awful.layout.inc( 1) end),
         awful.button({ }, 5, function () awful.layout.inc(-1) end)))

   mylayoutcont = wibox.container.background(
      -- s.mylayoutbox,
      wibox.widget{
         layout=wibox.layout.fixed.horizontal,
         space2Widget,
         s.mylayoutbox,
         space2Widget
      },
      theme.bg_focus, widgetBackgroundShape)
   s.mylayout = wibox.container.margin(mylayoutcont, 0, 0, 5, 5)

   -- Create a taglist widget
   local mytaglist = awful.widget.taglist(
      s, awful.widget.taglist.filter.all,
      awful.util.taglist_buttons)
   local mytaglistcont = wibox.container.background(
      wibox.widget{
         layout=wibox.layout.fixed.horizontal,
         space4Widget,
         mytaglist,
         space4Widget
      },
      theme.bg_focus, widgetBackgroundShape)
   s.mytag = wibox.container.margin(mytaglistcont, 0, 0, 5, 5)
   
   -- Create the indicator
   if screen:count() > 1 then
      s.focuswidget = wibox.widget {
         checked       = (s == awful.screen.focused()),
         color         = green, --beautiful.bg_normal,
         paddings      = 2,
         shape         = gears.shape['circle'],
         widget        = wibox.widget.checkbox,
         --    visible       = (s == awful.screen.focused()),
      }
      s.myfocuswidget = wibox.container.margin(s.focuswidget, 0, 0, 5, 5)
   else
      s.myfocuswidget = nil
   end
   
   -- Create a tasklist widget
   s.mytasklist = awful.widget.tasklist(
      s, awful.widget.tasklist.filter.currenttags,
      awful.util.tasklist_buttons,
      { bg_focus = theme.tasklist_bg_focus,
        fg_focus = theme.tasklist_fg_focus,
        shape = gears.shape.rounded_bar,
        shape_border_width = theme.tasklist_border_width,
        shape_border_color = theme.tasklist_border_color,
        align = "center" })

   -- Create the wibox
   s.mywibox = awful.wibar(
      { position = "top",
        screen = s,
        height = 32,
        bg     = theme.bg_normal})
   if s == screen.primary then
      s.mysystray = wibox.widget.systray()
      -- TODO: not sure if this is needed
      local mysystraybg = wibox.container.background(
         wibox.widget{
            layout=wibox.layout.fixed.horizontal,
            space4Widget,
            s.mysystray,
            space4Widget
         },
         theme.bg_focus_bare, widgetBackgroundShape)
      local mysystraycontainer = wibox.container.margin(mysystraybg, 0, 0, 5, 5)
      
      mytoprightwibox = {
         layout = wibox.layout.fixed.horizontal,
         spacing_widget = bar,
         spacing = 10,
         mysystraycontainer,
         -- VPN
         vpntextwidget,
         -- Net
         networkwidget,
         -- bat
         -- batwidget,
         -- cpu
         cpuwidget,
         -- mem
         memwidget,
         -- gpu
         gpuwidget,
         -- Volume
         -- volumewidget,
         -- weather
         myWeatherWidget,
         -- weathericonwidget,
         -- weathertextwidget,
         -- brightness
         -- mybrightnesswidget,
         -- cal
         calendarwidget,
         -- clock
         clockwidget,
         space2Widget
      }
   else
      mytoprightwibox = nil
   end
   
   -- Add widgets to the wibox
   s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
         layout = wibox.layout.fixed.horizontal,
         spacing_widget = bar,
         spacing = 10,
         s.myfocuswidget,
         -- spr_right,
         s.mytag,
         -- spr_small,
         -- s.mylayoutbox,
         s.mylayout,
         -- spr_small,
         s.mypromptboxcontainer,
      },
      nil, -- Center widgets
      mytoprightwibox,
   }
   
   -- Create the bottom wibox
   s.mybottomwibox = awful.wibar(
      {position = "bottom",
       screen = s,
       border_width = 0,
       height = 24,
       bg = theme.bg_normal})

   -- Add widgets to the bottom wibox
   s.mybottomwibox:setup {
      layout = wibox.layout.align.horizontal,
      nil,
      s.mytasklist, -- Middle widget
      nil -- Right widgets
   }
end

return theme
