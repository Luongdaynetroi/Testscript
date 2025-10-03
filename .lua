-- LVM Hub — Multi-tab UI (Player + Combat) (Client)
-- Paste vào executor / LocalScript (client). Test trong Studio/private server.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then return end

-- safe cleanup
local existing = game:GetService("CoreGui"):FindFirstChild("LVM_Hub_Screen")
if existing then existing:Destroy() end

-- helper tween
local function tween(obj, props, t) return TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props) end

-- Theme
local ACCENT = Color3.fromRGB(76,145,255)
local BG = Color3.fromRGB(28,30,36)
local PANEL = Color3.fromRGB(36,38,44)
local TXT = Color3.fromRGB(235,235,240)

-- Root
local screen = Instance.new("ScreenGui")
screen.Name = "LVM_Hub_Screen"
screen.ResetOnSpawn = false
screen.Parent = game:GetService("CoreGui")

-- Floating button
local float = Instance.new("TextButton", screen)
float.Name = "FloatBtn"
float.Text = "LVM"
float.Font = Enum.Font.GothamBold
float.TextSize = 14
float.TextColor3 = Color3.new(1,1,1)
float.BackgroundColor3 = ACCENT
float.Size = UDim2.new(0,56,0,56)
float.Position = UDim2.new(0.02,0,0.8,0)
float.AnchorPoint = Vector2.new(0.5,0.5)
float.AutoButtonColor = false
local fc = Instance.new("UICorner", float); fc.CornerRadius = UDim.new(1,0)
local fst = Instance.new("UIStroke", float); fst.Color = Color3.fromRGB(12,12,18); fst.Thickness = 1

-- Panel
local panel = Instance.new("Frame", screen)
panel.Name = "MainPanel"
panel.Size = UDim2.new(0,720,0,420)
panel.Position = UDim2.new(0.5, -360, 0.5, -210)
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.BackgroundColor3 = PANEL
panel.Visible = false
local pc = Instance.new("UICorner", panel); pc.CornerRadius = UDim.new(0,14)
local pst = Instance.new("UIStroke", panel); pst.Color = Color3.fromRGB(10,10,10); pst.Thickness = 1

-- Top strip & header
local top = Instance.new("Frame", panel); top.Size = UDim2.new(1,0,0,8); top.Position = UDim2.new(0,0,0,0); top.BackgroundColor3 = ACCENT; top.BackgroundTransparency = 0.12
Instance.new("UICorner", top).CornerRadius = UDim.new(0,6)

local header = Instance.new("Frame", panel); header.Size = UDim2.new(1,0,0,46); header.Position = UDim2.new(0,0,0,6); header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header); title.Text = "LVM Hub • Demo"; title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.TextColor3 = TXT; title.BackgroundTransparency = 1; title.Position = UDim2.new(0,16,0,6); title.Size = UDim2.new(0.5,0,0,34)

local closeBtn = Instance.new("TextButton", header); closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20; closeBtn.TextColor3 = TXT; closeBtn.BackgroundTransparency = 1; closeBtn.Size = UDim2.new(0,36,0,36); closeBtn.Position = UDim2.new(1,-46,0,4); closeBtn.AutoButtonColor = false
closeBtn.MouseButton1Click:Connect(function() tween(panel, {Position = float.Position}, 0.18):Play(); wait(0.18); panel.Visible = false end)

-- Layout: sidebar + content
local sidebar = Instance.new("Frame", panel); sidebar.Size = UDim2.new(0,180,1,-72); sidebar.Position = UDim2.new(0,12,0,64); sidebar.BackgroundTransparency = 1
local content = Instance.new("Frame", panel); content.Size = UDim2.new(1,-220,1,-72); content.Position = UDim2.new(0,204,0,64); content.BackgroundTransparency = 1

-- Sidebar header
local avatar = Instance.new("ImageLabel", sidebar); avatar.Size = UDim2.new(0,48,0,48); avatar.Position = UDim2.new(0,0,0,0); avatar.BackgroundTransparency = 1
local avc = Instance.new("UICorner", avatar); avc.CornerRadius = UDim.new(1,0)
local userlbl = Instance.new("TextLabel", sidebar); userlbl.Position = UDim2.new(0,56,0,8); userlbl.Size = UDim2.new(1,-56,0,24); userlbl.BackgroundTransparency = 1; userlbl.Text = player.Name; userlbl.Font = Enum.Font.GothamBold; userlbl.TextSize = 14; userlbl.TextColor3 = TXT; userlbl.TextXAlignment = Enum.TextXAlignment.Left

