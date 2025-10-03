-- LVM Hub — Full Tab UI (Player features implemented)
-- Client-side LocalScript / Executor paste
-- Test trong Studio / private server. Không có "anti-ban" evasion ngoài scope.
-- Features: multi-tab UI, Player tab fully implemented (InfJump, Fly, WalkSpeed, JumpPower, Noclip, Sprint, TP Walk, TP Step, Teleport Mouse/Player, Glide, AutoHeal, Anti-Fall Damage)
-- Author: Lâm Vĩ (for you). Paste & run.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
if not player then return end

-- single-run cleanup
local existing = game:GetService("CoreGui"):FindFirstChild("LVM_Hub_Screen")
if existing then existing:Destroy() end

-- helper tween
local function tween(obj, props, t) return TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props) end

-- theme
local ACCENT = Color3.fromRGB(85, 120, 255)
local PANEL = Color3.fromRGB(28, 30, 36)
local TXT = Color3.fromRGB(255,255,255) -- requested white text

-- root ScreenGui
local screen = Instance.new("ScreenGui")
screen.Name = "LVM_Hub_Screen"
screen.ResetOnSpawn = false
screen.Parent = game:GetService("CoreGui")

-- floating button
local float = Instance.new("TextButton", screen)
float.Name = "FloatBtn"
float.Text = "LVM"
float.Font = Enum.Font.GothamBold
float.TextSize = 14
float.TextColor3 = TXT
float.BackgroundColor3 = ACCENT
float.Size = UDim2.new(0,56,0,56)
float.Position = UDim2.new(0.02,0,0.82,0)
float.AnchorPoint = Vector2.new(0.5,0.5)
float.AutoButtonColor = false
local fc = Instance.new("UICorner", float); fc.CornerRadius = UDim.new(1,0)
local fst = Instance.new("UIStroke", float); fst.Color = Color3.fromRGB(12,12,18); fst.Thickness = 1

-- main panel
local panel = Instance.new("Frame", screen)
panel.Name = "MainPanel"
panel.Size = UDim2.new(0,720,0,460)
panel.Position = UDim2.new(0.5,-360,0.5,-230)
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.BackgroundColor3 = PANEL
panel.Visible = false
local pc = Instance.new("UICorner", panel); pc.CornerRadius = UDim.new(0,14)
local pst = Instance.new("UIStroke", panel); pst.Color = Color3.fromRGB(10,10,10); pst.Thickness = 1

-- top strip and header
local top = Instance.new("Frame", panel); top.Size = UDim2.new(1,0,0,8); top.Position = UDim2.new(0,0,0,0); top.BackgroundColor3 = ACCENT; top.BackgroundTransparency = 0.12
Instance.new("UICorner", top).CornerRadius = UDim.new(0,6)
local header = Instance.new("Frame", panel); header.Size = UDim2.new(1,0,0,52); header.Position = UDim2.new(0,0,0,6); header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header); title.Text = "LVM Hub • Full Demo"; title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.TextColor3 = TXT; title.BackgroundTransparency = 1; title.Position = UDim2.new(0,16,0,6); title.Size = UDim2.new(0.5,0,0,36)

local closeBtn = Instance.new("TextButton", header); closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20; closeBtn.TextColor3 = TXT; closeBtn.BackgroundTransparency = 1; closeBtn.Size = UDim2.new(0,36,0,36); closeBtn.Position = UDim2.new(1,-46,0,6); closeBtn.AutoButtonColor = false
closeBtn.MouseEnter:Connect(function() tween(closeBtn, {TextColor3 = Color3.fromRGB(255,100,100)}, 0.12):Play() end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, {TextColor3 = TXT}, 0.12):Play() end)
closeBtn.MouseButton1Click:Connect(function() tween(panel, {Position = float.Position}, 0.18):Play(); wait(0.18); panel.Visible = false end)

