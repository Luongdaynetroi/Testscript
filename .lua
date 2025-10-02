-- LVM Ultimate v3.8 — Stealth Edition
-- Changelog:
--  - ESP: filter hiển thị (dot/highlight/billboard) theo MAX_DIST
--  - Speed: thêm chế độ STEALTH_SPEED (apply via RootPart velocity) + giữ ORIGINAL_SPEED on join
--  - Cleanup: chắc cú hơn, ensure PlayerRemoving handled, cleanup conns
--  - GUI persistence: debounce ensure loop so nó không spawn đôi
--  - Small fixes/comments

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ===== Config =====
local UI_NAME = "LVM_Ultimate_v3_8"
local CHECK_GUI_INTERVAL = 1
local DEFAULT_MAX_DIST = 120
local DEFAULT_SPEED = 16
local TELEPORT_FORWARD_DIST = 3
local TELEPORT_UP_OFFSET = 3
local GUI_RECREATE_DEBOUNCE = 0.6

-- ===== State =====
local screenGui = nil
local guiConns = {}
local UI = {}
local espData = {}   -- player -> { labelInList, billboard, dot, highlight, charConn }
local genData = {}   -- genModel -> { highlight }
local playerList = {}
local currentPlayerIndex = 1
local genList = {}
local currentGenIndex = 1
local ESP_ENABLED = true
local MAX_DIST = DEFAULT_MAX_DIST
local SPEED_ENABLED = false
local APPLIED_SPEED = DEFAULT_SPEED
local ORIGINAL_SPEED = nil
local STEALTH_SPEED = false -- nếu true thì dùng RootPart velocity thay vì set WalkSpeed
local lastGuiEnsure = 0

-- ===== Helpers =====
local function safePcall(fn) local ok, res = pcall(fn) if not ok then warn("LVM_SAFE_PCALL:", res) end return ok, res end
local function safeParent(inst, parent) pcall(function() inst.Parent = parent end) end

local function tryGetGuiParent()
    if LocalPlayer then
        local ok, pg = pcall(function() return LocalPlayer:FindFirstChild("PlayerGui") end)
        if ok and pg then return pg end
        local ok2, pg2 = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 2) end)
        if ok2 and pg2 then return pg2 end
    end
    return CoreGui
end

local function make(class, props)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k ~= "Parent" then
                pcall(function() inst[k] = v end)
            end
        end
    end
    if props and props.Parent then safeParent(inst, props.Parent) end
    return inst
end

local function disconnectAll(t)
    for _,c in ipairs(t) do
        if c and type(c)=="RBXScriptConnection" then pcall(function() c:Disconnect() end) end
    end
    for i=1,#t do t[i] = nil end
end

-- ===== Teleport helpers =====
local function teleportToCFrame(cf)
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then return false, "no local character" end
    local ok, err = pcall(function() LocalPlayer.Character:SetPrimaryPartCFrame(cf) end)
    return ok, err
end

local function teleportToPlayer(target)
    if not target or not target.Character or not target.Character.PrimaryPart then return false, "invalid target" end
    local tgt = target.Character.PrimaryPart
    local forward = tgt.CFrame.LookVector * TELEPORT_FORWARD_DIST
    local pos = tgt.Position + forward + Vector3.new(0, TELEPORT_UP_OFFSET, 0)
    return teleportToCFrame(CFrame.new(pos, tgt.Position))
end

local function findNearestGeneratorPoint(gen)
    if not gen then return nil end
    local bestPart = nil
    local bestDist = math.huge
    local localPos = nil
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then localPos = LocalPlayer.Character.PrimaryPart.Position end
    for _,desc in ipairs(gen:GetDescendants()) do
        if desc:IsA("BasePart") then
            if tostring(desc.Name):match("^GeneratorPoint") then
                if localPos then
                    local d = (desc.Position - localPos).Magnitude
                    if d < bestDist then bestDist = d; bestPart = desc end
                else
                    bestPart = desc
                    break
                end
            end
        end
    end
    if not bestPart then
        for _,desc in ipairs(gen:GetDescendants()) do
            if desc:IsA("BasePart") then
                bestPart = desc
                break
            end
        end
    end
    return bestPart
