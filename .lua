-- LÂM VĨ HUB — FULL SAFE PACK (single-file)
-- RightControl = toggle UI
-- Save/Load config via writefile/readfile if available, otherwise uses getgenv()
-- WARNING: No aimbot/trigger/no-recoil/anti-ban/teleport-spam implemented. Placeholders only.
-- Paste into executor / LocalScript (client). Test in Studio/private server.

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

-- single-run cleanup
if getgenv().LamViHub_FULL then
    pcall(function() getgenv().LamViHub_FULL:Destroy() end)
end

-- Config & persistence
local CONFIG_FILE = "LamViHub_config.json"
local DEFAULT_CONFIG = {
    Keybinds = { ToggleUI = "RightControl" },
    Visual = { FOV = 70, Brightness = Lighting.Brightness or 1, RemoveFog = false, CameraShake = true, FullBright = false },
    Player = { WalkSpeed = 16, JumpPower = 50, SprintMult = 1.8, FlySpeed = 80, Glide = false, InfiniteJump = false, Noclip = false, AutoHeal = false, AntiFall = false },
    Misc = { AntiAFK = true, FPSBoost = false, VehicleDemo = false },
    Combat = { ESP = true, Highlight = true, Tracers = false },
    UI = { PanelPos = {0.5, 0.5}, FloatPos = {0.02, 0.82} },
}
getgenv().LAMVI_CONFIG = getgenv().LAMVI_CONFIG or DEFAULT_CONFIG

-- helper: writefile/readfile wrappers (exploit-specific). Fallback to getgenv if not present.
local function canWriteFile()
    return type(writefile) == "function" and type(readfile) == "function"
end

local function SaveConfigToFile()
    local ok, err = pcall(function()
        if canWriteFile() then
            writefile(CONFIG_FILE, HttpService:JSONEncode(getgenv().LAMVI_CONFIG))
        else
            -- fallback: keep in memory (getgenv already has)
            -- user may export via console
        end
    end)
    return ok, err
end

local function LoadConfigFromFile()
    if canWriteFile() then
        local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
        if ok and data then
            local ok2, tbl = pcall(function() return HttpService:JSONDecode(data) end)
            if ok2 and type(tbl) == "table" then
                getgenv().LAMVI_CONFIG = tbl
                return true
            end
        end
        return false
    else
        -- nothing to load, config in memory
        return true
    end
end