-- layout: sidebar + content
local sidebar = Instance.new("Frame", panel); sidebar.Size = UDim2.new(0,200,1,-92); sidebar.Position = UDim2.new(0,12,0,72); sidebar.BackgroundTransparency = 1
local content = Instance.new("Frame", panel); content.Size = UDim2.new(1,-232,1,-92); content.Position = UDim2.new(0,220,0,72); content.BackgroundTransparency = 1

-- sidebar header
local avatar = Instance.new("ImageLabel", sidebar); avatar.Size = UDim2.new(0,48,0,48); avatar.Position = UDim2.new(0,0,0,0); avatar.BackgroundTransparency = 1; avatar.Image = ""
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)
local userlbl = Instance.new("TextLabel", sidebar); userlbl.Position = UDim2.new(0,56,0,8); userlbl.Size = UDim2.new(1,-56,0,24); userlbl.BackgroundTransparency = 1; userlbl.Text = player.Name; userlbl.Font = Enum.Font.GothamBold; userlbl.TextSize = 14; userlbl.TextColor3 = TXT; userlbl.TextXAlignment = Enum.TextXAlignment.Left

-- create tab buttons
local tabNames = {"Player","Combat","Visual","Misc"}
local tabButtons = {}
local function makeSideBtn(txt, y)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1,-8,0,44); b.Position = UDim2.new(0,4,0,y)
    b.Text = "   "..txt; b.Font = Enum.Font.Gotham; b.TextSize = 15; b.TextColor3 = Color3.fromRGB(235,235,235)
    b.BackgroundColor3 = Color3.fromRGB(34,36,40); b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(10,10,10); s.Thickness = 1
    b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(46,49,56)}, 0.12):Play() end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(34,36,40)}, 0.12):Play() end)
    return b
end

for i,name in ipairs(tabNames) do
    tabButtons[name] = makeSideBtn(name, 64 + (i-1)*52)
end

-- content frames per tab with scrolling
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

    local layout = Instance.new("UIListLayout", scr)
    layout.Padding = UDim.new(0,12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scr.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
    end)

    TabFrames[name] = frm
end

-- default show Player
TabFrames.Player.Visible = true
tabButtons.Player.BackgroundColor3 = Color3.fromRGB(45,48,54)

-- small UI factories (text white)
local function makeSectionTitle(parent, text)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size = UDim2.new(1,-24,0,22)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 14
    lbl.TextColor3 = TXT
    lbl.Text = text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local function makeToggle(parent, text, init)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,-24,0,34); holder.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", holder); label.Size = UDim2.new(0.7,0,1,0); label.BackgroundTransparency = 1; label.Font=Enum.Font.Gotham; label.TextSize=14; label.TextColor3 = TXT; label.Text=text
    local sw = Instance.new("TextButton", holder); sw.Size = UDim2.new(0,48,0,26); sw.Position = UDim2.new(1,-54,0.5,-13); sw.BackgroundColor3 = Color3.fromRGB(70,70,75); sw.AutoButtonColor=false
    local swc = Instance.new("UICorner", sw); swc.CornerRadius = UDim.new(0,10)
    local fill = Instance.new("Frame", sw); fill.Size = UDim2.new(init and 1 or 0,0,1,0); fill.BackgroundColor3 = init and ACCENT or Color3.fromRGB(140,140,140); Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)
    local state = init or false
    sw.MouseButton1Click:Connect(function() state = not state; tween(fill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play(); tween(fill, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(140,140,140)}, 0.12):Play() end)
    return holder, function() return state end, function(v) state=v; tween(fill, {Size=UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play(); tween(fill, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(140,140,140)}, 0.12):Play() end
end

local function makeSlider(parent, text, minv, maxv, init)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,-24,0,48); holder.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", holder); lbl.Size = UDim2.new(0.6,0,0,18); lbl.Position=UDim2.new(0,0,0,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextColor3 = TXT; lbl.Text=text
    local val = Instance.new("TextLabel", holder); val.Size = UDim2.new(0.4,0,0,18); val.Position=UDim2.new(0.6,0,0,0); val.BackgroundTransparency=1; val.Font=Enum.Font.GothamBold; val.TextSize=13; val.TextColor3 = ACCENT; val.Text = tostring(init)
    local bar = Instance.new("Frame", holder); bar.Size = UDim2.new(1,0,0,10); bar.Position=UDim2.new(0,0,0,26); bar.BackgroundColor3 = Color3.fromRGB(40,40,44); Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)
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
    bar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; updateFromX(input.Position.X) end end)
    bar.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    bar.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then updateFromX(input.Position.X) end end)
    return holder, function() return tonumber(val.Text) end, function(v) local frac = math.clamp((v-minv)/(maxv-minv),0,1); fill.Size=UDim2.new(frac,0,1,0); val.Text=tostring(math.floor(v+0.5)) end