end

local function teleportToGenerator(gen)
    if not gen then return false, "no gen" end
    local part = findNearestGeneratorPoint(gen)
    if not part then return false, "no generator point" end
    local pos = part.Position + Vector3.new(0, TELEPORT_UP_OFFSET, 0)
    return teleportToCFrame(CFrame.new(pos, part.Position))
end

-- ===== ESP helpers =====
local function createOrUpdateListCanvas()
    if UI.listFrame and UI.listLayout then
        pcall(function()
            UI.listFrame.CanvasSize = UDim2.new(0, 0, 0, UI.listLayout.AbsoluteContentSize.Y + 8)
        end)
    end
end

local function clearESPForPlayer(player)
    local d = espData[player]
    if not d then return end
    pcall(function() if d.labelInList then d.labelInList:Destroy() end end)
    pcall(function() if d.billboard and d.billboard.Parent then d.billboard:Destroy() end end)
    pcall(function() if d.dot and d.dot.Parent then d.dot.Parent:Destroy() end end)
    pcall(function() if d.highlight and d.highlight.Parent then d.highlight:Destroy() end end)
    if d.charConn and type(d.charConn)=="RBXScriptConnection" then pcall(function() d.charConn:Disconnect() end) end
    espData[player] = nil
    createOrUpdateListCanvas()
end

local function updateESPVisibilityForPlayer(player)
    -- gọi khi distance thay đổi hoặc MAX_DIST thay đổi
    local d = espData[player]
    if not d then return end
    if not LocalPlayer or not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        -- can't compute -> default visible only label
        if d.labelInList then d.labelInList.TextColor3 = Color3.fromRGB(200,200,200) end
        if d.billboard and d.billboard.Parent then d.billboard.Enabled = false end
        if d.dot and d.dot.Parent then d.dot.Parent.Enabled = false end
        if d.highlight and d.highlight.Parent then d.highlight.Enabled = false end
        return
    end
    if player.Character and player.Character.PrimaryPart then
        local dist = (player.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
        local within = dist <= MAX_DIST
        -- label color + text
        local color = Color3.fromRGB(0,255,0)
        if player.Team and tostring(player.Team):lower():find("kill") then color = Color3.fromRGB(255,0,0) end
        if d.labelInList then
            d.labelInList.Text = player.Name .. " ("..math.floor(dist).."m)"
            d.labelInList.TextColor3 = color
        end
        if d.billboard and d.billboard.Parent then
            local tb = d.billboard:FindFirstChildOfClass("TextLabel")
            if tb then
                tb.Text = player.Name .. " ("..math.floor(dist).."m)"
                tb.TextColor3 = color
                d.billboard.Enabled = within
            end
        end
        if d.dot and d.dot.Parent then
            pcall(function() d.dot.BackgroundColor3 = color end)
            d.dot.Parent.Enabled = within
        end
        if d.highlight and d.highlight.Parent then
            pcall(function() d.highlight.FillColor = color; d.highlight.Enabled = within end)
        end
    else
        if d.labelInList then d.labelInList.Text = player.Name; d.labelInList.TextColor3 = Color3.fromRGB(200,200,200) end
        if d.billboard and d.billboard.Parent then d.billboard.Enabled = false end
        if d.dot and d.dot.Parent then d.dot.Parent.Enabled = false end
        if d.highlight and d.highlight.Parent then d.highlight.Enabled = false end
    end
end

local function ensureBillboardName(player, character)
    if not player or not character then return end
    local d = espData[player]
    if not d then return end
    pcall(function()
        if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
        local head = character:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            local bg = Instance.new("BillboardGui")
            bg.Name = "LVM_Billboard"
            bg.Adornee = head
            bg.Size = UDim2.new(0, 140, 0, 40)
            bg.AlwaysOnTop = true
            bg.StudsOffset = Vector3.new(0, 2.6, 0)
            bg.Parent = head

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            label.TextColor3 = Color3.fromRGB(240,240,240)
            label.Text = player.Name
            label.Parent = bg

            d.billboard = bg
        end
    end)
end

local function setupCharForPlayer(player, character)
    if not player or not character then return end
    local d = espData[player]
    if not d then return end

    pcall(function() if d.highlight and d.highlight.Parent then d.highlight:Destroy() end end)
    pcall(function() if d.dot and d.dot.Parent then d.dot.Parent:Destroy() end end)
    pcall(function() if d.billboard and d.billboard.Parent then d.billboard:Destroy() end end)

    safePcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "LVM_Player_HL"
        hl.Adornee = character
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 1
        hl.Parent = character
        d.highlight = hl
    end)

    safePcall(function()
        local head = character:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            local bg = Instance.new("BillboardGui")
            bg.Name = "LVM_Player_Dot"
            bg.Adornee = head
            bg.Size = UDim2.new(0, 60, 0, 20)
            bg.AlwaysOnTop = true
            bg.Parent = head

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Position = UDim2.new(0.5, -5, 0, -10)
            dot.BorderSizePixel = 0
            dot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            local corner = Instance.new("UICorner", dot)
            corner.CornerRadius = UDim.new(1, 0)
            dot.Parent = bg

            d.dot = dot
        end
    end)

    ensureBillboardName(player, character)
    updateESPVisibilityForPlayer(player)
