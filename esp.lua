-- === การตั้งค่าเฉพาะ ESP & Visuals ===
local Settings = {
    -- ESP & World Settings
    Enabled = false,
    MaxDistance = 1000,
    TextSize = 14,
    Name = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    Box = false,
    BoxType = "Box",
    BoxColor = Color3.fromRGB(255, 255, 255),
    HealthBar = false,
    HealthBarSide = "Left",
    DynamicHealthColor = true,
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthText = false,
    Weapon = false,
    WeaponColor = Color3.fromRGB(255, 255, 255),
    VisCheck = false,
    Tracers = false,
    TracerColor = Color3.fromRGB(255, 255, 255),
    Distance = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    Skeleton = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    Chams = false,
    ChamsFillColor = Color3.fromRGB(0, 251, 255),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    ChamsOutlineTransparency = 0,
    ChamsFillTransparency = 50,
    ChamsMaterial = "SmoothPlastic",
    ChamsVisibleCheck = false,
    ChamsVisibleColor = Color3.fromRGB(0, 255, 0),
    ChamsHiddenColor = Color3.fromRGB(255, 0, 0),
    OffScreenArrows = false,
    ArrowColor = Color3.fromRGB(255, 255, 255),
    ArrowSize = 22,
    ArrowRadius = 150,
    ArrowDistanceText = false,
    ArrowTextSize = 11,
    ArrowTextOffset = 24,
    TeamCheck = false,
    Fullbright = false,
    RemoveFog = false,
    CustomTime = false,
    TimeOfDay = 14,
    AmbientColorEnabled = false,
    AmbientColor = Color3.fromRGB(255, 255, 255),
    Thickness = 1.5
}

local ESPData = {}
local ChamsData = {}

local function createDrawing(class, properties)
    local draw = Drawing.new(class)
    for prop, val in pairs(properties) do
        draw[prop] = val
    end
    return draw
end

local function removeChams(player)
    if ChamsData[player] then
        if ChamsData[player].Highlight then
            ChamsData[player].Highlight:Destroy()
        end
        ChamsData[player] = nil
    end
end

local function removeESP(player)
    if ESPData[player] then
        if ESPData[player].Connection then ESPData[player].Connection:Disconnect() end
        if ESPData[player].Box then ESPData[player].Box:Remove() end
        if ESPData[player].BoxOutline then ESPData[player].BoxOutline:Remove() end
        
        if ESPData[player].CornerLines then
            for _, line in pairs(ESPData[player].CornerLines) do
                line:Remove()
            end
        end

        if ESPData[player].HealthBar then ESPData[player].HealthBar:Remove() end
        if ESPData[player].HealthBarOutline then ESPData[player].HealthBarOutline:Remove() end
        if ESPData[player].HealthTag then ESPData[player].HealthTag:Remove() end
        if ESPData[player].WeaponTag then ESPData[player].WeaponTag:Remove() end
        if ESPData[player].NameTag then ESPData[player].NameTag:Remove() end
        if ESPData[player].DistanceTag then ESPData[player].DistanceTag:Remove() end
        if ESPData[player].Tracer then ESPData[player].Tracer:Remove() end
        if ESPData[player].Arrow then ESPData[player].Arrow:Remove() end
        if ESPData[player].ArrowText then ESPData[player].ArrowText:Remove() end
        
        if ESPData[player].SkeletonLines then
            for _, line in pairs(ESPData[player].SkeletonLines) do
                line:Remove()
            end
        end
        ESPData[player] = nil
    end
    removeChams(player)
end