-- Sidebar buttons factory
local function makeSideBtn(txt, y)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1,-8,0,42); b.Position = UDim2.new(0,4,0,y)
    b.Text = "   "..txt; b.Font = Enum.Font.Gotham; b.TextSize = 15; b.TextColor3 = Color3.fromRGB(220,220,220)
    b.BackgroundColor3 = Color3.fromRGB(34,36,40); b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(10,10,10); s.Thickness = 1
    b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(46,49,56)}, 0.12):Play() end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(34,36,40)}, 0.12):Play() end)
    return b
end

local tabNames = {"Player","Combat","Visual","Misc"}
local tabButtons = {}
for i, name in ipairs(tabNames) do
    tabButtons[name] = makeSideBtn(name, 64 + (i-1)*48)
end

-- Content frames per tab (use ScrollingFrame to avoid overflow)
local TabFrames = {}
for _, name in ipairs(tabNames) do
    local frm = Instance.new("Frame", content)
    frm.Name = name.."Frame"
    frm.Size = UDim2.new(1,0,1,0)
    frm.BackgroundTransparency = 1
    frm.Visible = false

    local scr = Instance.new("ScrollingFrame", frm)
    scr.Name = "Scroll"
    scr.Size = UDim2.new(1,0,1,0)
    scr.CanvasSize = UDim2.new(0,0,0,0)
    scr.ScrollBarThickness = 6
    scr.BackgroundTransparency = 1
    scr.Parent = frm

    local layout = Instance.new("UIListLayout", scr)
    layout.Padding = UDim.new(0,12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- auto update canvas size
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scr.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 12)
    end)

    TabFrames[name] = frm
end

-- show Player by default
TabFrames.Player.Visible = true
tabButtons.Player.BackgroundColor3 = Color3.fromRGB(45,48,54)

-- helper factories for items (placed inside a tab's Scroll frame)
local function makeSectionTitle(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1,-24,0,22)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function makeToggle(parent, text, init)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,-24,0,34); holder.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", holder); label.Size = UDim2.new(0.7,0,1,0); label.Position = UDim2.new(0,0,0,0); label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham; label.TextSize = 14; label.TextColor3 = Color3.fromRGB(220,220,220); label.Text = text
    local sw = Instance.new("TextButton", holder); sw.Size = UDim2.new(0,46,0,24); sw.Position = UDim2.new(1,-50,0.5,-12); sw.BackgroundColor3 = Color3.fromRGB(60,60,65); sw.AutoButtonColor = false
    local swc = Instance.new("UICorner", sw); swc.CornerRadius = UDim.new(0,10)
    local fill = Instance.new("Frame", sw); fill.Size = UDim2.new(init and 1 or 0,0,1,0); fill.BackgroundColor3 = init and ACCENT or Color3.fromRGB(120,120,120); local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(0,8)
    local state = init or false
    sw.MouseButton1Click:Connect(function()
        state = not state
        tween(fill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play()
        tween(fill, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(120,120,120)}, 0.12):Play()
    end)
    return holder, function() return state end, function(v) state = v; tween(fill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play(); tween(fill, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(120,120,120)}, 0.12):Play() end
end

local function makeSlider(parent, text, minv, maxv, init)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,-24,0,48); holder.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", holder); lbl.Size = UDim2.new(0.6,0,0,18); lbl.Position = UDim2.new(0,0,0,0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 13; lbl.TextColor3 = Color3.fromRGB(210,210,210); lbl.Text = text
    local val = Instance.new("TextLabel", holder); val.Size = UDim2.new(0.4,0,0,18); val.Position = UDim2.new(0.6,0,0,0); val.BackgroundTransparency = 1; val.Font = Enum.Font.GothamBold; val.TextSize = 13; val.TextColor3 = ACCENT; val.Text = tostring(init)
    local bar = Instance.new("Frame", holder); bar.Size = UDim2.new(1,0,0,10); bar.Position = UDim2.new(0,0,0,26); bar.BackgroundColor3 = Color3.fromRGB(40,40,44)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((init-minv)/(maxv-minv),0,1,0); fill.BackgroundColor3 = ACCENT; Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)
    local dragging = false
    local function updateFromX(x)
        local abs = x - bar.AbsolutePosition.X
        local frac = math.clamp(abs / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(frac,0,1,0)
        local value = minv + frac*(maxv-minv)
        val.Text = tostring(math.floor(value+0.5))
        return value
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    bar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    bar.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateFromX(input.Position.X) end end)
    return holder, function() return tonumber(val.Text) end, function(v) local frac = math.clamp((v-minv)/(maxv-minv),0,1); fill.Size = UDim2.new(frac,0,1,0); val.Text = tostring(math.floor(v+0.5)) end