end

-- ---------------- Player Tab Controls ----------------
local playerScroll = TabFrames.Player:FindFirstChild("Scroll")

makeSectionTitle(playerScroll, "Player — Movement & Tools")
local infCtrl, getInf, setInf = makeToggle(playerScroll, "Infinite Jump", false)
local flyCtrl, getFly, setFly = makeToggle(playerScroll, "Fly (WASD + Space/Ctrl)", false)
local flySpeedCtrl, getFlySpeed, setFlySpeed = makeSlider(playerScroll, "Fly Speed", 10, 300, 80)
local wsCtrl, getWS, setWS = makeSlider(playerScroll, "WalkSpeed", 8, 300, 16)
local jpCtrl, getJP, setJP = makeSlider(playerScroll, "JumpPower", 20, 300, 50)
local nocCtrl, getNoc, setNoc = makeToggle(playerScroll, "Noclip (no collisions)", false)
local sprintCtrl, getSprint, setSprint = makeToggle(playerScroll, "Sprint (hold LeftShift)", false)
local sprintMultCtrl, getSprintMult, setSprintMult = makeSlider(playerScroll, "Sprint Mult", 1, 4, 1.8)
makeSectionTitle(playerScroll, "Teleport / Movement")
local tpMouseBtn = Instance.new("TextButton", playerScroll); tpMouseBtn.Size = UDim2.new(0,220,0,34); tpMouseBtn.Text = "Teleport → Mouse (click)"; tpMouseBtn.Font=Enum.Font.GothamBold; tpMouseBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); tpMouseBtn.TextColor3 = TXT; Instance.new("UICorner", tpMouseBtn).CornerRadius = UDim.new(0,8)
local playerDropdownBtn = Instance.new("TextButton", playerScroll); playerDropdownBtn.Size = UDim2.new(0,260,0,34); playerDropdownBtn.Text = "Select Player ▼"; playerDropdownBtn.Font=Enum.Font.GothamBold; playerDropdownBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); playerDropdownBtn.TextColor3 = TXT; Instance.new("UICorner", playerDropdownBtn).CornerRadius = UDim.new(0,8)
local tpToPlayerBtn = Instance.new("TextButton", playerScroll); tpToPlayerBtn.Size = UDim2.new(0,220,0,34); tpToPlayerBtn.Text = "Teleport → Player"; tpToPlayerBtn.Font=Enum.Font.GothamBold; tpToPlayerBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); tpToPlayerBtn.TextColor3 = TXT; Instance.new("UICorner", tpToPlayerBtn).CornerRadius = UDim.new(0,8)
local tpStepBtn = Instance.new("TextButton", playerScroll); tpStepBtn.Size = UDim2.new(0,160,0,34); tpStepBtn.Text = "TP Step (Key: T)"; tpStepBtn.Font = Enum.Font.GothamBold; tpStepBtn.BackgroundColor3 = Color3.fromRGB(44,44,48); tpStepBtn.TextColor3 = TXT; Instance.new("UICorner", tpStepBtn).CornerRadius = UDim.new(0,8)
makeSectionTitle(playerScroll, "Quality of Life")
local glideCtrl, getGlide, setGlide = makeToggle(playerScroll, "Glide (hold Space to slow fall)", false)
local healCtrl, getHeal, setHeal = makeToggle(playerScroll, "AutoHeal (restore HP)", false)
local antiFallCtrl, getAntiFall, setAntiFall = makeToggle(playerScroll, "Anti-Fall Damage (soften fall)", false)

