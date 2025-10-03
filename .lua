-- LVM Hub — Player Tab: mở rộng tính năng (client)
-- Paste vào executor / LocalScript (client). Test trong Studio/private server.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

if not player then return end

-- ============ SAFE single-run cleanup ============
local EXIST = player:FindFirstChild("LVMHub_CLIENT_EXT")
if EXIST then EXIST:Destroy() end
local holder = Instance.new("Folder"); holder.Name = "LVMHub_CLIENT_EXT"; holder.Parent = player

-- tiny helpers
local function tween(obj, props, time, style, direction)
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(time or 0.18, style, direction)
    return TweenService:Create(obj, info, props)
end

local function getChar()
    local c = player.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

-- ============ BUILD minimal panel if not exists ============
-- If user already has panel from previous UI, try find and extend it
local screen = game:GetService("CoreGui"):FindFirstChild("LVM_Hub_Screen")
if not screen then
    -- if previous premium UI isn't present, create a minimal screen+panel (simpler)
    screen = Instance.new("ScreenGui")
    screen.Name = "LVM_Hub_Screen"
    screen.Parent = game:GetService("CoreGui")
end

local panel = screen:FindFirstChild("LVM_Panel")
if not panel then
    panel = Instance.new("Frame")
    panel.Name = "LVM_Panel"
    panel.Size = UDim2.new(0, 720, 0, 420)
    panel.Position = UDim2.new(0.5, -360, 0.5, -210)
    panel.AnchorPoint = Vector2.new(0.5,0.5)
    panel.BackgroundColor3 = Color3.fromRGB(28,30,36)
    panel.BorderSizePixel = 0
    panel.Parent = screen
    panel.Visible = true
    local pc = Instance.new("UICorner", panel); pc.CornerRadius = UDim.new(0,12)
end

-- find or create content area
local contentArea = panel:FindFirstChild("Content") or Instance.new("Frame", panel)
contentArea.Name = "Content"
contentArea.Size = UDim2.new(1, -240, 1, -72)
contentArea.Position = UDim2.new(0, 204, 0, 64)
contentArea.BackgroundTransparency = 1