-- tween helper
local function tween(obj, props, t)
    return TweenService:Create(obj, TweenInfo.new(t or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

-- create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LamViHub_FULL_Screen"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui
getgenv().LamViHub_FULL = screenGui

-- basic theme
local ACCENT = Color3.fromRGB(85,120,255)
local BG = Color3.fromRGB(28,30,36)
local PANEL = Color3.fromRGB(36,38,44)
local TXT = Color3.fromRGB(255,255,255)

-- Notify (toast)
local function Notify(title, text, dur)
    dur = dur or 3
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 64)
    frame.Position = UDim2.new(1, -320, 0, 24 + (#screenGui:GetChildren()*4 % 120))
    frame.AnchorPoint = Vector2.new(0,0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.ZIndex = 50
    local c = Instance.new("UICorner", frame); c.CornerRadius = UDim.new(0,10)
    local titleLbl = Instance.new("TextLabel", frame)
    titleLbl.Size = UDim2.new(1, -16, 0, 20)
    titleLbl.Position = UDim2.new(0, 8, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextColor3 = TXT
    titleLbl.Text = title
    local msg = Instance.new("TextLabel", frame)
    msg.Size = UDim2.new(1, -16, 0, 36)
    msg.Position = UDim2.new(0, 8, 0, 28)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.TextColor3 = Color3.fromRGB(220,220,220)
    msg.Text = text
    frame.Position = frame.Position + UDim2.new(0,0,0,-80)
    tween(frame, {Position = UDim2.new(1, -320, 0, 24)}, 0.28):Play()
    task.delay(dur, function()
        if frame and frame.Parent then
            tween(frame, {Position = UDim2.new(1, -320, 0, -120)}, 0.22):Play()
            task.wait(0.28)
            pcall(function() frame:Destroy() end)
        end
    end)
end

-- GUI: floating button + main panel
local floatBtn = Instance.new("TextButton", screenGui)
floatBtn.Name = "LVM_Float"
floatBtn.Text = "LVM"
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 14
floatBtn.TextColor3 = TXT
floatBtn.BackgroundColor3 = ACCENT
floatBtn.Size = UDim2.new(0, 56, 0, 56)
floatBtn.Position = UDim2.new(getgenv().LAMVI_CONFIG.UI.FloatPos[1] or 0.02, 0, getgenv().LAMVI_CONFIG.UI.FloatPos[2] or 0.82, 0)
floatBtn.AnchorPoint = Vector2.new(0.5,0.5)
floatBtn.AutoButtonColor = false
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", floatBtn).Color = Color3.fromRGB(12,12,18)

local panel = Instance.new("Frame", screenGui)
panel.Name = "LVM_Panel"
panel.Size = UDim2.new(0, 820, 0, 520)
panel.Position = UDim2.new(getgenv().LAMVI_CONFIG.UI.PanelPos[1] or 0.5, -410, getgenv().LAMVI_CONFIG.UI.PanelPos[2] or 0.5, -260)
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.BackgroundColor3 = PANEL
panel.BorderSizePixel = 0
panel.Visible = false
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke", panel).Color = Color3.fromRGB(8,8,8)

-- header
local topStrip = Instance.new("Frame", panel); topStrip.Size = UDim2.new(1,0,0,8); topStrip.Position = UDim2.new(0,0,0,0); topStrip.BackgroundColor3 = ACCENT; topStrip.BackgroundTransparency = 0.12
Instance.new("UICorner", topStrip).CornerRadius = UDim.new(0,6)
local header = Instance.new("Frame", panel); header.Size = UDim2.new(1,0,0,56); header.Position = UDim2.new(0,0,0,8); header.BackgroundTransparency = 1
local title = Instance.new("TextLabel", header); title.Text = "Lâm Vĩ Hub — Full SAFE"; title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.TextColor3 = TXT; title.BackgroundTransparency = 1; title.Position = UDim2.new(0,16,0,10)
local closeBtn = Instance.new("TextButton", header); closeBtn.Text = "✕"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 20; closeBtn.TextColor3 = TXT; closeBtn.BackgroundTransparency = 1; closeBtn.Position = UDim2.new(1,-46,0,8); closeBtn.Size = UDim2.new(0,36,0,36); closeBtn.AutoButtonColor = false
closeBtn.MouseEnter:Connect(function() tween(closeBtn, {TextColor3 = Color3.fromRGB(255,100,100)}, 0.12):Play() end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, {TextColor3 = TXT}, 0.12):Play() end)
closeBtn.MouseButton1Click:Connect(function() tween(panel, {Position = floatBtn.Position}, 0.18):Play(); task.wait(0.18); panel.Visible = false end)

-- layout sidebar + content
local sidebar = Instance.new("Frame", panel); sidebar.Size = UDim2.new(0, 200, 1, -92); sidebar.Position = UDim2.new(0,12,0,72); sidebar.BackgroundTransparency = 1
local content = Instance.new("Frame", panel); content.Size = UDim2.new(1, -224, 1, -92); content.Position = UDim2.new(0, 216, 0, 72); content.BackgroundTransparency = 1

-- build tabs and scrolling frames
local TAB_ORDER = {"Player","Combat","Visual","Misc","Settings"}
local tabButtons = {}
local TabFrames = {}

local function makeSideButton(txt, y)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1,-8,0,44)
    b.Position = UDim2.new(0,4,0,y)
    b.Text = "   "..txt
    b.Font = Enum.Font.Gotham
    b.TextSize = 15
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.BackgroundColor3 = Color3.fromRGB(34,36,40)
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    local stroke = Instance.new("UIStroke", b); stroke.Color = Color3.fromRGB(10,10,10); stroke.Thickness = 1
    b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(46,49,56)}, 0.12):Play() end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = Color3.fromRGB(34,36,40)}, 0.12):Play() end)
    return b
end

for i, name in ipairs(TAB_ORDER) do
    local btn = makeSideButton(name, 64 + (i-1)*52)
    tabButtons[name] = btn

    local frm = Instance.new("Frame", content)
    frm.Name = name.."Frame"
    frm.Size = UDim2.new(1,0,1,0)
    frm.BackgroundTransparency = 1
    frm.Visible = false

    local scr = Instance.new("ScrollingFrame", frm)
    scr.Name = "Scroll"
    scr.Size = UDim2.new(1,0,1,0)
    scr.CanvasSize = UDim2.new(0,0,0,0)
    scr.ScrollBarThickness = 8
    scr.BackgroundTransparency = 1
    scr.Parent = frm

    local layout = Instance.new("UIListLayout", scr)
    layout.Padding = UDim.new(0,12)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scr.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 16)
    end)

    TabFrames[name] = frm
end

-- show default
TabFrames.Player.Visible = true
tabButtons.Player.BackgroundColor3 = Color3.fromRGB(45,48,54)

