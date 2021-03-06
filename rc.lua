-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Load Debian menu entries
require("debian.menu")
-- Load Vicious widget library
vicious = require("vicious")

-- For volume widget
cardid = 0
channel = "Master"
muted = false
-- channel = "Headphone"

-- For i3lock keybinding
function lock()
    awful.util.spawn_with_shell("i3lock -i /home/ajclisso/Dropbox/Work/Pictures/Backgrounds/RedLock.png && xset r rate 300 60")
end

function volume (mode, widget)
   if mode == "update" then
       local status = io.popen("amixer -c " .. cardid .. " -- sget " .. channel):read("*all")

       local volume = string.match(status, "(%d?%d?%d)%%")

       status = string.match(status, "%[(o[^%]]*)%]")

       if string.find(status, "on", 1, true) then
           widget:bar_properties_set("vol", {["bg"] = "#000000"})
       else
           widget:bar_properties_set("vol", {["bg"] = "#cc3333"})
       end
       widget:bar_data_add("vol", volume)
   elseif mode == "up" then
       awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 9%+")
       volume("update", widget)
   elseif mode == "down" then
       awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. channel .. " 9%-")
       volume("update", widget)
   elseif mode == "mute" then
       if muted then
           awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. "Master" .. " toggle")
           os.execute("sleep " .. tonumber(0.1))
           awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. "Headphone" .. " toggle")
           muted = false
           volume("update", widget)
        else
           awful.util.spawn("amixer -q -c " .. cardid .. " sset " .. "Master" .. " toggle")
           muted = true
           volume("update", widget)
       end
   end
end

function spotcmd(cmd)
    if cmd == "next" then
        awful.util.spawn("/home/ajclisso/Code/Python/PySpotifyInfo/spotify_control.py -c next")
    elseif cmd == "prev" then
        awful.util.spawn("/home/ajclisso/Code/Python/PySpotifyInfo/spotify_control.py -c previous")
    elseif cmd == "play" then
        awful.util.spawn("/home/ajclisso/Code/Python/PySpotifyInfo/spotify_control.py -c pp")
    end
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/themes/red/theme.lua")

-- This is used later as the default terminal and editor to run.
-- terminal = "x-terminal-emulator"
terminal = "xterm -fg white -bg black -T 'Terminal' -fa 'Deja Vu Sans Mono' -fs '11'"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.floating,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
-- Original code:
-- for s = 1, screen.count() do
--     -- Each screen has its own tag table.
--     tags[s] = awful.tag({ 1, 2, 3, 4 }, s, layouts[1])
-- end
tags[1] = awful.tag({ "1 Main", "2 Logs", "3 IM", "4 Misc"}, 1, layouts[1])
tags[2] = awful.tag({ "9 Chrome", "0 Spotify"}, 2, layouts[1])
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
clockwidget = awful.widget.textclock({ align = "right" }, "%a %b %d, %I:%M ", 20)

-- Create a volume widget http://awesome.naquadah.org/wiki/Farhavens_volume_widget
pb_volume = widget({ type = "progressbar", name = "pb_volume", align = "left" })
pb_volume.width = 12
pb_volume.height = 1
pb_volume.border_padding = 1
pb_volume.border_width = 1
pb_volume.ticks_count = 11
pb_volume.gap = 0
pb_volume.vertical = true

pb_volume:bar_properties_set("vol",
{
  ["bg"] = "#000000",
  ["fg"] = "green",
  ["fg_center"] = "yellow",
  ["fg_end"] = "red",
  ["fg_off"] = "black",
  ["border_color"] = "#999933",
  ["min_value"] = 0,
  ["max_value"] = 100,
  ["reverse"] = false
})

volume("update", pb_volume)

-- CPU usage widget
cpuwidget = widget({ type = "textbox" })
vicious.register(cpuwidget, vicious.widgets.cpu, " $1% | ")

-- RAM usage widget
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "$2MB | ", 2)

-- My Vicious widgets
spotwidget = widget({ type = "textbox" })
spotwidget.text = ""

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "bottom", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            pb_volume,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        s == 2 and clockwidget or nil,
        s == 2 and memwidget or nil,
        s == 2 and cpuwidget or nil,
        s == 1 and mysystray or nil,
        s == 1 and spotwidget or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "r",     function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "space", function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

-- Audio keybindings
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioRaiseVolume",function() volume("up", pb_volume) end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioLowerVolume",function() volume("down", pb_volume) end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioMute",function() volume("mute", pb_volume) end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioNext",function() spotcmd("next") end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioPrev",function() spotcmd("prev") end))
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "XF86AudioPlay",function() spotcmd("play") end))

-- i3lock keybinding
globalkeys = awful.util.table.join(globalkeys, awful.key({ }, "Pause", function() lock() end))

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Original code:
-- Compute the maximum number of digit we need, limited to 9
-- keynumber = 0
-- for s = 1, screen.count() do
--    keynumber = math.min(9, math.max(#tags[s], keynumber));
-- end
keynumber = 10

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        if     i == 1 then
                            awful.tag.viewonly(tags[1][1])  -- Main
                            awful.screen.focus(1)
                        elseif i == 2 then
                            awful.tag.viewonly(tags[1][2])  -- Logs
                            awful.screen.focus(1)
                        elseif i == 3 then
                            awful.tag.viewonly(tags[1][3])  -- IM
                            awful.screen.focus(1)
                        elseif i == 4 then
                            awful.tag.viewonly(tags[1][4])  -- Misc
                            awful.screen.focus(1)
                        elseif i == 9 then
                            awful.tag.viewonly(tags[2][1])  -- Chrome
                            awful.screen.focus(2)
                        elseif i == 10 then
                            awful.tag.viewonly(tags[2][2]) -- Pidgin
                            awful.screen.focus(2)
                        end
                        -- Original code:
                        -- local screen = mouse.screen
                        -- if tags[screen][i] then
                        --     awful.tag.viewonly(tags[screen][i])
                        -- end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
awful.hooks.timer.register(10, function() volume("update", pb_volume) end)

awful.util.spawn_with_shell("python3 ~/Code/Python/Python/scroll.py &")
awful.util.spawn_with_shell("dropbox start")
