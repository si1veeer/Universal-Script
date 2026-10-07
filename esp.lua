-- ==========================================
-- ไฟล์: esp.lua (เวอร์ชันสมบูรณ์ พร้อมวาดผลลัพธ์)
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
            
            if ESPData[player].HealthBar then ESPData[player].HealthBar:Remove() end
            if ESPData[player].HealthBarOutline then ESPData[player].HealthBarOutline:Remove() end
            if ESPData[player].NameTag then ESPData[player].NameTag:Remove() end
            if ESPData[player].DistanceTag then ESPData[player].DistanceTag:Remove() end
            if ESPData[player].Tracer then ESPData[player].Tracer:Remove() end
            
            ESPData[player] = nil
        end
        removeChams(player)
    end

    local function addPlayer(player)
        if player == LocalPlayer then return end

        local pData = {
            BoxOutline = createDrawing("Square", {Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Filled = false, Visible = false}),
            Box = createDrawing("Square", {Color = Settings.BoxColor, Thickness = 1.5, Filled = false, Visible = false}),
            HealthBarOutline = createDrawing("Square", {Color = Color3.fromRGB(0, 0, 0), Thickness = 1, Filled = true, Visible = false}),
            HealthBar = createDrawing("Square", {Color = Settings.HealthBarColor, Thickness = 1, Filled = true, Visible = false}),
            NameTag = createDrawing("Text", {Color = Settings.NameColor, Size = Settings.TextSize, Center = true, Outline = true, Visible = false}),
            DistanceTag = createDrawing("Text", {Color = Settings.DistanceColor, Size = Settings.TextSize, Center = true, Outline = true, Visible = false}),
            Tracer = createDrawing("Line", {Color = Settings.TracerColor, Thickness = 1, Visible = false}),
        }

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
            pData.HealthBar.Visible = false
            pData.HealthBarOutline.Visible = false
            pData.NameTag.Visible = false
            pData.DistanceTag.Visible = false
            pData.Tracer.Visible = false
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

            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = myRoot and (myRoot.Position - rootPart.Position).Magnitude or 0
            if distance > Settings.MaxDistance then
                hideAll()
                return
            end

            -- แปลงตำแหน่ง 3D เป็น 2D บนหน้าจอ
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

            if onScreen then
                -- คำนวณขนาด Box ตามระยะทาง
                local headVector = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legVector = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headVector.Y - legVector.Y)
                local width = height / 2

                local boxPos = Vector2.new(vector.X - width / 2, headVector.Y)
                local boxSize = Vector2.new(width, height)

                -- อัปเดต Box ESP
                if Settings.Box then
                    pData.Box.Size = boxSize
                    pData.Box.Position = boxPos
                    pData.Box.Color = Settings.BoxColor
                    pData.Box.Visible = true

                    pData.BoxOutline.Size = boxSize
                    pData.BoxOutline.Position = boxPos
                    pData.BoxOutline.Visible = true
                else
                    pData.Box.Visible = false
                    pData.BoxOutline.Visible = false
                end

                -- อัปเดต Name ESP
                if Settings.Name then
                    pData.NameTag.Text = player.Name
                    pData.NameTag.Position = Vector2.new(vector.X, headVector.Y - 18)
                    pData.NameTag.Color = Settings.NameColor
                    pData.NameTag.Visible = true
                else
                    pData.NameTag.Visible = false
                end

                -- อัปเดต Distance ESP
                if Settings.Distance then
                    pData.DistanceTag.Text = math.floor(distance) .. " studs"
                    pData.DistanceTag.Position = Vector2.new(vector.X, legVector.Y + 5)
                    pData.DistanceTag.Color = Settings.DistanceColor
                    pData.DistanceTag.Visible = true
                else
                    pData.DistanceTag.Visible = false
                end

                -- อัปเดต Tracer
                if Settings.Tracers then
                    pData.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    pData.Tracer.To = Vector2.new(vector.X, vector.Y)
                    pData.Tracer.Color = Settings.TracerColor
                    pData.Tracer.Visible = true
                else
                    pData.Tracer.Visible = false
                end

                -- อัปเดต Chams (Highlight)
                if Settings.Chams then
                    highlight.Adornee = character
                    highlight.FillColor = Settings.ChamsFillColor
                    highlight.OutlineColor = Settings.ChamsOutlineColor
                    highlight.FillTransparency = Settings.ChamsFillTransparency / 100
                    highlight.OutlineTransparency = Settings.ChamsOutlineTransparency / 100
                    highlight.Enabled = true
                else
                    highlight.Enabled = false
                end
            else
                hideAll()
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