local function addPlayer(player)
    if player == LocalPlayer then return end
    
    local skeletonJoints = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }

    local skeletonJointsR6 = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    }

    local pData = {
        BoxOutline = createDrawing("Square", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Filled = false, Visible = false}),
        Box = createDrawing("Square", {Color = Settings.BoxColor, Thickness = Settings.Thickness, Filled = false, Visible = false}),
        CornerLines = {},
        HealthBarOutline = createDrawing("Square", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Filled = true, Visible = false}),
        HealthBar = createDrawing("Square", {Color = Settings.HealthBarColor, Thickness = 1, Filled = true, Visible = false}),
        HealthTag = createDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Size = 12, Center = false, Outline = true, Visible = false}),
        WeaponTag = createDrawing("Text", {Color = Settings.WeaponColor, Size = Settings.TextSize, Center = true, Outline = true, Visible = false}),
        NameTag = createDrawing("Text", {Color = Settings.NameColor, Size = Settings.TextSize, Center = true, Outline = true, Visible = false}),
        DistanceTag = createDrawing("Text", {Color = Settings.DistanceColor, Size = Settings.TextSize, Center = true, Outline = true, Visible = false}),
        Tracer = createDrawing("Line", {Color = Settings.TracerColor, Thickness = 1, Visible = false}),
        Arrow = createDrawing("Triangle", {Color = Settings.ArrowColor, Filled = true, Visible = false, Transparency = 0.8}),
        ArrowText = createDrawing("Text", {Color = Color3.fromRGB(255, 255, 255), Size = 11, Center = true, Outline = true, Visible = false}),
        SkeletonLines = {},
        LastVisCheck = 0,
        CachedVisResult = true
    }

    for i = 1, 16 do
        pData.CornerLines[i] = createDrawing("Line", {Color = Settings.BoxColor, Thickness = 1.5, Visible = false})
    end

    for i = 1, 14 do
        pData.SkeletonLines[i] = createDrawing("Line", {Color = Settings.SkeletonColor, Thickness = 1, Visible = false, Transparency = 0.8})
    end

    ESPData[player] = pData

    local highlight = Instance.new("Highlight")
    highlight.Adornee = nil
    highlight.FillColor = Settings.ChamsFillColor
    highlight.OutlineColor = Settings.ChamsOutlineColor
    highlight.FillTransparency = Settings.ChamsFillTransparency / 100
    highlight.OutlineTransparency = Settings.ChamsOutlineTransparency / 100
    highlight.Enabled = false
    highlight.Parent = game:GetService("CoreGui")
    ChamsData[player] = {Highlight = highlight}

    local function hideAll()
        pData.Box.Visible = false
        pData.BoxOutline.Visible = false
        for _, line in pairs(pData.CornerLines) do line.Visible = false end
        pData.HealthBar.Visible = false
        pData.HealthBarOutline.Visible = false
        pData.HealthTag.Visible = false
        pData.WeaponTag.Visible = false
        pData.NameTag.Visible = false
        pData.DistanceTag.Visible = false
        pData.Tracer.Visible = false
        pData.Arrow.Visible = false
        pData.ArrowText.Visible = false
        for _, line in pairs(pData.SkeletonLines) do
            line.Visible = false
        end
        highlight.Enabled = false
    end

    pData.Connection = RunService.RenderStepped:Connect(function()
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")

        if not Settings.Enabled or not rootPart or not humanoid or not head or humanoid.Health <= 0 then
            hideAll()
            return
        end

        if Settings.TeamCheck and player.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
            hideAll()
            return
        end

        local distance = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude or 0
        if distance > Settings.MaxDistance then
            hideAll()
            return
        end

        local currentTime = tick()
        if currentTime - pData.LastVisCheck > 0.2 then
            pData.LastVisCheck = currentTime
            local isVisible = true
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                local origin = Camera.CFrame.Position
                local targetPos = head.Position
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                
                local filterTable = {LocalPlayer.Character, character}
                if Camera then table.insert(filterTable, Camera) end
                raycastParams.FilterDescendantsInstances = filterTable
                
                local result = workspace:Raycast(origin, targetPos - origin, raycastParams)
                if result then
                    isVisible = false
                end
            end
            pData.CachedVisResult = isVisible
        end

        if Settings.VisCheck and not pData.CachedVisResult then
            hideAll()
            return
        end

        if Settings.Chams then
            highlight.Adornee = character
            if Settings.ChamsVisibleCheck then
                if pData.CachedVisResult then
                    highlight.FillColor = Settings.ChamsVisibleColor
                else
                    highlight.FillColor = Settings.ChamsHiddenColor
                end
            else
                highlight.FillColor = Settings.ChamsFillColor
            end
            highlight.OutlineColor = Settings.ChamsOutlineColor
            highlight.FillTransparency = Settings.ChamsFillTransparency / 100
            highlight.OutlineTransparency = Settings.ChamsOutlineTransparency / 100
            
            for _, desc in ipairs(character:GetDescendants()) do
                if desc:IsA("BasePart") then
                    pcall(function()
                        desc.Material = Enum.Material[Settings.ChamsMaterial] or Enum.Material.SmoothPlastic
                    end)
                end
            end

            highlight.Enabled = true
        else
            highlight.Enabled = false
            if character then
                for _, desc in ipairs(character:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        pcall(function()
                            desc.Material = Enum.Material.SmoothPlastic
                        end)
                    end
                end
            end
        end

        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

        if not onScreen then
            hideAll()
            if Settings.OffScreenArrows then
                local camPos = Camera.CFrame.Position
                local camLook = Camera.CFrame.LookVector
                local relPos = rootPart.Position - camPos
                local relFlat = Vector3.new(relPos.X, 0, relPos.Z).Unit
                local lookFlat = Vector3.new(camLook.X, 0, camLook.Z).Unit
                
                local dot = lookFlat:Dot(relFlat)
                local cross = lookFlat:Cross(relFlat).Y
                local angle = math.acos(math.clamp(dot, -1, 1))
                if cross < 0 then angle = -angle end

                local viewCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local radius = Settings.ArrowRadius
                local arrowPos = viewCenter + Vector2.new(math.cos(angle - math.pi/2), math.sin(angle - math.pi/2)) * radius

                local size = Settings.ArrowSize
                local dir = (viewCenter - arrowPos).Unit
                local p1 = arrowPos
                local p2 = arrowPos + Vector2.new(-dir.Y, dir.X) * (size / 2) - dir * size
                local p3 = arrowPos + Vector2.new(dir.Y, -dir.X) * (size / 2) - dir * size

                pData.Arrow.PointA = p1
                pData.Arrow.PointB = p2
                pData.Arrow.PointC = p3
                pData.Arrow.Color = Settings.ArrowColor
                pData.Arrow.Visible = true

                if Settings.ArrowDistanceText then
                    pData.ArrowText.Text = math.floor(distance) .. "m"
                    pData.ArrowText.Size = Settings.ArrowTextSize
                    pData.ArrowText.Position = arrowPos + (dir * -Settings.ArrowTextOffset)
                    pData.ArrowText.Visible = true
                else
                    pData.ArrowText.Visible = false
                end
            end
            return
        else
            pData.Arrow.Visible = false
            pData.ArrowText.Visible = false
        end

        local topWorld = head.Position + Vector3.new(0, 0.8, 0)
        local bottomWorld = rootPart.Position - Vector3.new(0, 3, 0)

        local topPos = Camera:WorldToViewportPoint(topWorld)
        local bottomPos = Camera:WorldToViewportPoint(bottomWorld)

        local boxHeight = math.abs(topPos.Y - bottomPos.Y)
        local boxWidth = boxHeight / 2.0 
        
        local boxX = rootPos.X - (boxWidth / 2)
        local boxY = topPos.Y

        if Settings.Box then
            if Settings.BoxType == "Box" then
                for _, line in pairs(pData.CornerLines) do line.Visible = false end

                pData.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                pData.BoxOutline.Position = Vector2.new(boxX, boxY)
                pData.BoxOutline.Visible = true

                pData.Box.Size = Vector2.new(boxWidth, boxHeight)
                pData.Box.Position = Vector2.new(boxX, boxY)
                pData.Box.Color = Settings.BoxColor
                pData.Box.Visible = true
            elseif Settings.BoxType == "Corner" then
                pData.Box.Visible = false
                pData.BoxOutline.Visible = false

                local lengthX = boxWidth / 4
                local lengthY = boxHeight / 4
                local lines = pData.CornerLines

                local outlineColor = Color3.fromRGB(0, 0, 0)
                local boxColor = Settings.BoxColor

                lines[1].From = Vector2.new(boxX, boxY) lines[1].To = Vector2.new(boxX + lengthX, boxY) lines[1].Color = outlineColor lines[1].Thickness = 2.5
                lines[2].From = Vector2.new(boxX, boxY) lines[2].To = Vector2.new(boxX + lengthX, boxY) lines[2].Color = boxColor lines[2].Thickness = 1.25
                
                lines[3].From = Vector2.new(boxX, boxY) lines[3].To = Vector2.new(boxX, boxY + lengthY) lines[3].Color = outlineColor lines[3].Thickness = 2.5
                lines[4].From = Vector2.new(boxX, boxY) lines[4].To = Vector2.new(boxX, boxY + lengthY) lines[4].Color = boxColor lines[4].Thickness = 1.25

                lines[5].From = Vector2.new(boxX + boxWidth, boxY) lines[5].To = Vector2.new(boxX + boxWidth - lengthX, boxY) lines[5].Color = outlineColor lines[5].Thickness = 2.5
                lines[6].From = Vector2.new(boxX + boxWidth, boxY) lines[6].To = Vector2.new(boxX + boxWidth - lengthX, boxY) lines[6].Color = boxColor lines[6].Thickness = 1.25
                
                lines[7].From = Vector2.new(boxX + boxWidth, boxY) lines[7].To = Vector2.new(boxX + boxWidth, boxY + lengthY) lines[7].Color = outlineColor lines[7].Thickness = 2.5
                lines[8].From = Vector2.new(boxX + boxWidth, boxY) lines[8].To = Vector2.new(boxX + boxWidth, boxY + lengthY) lines[8].Color = boxColor lines[8].Thickness = 1.25

                lines[9].From = Vector2.new(boxX, boxY + boxHeight) lines[9].To = Vector2.new(boxX + lengthX, boxY + boxHeight) lines[9].Color = outlineColor lines[9].Thickness = 2.5
                lines[10].From = Vector2.new(boxX, boxY + boxHeight) lines[10].To = Vector2.new(boxX + lengthX, boxY + boxHeight) lines[10].Color = boxColor lines[10].Thickness = 1.25
                
                lines[11].From = Vector2.new(boxX, boxY + boxHeight) lines[11].To = Vector2.new(boxX, boxY + boxHeight - lengthY) lines[11].Color = outlineColor lines[11].Thickness = 2.5
                lines[12].From = Vector2.new(boxX, boxY + boxHeight) lines[12].To = Vector2.new(boxX, boxY + boxHeight - lengthY) lines[12].Color = boxColor lines[12].Thickness = 1.25

                lines[13].From = Vector2.new(boxX + boxWidth, boxY + boxHeight) lines[13].To = Vector2.new(boxX + boxWidth - lengthX, boxY + boxHeight) lines[13].Color = outlineColor lines[13].Thickness = 2.5
                lines[14].From = Vector2.new(boxX + boxWidth, boxY + boxHeight) lines[14].To = Vector2.new(boxX + boxWidth - lengthX, boxY + boxHeight) lines[14].Color = boxColor lines[14].Thickness = 1.25
                
                lines[15].From = Vector2.new(boxX + boxWidth, boxY + boxHeight) lines[15].To = Vector2.new(boxX + boxWidth, boxY + boxHeight - lengthY) lines[15].Color = outlineColor lines[15].Thickness = 2.5
                lines[16].From = Vector2.new(boxX + boxWidth, boxY + boxHeight) lines[16].To = Vector2.new(boxX + boxWidth, boxY + boxHeight - lengthY) lines[16].Color = boxColor lines[16].Thickness = 1.25

                for i = 1, 16 do
                    lines[i].Visible = true
                end
            else
                pData.Box.Visible = false
                pData.BoxOutline.Visible = false
                for _, line in pairs(pData.CornerLines) do line.Visible = false end
            end
        else
            pData.Box.Visible = false
            pData.BoxOutline.Visible = false
            for _, line in pairs(pData.CornerLines) do line.Visible = false end
        end

        if Settings.HealthBar then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = boxHeight * healthPercent
            local barX = (Settings.HealthBarSide == "Left") and (boxX - 5) or (boxX + boxWidth + 2)
            
            pData.HealthBarOutline.Size = Vector2.new(3, boxHeight)
            pData.HealthBarOutline.Position = Vector2.new(barX, boxY)
            pData.HealthBarOutline.Visible = true

            pData.HealthBar.Size = Vector2.new(1, barHeight)
            pData.HealthBar.Position = Vector2.new(barX + 1, boxY + boxHeight - barHeight)
            
            if Settings.DynamicHealthColor then
                pData.HealthBar.Color = Color3.fromHSV(healthPercent * 0.3, 1, 1)
            else
                pData.HealthBar.Color = Settings.HealthBarColor
            end
            pData.HealthBar.Visible = true

            if Settings.HealthText then
                pData.HealthTag.Text = math.floor(humanoid.Health)
                pData.HealthTag.Size = 12
                if Settings.HealthBarSide == "Left" then
                    pData.HealthTag.Position = Vector2.new(barX - 20, boxY + boxHeight - barHeight - 5)
                else
                    pData.HealthTag.Position = Vector2.new(barX + 6, boxY + boxHeight - barHeight - 5)
                end
                pData.HealthTag.Visible = true
            else
                pData.HealthTag.Visible = false
            end
        else
            pData.HealthBar.Visible = false
            pData.HealthBarOutline.Visible = false
            pData.HealthTag.Visible = false
        end

        if Settings.Name then
            pData.NameTag.Text = player.Name
            pData.NameTag.Size = Settings.TextSize
            pData.NameTag.Position = Vector2.new(boxX + (boxWidth / 2), boxY - Settings.TextSize - 4)
            pData.NameTag.Color = Settings.NameColor
            pData.NameTag.Visible = true
        else
            pData.NameTag.Visible = false
        end

        if Settings.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pData.DistanceTag.Text = "[" .. math.floor(distance) .. "m]"
            pData.DistanceTag.Size = Settings.TextSize
            pData.DistanceTag.Position = Vector2.new(boxX + (boxWidth / 2), boxY + boxHeight + 2)
            pData.DistanceTag.Color = Settings.DistanceColor
            pData.DistanceTag.Visible = true
        else
            pData.DistanceTag.Visible = false
        end

        if Settings.Weapon then
            local tool = character:FindFirstChildOfClass("Tool")
            pData.WeaponTag.Text = tool and tool.Name or "None"
            pData.WeaponTag.Size = Settings.TextSize
            pData.WeaponTag.Position = Vector2.new(boxX + (boxWidth / 2), boxY + boxHeight + (Settings.Distance and 18 or 2))
            pData.WeaponTag.Color = Settings.WeaponColor
            pData.WeaponTag.Visible = true
        else
            pData.WeaponTag.Visible = false
        end

        if Settings.Tracers then
            pData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            pData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            pData.Tracer.Color = Settings.TracerColor
            pData.Tracer.Visible = true
        else
            pData.Tracer.Visible = false
        end

        if Settings.Skeleton then
            local joints = humanoid.RigType == Enum.HumanoidRigType.R15 and skeletonJoints or skeletonJointsR6
            for i, joint in ipairs(joints) do
                local partA = character:FindFirstChild(joint[1])
                local partB = character:FindFirstChild(joint[2])
                local line = pData.SkeletonLines[i]

                if partA and partB and line then
                    local posA, onScreenA = Camera:WorldToViewportPoint(partA.Position)
                    local posB, onScreenB = Camera:WorldToViewportPoint(partB.Position)

                    if onScreenA or onScreenB then
                        line.From = Vector2.new(posA.X, posA.Y)
                        line.To = Vector2.new(posB.X, posB.Y)
                        line.Color = Settings.SkeletonColor
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    if line then line.Visible = false end
                end
            end
        else
            for _, line in pairs(pData.SkeletonLines) do
                line.Visible = false
            end
        end
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeESP(player)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do 
    addPlayer(player) 
end

Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if Settings.Fullbright then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end

    if Settings.RemoveFog then
        Lighting.FogEnd = 999999
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                v.Density = 0
            end
        end
    else
        Lighting.FogEnd = OriginalLighting.FogEnd
    end

    if Settings.CustomTime then
        Lighting.ClockTime = Settings.TimeOfDay
    else
        Lighting.ClockTime = OriginalLighting.ClockTime
    end

    if Settings.AmbientColorEnabled then
        Lighting.Ambient = Settings.AmbientColor
    else
        Lighting.Ambient = OriginalLighting.Ambient
    end
end)

-----------------------------------------------------------------
-- UI Elements (Visuals & Misc)
-----------------------------------------------------------------

VisualsEsp:Toggle({
    Name = "Enabled", 
    Default = false, 
    Flag = "ESP_Enabled",
    Callback = function(Value)
        Settings.Enabled = Value
    end
})

local NameToggle = VisualsEsp:Toggle({
    Name = "Name", 
    Default = false, 
    Flag = "ESP_Name",
    Callback = function(Value)
        Settings.Name = Value
    end
})

NameToggle:Colorpicker({ 
    Name = "Name Color", 
    Flag = "ESP_NameColor", 
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value, Alpha)
        Settings.NameColor = Value
    end
})