-- UI element factories
local function makeLabel(parent, txt)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,-24,0,20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 14
    l.TextColor3 = TXT
    l.Text = txt
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function makeToggle(parent, txt, init)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,-24,0,34); holder.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", holder); label.Size = UDim2.new(0.72,0,1,0); label.BackgroundTransparency = 1; label.Font=Enum.Font.Gotham; label.TextSize=14; label.TextColor3=TXT; label.Text=txt
    local sw = Instance.new("TextButton", holder); sw.Size = UDim2.new(0,52,0,26); sw.Position = UDim2.new(1,-60,0.5,-13); sw.BackgroundColor3 = Color3.fromRGB(70,70,75); sw.AutoButtonColor=false
    local swc = Instance.new("UICorner", sw); swc.CornerRadius = UDim.new(0,10)
    local fill = Instance.new("Frame", sw); fill.Size = UDim2.new(init and 1 or 0,0,1,0); fill.BackgroundColor3 = init and ACCENT or Color3.fromRGB(140,140,140); Instance.new("UICorner", fill).CornerRadius = UDim.new(0,8)
    local state = init or false
    sw.MouseButton1Click:Connect(function() state = not state; tween(fill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play(); tween(fill, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(140,140,140)}, 0.12):Play() end)
    return holder, function() return state end, function(v) state = v; tween(fill, {Size = UDim2.new(state and 1 or 0,0,1,0)}, 0.12):Play(); tween(fill, {BackgroundColor3 = state and ACCENT or Color3.fromRGB(140,140,140)}, 0.12):Play() end
end

local function makeSlider(parent, txt, minv, maxv, init)
    local holder = Instance.new("Frame", parent); holder.Size = UDim2.new(1,-24,0,48); holder.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", holder); lbl.Size = UDim2.new(0.6,0,0,18); lbl.Position = UDim2.new(0,0,0,0); lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextColor3=TXT; lbl.Text=txt
    local val = Instance.new("TextLabel", holder); val.Size = UDim2.new(0.4,0,0,18); val.Position = UDim2.new(0.6,0,0,0); val.BackgroundTransparency=1; val.Font=Enum.Font.GothamBold; val.TextSize=13; val.TextColor3=ACCENT; val.Text = tostring(init)
    local bar = Instance.new("Frame", holder); bar.Size = UDim2.new(1,0,0,10); bar.Position = UDim2.new(0,0,0,26); bar.BackgroundColor3 = Color3.fromRGB(40,40,44); Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((init-minv)/(maxv-minv),0,1,0); fill.BackgroundColor3 = ACCENT; Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)
    local dragging = false
    local function updateFromX(x)
        local abs = x - bar.AbsolutePosition.X
        local frac = math.clamp(abs / (bar.AbsoluteSize.X), 0, 1)
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

-- ---------------- Player Tab (movement features implemented client-side) ----------------
local playerScr = TabFrames.Player:FindFirstChild("Scroll")
makeLabel(playerScr, "Movement — client-side helpers (test in Studio/private server).")
local infHolder, getInf, setInf = makeToggle(playerScr, "Infinite Jump", getgenv().LAMVI_CONFIG.Player.InfiniteJump)
local flyHolder, getFly, setFly = makeToggle(playerScr, "Fly (WASD + Space/Ctrl)", false)
local flySpeedHolder, getFlySpeed, setFlySpeed = makeSlider(playerScr, "Fly Speed", 10, 300, getgenv().LAMVI_CONFIG.Player.FlySpeed)
local wsHolder, getWS, setWS = makeSlider(playerScr, "WalkSpeed", 8, 300, getgenv().LAMVI_CONFIG.Player.WalkSpeed)
local jpHolder, getJP, setJP = makeSlider(playerScr, "JumpPower", 20, 300, getgenv().LAMVI_CONFIG.Player.JumpPower)
local nocHolder, getNoc, setNoc = makeToggle(playerScr, "Noclip (client-only)", getgenv().LAMVI_CONFIG.Player.Noclip)
local sprintHolder, getSprint, setSprint = makeToggle(playerScr, "Sprint (hold LeftShift)", false)
local sprintMultHolder, getSprintMult, setSprintMult = makeSlider(playerScr, "Sprint Mult", 1, 4, getgenv().LAMVI_CONFIG.Player.SprintMult)
local glideHolder, getGlide, setGlide = makeToggle(playerScr, "Glide (hold Space to slow fall)", getgenv().LAMVI_CONFIG.Player.Glide)
local autoHealHolder, getAutoHeal, setAutoHeal = makeToggle(playerScr, "AutoHeal (client-side)", getgenv().LAMVI_CONFIG.Player.AutoHeal)
local antiFallHolder, getAntiFall, setAntiFall = makeToggle(playerScr, "Anti-Fall Soften", getgenv().LAMVI_CONFIG.Player.AntiFall)
makeLabel(playerScr, "Teleportation")
local tpMouseBtn = Instance.new("TextButton", playerScr); tpMouseBtn.Size = UDim2.new(0,220,0,34); tpMouseBtn.Text="Teleport → Mouse (click)"; tpMouseBtn.Font=Enum.Font.GothamBold; tpMouseBtn.BackgroundColor3=Color3.fromRGB(44,44,48); tpMouseBtn.TextColor3=TXT; Instance.new("UICorner", tpMouseBtn).CornerRadius = UDim.new(0,8)
local tpPlayerBtn = Instance.new("TextButton", playerScr); tpPlayerBtn.Size=UDim2.new(0,220,0,34); tpPlayerBtn.Text="Teleport → Player (select first)"; tpPlayerBtn.Font=Enum.Font.GothamBold; tpPlayerBtn.BackgroundColor3=Color3.fromRGB(44,44,48); tpPlayerBtn.TextColor3=TXT; Instance.new("UICorner", tpPlayerBtn).CornerRadius = UDim.new(0,8)
local tpStepBtn = Instance.new("TextButton", playerScr); tpStepBtn.Size=UDim2.new(0,160,0,34); tpStepBtn.Text="TP Step (T)"; tpStepBtn.Font=Enum.Font.GothamBold; tpStepBtn.BackgroundColor3=Color3.fromRGB(44,44,48); tpStepBtn.TextColor3=TXT; Instance.new("UICorner", tpStepBtn).CornerRadius = UDim.new(0,8)