-- player dropdown frame
local dropdown = Instance.new("Frame", playerScroll); dropdown.Size = UDim2.new(0,260,0,0); dropdown.Position = UDim2.new(0,12,0,0); dropdown.ClipsDescendants = true; dropdown.BackgroundTransparency = 1

local function refreshPlayerDropdown()
    for _,v in pairs(dropdown:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local idx = 0
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= player then
            local b = Instance.new("TextButton", dropdown); b.Size = UDim2.new(1,0,0,28); b.Position = UDim2.new(0,0,0, idx*28); b.Text = pl.Name; b.Font = Enum.Font.Gotham; b.BackgroundColor3 = Color3.fromRGB(50,50,54); b.TextColor3 = TXT
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
            b.MouseButton1Click:Connect(function() playerDropdownBtn.Text = pl.Name.." ▼"; dropdown:TweenSize(UDim2.new(0,260,0,0), "Out", "Quad", 0.18, true) end)
            idx = idx + 1
        end
    end
end
playerDropdownBtn.MouseButton1Click:Connect(function()
    if dropdown.Size.Y.Offset == 0 then refreshPlayerDropdown(); dropdown:TweenSize(UDim2.new(0,260,0, math.max(1,#Players:GetPlayers()-1) * 28), "Out", "Quad", 0.18, true) else dropdown:TweenSize(UDim2.new(0,260,0,0), "Out", "Quad", 0.18, true) end
end)

-- ---------------- Player functionality ----------------
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

-- WalkSpeed/JPP update loop
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

-- Noclip loop
RunService.Stepped:Connect(function()
    if getNoc() then
        local c = player.Character
        if c then
            for _,part in pairs(c:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- AutoHeal / Anti-Fall / Glide
RunService.Heartbeat:Connect(function()
    local c, hrp, hum = getChar()
    if not hum then return end
    -- AutoHeal
    if getHeal() then
        if hum.Health < hum.MaxHealth then pcall(function() hum.Health = hum.MaxHealth end) end
    end
    -- Glide
    if getGlide() and hrp then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hrp.Velocity.Y < -6 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, math.max(hrp.Velocity.Y, -6), hrp.Velocity.Z)
        end
    end
    -- Anti-fall: if fall speed large and antiFall on, reduce damage by setting Health to safe after land
    -- We'll implement simple softening: detect when falling and then landed
    -- track via attribute
    if getAntiFall() and hrp then
        local fallThresh = -60
        if hrp.Velocity.Y < fallThresh then
            hrp:SetAttribute("LVM_FallingHard", true)
        end
        if hrp:GetAttribute("LVM_FallingHard") and math.abs(hrp.Velocity.Y) < 1 then
            -- landed
            pcall(function()
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    hum.Health = math.min(hum.MaxHealth, hum.Health + 30) -- soft heal after heavy fall
                end
            end)
            hrp:SetAttribute("LVM_FallingHard", false)
        end
    end
end)

-- Fly implementation
local flyBV
local flyConn
local function startFly()
    local c, hrp = getChar()
    if not hrp then return end
    if flyBV then flyBV:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.P = 1250
    flyBV.Parent = hrp
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
        task.wait(0.12)
    end
end)

-- TP Walk: hold LeftAlt to step toward mouse
local mouse = player:GetMouse()
local lastTP = 0
local TP_COOLDOWN = 0.08 -- rate-limit
RunService.Heartbeat:Connect(function()
    if getTPWalk and getTPW and getTPW() and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local c, hrp = getChar()
        if c and hrp and tick() - lastTP > TP_COOLDOWN then
            local target = mouse.Hit and mouse.Hit.Position
            if target then
                local dir = (target - hrp.Position)
                local step = tonumber((function() local v = getTPStep and getTPStep(); return (v and tonumber(v)) or 8 end)()) or 8
                local dist = dir.Magnitude
                if dist > 1 then
                    local newPos = hrp.Position + dir.Unit * math.min(step, dist)
                    pcall(function() c:SetPrimaryPartCFrame(CFrame.new(newPos + Vector3.new(0,2,0))) end)
                    lastTP = tick()
                end
            end
        end
    end
end)

-- Teleport to mouse click
tpMouseBtn.MouseButton1Click:Connect(function()
    local c, hrp = getChar()
    if not hrp then return end
    local target = mouse.Hit and mouse.Hit.Position
    if target and tick() - lastTP > 0.15 then
        pcall(function() c:SetPrimaryPartCFrame(CFrame.new(target + Vector3.new(0,3,0))) end)
        lastTP = tick()
    end
end)

-- Teleport to selected player
tpToPlayerBtn.MouseButton1Click:Connect(function()
    local sel = playerDropdownBtn.Text:gsub(" ▼$","")
    if sel == "Select Player" then return end
    local target = Players:FindFirstChild(sel)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local pos = target.Character.HumanoidRootPart.Position
        local c, hrp = getChar()
        if c and hrp then pcall(function() c:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0,3,0))) end) end
    end
end)

-- TP Step (key T) - forward by step amount
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.T then
        local c, hrp = getChar()
        if hrp then
            local step = tonumber((function() local v = getTPStep and getTPStep(); return (v and tonumber(v)) or 8 end)()) or 8
            local cam = workspace.CurrentCamera
            local newPos = hrp.Position + cam.CFrame.LookVector * step
            pcall(function() c:SetPrimaryPartCFrame(CFrame.new(newPos + Vector3.new(0,3,0))) end)
        end
    end
end)