local BoxToggle = VisualsEsp:Toggle({
    Name = "Box", 
    Default = false, 
    Flag = "ESP_Box",
    Callback = function(Value)
        Settings.Box = Value
    end
})

BoxToggle:Colorpicker({ 
    Name = "Box Color", 
    Flag = "ESP_BoxColor", 
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value, Alpha)
        Settings.BoxColor = Value
    end
})

VisualsEsp:Dropdown({
    Name = "Box Type", 
    Flag = "ESP_BoxType", 
    Items = {"Box", "Corner"}, 
    Multi = false,
    Default = "Box",
    Callback = function(Value)
        if type(Value) == "table" then
            Settings.BoxType = Value[1] or table.concat(Value, "")
        else
            Settings.BoxType = tostring(Value)
        end
    end
})

local HealthBarToggle = VisualsEsp:Toggle({
    Name = "Health Bar", 
    Default = false, 
    Flag = "ESP_HealthBar",
    Callback = function(Value)
        Settings.HealthBar = Value
    end
})

HealthBarToggle:Colorpicker({ 
    Name = "Health Bar Color", 
    Flag = "ESP_HealthBarColor", 
    Default = Color3.fromRGB(0, 255, 0), 
    Callback = function(Value, Alpha)
        Settings.HealthBarColor = Value
    end
})