-- player selection dropdown
local dropdown = Instance.new("Frame", playerScr); dropdown.Size = UDim2.new(0,260,0,0); dropdown.ClipsDescendants=true; dropdown.BackgroundTransparency=1
local playerSelectButton = Instance.new("TextButton", playerScr); playerSelectButton.Size = UDim2.new(0,260,0,34); playerSelectButton.Text = "Select Player ▼"; playerSelectButton.Font = Enum.Font.GothamBold; playerSelectButton.BackgroundColor3 = Color3.fromRGB(44,44,48); playerSelectButton.TextColor3 = TXT; Instance.new("UICorner", playerSelectButton).CornerRadius = UDim.new(0,8)

local function refreshPlayerDropdown()
    for _,v in pairs(dropdown:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local idx = 0
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local b = Instance.new("TextButton", dropdown); b.Size=UDim2.new(1,0,0,28); b.Position=UDim2.new(0,0,0, idx*28); b.Text=pl.Name; b.Font=Enum.Font.Gotham; b.BackgroundColor3=Color3.fromRGB(50,50,54); b.TextColor3=TXT; Instance.new("UICorner", b).CornerRadius=UDim.new(0,6)
            b.MouseButton1Click:Connect(function() playerSelectButton.Text = pl.Name.." ▼"; dropdown:TweenSize(UDim2.new(0,260,0,0), "Out", "Quad", 0.18, true) end)
            idx = idx + 1
        end
    end
end
playerSelectButton.MouseButton1Click:Connect(function()
    if dropdown.Size.Y.Offset == 0 then refreshPlayerDropdown(); dropdown:TweenSize(UDim2.new(0,260,0, math.max(1,#Players:GetPlayers()-1) * 28), "Out", "Quad", 0.18, true)
    else dropdown:TweenSize(UDim2.new(0,260,0,0),"Out","Quad",0.18,true) end
end)

-- ---------------- Combat Tab (ESP visual-only) ----------------
local combatScr = TabFrames.Combat:FindFirstChild("Scroll")
makeLabel(combatScr, "Combat — visual overlays only (no auto-aim / trigger).")
local espHolder, getESPToggle, setESPToggle = makeToggle(combatScr, "ESP (name + distance)", getgenv().LAMVI_CONFIG.Combat.ESP)
local highHolder, getHighToggle, setHighToggle = makeToggle(combatScr, "Highlight (fill)", getgenv().LAMVI_CONFIG.Combat.Highlight)
local tracersHolder, getTracersToggle, setTracersToggle = makeToggle(combatScr, "Tracers (visual only)", getgenv().LAMVI_CONFIG.Combat.Tracers)
makeLabel(combatScr, "Note: aimbot/triggerbot are disabled for safety and policy reasons. Placeholders show status only.")

-- ---------------- Visual Tab ----------------
local visualScr = TabFrames.Visual:FindFirstChild("Scroll")
makeLabel(visualScr, "Visual tweaks (client-side only)")
local fovHolder2, getFOV2, setFOV2 = makeSlider(visualScr, "FOV", 45, 120, getgenv().LAMVI_CONFIG.Visual.FOV)
local brightHolder, getBright, setBright = makeSlider(visualScr, "Brightness", 0.1, 5, getgenv().LAMVI_CONFIG.Visual.Brightness)
local fogHolder, getFog, setFog = makeToggle(visualScr, "Remove Fog", getgenv().LAMVI_CONFIG.Visual.RemoveFog)
local camShakeHolder, getCamShake, setCamShake = makeToggle(visualScr, "Camera Shake (store pref)", getgenv().LAMVI_CONFIG.Visual.CameraShake)
local fullBrightHolder, getFullBright, setFullBright = makeToggle(visualScr, "FullBright (client-only)", getgenv().LAMVI_CONFIG.Visual.FullBright)

-- ---------------- Misc Tab ----------------
local miscScr = TabFrames.Misc:FindFirstChild("Scroll")
makeLabel(miscScr, "Misc utilities")
local antiAfkHolder, getAntiAfk, setAntiAfk = makeToggle(miscScr, "Anti AFK", getgenv().LAMVI_CONFIG.Misc.AntiAFK)
local fpsBoostHolder, getFPSBoost, setFPSBoost = makeToggle(miscScr, "FPS Booster (client)", getgenv().LAMVI_CONFIG.Misc.FPSBoost)
local rejoinBtn = Instance.new("TextButton", miscScr); rejoinBtn.Size=UDim2.new(0,220,0,34); rejoinBtn.Text="Rejoin (same server)"; rejoinBtn.Font=Enum.Font.GothamBold; rejoinBtn.BackgroundColor3=Color3.fromRGB(44,44,48); rejoinBtn.TextColor3=TXT; Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0,8)
local serverhopBtn = Instance.new("TextButton", miscScr); serverhopBtn.Size=UDim2.new(0,220,0,34); serverhopBtn.Text="Server Hop"; serverhopBtn.Font=Enum.Font.GothamBold; serverhopBtn.BackgroundColor3=Color3.fromRGB(44,44,48); serverhopBtn.TextColor3=TXT; Instance.new("UICorner", serverhopBtn).CornerRadius = UDim.new(0,8)
local resetBtn = Instance.new("TextButton", miscScr); resetBtn.Size=UDim2.new(0,220,0,34); resetBtn.Text="Reset Character"; resetBtn.Font=Enum.Font.GothamBold; resetBtn.BackgroundColor3=Color3.fromRGB(44,44,48); resetBtn.TextColor3=TXT; Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)
local exportBtn = Instance.new("TextButton", miscScr); exportBtn.Size=UDim2.new(0,220,0,34); exportBtn.Text="Export Config (console)"; exportBtn.Font=Enum.Font.GothamBold; exportBtn.BackgroundColor3=Color3.fromRGB(60,60,80); exportBtn.TextColor3=TXT; Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0,8)
local importBtn = Instance.new("TextButton", miscScr); importBtn.Size=UDim2.new(0,220,0,34); importBtn.Text="Import Config (paste JSON)"; importBtn.Font=Enum.Font.GothamBold; importBtn.BackgroundColor3=Color3.fromRGB(60,60,80); importBtn.TextColor3=TXT; Instance.new("UICorner", importBtn).CornerRadius = UDim.new(0,8)
local importBox = Instance.new("TextBox", miscScr); importBox.Size = UDim2.new(0,420,0,80); importBox.ClearTextOnFocus = false; importBox.Text = ""; Instance.new("UICorner", importBox).CornerRadius = UDim.new(0,6)

-- ---------------- Settings Tab ----------------
local settingsScr = TabFrames.Settings:FindFirstChild("Scroll")
makeLabel(settingsScr, "Settings")
local keybindBtn = Instance.new("TextButton", settingsScr); keybindBtn.Size=UDim2.new(0,300,0,34); keybindBtn.Text="Set Toggle UI Key (press desired key)"; keybindBtn.Font=Enum.Font.GothamBold; keybindBtn.BackgroundColor3=Color3.fromRGB(44,44,48); keybindBtn.TextColor3=TXT; Instance.new("UICorner", keybindBtn).CornerRadius = UDim.new(0,8)
local saveBtn = Instance.new("TextButton", settingsScr); saveBtn.Size=UDim2.new(0,200,0,34); saveBtn.Text="Save Config"; saveBtn.Font=Enum.Font.GothamBold; saveBtn.BackgroundColor3=Color3.fromRGB(44,44,48); saveBtn.TextColor3=TXT; Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,8)
local loadBtn = Instance.new("TextButton", settingsScr); loadBtn.Size=UDim2.new(0,200,0,34); loadBtn.Text="Load Config (file)"; loadBtn.Font=Enum.Font.GothamBold; loadBtn.BackgroundColor3=Color3.fromRGB(44,44,48); loadBtn.TextColor3=TXT; Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0,8)