end

-- ---------------- Player Tab Controls ----------------
local playerScroll = TabFrames.Player:FindFirstChild("Scroll")
-- Add controls into playerScroll
makeSectionTitle(playerScroll, "Player Utilities — packed")
local infCtrl, getInf, setInf = makeToggle(playerScroll, "Infinite Jump", false)
local flyCtrl, getFly, setFly = makeToggle(playerScroll, "Fly (WASD + Space/CTRL)", false)
local flySpeedCtrl, getFlySpeed, setFlySpeed = makeSlider(playerScroll, "Fly Speed", 10, 300, 80)
local wsCtrl, getWS, setWS = makeSlider(playerScroll, "WalkSpeed", 8, 300, 16)
local jpCtrl, getJP, setJP = makeSlider(playerScroll, "JumpPower", 20, 300, 50)
local nocCtrl, getNoc, setNoc = makeToggle(playerScroll, "Noclip (no collisions)", false)
local sprintCtrl, getSprint, setSprint = makeToggle(playerScroll, "Sprint (hold LeftShift)", false)
local sprintMultCtrl, getSprintMult, setSprintMult = makeSlider(playerScroll, "Sprint Mult", 1, 4, 1.8)
makeSectionTitle(playerScroll, "Teleport / Movement")
local tpMouseBtn = Instance.new("TextButton", playerScroll); tpMouseBtn.Size = UDim2.new(0,200,0,34); tpMouseBtn.Text = "Teleport → Mouse (click)"; tpMouseBtn.Font = Enum.Font.GothamBold; tpMouseBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); tpMouseBtn.AutoButtonColor = false; Instance.new("UICorner", tpMouseBtn).CornerRadius = UDim.new(0,8)
local playerDropdownBtn = Instance.new("TextButton", playerScroll); playerDropdownBtn.Size = UDim2.new(0,220,0,34); playerDropdownBtn.Text = "Select Player ▼"; playerDropdownBtn.Font = Enum.Font.GothamBold; playerDropdownBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); playerDropdownBtn.AutoButtonColor = false; Instance.new("UICorner", playerDropdownBtn).CornerRadius = UDim.new(0,8)
local tpToPlayerBtn = Instance.new("TextButton", playerScroll); tpToPlayerBtn.Size = UDim2.new(0,200,0,34); tpToPlayerBtn.Text = "Teleport → Player"; tpToPlayerBtn.Font = Enum.Font.GothamBold; tpToPlayerBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); tpToPlayerBtn.AutoButtonColor = false; Instance.new("UICorner", tpToPlayerBtn).CornerRadius = UDim.new(0,8)

-- player dropdown contents
local dropdown = Instance.new("Frame", playerScroll); dropdown.Size = UDim2.new(0,220,0,0); dropdown.ClipsDescendants = true; dropdown.BackgroundTransparency = 1