VisualsEsp:Dropdown({
    Name = "Health Bar Side",
    Flag = "ESP_HealthBarSide",
    Items = {"Left", "Right"},
    Multi = false,
    Default = "Left",
    Callback = function(Value)
        Settings.HealthBarSide = type(Value) == "table" and (Value[1] or "Left") or tostring(Value)
    end
})

VisualsEsp:Toggle({
    Name = "Health Text",
    Default = false,
    Flag = "ESP_HealthText",
    Callback = function(Value)
        Settings.HealthText = Value
    end
})

local WeaponToggle = VisualsEsp:Toggle({
    Name = "Weapon ESP",
    Default = false,
    Flag = "ESP_Weapon",
    Callback = function(Value)
        Settings.Weapon = Value
    end
})

WeaponToggle:Colorpicker({
    Name = "Weapon Color",
    Flag = "ESP_WeaponColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        Settings.WeaponColor = Value
    end
})

local TracerToggle = VisualsEsp:Toggle({
    Name = "Tracers", 
    Default = false, 
    Flag = "ESP_Tracers",
    Callback = function(Value)
        Settings.Tracers = Value
    end
})

TracerToggle:Colorpicker({ 
    Name = "Tracer Color", 
    Flag = "ESP_TracerColor", 
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value, Alpha)
        Settings.TracerColor = Value
    end
})

