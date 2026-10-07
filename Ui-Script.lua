return function(Library, Window, Settings)
    -- สร้าง Tab และ Section สำหรับเมนู
    local VisualsTab = Window:Tab({ Name = "Visuals" })
    local VisualsEsp = VisualsTab:Section({ Name = "Esp", Side = "Left" })
    local VisualsMisc = VisualsTab:Section({ Name = "Misc", Side = "Right" })

    VisualsEsp:Toggle({
        Name = "Enabled", Default = false, Flag = "ESP_Enabled",
        Callback = function(Value) Settings.Enabled = Value end
    })

    local NameToggle = VisualsEsp:Toggle({
        Name = "Name", Default = false, Flag = "ESP_Name",
        Callback = function(Value) Settings.Name = Value end
    })
    NameToggle:Colorpicker({
        Name = "Name Color", Flag = "ESP_NameColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.NameColor = Value end
    })

    local BoxToggle = VisualsEsp:Toggle({
        Name = "Box", Default = false, Flag = "ESP_Box",
        Callback = function(Value) Settings.Box = Value end
    })
    BoxToggle:Colorpicker({
        Name = "Box Color", Flag = "ESP_BoxColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.BoxColor = Value end
    })

    VisualsEsp:Dropdown({
        Name = "Box Type", Flag = "ESP_BoxType", Items = {"Box", "Corner"}, Multi = false, Default = "Box",
        Callback = function(Value) Settings.BoxType = type(Value) == "table" and Value[1] or tostring(Value) end
    })

    local HealthBarToggle = VisualsEsp:Toggle({
        Name = "Health Bar", Default = false, Flag = "ESP_HealthBar",
        Callback = function(Value) Settings.HealthBar = Value end
    })
    HealthBarToggle:Colorpicker({
        Name = "Health Bar Color", Flag = "ESP_HealthBarColor", Default = Color3.fromRGB(0, 255, 0),
        Callback = function(Value) Settings.HealthBarColor = Value end
    })

    VisualsEsp:Dropdown({
        Name = "Health Bar Side", Flag = "ESP_HealthBarSide", Items = {"Left", "Right"}, Multi = false, Default = "Left",
        Callback = function(Value) Settings.HealthBarSide = type(Value) == "table" and Value[1] or tostring(Value) end
    })

    VisualsEsp:Toggle({
        Name = "Health Text", Default = false, Flag = "ESP_HealthText",
        Callback = function(Value) Settings.HealthText = Value end
    })

    local WeaponToggle = VisualsEsp:Toggle({
        Name = "Weapon ESP", Default = false, Flag = "ESP_Weapon",
        Callback = function(Value) Settings.Weapon = Value end
    })
    WeaponToggle:Colorpicker({
        Name = "Weapon Color", Flag = "ESP_WeaponColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.WeaponColor = Value end
    })

    local TracerToggle = VisualsEsp:Toggle({
        Name = "Tracers", Default = false, Flag = "ESP_Tracers",
        Callback = function(Value) Settings.Tracers = Value end
    })
    TracerToggle:Colorpicker({
        Name = "Tracer Color", Flag = "ESP_TracerColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.TracerColor = Value end
    })

    local DistanceToggle = VisualsEsp:Toggle({
        Name = "Distance", Default = false, Flag = "ESP_Distance",
        Callback = function(Value) Settings.Distance = Value end
    })
    DistanceToggle:Colorpicker({
        Name = "Distance Color", Flag = "ESP_DistanceColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.DistanceColor = Value end
    })

    local SkeletonToggle = VisualsEsp:Toggle({
        Name = "Skeleton", Default = false, Flag = "ESP_Skeleton",
        Callback = function(Value) Settings.Skeleton = Value end
    })
    SkeletonToggle:Colorpicker({
        Name = "Skeleton Color", Flag = "ESP_SkeletonColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.SkeletonColor = Value end
    })

    local ChamsToggle = VisualsEsp:Toggle({
        Name = "Chams", Default = false, Flag = "ESP_Chams",
        Callback = function(Value) Settings.Chams = Value end
    })
    ChamsToggle:Colorpicker({
        Name = "Chams Fill", Flag = "ESP_ChamsFillColor", Default = Color3.fromRGB(0, 251, 255),
        Callback = function(Value) Settings.ChamsFillColor = Value end
    })
    ChamsToggle:Colorpicker({
        Name = "Chams Outline", Flag = "ESP_ChamsOutlineColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.ChamsOutlineColor = Value end
    })

    VisualsEsp:Dropdown({
        Name = "Chams Material", Flag = "ESP_ChamsMaterial", Items = {"SmoothPlastic", "Neon", "Glass", "ForceField"}, Multi = false, Default = "SmoothPlastic",
        Callback = function(Value) Settings.ChamsMaterial = type(Value) == "table" and Value[1] or tostring(Value) end
    })

    VisualsEsp:Slider({
        Name = "Chams Fill Transparency", Default = 50, Min = 0, Max = 100, Inc = 1, Flag = "ESP_ChamsFillTransparency",
        Callback = function(Value) Settings.ChamsFillTransparency = Value end
    })
    VisualsEsp:Slider({
        Name = "Chams Outline Stroke", Default = 0, Min = 0, Max = 100, Inc = 1, Flag = "ESP_ChamsOutlineTransparency",
        Callback = function(Value) Settings.ChamsOutlineTransparency = Value end
    })

    local ChamsVisCheckToggle = VisualsEsp:Toggle({
        Name = "Chams VisCheck", Default = false, Flag = "ESP_ChamsVisCheck",
        Callback = function(Value) Settings.ChamsVisibleCheck = Value end
    })
    ChamsVisCheckToggle:Colorpicker({
        Name = "Visible Color", Flag = "ESP_ChamsVisColor", Default = Color3.fromRGB(0, 255, 0),
        Callback = function(Value) Settings.ChamsVisibleColor = Value end
    })
    ChamsVisCheckToggle:Colorpicker({
        Name = "Hidden Color", Flag = "ESP_ChamsHiddenColor", Default = Color3.fromRGB(255, 0, 0),
        Callback = function(Value) Settings.ChamsHiddenColor = Value end
    })

    local ArrowToggle = VisualsEsp:Toggle({
        Name = "Off-Screen Arrows", Default = false, Flag = "ESP_Arrows",
        Callback = function(Value) Settings.OffScreenArrows = Value end
    })
    ArrowToggle:Colorpicker({
        Name = "Arrow Color", Flag = "ESP_ArrowColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.ArrowColor = Value end
    })
    VisualsEsp:Slider({
        Name = "Arrow Size", Default = 22, Min = 10, Max = 40, Inc = 1, Flag = "ESP_ArrowSize",
        Callback = function(Value) Settings.ArrowSize = Value end
    })
    VisualsEsp:Slider({
        Name = "Arrow Radius", Default = 150, Min = 50, Max = 300, Inc = 10, Flag = "ESP_ArrowRadius",
        Callback = function(Value) Settings.ArrowRadius = Value end
    })
    VisualsEsp:Toggle({
        Name = "Arrow Distance", Default = false, Flag = "ESP_ArrowDistance",
        Callback = function(Value) Settings.ArrowDistanceText = Value end
    })
    VisualsEsp:Slider({
        Name = "Arrow Text Size", Default = 11, Min = 8, Max = 20, Inc = 1, Flag = "ESP_ArrowTextSize",
        Callback = function(Value) Settings.ArrowTextSize = Value end
    })
    VisualsEsp:Slider({
        Name = "Arrow Text Offset", Default = 24, Min = 10, Max = 60, Inc = 1, Flag = "ESP_ArrowTextOffset",
        Callback = function(Value) Settings.ArrowTextOffset = Value end
    })

    VisualsMisc:Toggle({
        Name = "Team Check", Default = false, Flag = "Misc_TeamCheck",
        Callback = function(Value) Settings.TeamCheck = Value end
    })
    VisualsMisc:Toggle({
        Name = "Visible Check", Default = false, Flag = "Misc_VisCheck",
        Callback = function(Value) Settings.VisCheck = Value end
    })
    VisualsMisc:Toggle({
        Name = "Fullbright", Default = false, Flag = "Misc_Fullbright",
        Callback = function(Value) Settings.Fullbright = Value end
    })
    VisualsMisc:Toggle({
        Name = "RemoveFog", Default = false, Flag = "Misc_RemoveFog",
        Callback = function(Value) Settings.RemoveFog = Value end
    })
    VisualsMisc:Toggle({
        Name = "Custom Time", Default = false, Flag = "Misc_CustomTime",
        Callback = function(Value) Settings.CustomTime = Value end
    })
    VisualsMisc:Slider({
        Name = "Time of Day", Default = 14, Min = 0, Max = 24, Inc = 0.5, Flag = "Misc_TimeOfDay",
        Callback = function(Value) Settings.TimeOfDay = Value end
    })

    local AmbientToggle = VisualsMisc:Toggle({
        Name = "Custom World Ambient Color", Default = false, Flag = "Misc_AmbientToggle",
        Callback = function(Value) Settings.AmbientColorEnabled = Value end
    })
    AmbientToggle:Colorpicker({
        Name = "Ambient Color", Flag = "Misc_AmbientColor", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value) Settings.AmbientColor = Value end
    })

    VisualsMisc:Slider({
        Name = "Text Size", Default = 14, Min = 10, Max = 24, Inc = 1, Flag = "Misc_TextSize",
        Callback = function(Value) Settings.TextSize = Value end
    })
    VisualsMisc:Slider({
        Name = "Max Distance", Default = 1000, Min = 100, Max = 5000, Inc = 50, Flag = "Misc_MaxDistance",
        Callback = function(Value) Settings.MaxDistance = Value end
    })
end
