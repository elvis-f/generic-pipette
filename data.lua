local function sprite(name)
    return '__generic-pipette__/graphics/icons/'..name
end

local styles = data.raw["gui-style"].default

styles["gp_content_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    vertically_stretchable = "on"
}

styles["gp_controls_flow"] = {
    type = "horizontal_flow_style",
    vertical_align = "center",
    horizontal_spacing = 16
}

styles["gp_deep_frame"] = {
    type = "frame_style",
    parent = "slot_button_deep_frame",
    vertically_stretchable = "off",
    horizontally_stretchable = "off",
    top_margin = 16,
    left_margin = 8,
    right_margin = 8,
    bottom_margin = 4
}

data:extend({
    {
        type = 'item-subgroup',
        group = 'logistics',
        subgroup = 'belt',
        name = 'gp:generic-belt',

        icon = sprite 'generic-belt.png',
        icon_size = 64,
    },
    {
        type = 'sprite',
        name = 'gp:generic-belt-sprite',
        filename = sprite 'generic-belt.png',

        width = 64,
        height = 64,
    },
    {
        type = 'sprite',
        name = 'gp:generic-inserter-sprite',
        filename = sprite 'generic-inserter.png',

        width = 64,
        height = 64,
    }
})