local DistanceToggle = VisualsEsp:Toggle({
    Name = "Distance", 
    Default = false, 
    Flag = "ESP_Distance",
    Callback = function(Value)
        Settings.Distance = Value
    end
})

DistanceToggle:Colorpicker({ 
    Name = "Distance Color", 
    Flag = "ESP_DistanceColor", 
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value, Alpha)
        Settings.DistanceColor = Value
    end
})

local SkeletonToggle = VisualsEsp:Toggle({
    Name = "Skeleton", 
    Default = false, 
    Flag = "ESP_Skeleton",
    Callback = function(Value)
        Settings.Skeleton = Value
    end
})

SkeletonToggle:Colorpicker({ 
    Name = "Skeleton Color", 
    Flag = "ESP_SkeletonColor", 
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value, Alpha)
        Settings.SkeletonColor = Value
    end
})

local ChamsToggle = VisualsEsp:Toggle({
    Name = "Chams", 
    Default = false, 
    Flag = "ESP_Chams",
    Callback = function(Value)
        Settings.Chams = Value
    end
})

ChamsToggle:Colorpicker({ 
    Name = "Chams Fill", 
    Flag = "ESP_ChamsFillColor", 
    Default = Color3.fromRGB(0, 251, 255), 
    Callback = function(Value, Alpha)
        Settings.ChamsFillColor = Value
    end
})