end

local function applyPlayerESP(player)
    if not player or player == LocalPlayer or espData[player] then return end
    local data = {}
    espData[player] = data

    if UI.listFrame then
        local label = make("TextLabel", {
            Parent = UI.listFrame,
            Size = UDim2.new(1, -10, 0, 18),
            BackgroundTransparency = 1,
            Text = player.Name,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextColor3 = Color3.fromRGB(240,240,240)
        })
        data.labelInList = label
        createOrUpdateListCanvas()
    end

    if player.Character then
        pcall(function() setupCharForPlayer(player, player.Character) end)
    end

    data.charConn = player.CharacterAdded:Connect(function(c)
        task.wait(0.2)
        pcall(function() setupCharForPlayer(player, c) end)
    end)
end

-- ===== Generator functions =====
local function applyGenESP(gen)
    if not gen or genData[gen] then return end
    safePcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "LVM_Gen_HL"
        hl.Adornee = gen
        hl.FillColor = Color3.fromRGB(255, 215, 0)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Parent = gen
        genData[gen] = { highlight = hl }
    end)
end

local function clearESPForGen(gen)
    local d = genData[gen]
    if not d then return end
    pcall(function() if d.highlight and d.highlight.Parent then d.highlight:Destroy() end end)
    genData[gen] = nil
end

-- ===== Lists =====
local function rebuildPlayerList()
    playerList = {}
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerList, p) end
    end
    if #playerList == 0 then currentPlayerIndex = 0 else currentPlayerIndex = math.clamp(currentPlayerIndex, 1, #playerList) end
end

local function rebuildGenList()
    genList = {}
    for gen,_ in pairs(genData) do
        if gen and gen.Parent then table.insert(genList, gen) end
    end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and tostring(obj.Name):lower():find("gen") and not genData[obj] then
            applyGenESP(obj)
            table.insert(genList, obj)
        end
    end
    if #genList == 0 then currentGenIndex = 0 else currentGenIndex = math.clamp(currentGenIndex, 1, #genList) end
end