-- Keybind manager
local listeningKey = false
keybindBtn.MouseButton1Click:Connect(function()
    Notify("Keybind", "Press a key to set UI toggle", 2)
    listeningKey = true
end)
UserInputService.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if listeningKey and inp.UserInputType == Enum.UserInputType.Keyboard then
        local name = inp.KeyCode.Name
        getgenv().LAMVI_CONFIG.Keybinds.ToggleUI = name
        Notify("Keybind", "ToggleUI set to "..name, 2)
        listeningKey = false
        SaveConfigToFile()
    end
end)

-- save/load actions
saveBtn.MouseButton1Click:Connect(function()
    SaveConfigToFile()
    Notify("Config", "Saved (if writefile available). Export also prints JSON to console.", 2)
end)
loadBtn.MouseButton1Click:Connect(function()
    local ok = LoadConfigFromFile()
    Notify("Config", ok and "Loaded config file" or "Load failed", 2)
end)
exportBtn.MouseButton1Click:Connect(function()
    local ok, json = pcall(function() return HttpService:JSONEncode(getgenv().LAMVI_CONFIG) end)
    if ok then
        print("[Lâm Vĩ CONFIG EXPORT]")
        print(json)
        Notify("Export", "Config printed to console", 2)
    else
        Notify("Export fail", "Cannot encode config", 2)
    end
end)
importBtn.MouseButton1Click:Connect(function()
    local txt = importBox.Text
    local ok, tbl = pcall(function() return HttpService:JSONDecode(txt) end)
    if ok and type(tbl) == "table" then
        getgenv().LAMVI_CONFIG = tbl
        Notify("Import", "Config loaded to runtime", 2)
    else
        Notify("Import failed", "Invalid JSON", 3)
    end
end)