ChamsToggle:Colorpicker({ 
    Name = "Chams Outline", 
    Flag = "ESP_ChamsOutlineColor", 
    Default = Color3.fromRGB(255, 255, 255), 
    Callback = function(Value, Alpha)
        Settings.ChamsOutlineColor = Value
    end
})

VisualsEsp:Dropdown({
    Name = "Chams Material",
    Flag = "ESP_ChamsMaterial",
    Items = {"SmoothPlastic", "Neon", "Glass", "ForceField"},
    Multi = false,
    Default = "SmoothPlastic",
    Callback = function(Value)
        if type(Value) == "table" then
            Settings.ChamsMaterial = Value[1] or "SmoothPlastic"
        else
            Settings.ChamsMaterial = tostring(Value)
        end
    end
})

VisualsEsp:Slider({
    Name = "Chams Fill Transparency",
    Default = 50,
    Min = 0,
    Max = 100,
    Inc = 1,
    Flag = "ESP_ChamsFillTransparency",
    Callback = function(Value)
        Settings.ChamsFillTransparency = Value
    end
})

VisualsEsp:Slider({
    Name = "Chams Outline Stroke",
    Default = 0,
    Min = 0,
    Max = 100,
    Inc = 1,
    Flag = "ESP_ChamsOutlineTransparency",
    Callback = function(Value)
        Settings.ChamsOutlineTransparency = Value
    end
})