local function updateSelectorLabel()
    if not UI.nameLabel then return end
    if #playerList == 0 or currentPlayerIndex == 0 then UI.nameLabel.Text = "No players" else
        local p = playerList[currentPlayerIndex]
        if p and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and p.Character and p.Character.PrimaryPart then
            local d = math.floor((p.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude)
            UI.nameLabel.Text = p.Name .. " (" .. d .. "m)"
        else
            UI.nameLabel.Text = (p and p.Name) or "Unknown"
        end
    end
    if UI.genLabel then
        if #genList == 0 or currentGenIndex == 0 then UI.genLabel.Text = "No gen" else UI.genLabel.Text = genList[currentGenIndex].Name or "Gen" end
    end
end

-- ===== GUI creation =====
local function clearGuiState()
    disconnectAll(guiConns)
    guiConns = {}
    UI = {}
end

local function createGUI()
    if screenGui and screenGui.Parent then
        pcall(function() screenGui:Destroy() end)
    end
    clearGuiState()

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = UI_NAME
    screenGui.ResetOnSpawn = false
    safeParent(screenGui, tryGetGuiParent())

    local frame = make("Frame", {
        Parent = screenGui,
        Size = UDim2.new(0, 360, 0, 420),
        Position = UDim2.new(1, -380, 0.10, 0),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Active = true,
    })
    make("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 8) })

    -- draggable
    do
        local dragging, dragStart, startPos
        local c1 = frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        local c2 = frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        table.insert(guiConns, c1); table.insert(guiConns, c2)
    end

    local title = make("TextLabel", { Parent = frame, Size = UDim2.new(1,0,0,28), Text = "🧠 LVM Ultimate v3.8 (Stealth)", BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.GothamBold, TextSize = 16 })

    local listFrame = make("ScrollingFrame", { Parent = frame, Size = UDim2.new(1, -16, 0, 180), Position = UDim2.new(0, 8, 0, 36), BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0) })
    local listLayout = make("UIListLayout", { Parent = listFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })

    local controls = make("Frame", { Parent = frame, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 228), BackgroundTransparency = 1 })
    local espToggle = make("TextButton", { Parent = controls, Size = UDim2.new(0.22, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0), Text = "ESP: ON", BackgroundColor3 = Color3.fromRGB(60,60,60), BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 13 })
    local distInput = make("TextBox", { Parent = controls, Size = UDim2.new(0.22, 0, 1, 0), Position = UDim2.new(0.24, 6, 0, 0), Text = tostring(MAX_DIST), ClearTextOnFocus = false, BackgroundColor3 = Color3.fromRGB(40,40,44), BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Center })
    local speedInput = make("TextBox", { Parent = controls, Size = UDim2.new(0.22, 0, 1, 0), Position = UDim2.new(0.48, 12, 0, 0), Text = tostring(APPLIED_SPEED), ClearTextOnFocus = false, BackgroundColor3 = Color3.fromRGB(40,40,44), BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(230,230,230), TextXAlignment = Enum.TextXAlignment.Center })
    local applySpeedBtn = make("TextButton", { Parent = controls, Size = UDim2.new(0.12, 0, 1, 0), Position = UDim2.new(0.72, 12, 0, 0), Text = "Apply", BackgroundColor3 = Color3.fromRGB(70,120,240), BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 13 })
    local speedToggleBtn = make("TextButton", { Parent = controls, Size = UDim2.new(0.12, 0, 1, 0), Position = UDim2.new(0.84, 18, 0, 0), Text = "Off", BackgroundColor3 = Color3.fromRGB(120,120,120), BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 12 })

    local selectorFrame = make("Frame", { Parent = frame, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 264), BackgroundTransparency = 1 })
    local leftBtn = make("TextButton", { Parent = selectorFrame, Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(0, 0, 0, 0), Text = "<", Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0 })
    local nameLabel = make("TextLabel", { Parent = selectorFrame, Size = UDim2.new(0.6, -4, 1, 0), Position = UDim2.new(0.12, 30, 0, 0), Text = "Nobody", BackgroundTransparency = 1, TextScaled = true, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(240,240,240), TextXAlignment = Enum.TextXAlignment.Center })
    local rightBtn = make("TextButton", { Parent = selectorFrame, Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(0.74, 0, 0, 0), Text = ">", Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0 })

    local teleportPlayerBtn = make("TextButton", { Parent = frame, Size = UDim2.new(0.46, -14, 0, 28), Position = UDim2.new(0, 8, 0, 296), Text = "Teleport Player", BackgroundColor3 = Color3.fromRGB(70,120,240), BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 14 })
    local teleportGenBtn = make("TextButton", { Parent = frame, Size = UDim2.new(0.46, -14, 0, 28), Position = UDim2.new(0.54, 6, 0, 296), Text = "Teleport Gen", BackgroundColor3 = Color3.fromRGB(90,160,60), BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 14 })

    local genSelectorFrame = make("Frame", { Parent = frame, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 332), BackgroundTransparency = 1 })
    local genLeft = make("TextButton", { Parent = genSelectorFrame, Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(0, 0, 0, 0), Text = "<", Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0 })
    local genLabel = make("TextLabel", { Parent = genSelectorFrame, Size = UDim2.new(0.8, -40, 1, 0), Position = UDim2.new(0.12, 30, 0, 0), Text = "No gen", BackgroundTransparency = 1, TextScaled = true, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(240,240,240), TextXAlignment = Enum.TextXAlignment.Center })
    local genRight = make("TextButton", { Parent = genSelectorFrame, Size = UDim2.new(0, 28, 1, 0), Position = UDim2.new(0.92, 0, 0, 0), Text = ">", Font = Enum.Font.GothamBold, TextSize = 16, BorderSizePixel = 0 })

    local clearBtn = make("TextButton", { Parent = frame, Size = UDim2.new(1, -16, 0, 28), Position = UDim2.new(0, 8, 0, 368), Text = "Clear All & Destroy GUI", BackgroundColor3 = Color3.fromRGB(200,50,50), BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255,255,255) })

    -- store UI refs
    UI.screenGui = screenGui
    UI.frame = frame
    UI.listFrame = listFrame
    UI.listLayout = listLayout
    UI.espToggle = espToggle
    UI.distInput = distInput
    UI.speedInput = speedInput
    UI.applySpeedBtn = applySpeedBtn
    UI.speedToggleBtn = speedToggleBtn
    UI.leftBtn = leftBtn
    UI.rightBtn = rightBtn
    UI.nameLabel = nameLabel
    UI.teleportPlayerBtn = teleportPlayerBtn
    UI.teleportGenBtn = teleportGenBtn
    UI.genLeft = genLeft
    UI.genRight = genRight
    UI.genLabel = genLabel
    UI.clearBtn = clearBtn

    -- wire events
    table.insert(guiConns, espToggle.MouseButton1Click:Connect(function()
        ESP_ENABLED = not ESP_ENABLED
        espToggle.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
        -- update visuals immediately
        for p,_ in pairs(espData) do updateESPVisibilityForPlayer(p) end
    end))

    table.insert(guiConns, distInput.FocusLost:Connect(function()
        local n = tonumber(distInput.Text)
        if n and n > 10 then MAX_DIST = n else distInput.Text = tostring(MAX_DIST) end
        for p,_ in pairs(espData) do updateESPVisibilityForPlayer(p) end
    end))

    local function applySpeedFromUI()
        local s = tonumber(UI.speedInput.Text)
        if s and s >= 0 then
            APPLIED_SPEED = s
            if SPEED_ENABLED and LocalPlayer and LocalPlayer.Character then
                local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h and not STEALTH_SPEED then pcall(function() h.WalkSpeed = APPLIED_SPEED end) end
            end
        else
            UI.speedInput.Text = tostring(APPLIED_SPEED)
        end
    end
    table.insert(guiConns, applySpeedBtn.MouseButton1Click:Connect(function() applySpeedFromUI() end))
    table.insert(guiConns, UI.speedInput.FocusLost:Connect(function() applySpeedFromUI() end))

    table.insert(guiConns, UI.speedToggleBtn.MouseButton1Click:Connect(function()
        -- toggle both speed on/off; hold shift to toggle stealth variant
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
            STEALTH_SPEED = not STEALTH_SPEED
            UI.speedToggleBtn.Text = STEALTH_SPEED and "On (Stealth)" or (SPEED_ENABLED and "On" or "Off")
            UI.speedToggleBtn.BackgroundColor3 = STEALTH_SPEED and Color3.fromRGB(170,85,255) or (SPEED_ENABLED and Color3.fromRGB(70,120,240) or Color3.fromRGB(120,120,120))
            return
        end

        if SPEED_ENABLED then
            SPEED_ENABLED = false
            UI.speedToggleBtn.Text = "Off"
            UI.speedToggleBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
            if LocalPlayer and LocalPlayer.Character then
                local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h and ORIGINAL_SPEED then pcall(function() h.WalkSpeed = ORIGINAL_SPEED end) end
            end
        else
            SPEED_ENABLED = true
            APPLIED_SPEED = tonumber(UI.speedInput.Text) or APPLIED_SPEED
            UI.speedToggleBtn.Text = STEALTH_SPEED and "On (Stealth)" or "On"
            UI.speedToggleBtn.BackgroundColor3 = STEALTH_SPEED and Color3.fromRGB(170,85,255) or Color3.fromRGB(70,120,240)
            if LocalPlayer and LocalPlayer.Character then
                local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then
                    ORIGINAL_SPEED = ORIGINAL_SPEED or h.WalkSpeed
                    if not STEALTH_SPEED then pcall(function() h.WalkSpeed = APPLIED_SPEED end) end
                end
            end
        end
    end))

    -- selector
    table.insert(guiConns, leftBtn.MouseButton1Click:Connect(function()
        if #playerList == 0 then return end
        currentPlayerIndex = currentPlayerIndex - 1
        if currentPlayerIndex < 1 then currentPlayerIndex = #playerList end
        updateSelectorLabel()
    end))
    table.insert(guiConns, rightBtn.MouseButton1Click:Connect(function()
        if #playerList == 0 then return end
        currentPlayerIndex = currentPlayerIndex + 1
        if currentPlayerIndex > #playerList then currentPlayerIndex = 1 end
        updateSelectorLabel()
    end))

    -- teleport player
    table.insert(guiConns, teleportPlayerBtn.MouseButton1Click:Connect(function()
        if #playerList == 0 or currentPlayerIndex == 0 then return end
        local target = playerList[currentPlayerIndex]
        if target then local ok,err = teleportToPlayer(target) if not ok then warn("Teleport player failed:", err) end end
    end))

    -- teleport gen
    table.insert(guiConns, teleportGenBtn.MouseButton1Click:Connect(function()
        if #genList == 0 or currentGenIndex == 0 then return end
        local gen = genList[currentGenIndex]
        if gen then local ok,err = teleportToGenerator(gen) if not ok then warn("Teleport gen failed:", err) end end
    end))

    -- gen selector
    table.insert(guiConns, genLeft.MouseButton1Click:Connect(function()
        if #genList == 0 then return end
        currentGenIndex = currentGenIndex - 1
        if currentGenIndex < 1 then currentGenIndex = #genList end
        updateSelectorLabel()
    end))
    table.insert(guiConns, genRight.MouseButton1Click:Connect(function()
        if #genList == 0 then return end
        currentGenIndex = currentGenIndex + 1
        if currentGenIndex > #genList then currentGenIndex = 1 end
        updateSelectorLabel()
    end))

    -- clear
    table.insert(guiConns, clearBtn.MouseButton1Click:Connect(function()
        cleanupAll()
    end))

    UI.listLayout = listLayout

    rebuildPlayerList()
    rebuildGenList()
    createOrUpdateListCanvas()
    updateSelectorLabel()