-- Tab switching
local function hideAllTabs()
    for _, frm in pairs(TabFrames) do frm.Visible = false end
    for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(34,36,40) end
end
for name,btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        hideAllTabs()
        TabFrames[name].Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(45,48,54)
    end)
end

-- Panel drag
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
    header.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput and dragStart and startPos then
            local delta = dragInput.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            -- save to config
            getgenv().LAMVI_CONFIG.UI.PanelPos = {panel.Position.X.Scale, panel.Position.Y.Scale}
        end
    end)
end

-- float button open/close
floatBtn.MouseButton1Click:Connect(function()
    if panel.Visible then
        tween(panel, {Position = floatBtn.Position}, 0.18):Play(); task.wait(0.18); panel.Visible = false
    else
        panel.Visible = true; panel.Position = floatBtn.Position; tween(panel, {Position = UDim2.new(0.5, -410, 0.5, -260)}, 0.22):Play()
    end
end)

-- quick toggle via configured key (RightControl default)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local keyName = getgenv().LAMVI_CONFIG.Keybinds and getgenv().LAMVI_CONFIG.Keybinds.ToggleUI or "RightControl"
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == keyName then
        if panel.Visible then tween(panel, {Position = floatBtn.Position}, 0.18):Play(); task.wait(0.18); panel.Visible = false
        else panel.Visible = true; panel.Position = floatBtn.Position; tween(panel, {Position = UDim2.new(0.5, -410, 0.5, -260)}, 0.22):Play() end
    end
end)

-- AntiRemove: recreate screenGui if removed
screenGui.DescendantRemoving:Connect(function(obj)
    task.delay(0.12, function()
        if not screenGui.Parent then
            screenGui.Parent = CoreGui
            Notify("Lâm Vĩ", "GUI restored", 2)
        end
    end)
end)

-- ---------------- Implement features ----------------

-- Helper to safely get character/humanoid/hrp
local function getChar()
    local c = LocalPlayer.Character
    if not c then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    local hum = c:FindFirstChildOfClass("Humanoid")
    return c, hrp, hum
end

-- Infinite jump
UserInputService.JumpRequest:Connect(function()
    if getInf() then
        local _,_,hum = getChar()
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end)

-- WalkSpeed & JumpPower loop
RunService.Heartbeat:Connect(function()
    local _,_,hum = getChar()
    if hum then
        -- walk speed
        local base = tonumber(getWS()) or 16
        if getSprint() and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            hum.WalkSpeed = base * (tonumber(getSprintMult()) or 1.8)
        else
            hum.WalkSpeed = tonumber(getWS()) or 16
        end
        -- jump
        hum.JumpPower = tonumber(getJP()) or 50
    end
end)

-- Noclip (client-only)
RunService.Stepped:Connect(function()
    if getNoc() then
        local c = LocalPlayer.Character
        if c then
            for _, part in pairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end
end)

-- Glide & AntiFall & AutoHeal
local function clampYVelTo(v, limit)
    if v and v.Y and v.Y < limit then
        v = Vector3.new(v.X, math.max(v.Y, limit), v.Z)
    end
    return v
end

RunService.Heartbeat:Connect(function()
    local c, hrp, hum = getChar()
    if not hum then return end
    -- AutoHeal
    if getAutoHeal() then
        pcall(function() if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end end)
    end
    -- Glide
    if getGlide() and hrp then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and hrp.Velocity.Y < -4 then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, math.max(hrp.Velocity.Y, -6), hrp.Velocity.Z)
        end
    end
    -- Anti-Fall soften: mark falling then heal a bit on landing
    if getAntiFall() and hrp then
        if hrp.Velocity.Y < -60 then hrp:SetAttribute("LVM_FALLING_HARD", true) end
        if hrp:GetAttribute("LVM_FALLING_HARD") and math.abs(hrp.Velocity.Y) < 1 then
            pcall(function() hum.Health = math.min(hum.MaxHealth, (hum.Health or 1) + 30) end)
            hrp:SetAttribute("LVM_FALLING_HARD", false)
        end
    end
end)

-- Fly (BodyVelocity)
local flyBV, flyConn
local function startFly()
    local c, hrp, hum = getChar()
    if not hrp then return end
    if flyBV then flyBV:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
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

-- Teleport to mouse & TP step & TP to player (client attempts: may be blocked by server)
local mouse = LocalPlayer:GetMouse()
local tpCooldown = 0
tpMouseBtn.MouseButton1Click:Connect(function()
    local c, hrp, hum = getChar()
    if not hrp then return end
    local target = mouse.Hit and mouse.Hit.Position
    if target and tick() - tpCooldown > 0.2 then
        pcall(function() c:SetPrimaryPartCFrame(CFrame.new(target + Vector3.new(0,3,0))) end)
        tpCooldown = tick()
    end
end)