-- refresh dropdown on join/leave
Players.PlayerAdded:Connect(function() refreshPlayerDropdown() end)
Players.PlayerRemoving:Connect(function() refreshPlayerDropdown() end)

-- TP Step button (just info)
tpStepBtn.MouseButton1Click:Connect(function() -- flash a small notification
    tween(tpStepBtn, {BackgroundColor3 = ACCENT}, 0.12):Play()
    wait(0.12)
    tween(tpStepBtn, {BackgroundColor3 = Color3.fromRGB(44,44,48)}, 0.12):Play()
end)

-- Safety hotkey: RightControl to hide UI fast
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if panel.Visible then
            tween(panel, {Position = float.Position}, 0.18):Play(); wait(0.18); panel.Visible = false
        else
            panel.Visible = true; panel.Position = float.Position
            tween(panel, {Position = UDim2.new(0.5,-360,0.5,-230)}, 0.22):Play()
        end
    end
end)

-- Make float button open panel
float.MouseButton1Click:Connect(function()
    if panel.Visible then
        tween(panel, {Position = float.Position}, 0.18):Play(); wait(0.18); panel.Visible = false
    else
        panel.Visible = true; panel.Position = float.Position
        tween(panel, {Position = UDim2.new(0.5,-360,0.5,-230)}, 0.22):Play()
    end
end)

-- tab switching logic
local function hideAllTabs()
    for k,v in pairs(TabFrames) do v.Visible = false end
    for k,v in pairs(tabButtons) do v.BackgroundColor3 = Color3.fromRGB(34,36,40); v.TextColor3 = Color3.fromRGB(235,235,235) end
end
for name,btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        hideAllTabs()
        TabFrames[name].Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(45,48,54)
    end)
end

-- initial state
hideAllTabs(); TabFrames.Player.Visible = true; tabButtons.Player.BackgroundColor3 = Color3.fromRGB(45,48,54)
refreshPlayerDropdown()

print("LVM Hub — Player tab loaded. Test Player features in Studio/private server. Tell me which Combat/Visual/Misc features to implement next.")