end

-- ensure GUI exists (debounced)
local function ensureGUIExists()
    local now = tick()
    if now - lastGuiEnsure < GUI_RECREATE_DEBOUNCE then return end
    lastGuiEnsure = now
    if not screenGui or not screenGui.Parent then
        createGUI()
    else
        local parent = tryGetGuiParent()
        if screenGui.Parent ~= parent then safeParent(screenGui, parent) end
    end
end

-- ===== Cleanup =====
function cleanupAll()
    for p,_ in pairs(espData) do
        clearESPForPlayer(p)
    end
    for g,_ in pairs(genData) do
        clearESPForGen(g)
    end
    espData = {}
    genData = {}
    playerList = {}
    genList = {}
    if screenGui and screenGui.Parent then pcall(function() screenGui:Destroy() end) end
    clearGuiState()
end
_G.LVM_CleanupAll = cleanupAll

-- ===== Core init and listeners =====
for _,p in ipairs(Players:GetPlayers()) do
    applyPlayerESP(p)
end

Players.PlayerAdded:Connect(function(p)
    applyPlayerESP(p)
    rebuildPlayerList()
    updateSelectorLabel()
end)
Players.PlayerRemoving:Connect(function(p)
    clearESPForPlayer(p)
    rebuildPlayerList()
    updateSelectorLabel()
end)