-- ============ Player tab UI (we'll create a subframe in contentArea) ============
local playerTabFrame = contentArea:FindFirstChild("PlayerTabFrame")
if playerTabFrame then playerTabFrame:Destroy() end
playerTabFrame = Instance.new("Frame", contentArea)
playerTabFrame.Name = "PlayerTabFrame"
playerTabFrame.Size = UDim2.new(1,0,1,0)
playerTabFrame.BackgroundTransparency = 1

-- helper factory reused
local function makeLabel(parent, text, y)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1, -24, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function makeToggle(parent, posY, labelTxt, init)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, -24, 0, 34)
    holder.Position = UDim2.new(0, 12, 0, posY)
    holder.BackgroundTransparency = 1

    local t = Instance.new("TextLabel", holder)
    t.Size = UDim2.new(0.6, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.Gotham
    t.TextSize = 14
    t.TextColor3 = Color3.fromRGB(220,220,220)
    t.Text = labelTxt

    local sw = Instance.new("TextButton", holder)
    sw.Size = UDim2.new(0, 46, 0, 24)
    sw.Position = UDim2.new(1, -50, 0.5, -12)
    sw.BackgroundColor3 = Color3.fromRGB(60,60,65)
    sw.Text = ""
    sw.AutoButtonColor = false
    local swCorner = Instance.new("UICorner", sw); swCorner.CornerRadius = UDim.new(0,10)
    local swFill = Instance.new("Frame", sw)
    swFill.Size = UDim2.new(init and 1 or 0, 0, 1, 0)
    swFill.BackgroundColor3 = init and Color3.fromRGB(85,120,255) or Color3.fromRGB(120,120,120)
    local swFillCorner = Instance.new("UICorner", swFill); swFillCorner.CornerRadius = UDim.new(0,8)

    local state = init or false
    sw.MouseButton1Click:Connect(function()
        state = not state
        tween(swFill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play()
        tween(swFill, {BackgroundColor3 = state and Color3.fromRGB(85,120,255) or Color3.fromRGB(120,120,120)}, 0.12):Play()
    end)

    return holder, function() return state end, function(v) state = v; tween(swFill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play(); tween(swFill, {BackgroundColor3 = state and Color3.fromRGB(85,120,255) or Color3.fromRGB(120,120,120)}, 0.12):Play() end
end

local function makeSlider(parent, posY, labelTxt, minV, maxV, init)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, -24, 0, 40)
    holder.Position = UDim2.new(0, 12, 0, posY)
    holder.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(0.6, 0, 0, 18)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(210,210,210)
    lbl.Text = labelTxt

    local valLabel = Instance.new("TextLabel", holder)
    valLabel.Size = UDim2.new(0.4, 0, 0, 18)
    valLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 13
    valLabel.TextColor3 = Color3.fromRGB(85,120,255)
    valLabel.Text = tostring(init)

    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(1, 0, 0, 10)
    bar.Position = UDim2.new(0, 0, 0, 22)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local barCorner = Instance.new("UICorner", bar); barCorner.CornerRadius = UDim.new(0,6)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((init - minV)/(maxV - minV), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(85,120,255)
    local fillCorner = Instance.new("UICorner", fill); fillCorner.CornerRadius = UDim.new(0,6)

    local dragging = false
    local function updateFromX(x)
        local absPos = x - bar.AbsolutePosition.X
        local frac = math.clamp(absPos / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(frac, 0, 1, 0)
        local value = minV + frac * (maxV - minV)
        valLabel.Text = tostring(math.floor(value+0.5))
        return value
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    bar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateFromX(input.Position.X)
        end
    end)

    return holder, function() return tonumber(valLabel.Text) end, function(v) local frac = math.clamp((v-minV)/(maxV-minV),0,1); fill.Size = UDim2.new(frac,0,1,0); valLabel.Text = tostring(math.floor(v+0.5)) end
end

-- ============ Create controls (lots of player features) ============
local y = 6
makeLabel(playerTabFrame, "Player Utilities — packed", y); y = y + 28

-- Infinite Jump
local infHolder, getInf, setInf = makeToggle(playerTabFrame, y, "Infinite Jump", false); y = y + 44
-- Fly toggle + speed slider
local flyHolder, getFly, setFly = makeToggle(playerTabFrame, y, "Fly", false); y = y + 44
local flySpeedFrame, getFlySpeed, setFlySpeed = makeSlider(playerTabFrame, y, "Fly Speed", 10, 300, 80); y = y + 48
-- WalkSpeed slider
local wsFrame, getWS, setWS = makeSlider(playerTabFrame, y, "WalkSpeed", 8, 300, 16); y = y + 48
-- JumpPower slider
local jpFrame, getJP, setJP = makeSlider(playerTabFrame, y, "JumpPower", 20, 300, 50); y = y + 48
-- Noclip toggle
local nocHolder, getNoc, setNoc = makeToggle(playerTabFrame, y, "Noclip (no collisions)", false); y = y + 44
-- Sprint toggle + sprint multiplier slider
local sprintHolder, getSprint, setSprint = makeToggle(playerTabFrame, y, "Sprint (hold LeftShift)", false); y = y + 44
local sprintFrame, getSprintMult, setSprintMult = makeSlider(playerTabFrame, y, "Sprint Mult", 1, 4, 1.8); y = y + 48
-- TPWalk (hold LeftAlt to move/teleport toward mouse smoothly)
local tpwHolder, getTPW, setTPW = makeToggle(playerTabFrame, y, "TP Walk (hold LeftAlt)", false); y = y + 44
local tpStepFrame, getTPStep, setTPStep = makeSlider(playerTabFrame, y, "TP Step (studs)", 1, 50, 8); y = y + 48
-- Teleport to mouse / teleport to player (dropdown + button)
local tpToMouseBtn = Instance.new("TextButton", playerTabFrame)
tpToMouseBtn.Size = UDim2.new(0, 160, 0, 34)
tpToMouseBtn.Position = UDim2.new(0, 12, 0, y)
tpToMouseBtn.Text = "Teleport → Mouse (click)"
tpToMouseBtn.Font = Enum.Font.GothamBold
tpToMouseBtn.TextSize = 14
tpToMouseBtn.BackgroundColor3 = Color3.fromRGB(44,44,48)
tpToMouseBtn.TextColor3 = Color3.fromRGB(235,235,235)
local tpCorner = Instance.new("UICorner", tpToMouseBtn); tpCorner.CornerRadius = UDim.new(0,8)
y = y + 44

local playerDropdown = Instance.new("TextButton", playerTabFrame)
playerDropdown.Size = UDim2.new(0, 220, 0, 34)
playerDropdown.Position = UDim2.new(0, 12, 0, y)
playerDropdown.Text = "Select Player ▼"
playerDropdown.Font = Enum.Font.GothamBold
playerDropdown.TextSize = 14
playerDropdown.BackgroundColor3 = Color3.fromRGB(44,44,48)
playerDropdown.TextColor3 = Color3.fromRGB(235,235,235)
local pdCorner = Instance.new("UICorner", playerDropdown); pdCorner.CornerRadius = UDim.new(0,8)
y = y + 44

local tpToPlayerBtn = Instance.new("TextButton", playerTabFrame)
tpToPlayerBtn.Size = UDim2.new(0, 160, 0, 34)
tpToPlayerBtn.Position = UDim2.new(0, 12, 0, y)
tpToPlayerBtn.Text = "Teleport → Player"
tpToPlayerBtn.Font = Enum.Font.GothamBold
tpToPlayerBtn.TextSize = 14
tpToPlayerBtn.BackgroundColor3 = Color3.fromRGB(44,44,48)
tpToPlayerBtn.TextColor3 = Color3.fromRGB(235,235,235)
local tppCorner = Instance.new("UICorner", tpToPlayerBtn); tppCorner.CornerRadius = UDim.new(0,8)
y = y + 44

-- AutoHeal toggle
local healHolder, getHeal, setHeal = makeToggle(playerTabFrame, y, "Auto Heal (restore HP)", false); y = y + 44
-- Glide toggle (slow fall when space while falling)
local glideHolder, getGlide, setGlide = makeToggle(playerTabFrame, y, "Glide (hold Space)", false); y = y + 44

-- small helper: populate playerDropdown menu (simple)
local dropdownOpen = false
local dropFrame = Instance.new("Frame", playerTabFrame)
dropFrame.Size = UDim2.new(0, 220, 0, 0)
dropFrame.Position = UDim2.new(0, 12, 0, (y-44))
dropFrame.ClipsDescendants = true
dropFrame.BackgroundTransparency = 1

local function refreshPlayerList()
    for _,c in pairs(dropFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local idx = 0
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player then
            local b = Instance.new("TextButton", dropFrame)
            b.Size = UDim2.new(1, 0, 0, 28)
            b.Position = UDim2.new(0, 0, 0, idx*28)
            b.Text = pl.Name
            b.Font = Enum.Font.Gotham
            b.TextSize = 14
            b.BackgroundColor3 = Color3.fromRGB(50,50,54)
            b.TextColor3 = Color3.fromRGB(230,230,230)
            local bc = Instance.new("UICorner", b); bc.CornerRadius = UDim.new(0,6)
            b.MouseButton1Click:Connect(function()
                playerDropdown.Text = pl.Name.." ▼"
                dropdownOpen = false
                dropFrame:TweenSize(UDim2.new(0,220,0,0), "Out", "Quad", 0.18, true)
            end)
            idx = idx + 1
        end
    end
end

playerDropdown.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    if dropdownOpen then
        refreshPlayerList()
        dropFrame:TweenSize(UDim2.new(0,220,0,math.max(1, #Players:GetPlayers()-1) * 28), "Out", "Quad", 0.18, true)
    else
        dropFrame:TweenSize(UDim2.new(0,220,0,0), "Out", "Quad", 0.18, true)
    end
end)

-- ============ Feature implementations ============
-- state storage
local state = {
    Fly = false,
    FlySpeed = 80,
    InfJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    SprintEnabled = false,
    SprintMult = 1.8,
    TPWalk = false,
    TPStep = 8,
    AutoHeal = false,
    Glide = false,
}

-- wire UI -> state
setInf(false)
setFly(false); setFlySpeed(80)
setWS(16)
setJP(50)
setNoc(false)
setSprint(false); setSprintMult(1.8)
setTPW(false); setTPStep(8)
setHeal(false)
setGlide(false)

-- slider callbacks
do
    -- find getters from created controls
    local _, getFS, setFS = getFlySpeed or function() end
    -- but we returned them above; so actually use getFlySpeed var
end

-- apply WalkSpeed & JumpPower continuously
RunService.Heartbeat:Connect(function()
    local _, hrp, hum = getChar()
    if hum then
        -- base walkspeed (modified by sprint)
        local baseWS = tonumber(playerTabFrame:FindFirstChildWhichIsA("TextLabel") and state.WalkSpeed) or state.WalkSpeed
        local ws = state.WalkSpeed
        -- sprint hold
        if state.SprintEnabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            hum.WalkSpeed = ws * state.SprintMult
        else
            hum.WalkSpeed = ws
        end
        hum.JumpPower = state.JumpPower
    end
end)

-- Hook slider update by reading UI values periodically (since our sliders use get functions)
local function readSliders()
    -- parse the holder children to get values (we created functions earlier but for simplicity read the labels)
    -- WalkSpeed
    local wsVal = wsFrame and wsFrame:FindFirstChildWhichIsA("TextLabel", true)
    -- Our makeSlider places a label (first child) and a value label (second). To be safe, scan children
    for _,v in pairs(wsFrame:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:match("^%d+$") then
            state.WalkSpeed = tonumber(v.Text) or state.WalkSpeed
            break
        end
    end
    -- JumpPower
    for _,v in pairs(jpFrame:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:match("^%d+$") then
            state.JumpPower = tonumber(v.Text) or state.JumpPower
            break
        end
    end
    -- Fly speed
    for _,v in pairs(flySpeedFrame:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:match("^%d+$") then
            state.FlySpeed = tonumber(v.Text) or state.FlySpeed
            break
        end
    end
    -- Sprint mult
    for _,v in pairs(sprintFrame:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:match("^%d+$") then
            state.SprintMult = tonumber(v.Text) or state.SprintMult
            break
        end
    end
    for _,v in pairs(tpStepFrame:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:match("^%d+$") then
            state.TPStep = tonumber(v.Text) or state.TPStep
            break
        end
    end
end

-- Inf jump hookup
UserInputService.JumpRequest:Connect(function()
    if getInf() then
        local _,_,hum = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Noclip loop
local nocConn
RunService.Stepped:Connect(function()
    -- update state booleans from toggles UI (sync)
    state.InfJump = getInf()
    state.Fly = getFly()
    state.Noclip = getNoc()
    state.SprintEnabled = getSprint()
    state.TPWalk = getTPW()
    state.AutoHeal = getHeal()
    state.Glide = getGlide()
    readSliders()

    local char, hrp, hum = getChar()
    if not char or not hrp or not hum then return end

    if state.Noclip then
        for _,part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then
                part.CanCollide = false
            end
        end
    end

    -- AutoHeal
    if state.AutoHeal then
        if hum and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end

    -- Glide: if enabled and space held and falling, reduce downward velocity
    if state.Glide and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local vel = hrp.Velocity
        if vel.Y < -5 then
            -- gentle slow down fall
            hrp.Velocity = Vector3.new(vel.X, -5, vel.Z)
        end
    end
end)

-- Fly implementation (BodyVelocity on HRP, controlled by camera)
local flyBV
local flyConn
local function startFly()
    local _, hrp = getChar()
    if not hrp then return end
    if flyBV and flyBV.Parent then flyBV:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.P = 1250
    flyBV.Parent = hrp
    -- update loop
    flyConn = RunService.RenderStepped:Connect(function()
        if not getFly() then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        if move.Magnitude > 0 then
            flyBV.Velocity = move.Unit * state.FlySpeed
        else
            flyBV.Velocity = Vector3.new(0,0,0)
        end
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV = nil end
end

-- toggle Fly via UI getter
spawn(function()
    while true do
        if getFly() then
            if not flyBV then startFly() end
        else
            if flyBV then stopFly() end
        end
        task.wait(0.15)
    end
end)

-- TP Walk: while holding LeftAlt, teleport toward mouse in steps (smooth-ish)
local mouse = player:GetMouse()
RunService.Heartbeat:Connect(function(dt)
    if state.TPWalk and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local char, hrp, hum = getChar()
        if char and hrp then
            local target = mouse.Hit and mouse.Hit.Position
            if target then
                -- move a step towards target
                local dir = (target - hrp.Position)
                local dist = dir.Magnitude
                if dist > 1 then
                    local step = math.min(state.TPStep, dist)
                    local newPos = hrp.Position + dir.Unit * step
                    -- prefer SetPrimaryPartCFrame if possible
                    pcall(function()
                        char:SetPrimaryPartCFrame(CFrame.new(newPos + Vector3.new(0,2,0)))
                    end)
                end
            end
        end
    end
end)

-- Teleport to mouse click
tpToMouseBtn.MouseButton1Click:Connect(function()
    local char, hrp, hum = getChar()
    if not hrp then return end
    local target = mouse.Hit and mouse.Hit.Position
    if target then
        pcall(function() char:SetPrimaryPartCFrame(CFrame.new(target + Vector3.new(0,3,0))) end)
    end
end)

-- Teleport to selected player
tpToPlayerBtn.MouseButton1Click:Connect(function()
    local selName = playerDropdown.Text:gsub(" ▼$", "")
    if selName == "Select Player" then return end
    local target = Players:FindFirstChild(selName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos = target.Character.HumanoidRootPart.Position
        local char, hrp = getChar()
        if hrp and char then
            pcall(function() char:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0,3,0))) end)
        end
    end
end)

-- update player dropdown when players change
Players.PlayerAdded:Connect(function() if dropdownOpen then refreshPlayerList() end end)
Players.PlayerRemoving:Connect(function() if dropdownOpen then refreshPlayerList() end end)

-- Teleport short TP (TP Step key: T) - one-press forward teleport by TPStep studs
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        if state.TPWalk then
            local char, hrp, hum = getChar()
            if hrp then
                local cam = workspace.CurrentCamera
                local newPos = hrp.Position + cam.CFrame.LookVector * state.TPStep
                pcall(function() char:SetPrimaryPartCFrame(CFrame.new(newPos + Vector3.new(0,3,0))) end)
            end
        end
    end
end)

-- cleanup on character removal: ensure fly BV removed
player.CharacterRemoving:Connect(function()
    stopFly()
end)

-- final print quick help
print([[
LVM Player tab loaded (client).
Keys:
 - Sprint: hold LeftShift (if enabled)
 - TPWalk: hold LeftAlt (moves toward mouse by steps)
 - TP Step quick: press T to teleport forward by TP Step
 - Teleport mouse: click "Teleport → Mouse"
 - Teleport player: select name then "Teleport → Player"
 - Fly: enable in UI, then use WASD + Space/CTRL to move
 - Glide: hold Space while falling to slow down
]])
