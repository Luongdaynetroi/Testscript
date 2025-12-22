-- ts file was generated at discord.gg/25ms


local vu1 = game:GetService("TweenService")
local v2 = game.Players.LocalPlayer
local vu3 = Instance.new("ScreenGui")
vu3.Name = "NotificationGUI"
vu3.Parent = v2:WaitForChild("PlayerGui")
vu3.IgnoreGuiInset = true
vu3.ResetOnSpawn = false
local vu4 = Instance.new("Frame")
vu4.Name = "Overlay"
vu4.Size = UDim2.new(1, 0, 1, 0)
vu4.BackgroundTransparency = 1
vu4.Parent = vu3
local v5 = Instance.new("UIGradient")
v5.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 20))
})
v5.Rotation = 45
v5.Parent = vu4
local vu6 = Instance.new("Frame")
vu6.Name = "NotificationFrame"
vu6.Size = UDim2.new(0, 400, 0, 200)
vu6.Position = UDim2.new(0.5, 0, 0.5, 0)
vu6.AnchorPoint = Vector2.new(0.5, 0.5)
vu6.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
vu6.BackgroundTransparency = 1
vu6.BorderSizePixel = 0
vu6.Parent = vu4
local v7 = Instance.new("UICorner")
v7.CornerRadius = UDim.new(0, 20)
v7.Parent = vu6
local vu8 = Instance.new("UIStroke")
vu8.Color = Color3.fromRGB(100, 100, 255)
vu8.Thickness = 3
vu8.Transparency = 1
vu8.Parent = vu6
local vu9 = Instance.new("ImageLabel")
vu9.Name = "Glow"
vu9.Size = UDim2.new(1, 40, 1, 40)
vu9.Position = UDim2.new(0, - 20, 0, - 20)
vu9.BackgroundTransparency = 1
vu9.Image = "rbxassetid://138072662094067"
vu9.ImageColor3 = Color3.fromRGB(50, 50, 150)
vu9.ScaleType = Enum.ScaleType.Slice
vu9.SliceCenter = Rect.new(100, 100, 100, 100)
vu9.ImageTransparency = 1
vu9.Parent = vu6
local vu10 = Instance.new("TextLabel")
vu10.Name = "MainText"
vu10.Size = UDim2.new(1, - 40, 0, 80)
vu10.Position = UDim2.new(0, 20, 0, 40)
vu10.BackgroundTransparency = 1
vu10.Text = "COME BACK SOON"
vu10.TextColor3 = Color3.new(1, 1, 1)
vu10.TextSize = 36
vu10.Font = Enum.Font.GothamBold
vu10.TextTransparency = 1
vu10.TextStrokeTransparency = 0.8
vu10.TextStrokeColor3 = Color3.fromRGB(100, 100, 255)
vu10.Parent = vu6
local vu11 = Instance.new("TextLabel")
vu11.Name = "SubText"
vu11.Size = UDim2.new(1, - 40, 0, 40)
vu11.Position = UDim2.new(0, 20, 0, 120)
vu11.BackgroundTransparency = 1
vu11.Text = "yomka was here"
vu11.TextColor3 = Color3.fromRGB(200, 200, 255)
vu11.TextSize = 20
vu11.Font = Enum.Font.Gotham
vu11.TextTransparency = 1
vu11.Parent = vu6
local vu12 = Instance.new("ImageLabel")
vu12.Name = "Icon"
vu12.Size = UDim2.new(0, 60, 0, 60)
vu12.Position = UDim2.new(0.5, 0, 0, - 30)
vu12.AnchorPoint = Vector2.new(0.5, 0)
vu12.BackgroundTransparency = 1
vu12.Image = "rbxassetid://138072662094067"
vu12.ImageTransparency = 1
vu12.Parent = vu6
local v13 = Instance.new("TextLabel")
v13.Name = "Watermark"
v13.Size = UDim2.new(0, 300, 0, 40)
v13.Position = UDim2.new(1, - 20, 1, - 15)
v13.AnchorPoint = Vector2.new(1, 1)
v13.BackgroundTransparency = 1
v13.Text = "Duc Luong"
v13.TextColor3 = Color3.fromRGB(150, 150, 255)
v13.TextSize = 22
v13.Font = Enum.Font.GothamBold
v13.TextTransparency = 0.4
v13.TextXAlignment = Enum.TextXAlignment.Right
v13.Parent = vu3
local v14 = Instance.new("UIStroke")
v14.Color = Color3.fromRGB(100, 100, 200)
v14.Thickness = 1
v14.Transparency = 0.6
v14.Parent = v13
local vu15 = Instance.new("Frame")
vu15.Name = "Particles"
vu15.Size = UDim2.new(1, 0, 1, 0)
vu15.BackgroundTransparency = 1
vu15.Parent = vu6
for _ = 1, 8 do
    local v16 = Instance.new("Frame")
    v16.Size = UDim2.new(0, 8, 0, 8)
    v16.Position = UDim2.new(math.random(), 0, math.random(), 0)
    v16.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    v16.BackgroundTransparency = 1
    v16.BorderSizePixel = 0
    local v17 = Instance.new("UICorner")
    v17.CornerRadius = UDim.new(1, 0)
    v17.Parent = v16
    v16.Parent = vu15
end
vu6.Position = UDim2.new(0.5, 0, 0.6, 0);
(function()
    local v18 = vu1:Create(vu4, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2
    })
    local v19 = vu1:Create(vu6, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.1,
        Position = UDim2.new(0.5, 0, 0.45, 0)
    })
    local v20 = vu1:Create(vu10, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 0
    })
    local v21 = vu1:Create(vu11, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.3), {
        TextTransparency = 0.2
    })
    local v22 = vu1:Create(vu12, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0.3,
        Rotation = 360
    })
    local v23 = vu1:Create(vu8, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 0.3
    })
    local v24 = vu1:Create(vu9, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        ImageTransparency = 0.5
    })
    v18:Play()
    v19:Play()
    v20:Play()
    v21:Play()
    v22:Play()
    v23:Play()
    v24:Play()
    local v25 = vu15
    local v26, v27, v28 = ipairs(v25:GetChildren())
    while true do
        local v29
        v28, v29 = v26(v27, v28)
        if v28 == nil then
            break
        end
        if v29:IsA("Frame") then
            local v30 = math.random()
            local v31 = math.random()
            vu1:Create(v29, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(v30, 0, v31, 0),
                BackgroundTransparency = 0.5
            }):Play()
        end
    end
    wait(3)
    local v32 = vu1:Create(vu4, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    })
    local v33 = vu1:Create(vu6, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.55, 0)
    })
    local v34 = vu1:Create(vu10, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    })
    local v35 = vu1:Create(vu11, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        TextTransparency = 1
    })
    local v36 = vu1:Create(vu12, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        ImageTransparency = 1,
        Rotation = 0
    })
    local v37 = vu1:Create(vu8, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 1
    })
    local v38 = vu1:Create(vu9, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        ImageTransparency = 1
    })
    v32:Play()
    v33:Play()
    v34:Play()
    v35:Play()
    v36:Play()
    v37:Play()
    v38:Play()
    wait(1)
    vu3:Destroy()
end)()