for _,obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Model") and tostring(obj.Name):lower():find("gen") then
        applyGenESP(obj)
    end
end

Workspace.DescendantAdded:Connect(function(o)
    if o:IsA("Model") and tostring(o.Name):lower():find("gen") then
        applyGenESP(o)
        rebuildGenList()
        updateSelectorLabel()
    end
end)
Workspace.DescendantRemoving:Connect(function(o)
    if genData[o] then clearESPForGen(o) end
    rebuildGenList()
    updateSelectorLabel()
end)

if LocalPlayer then
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.25)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then ORIGINAL_SPEED = ORIGINAL_SPEED or humanoid.WalkSpeed end
        if SPEED_ENABLED and humanoid and not STEALTH_SPEED then pcall(function() humanoid.WalkSpeed = APPLIED_SPEED end) end
        for pl, data in pairs(espData) do
            if pl.Character then pcall(function() setupCharForPlayer(pl, pl.Character) end) end
        end
    end)
end

-- Heartbeat: update labels, colors, remove empty gens, apply speed
RunService.Heartbeat:Connect(function(dt)
    -- update player visuals
    for player, data in pairs(espData) do
        if not data or not player then
            -- skip
        else
            if not ESP_ENABLED then
                if data.labelInList then data.labelInList.TextColor3 = Color3.fromRGB(140,140,140) end
                if data.billboard and data.billboard.Parent then data.billboard.Enabled = false end
                if data.dot and data.dot.Parent then data.dot.Parent.Enabled = false end
                if data.highlight and data.highlight.Parent then data.highlight.Enabled = false end
            else
                updateESPVisibilityForPlayer(player)
            end
        end
    end

    -- generator upkeep
    for gen, d in pairs(genData) do
        if not gen or not gen.Parent then
            clearESPForGen(gen)
        else
            local points = 0
            for _, child in ipairs(gen:GetChildren()) do
                if child.Name:match("^GeneratorPoint") then points = points + 1 end
            end
            if points == 0 then
                if d.highlight and d.highlight.Parent then
                    pcall(function() d.highlight:Destroy() end)
                end
                genData[gen] = nil
            else
                if d.highlight then pcall(function() d.highlight.Enabled = true end) end
            end
        end
    end

    updateSelectorLabel()

    -- apply speed if enabled
    if SPEED_ENABLED and LocalPlayer and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if STEALTH_SPEED then
                -- stealth: apply small velocity pulses based on MoveDirection to emulate speed without setting WalkSpeed
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local moveDir = humanoid.MoveDirection
                    if moveDir.Magnitude > 0.01 then
                        -- set velocity along moveDir, preserve Y velocity
                        local vel = moveDir.Unit * APPLIED_SPEED
                        local currentY = root.Velocity.Y
                        pcall(function() root.Velocity = Vector3.new(vel.X, currentY, vel.Z) end)
                    end
                end
            else
                pcall(function() humanoid.WalkSpeed = APPLIED_SPEED end)
            end
        end
    end
end)

-- GUI persistence monitor (debounced)
task.spawn(function()
    while true do
        ensureGUIExists()
        task.wait(CHECK_GUI_INTERVAL)
    end
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        cleanupAll()
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        if UI and UI.screenGui and UI.screenGui.Parent then
            UI.screenGui.Enabled = not UI.screenGui.Enabled
        elseif screenGui and screenGui.Parent then
            screenGui.Enabled = not screenGui.Enabled
        end
    end
end)

-- final
createGUI()
print("LVM Ultimate v3.8 (Stealth) loaded. Paste any console errors here if something fails.")