local ChamsVisCheckToggle = VisualsEsp:Toggle({
    Name = "Chams VisCheck",
    Default = false,
    Flag = "ESP_ChamsVisCheck",
    Callback = function(Value)
        Settings.ChamsVisibleCheck = Value
    end
})

ChamsVisCheckToggle:Colorpicker({
    Name = "Visible Color",
    Flag = "ESP_ChamsVisColor",
    Default = Color3.fromRGB(0, 255, 0),
    Callback = function(Value)
        Settings.ChamsVisibleColor = Value
    end
})

ChamsVisCheckToggle:Colorpicker({
    Name = "Hidden Color",
    Flag = "ESP_ChamsHiddenColor",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        Settings.ChamsHiddenColor = Value
    end
})

local ArrowToggle = VisualsEsp:Toggle({
    Name = "Off-Screen Arrows",
    Default = false,
    Flag = "ESP_Arrows",
    Callback = function(Value)
        Settings.OffScreenArrows = Value
    end
})

ArrowToggle:Colorpicker({
    Name = "Arrow Color",
    Flag = "ESP_ArrowColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        Settings.ArrowColor = Value
    end
})

VisualsEsp:Slider({
    Name = "Arrow Size",
    Default = 22,
    Min = 10,
    Max = 40,
    Inc = 1,
    Flag = "ESP_ArrowSize",
    Callback = function(Value)
        Settings.ArrowSize = Value
    end
})

