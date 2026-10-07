-- ==========================================
-- ไฟล์: esp.lua บน GitHub (อัปเดตใหม่)
-- ==========================================
local espModule = {}

function espModule.Load(Settings, LocalPlayer, Camera, Players, RunService)
    local Lighting = game:GetService("Lighting")
    
    local OriginalLighting = {
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        FogEnd = Lighting.FogEnd,
        Ambient = Lighting.Ambient,
        ClockTime = Lighting.ClockTime
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
                for _, line in pairs(ESPData[player].CornerLines) do line:Remove() end
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
                for _, line in pairs(ESPData[player].SkeletonLines) do line:Remove() end
            end
            ESPData[player] = nil
        end
        removeChams(player)
    end

    local function addPlayer(player)
        if player == LocalPlayer then return end
        
        local skeletonJoints = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
            {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
            {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
        }

        local skeletonJointsR6 = {
            {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
            {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
        }

        local pData = {
            BoxOutline = createDrawing("Square", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Filled = false, Visible = false}),
            Box = createDrawing("Square", {Color = Settings.BoxColor, Thickness = 1.5, Filled = false, Visible = false}),
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

        for i = 1, 16 do pData.CornerLines[i] = createDrawing("Line", {Color = Settings.BoxColor, Thickness = 1.5, Visible = false}) end
        for i = 1, 14 do pData.SkeletonLines[i] = createDrawing("Line", {Color = Settings.SkeletonColor, Thickness = 1, Visible = false, Transparency = 0.8}) end

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
            for _, line in pairs(pData.SkeletonLines) do line.Visible = false end
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

            -- ตัวอย่างการอัปเดตสีและตำแหน่ง
            pData.NameTag.Color = Settings.NameColor
            pData.Box.Color = Settings.BoxColor
            pData.Tracer.Color = Settings.TracerColor
            pData.DistanceTag.Color = Settings.DistanceColor

            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if not onScreen then
                hideAll()
                return
            else
                pData.Box.Visible = Settings.Box
                pData.NameTag.Visible = Settings.Name
                pData.DistanceTag.Visible = Settings.Distance
                pData.Tracer.Visible = Settings.Tracers
            end
        end)

        player.AncestryChanged:Connect(function(_, parent)
            if not parent then removeESP(player) end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do addPlayer(player) end
    Players.PlayerAdded:Connect(addPlayer)
    Players.PlayerRemoving:Connect(removeESP)
end

return espModule