tpPlayerBtn.MouseButton1Click:Connect(function()
    local sel = playerSelectButton.Text:gsub(" ▼$","")
    if sel == "Select Player" then Notify("Teleport", "Select a player first.", 2); return end
    local target = Players:FindFirstChild(sel)
    if target and target.Character and target.Character.PrimaryPart then
        local c = LocalPlayer.Character
        if c and c.PrimaryPart then pcall(function() c:SetPrimaryPartCFrame(CFrame.new(target.Character.PrimaryPart.Position + Vector3.new(0,3,0))) end) end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.T then
        local c, hrp, hum = getChar()
        if hrp then
            local step = 8
            local cam = workspace.CurrentCamera
            local newPos = hrp.Position + cam.CFrame.LookVector * step
            pcall(function() c:SetPrimaryPartCFrame(CFrame.new(newPos + Vector3.new(0,3,0))) end)
        end
    end
end)

-- ---------------- Combat: ESP visual-only (Billboard + Highlight) ----------------
local espFolder = Instance.new("Folder", screenGui); espFolder.Name = "LVM_ESP_Folder"
local highlightMap = {}

local function createESPForPlayer(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("LVM_BB") then return end
    -- Billboard
    local bb = Instance.new("BillboardGui")
    bb.Name = "LVM_BB"
    bb.Adornee = head
    bb.Size = UDim2.new(0,150,0,40)
    bb.StudsOffset = Vector3.new(0, 2.4, 0)
    bb.AlwaysOnTop = true
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1,0,1,0); txt.BackgroundTransparency = 1; txt.Font = Enum.Font.GothamBold; txt.TextSize = 14; txt.TextColor3 = TXT
    txt.Text = plr.Name
    bb.Parent = head
    -- Highlight
    if getHighToggle() then
        if not plr.Character:FindFirstChild("LVM_HL") then
            local hl = Instance.new("Highlight", plr.Character)
            hl.Name = "LVM_HL"
            hl.FillTransparency = 0.6
            hl.OutlineTransparency = 1
            highlightMap[plr] = hl
        end
    end
end

local function removeESPForPlayer(plr)
    local ch = plr.Character
    if ch then
        local head = ch:FindFirstChild("Head")
        if head then
            local bb = head:FindFirstChild("LVM_BB")
            if bb then pcall(function() bb:Destroy() end) end
        end
        if highlightMap[plr] then pcall(function() highlightMap[plr]:Destroy() end); highlightMap[plr] = nil end
    end
end

Players.PlayerAdded:Connect(function(plr) task.delay(0.6, function() if getESPToggle() then createESPForPlayer(plr) end end) end)
Players.PlayerRemoving:Connect(function(plr) removeESPForPlayer(plr) end)
-- initial
for _,pl in pairs(Players:GetPlayers()) do if pl ~= LocalPlayer then createESPForPlayer(pl) end end

-- dynamic monitor loops
RunService.Heartbeat:Connect(function()
    -- toggle ESP visuals
    if getESPToggle() then
        for _,pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                if pl.Character and pl.Character:FindFirstChild("Head") then
                    local head = pl.Character.Head
                    local bb = head:FindFirstChild("LVM_BB")
                    if not bb then createESPForPlayer(pl) end
                    local label = head:FindFirstChild("LVM_BB") and head.LVM_BB:FindFirstChildWhichIsA("TextLabel")
                    if label and pl.Character and pl.Character.PrimaryPart and LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
                        local dist = math.floor((pl.Character.PrimaryPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude)
                        label.Text = pl.Name.." ["..dist.."m]"
                    end
                end
                if getHighToggle() and not highlightMap[pl] and pl.Character then
                    local ok, hl = pcall(function()
                        local h = Instance.new("Highlight", pl.Character)
                        h.Name = "LVM_HL"
                        h.FillTransparency = 0.6
                        h.OutlineTransparency = 1
                        return h
                    end)
                    if ok then highlightMap[pl] = hl end
                end
            end
        end
    else
        -- remove overlays
        for _,pl in pairs(Players:GetPlayers()) do
            removeESPForPlayer(pl)
        end
    end
end)

-- ---------------- Visual tweaks implementation ----------------
local cam = workspace.CurrentCamera
local function applyFOV(v) if cam then cam.FieldOfView = tonumber(v) or 70 end end
local function applyBrightness(v) pcall(function() Lighting.Brightness = tonumber(v) or 1 end) end
local function applyFog(remove)
    pcall(function()
        if remove then
            Lighting.FogStart = 1e6
            Lighting.FogEnd = 1e6
        else
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        end
    end)
end
local fullBrightSaved = {}
local function setFullBright(on)
    if on then
        -- store some lighting values then set bright-ish
        fullBrightSaved.Brightness = Lighting.Brightness
        fullBrightSaved.Ambient = Lighting.Ambient
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(180,180,180)
    else
        pcall(function()
            Lighting.Brightness = fullBrightSaved.Brightness or 1
            Lighting.Ambient = fullBrightSaved.Ambient or Color3.fromRGB(128,128,128)
        end)
    end
end

-- sync UI <-> runtime (apply at loop)
RunService.RenderStepped:Connect(function()
    -- FOV
    local v = getFOV2() or getFOV() or (getgenv().LAMVI_CONFIG.Visual.FOV or 70)
    applyFOV(tonumber(v))
    -- Brightness
    local b = tonumber(getBright()) or getgenv().LAMVI_CONFIG.Visual.Brightness or 1
    applyBrightness(b)
    -- Fog
    applyFog(getFog())
    -- Fullbright
    setFullBright(getFullBright())
end)

-- ---------------- Misc implementations ----------------
local afkConn
local function setAntiAFK(enable)
    if enable then
        if afkConn then return end
        afkConn = LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            Notify("AntiAFK", "Ping", 1)
        end)
    else
        if afkConn then afkConn:Disconnect(); afkConn = nil end
    end