local function refreshPlayerDropdown()
    for _,v in pairs(dropdown:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local idx = 0
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player then
            local b = Instance.new("TextButton", dropdown); b.Size = UDim2.new(1,0,0,28); b.Position = UDim2.new(0,0,0, idx*28); b.Text = pl.Name; b.Font = Enum.Font.Gotham; b.BackgroundColor3 = Color3.fromRGB(50,50,54)
            b.TextColor3 = Color3.fromRGB(230,230,230); Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
            b.MouseButton1Click:Connect(function() playerDropdownBtn.Text = pl.Name.." ▼"; dropdown:TweenSize(UDim2.new(0,220,0,0), "Out", "Quad", 0.18, true) end)
            idx = idx + 1
        end
    end
end
playerDropdownBtn.MouseButton1Click:Connect(function()
    if dropdown.Size.Y.Offset == 0 then
        refreshPlayerDropdown()
        dropdown:TweenSize(UDim2.new(0,220,0, math.max(1,#Players:GetPlayers()-1) * 28), "Out", "Quad", 0.18, true)
    else
        dropdown:TweenSize(UDim2.new(0,220,0,0), "Out", "Quad", 0.18, true)
    end
end)

-- ---------------- Combat Tab Controls ----------------
local combatScroll = TabFrames.Combat:FindFirstChild("Scroll")
makeSectionTitle(combatScroll, "Combat Utilities")
local espToggleCtrl, getESPToggle, setESPToggle = makeToggle(combatScroll, "ESP (name tags)", false)
local boxesToggleCtrl, getBoxesToggle, setBoxesToggle = makeToggle(combatScroll, "Highlight (boxes)", false)
local aimToggleCtrl, getAimToggle, setAimToggle = makeToggle(combatScroll, "Aim Assist (dot)", false)
local aimSensCtrl, getAimSens, setAimSens = makeSlider(combatScroll, "Aim Sensitivity", 1, 200, 80)

-- ---------------- Functionality Implementation ----------------
-- safe getters for character
local function getChar()
    local c = player.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if getInf() then
        local _,_,hum = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- WalkSpeed & JumpPower update loop
RunService.Heartbeat:Connect(function()
    local _,_,hum = getChar()
    if hum then
        -- sprint
        local baseWS = tonumber(getWS()) or 16
        if getSprint() and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            hum.WalkSpeed = baseWS * (tonumber(getSprintMult()) or 1.8)
        else
            hum.WalkSpeed = tonumber(getWS()) or 16
        end
        hum.JumpPower = tonumber(getJP()) or 50
    end
end)

-- Noclip
local nocRunning = false
RunService.Stepped:Connect(function()
    if getNoc() then
        local c,hrp = getChar()
        if c then
            for _,p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end
end)

-- Fly (BodyVelocity)
local flyBV
local flyConn
local function startFly()
    local c,hrp = getChar()
    if not hrp then return end
    if flyBV then flyBV:Destroy() end
    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.P = 1250
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
            flyBV.Velocity = move.Unit * (tonumber(getFlySpeed()) or 80)
        else
            flyBV.Velocity = Vector3.new(0,0,0)
        end
    end)
end
local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV = nil end
end
-- monitor fly toggle
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

-- TP to mouse
local mouse = player:GetMouse()
tpMouseBtn.MouseButton1Click:Connect(function()
    local c,hrp,hum = getChar()
    if not hrp then return end
    local target = mouse.Hit and mouse.Hit.Position
    if target then
        pcall(function() c:SetPrimaryPartCFrame(CFrame.new(target + Vector3.new(0,3,0))) end)
    end
end)

-- Teleport to selected player
tpToPlayerBtn.MouseButton1Click:Connect(function()
    local sel = playerDropdownBtn.Text:gsub(" ▼$","")
    if sel == "Select Player" then return end
    local target = Players:FindFirstChild(sel)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos = target.Character.HumanoidRootPart.Position
        local c,hrp = getChar()
        if c and hrp then pcall(function() c:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0,3,0))) end) end
    end
end)

-- Refresh dropdown on player join/leave
Players.PlayerAdded:Connect(refreshPlayerDropdown)
Players.PlayerRemoving:Connect(refreshPlayerDropdown)

-- Combat features: ESP + Aim dot + Highlight
local espFolder = Instance.new("Folder", screen); espFolder.Name = "LVM_ESP"
local highlights = {}
local aimDot
local aimConn

local function enableESP()
    for _,pl in pairs(Players:GetPlayers()) do
        if pl ~= player and pl.Character and pl.Character:FindFirstChild("Head") then
            local tag = Instance.new("BillboardGui")
            tag.Name = "LVM_Tag"
            tag.Adornee = pl.Character.Head
            tag.Size = UDim2.new(0,120,0,30)
            tag.AlwaysOnTop = true
            local lab = Instance.new("TextLabel", tag)
            lab.Size = UDim2.new(1,0,1,0); lab.BackgroundTransparency = 1; lab.Font = Enum.Font.GothamBold; lab.TextSize = 14; lab.TextColor3 = Color3.new(1,1,1)
            lab.Text = pl.Name
            tag.Parent = espFolder
        end
    end
    -- dynamic
    Players.PlayerAdded:Connect(function(pl)
        if getESPToggle() and pl ~= player then
            task.wait(0.2)
            if pl.Character and pl.Character:FindFirstChild("Head") then
                local tag = Instance.new("BillboardGui")
                tag.Name = "LVM_Tag"
                tag.Adornee = pl.Character.Head
                tag.Size = UDim2.new(0,120,0,30)
                tag.AlwaysOnTop = true
                local lab = Instance.new("TextLabel", tag)
                lab.Size = UDim2.new(1,0,1,0); lab.BackgroundTransparency = 1; lab.Font = Enum.Font.GothamBold; lab.TextSize = 14; lab.TextColor3 = Color3.new(1,1,1)
                lab.Text = pl.Name
                tag.Parent = espFolder
            end
        end
    end)