VisualsEsp:Slider({
    Name = "Arrow Radius",
    Default = 150,
    Min = 50,
    Max = 300,
    Inc = 10,
    Flag = "ESP_ArrowRadius",
    Callback = function(Value)
        Settings.ArrowRadius = Value
    end
})

VisualsEsp:Toggle({
    Name = "Arrow Distance",
    Default = false,
    Flag = "ESP_ArrowDistance",
    Callback = function(Value)
        Settings.ArrowDistanceText = Value
    end
})

VisualsEsp:Slider({
    Name = "Arrow Text Size",
    Default = 11,
    Min = 8,
    Max = 20,
    Inc = 1,
    Flag = "ESP_ArrowTextSize",
    Callback = function(Value)
        Settings.ArrowTextSize = Value
    end
})

VisualsEsp:Slider({
    Name = "Arrow Text Offset",
    Default = 24,
    Min = 10,
    Max = 60,
    Inc = 1,
    Flag = "ESP_ArrowTextOffset",
    Callback = function(Value)
        Settings.ArrowTextOffset = Value
    end
})

VisualsMisc:Toggle({
    Name = "Team Check",
    Default = false,
    Flag = "Misc_TeamCheck",
    Callback = function(Value)
        Settings.TeamCheck = Value
    end
})

VisualsMisc:Toggle({
    Name = "Visible Check",
    Default = false,
    Flag = "Misc_VisCheck",
    Callback = function(Value)
        Settings.VisCheck = Value
    end
})

VisualsMisc:Toggle({
    Name = "Fullbright",
    Default = false,
    Flag = "Misc_Fullbright",
    Callback = function(Value)
        Settings.Fullbright = Value
    end
})

VisualsMisc:Toggle({
    Name = "RemoveFog",
    Default = false,
    Flag = "Misc_RemoveFog",
    Callback = function(Value)
        Settings.RemoveFog = Value
    end
})

VisualsMisc:Toggle({
    Name = "Custom Time",
    Default = false,
    Flag = "Misc_CustomTime",
    Callback = function(Value)
        Settings.TargetCustomTime = Value
    end
})

VisualsMisc:Slider({
    Name = "Time of Day",
    Default = 14,
    Min = 0,
    Max = 24,
    Inc = 0.5,
    Flag = "Misc_TimeOfDay",
    Callback = function(Value)
        Settings.TimeOfDay = Value
    end
})

local AmbientToggle = VisualsMisc:Toggle({
    Name = "Custom World Ambient Color",
    Default = false,
    Flag = "Misc_AmbientToggle",
    Callback = function(Value)
        Settings.AmbientColorEnabled = Value
    end
})

AmbientToggle:Colorpicker({
    Name = "Ambient Color",
    Flag = "Misc_AmbientColor",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(Value)
        Settings.AmbientColor = Value
    end
})

VisualsMisc:Slider({
    Name = "Text Size",
    Default = 14,
    Min = 10,
    Max = 24,
    Inc = 1,
    Flag = "Misc_TextSize",
    Callback = function(Value)
        Settings.TextSize = Value
    end
})

VisualsMisc:Slider({
    Name = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Inc = 50,
    Flag = "Misc_MaxDistance",
    Callback = function(Value)
        Settings.MaxDistance = Value
    end
})