end
setAntiAFK(getAntiAfk())

fpsBtn.MouseButton1Click:Connect(function()
    -- quick FPS boost
    pcall(function() Lighting.GlobalShadows = false end)
    for _,v in pairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("BloomEffect") then
            pcall(function() v.Enabled = false end)
        end
    end
    Notify("FPS Boost", "Client postprocess trimmed.", 2)
end)

rejoinBtn.MouseButton1Click:Connect(function()
    Notify("Rejoin", "Attempting rejoin...", 2)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

serverhopBtn.MouseButton1Click:Connect(function()
    Notify("ServerHop", "Teleporting to another server (may pick same server).", 2)
    pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
end)

resetBtn.MouseButton1Click:Connect(function()
    Notify("Reset", "Resetting character...", 1)
    pcall(function() LocalPlayer.Character:BreakJoints() end)
end)

-- import/export done earlier

-- ---------------- Placeholders for disallowed/unsafe features ----------------
-- For features like aimbot / triggerbot / anti-ban / server-side auto-farm, we provide UI placeholders
-- that simply toggle a flag and show a notification. We do NOT implement automatic aim or network manipulation.

local combatPlaceBtn = Instance.new("TextButton", combatScr); combatPlaceBtn.Size = UDim2.new(0,300,0,34); combatPlaceBtn.Text="[Placeholder] Aim Assist (DISABLED)"; combatPlaceBtn.Font=Enum.Font.GothamBold; combatPlaceBtn.BackgroundColor3=Color3.fromRGB(75,40,40); combatPlaceBtn.TextColor3=Color3.fromRGB(255,200,200); Instance.new("UICorner", combatPlaceBtn).CornerRadius=UDim.new(0,8)
combatPlaceBtn.MouseButton1Click:Connect(function()
    Notify("Placeholder", "Aim Assist / TriggerBot are disabled by design.", 3)
end)

local autoFarmBtn = Instance.new("TextButton", miscScr); autoFarmBtn.Size = UDim2.new(0,300,0,34); autoFarmBtn.Text = "[Placeholder] Auto Farm (DISABLED)"; autoFarmBtn.Font=Enum.Font.GothamBold; autoFarmBtn.BackgroundColor3=Color3.fromRGB(75,40,40); autoFarmBtn.TextColor3=Color3.fromRGB(255,200,200); Instance.new("UICorner", autoFarmBtn).CornerRadius=UDim.new(0,8)
autoFarmBtn.MouseButton1Click:Connect(function()
    Notify("Placeholder", "Auto Farm disabled. Use safe, server-approved methods.", 3)
end)

-- ---------------- Final touches ----------------

-- initial apply config/load
LoadConfigFromFile()
-- sync UI toggles with config values (best-effort)
setFOV2(getgenv().LAMVI_CONFIG.Visual.FOV or 70)
setBright(getgenv().LAMVI_CONFIG.Visual.Brightness or 1)
setFog(getgenv().LAMVI_CONFIG.Visual.RemoveFog or false)
setFullBright(getgenv().LAMVI_CONFIG.Visual.FullBright or false)
setAntiAfk(getgenv().LAMVI_CONFIG.Misc.AntiAFK or true)

-- save periodically
spawn(function()
    while true do
        SaveConfigToFile()
        task.wait(6)
    end
end)

Notify("Lâm Vĩ Hub", "Safe full script loaded. UI: RightControl to toggle (or set in Settings).", 3)

-- expose for tinkering
getgenv().LamViHub_FULL = getgenv().LamViHub_FULL or {}
getgenv().LamViHub_FULL.ScreenGui = screenGui
getgenv().LAMVI_CONFIG = getgenv().LAMVI_CONFIG or DEFAULT_CONFIG

print("[Lâm Vĩ Hub] Loaded. Config saved to file if environment supports writefile/readfile.")
