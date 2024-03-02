mod_gui = require("mod-gui")

local item_sprites = {"inserter"}

local function build_popup(player, item_list)
    local player_global = global.players[player.index]

    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="gp_popup_frame", caption={"gui.select_tier"}, direction="vertical"}

    main_frame.style.size = {200, 100}
    main_frame.auto_center = true

    player.opened = main_frame

    local button_table = main_frame.add{type="table", column_count=3}

    for i = 1, 3 do
        local sprite_name = item_list[i]

        button_table.add{type="sprite-button", sprite=("item/"..sprite_name)}
    end
end

local function build_interface(player)
    local player_global = global.players[player.index]

    local screen_element = player.gui.screen
    local main_frame = screen_element.add{type="frame", name="gp_main_frame", caption={"gp.title"}, direction="vertical"}

    main_frame.style.size = {200, 200}
    main_frame.auto_center = true

    player.opened = main_frame
    
    local content_frame = main_frame.add{type="frame", name="content_frame", direction="vertical", style="gp_content_frame"}
    
    local gp_belt_container = content_frame.add{type="flow", direction="vertical"}
    local gp_belt_label = gp_belt_container.add{type="label", caption={"gui.belt_label"}}
    local gp_belt_icons_flow = gp_belt_container.add{type="flow", direction="horizontal"}

    local gp_belt_generic_button = gp_belt_icons_flow.add{type="sprite-button", sprite="gp:generic-belt-sprite"}
    local gp_belt_hand = gp_belt_icons_flow.add{type="sprite", sprite="utility/hand", name="belts_hand"}
    gp_belt_hand.style.padding = 4
    local gp_belt_selector = gp_belt_icons_flow.add{type="sprite-button", sprite="utility/upgrade_blueprint", name="belt_selector"}

    local line = content_frame.add{type="line"}
    line.style.padding = 4
   
end

local function toggle_interface(player)
    local main_frame = player.gui.screen.gp_main_frame

    if main_frame == nil then
        build_interface(player)
    else
        main_frame.destroy()
    end
end

local function initialize_global(player)
    global.players[player.index] = { controls_active = true, button_count = 0, selected_item = nil }
end

script.on_init(function()
    local freeplay = remote.interfaces["freeplay"]
    if freeplay then  -- Disable freeplay popup-message
        if freeplay["set_skip_intro"] then remote.call("freeplay", "set_skip_intro", true) end
        if freeplay["set_disable_crashsite"] then remote.call("freeplay", "set_disable_crashsite", true) end
    end

    global.players = {}

    for _, player in pairs(game.players) do
        initialize_global(player)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    initialize_global(player)

    local button_flow = mod_gui.get_button_flow(player)
    button_flow.add{type="sprite-button", name="gp_settings", sprite="utility/refresh", style=mod_gui.button_style}

    game.print("bruh test!")

    if game.active_mods["IndustrialRevolution3"] then
        game.print("IR3 installed!")
    end

    if game.active_mods["SpaceExploration"] then
        game.print("SE installed!")
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "gp_settings" then
        local player = game.get_player(event.player_index)
        toggle_interface(player)
    end
    if event.element.name == "belts_hand" then
        if event.element.sprite == 'utility/hand_black' then
            event.element.sprite = 'utility/hand'
        else
            event.element.sprite = 'utility/hand_black'
        end
    end
    if event.element.name == "belt_selector" then
        build_popup(game.get_player(event.player_index), {"transport-belt", "fast-transport-belt", "express-transport-belt"})
    end
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)