end

local function disableESP()
    for _,v in pairs(espFolder:GetChildren()) do pcall(function() v:Destroy() end) end
end

-- Monitor ESP toggle
spawn(function()
    while true do
        if getESPToggle() then enableESP() else disableESP() end
        task.wait(0.6)
    end
end)

-- Highlight boxes
spawn(function()
    while true do
        if getBoxesToggle() then
            for _,pl in pairs(Players:GetPlayers()) do
                if pl ~= player and pl.Character and not highlights[pl] then
                    local ok, hl = pcall(function()
                        local h = Instance.new("Highlight", pl.Character)
                        h.Name = "LVM_HL"
                        h.FillTransparency = 0.6
                        h.OutlineTransparency = 1
                        return h
                    end)
                    if ok then highlights[pl] = hl end
                end
            end
        else
            for pl,hl in pairs(highlights) do
                pcall(function() hl:Destroy() end)
            end
            highlights = {}
        end
        task.wait(0.7)
    end
end)

-- Aim dot (simple)
local function startAimDot()
    if aimDot then aimDot:Destroy() end
    aimDot = Instance.new("BillboardGui", screen)
    aimDot.Size = UDim2.new(0,8,0,8); aimDot.AlwaysOnTop = true
    local f = Instance.new("Frame", aimDot); f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = Color3.fromRGB(255,60,60); f.BorderSizePixel = 0; Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
    aimConn = RunService.RenderStepped:Connect(function()
        if not getAimToggle() then return end
        local cam = workspace.CurrentCamera
        local best, bestD = nil, math.huge
        for _,pl in pairs(Players:GetPlayers()) do
            if pl ~= player and pl.Character and pl.Character:FindFirstChild("Head") then
                local screenPos, on = cam:WorldToViewportPoint(pl.Character.Head.Position)
                if on then
                    local dx = screenPos.X - cam.ViewportSize.X/2
                    local dy = screenPos.Y - cam.ViewportSize.Y/2
                    local d = math.sqrt(dx*dx + dy*dy)
                    if d < bestD then bestD = d; best = pl end
                end
            end
        end
        if best and best.Character and best.Character:FindFirstChild("Head") then
            aimDot.Adornee = best.Character.Head
            aimDot.Enabled = true
        else
            aimDot.Enabled = false
        end
    end)
end

local function stopAimDot()
    if aimConn then aimConn:Disconnect(); aimConn = nil end
    if aimDot and aimDot.Parent then aimDot:Destroy(); aimDot = nil end
end

-- Monitor Aim toggle
spawn(function()
    while true do
        if getAimToggle() then
            if not aimDot then startAimDot() end
        else
            if aimDot then stopAimDot() end
        end
        task.wait(0.2)
    end
end)

-- ---------------- Tab switching logic ----------------
local function hideAllTabs()
    for k,v in pairs(TabFrames) do v.Visible = false end
    for k,v in pairs(tabButtons) do v.BackgroundColor3 = Color3.fromRGB(34,36,40); v.TextColor3 = Color3.fromRGB(220,220,220) end
end

for name,btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        hideAllTabs()
        TabFrames[name].Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(45,48,54)
    end)
end

-- Panel drag (via header)
do
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput and dragStart and startPos then
            local delta = dragInput.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Float button open/close
float.MouseButton1Click:Connect(function()
    if panel.Visible then
        tween(panel, {Position = float.Position}, 0.18):Play(); wait(0.18); panel.Visible = false
    else
        panel.Visible = true; panel.Position = float.Position
        tween(panel, {Position = UDim2.new(0.5, -360, 0.5, -210)}, 0.22):Play()
    end
end)

-- keyboard toggle (RightControl)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        float:Activate()
        float.MouseButton1Click:Wait()
    end
end)

-- final: open default tab Player
hideAllTabs(); TabFrames.Player.Visible = true; tabButtons.Player.BackgroundColor3 = Color3.fromRGB(45,48,54)

print("LVM Hub multi-tab UI loaded. Player + Combat tabs active. Test trong Studio/private server.")
