mod_gui = require("mod-gui")

local item_sprites = {"inserter"}

local popup_frame = nil
local is_popup_visible = false

local gp_inserter_list = {}
local gp_belt_list = {}

local gp_selected_belt = nil
local gp_selected_inserter = nil

local gp_belt_override = false
local gp_inserter_override = false

local function build_popup(player, item_list, category, location)
    local screen_element    = player.gui.left
    local main_frame        = screen_element.add{type="frame", caption={"gui.select_tier"}, direction="vertical"}
    
    main_frame.location     = location

    player.opened           = main_frame

    local button_table      = main_frame.add{type="table", column_count=3}

    for i = 1, #item_list do
        local sprite_name = item_list[i]

        button_table.add{type="sprite-button", tags={class="gp_tier_selector", category=category, item=sprite_name}, sprite=("item/"..sprite_name)}
    end

    return main_frame
end

local function build_section(parent_frame, config)
    local container      = parent_frame.add{type="flow", direction="vertical"}

    local label          = container.add{type="label", caption=config.label}
    local icons_flow     = container.add{type="flow", direction="horizontal"}

    local generic_button = icons_flow.add{type="sprite-button", sprite=config.generic_sprite}
    local hand           = icons_flow.add{type="sprite", sprite="utility/hand", tags={class="hand"}}
    hand.style.padding   = 4

    local sprite         = (config.selected_item and {"item/"..config.selected_item} or {"utility/upgrade_blueprint"})[1]
    local selector       = icons_flow.add{type="sprite-button", sprite=sprite, name=config.selector_name}

    return container
end

local function build_interface(player)
    local player_global = global.players[player.index]
    local screen_element = player.gui.left

    local main_frame = screen_element.add{
        type="frame",
        name="gp_main_frame",
        caption={"gp.title"},
        direction="vertical",
        location={0, 300}
    }

    player.opened = main_frame
    
    local content_frame = main_frame.add{
        type="frame",
        name="content_frame",
        direction="vertical",
        style="gp_content_frame"
    }

    local sections = {

        -- selector_name: (string)      | The name used by the on_gui_click event 
        -- label: (localised string)    | Section label
        -- generic_sprite: (StringPath) | Path to the generic sprite, should be defined in data.lua
        -- selected_item: (item)        | Reference to the currently selected state variable

        belt = {
            selector_name = "belt_selector",
            label = {"gui.belt_label"},
            generic_sprite = "gp:generic-belt-sprite",
            selected_item = gp_selected_belt
        },
        inserter = {
            selector_name = "inserter_selector",
            label = {"gui.inserter_label"},
            generic_sprite = "gp:generic-inserter-sprite",
            selected_item = gp_selected_inserter
        }
    }

    for section_name, section_data in pairs(sections) do
        build_section(content_frame, section_data)
    end

    local line = content_frame.add{type="line"}
    line.style.padding = 4
   
end

local function toggle_interface(player)
    local main_frame = player.gui.left.gp_main_frame

    if main_frame == nil then
        build_interface(player)
    else
        main_frame.destroy()
    end
end

local function initialize_global(player)
    global.players[player.index] = { controls_active = true, button_count = 0, selected_item = nil }
end

local function setup_tiers()
    if game.active_mods["IndustrialRevolution3"] then
        game.print("IR3 installed!")

        gp_inserter_list    = {"burner-inserter","steam-inserter", "inserter", "fast-inserter", "stack-inserter"}
        gp_belt_list        = {"transport-belt", "fast-transport-belt", "express-transport-belt"}

    elseif game.active_mods["SpaceExploration"] then
        game.print("SE installed!")

    else
        gp_inserter_list    = {"burner-inserter", "inserter", "fast-inserter", "stack-inserter"}
        gp_belt_list        = {"transport-belt", "fast-transport-belt", "express-transport-belt"}
    end
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

    setup_tiers()
end)

script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)

    if player == nil then
        game.print("ERROR! NO PLAYER")
        do return end
    end

    initialize_global(player)

    local button_flow = mod_gui.get_button_flow(player)
    button_flow.add{type="sprite-button", name="gp_settings", sprite="utility/refresh", style=mod_gui.button_style}
end)


-- HORRIBLE CODE, FIND BETTER SOLUTIONS IDIOT
script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)

    if event.element.name == "gp_settings" then
        toggle_interface(player)
    end

    if event.element.tags.class == "hand" then
        if event.element.sprite == 'utility/hand_black' then
            event.element.sprite = 'utility/hand'
        else
            event.element.sprite = 'utility/hand_black'
        end
    end


    -- Figure out how to use relative coordinates instead of hardcoded ones
    if event.element.name == "belt_selector" then
        if(popup_frame) then
            popup_frame.destroy()
        end

        popup_frame = build_popup(player, gp_belt_list, "belt", {200, 350})
        is_popup_visible = true 
    end

    if event.element.name == "inserter_selector" then
        if(popup_frame) then
            popup_frame.destroy()
        end
        popup_frame = build_popup(player, gp_inserter_list, "inserter", {200, 350})
        is_popup_visible = true
    end

    if event.element.tags.class == "gp_tier_selector" then
        if event.element.tags.category == "belt" then
            gp_selected_belt = event.element.tags.item

            toggle_interface(player)
            toggle_interface(player)

        elseif event.element.tags.category == "inserter" then
            gp_selected_inserter = event.element.tags.item

            toggle_interface(player)
            toggle_interface(player)
        end

        if popup_frame then
            is_popup_visible = false
            popup_frame.destroy()
        end
    end
end)

script.on_event(defines.events.on_player_removed, function(event)
    global.players[event.player_index] = nil
end)

script.on_event(defines.events.on_player_pipette, function(event)
    local player = game.get_player(event.player_index)

    game.print("pipetting all over the place")
    if (player ~= nil) then
        local inventory = player.character.get_main_inventory()

        if(inventory ~= nil) then
            game.print(event.item.subgroup.name)
            if(event.item.subgroup.name == "belt") then
                player.cursor_stack.set_stack((inventory.find_item_stack(gp_selected_belt or "")))
            end
        end
    end
end)
