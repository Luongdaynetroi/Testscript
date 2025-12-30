local v1 = next
local v2 = {
    game.ReplicatedStorage.Util,
    game.ReplicatedStorage.Common,
    game.ReplicatedStorage.Remotes,
    game.ReplicatedStorage.Assets,
    game.ReplicatedStorage.FX
}
local v3 = nil
local vu4 = nil
local vu5 = nil
while true do
    local v6
    v3, v6 = v1(v2, v3)
    if v3 == nil then
        break
    end
    local v7 = next
    local v8, v9 = v6:GetChildren()
    while true do
        local v10
        v9, v10 = v7(v8, v9)
        if v9 == nil then
            break
        end
        if v10:IsA("RemoteEvent") and v10:GetAttribute("Id") then
            vu5 = v10:GetAttribute("Id")
            vu4 = v10
        end
    end
    v6.ChildAdded:Connect(function(p11)
        if p11:IsA("RemoteEvent") and p11:GetAttribute("Id") then
            vu5 = p11:GetAttribute("Id")
            vu4 = p11
        end
    end)
end
task.spawn(function()
    while task.wait(0.0001) do
        local v12 = game.Players.LocalPlayer.Character
        local v13
        if v12 then
            v13 = v12:FindFirstChild("HumanoidRootPart")
        else
            v13 = v12
        end
        local v14, v15, v16 = ipairs({
            workspace.Enemies,
            workspace.Characters
        })
        local vu17 = {}
        while true do
            local v18
            v16, v18 = v14(v15, v16)
            if v16 == nil then
                break
            end
            local v19, v20, v21 = ipairs(v18 and v18:GetChildren() or {})
            while true do
                local v22
                v21, v22 = v19(v20, v21)
                if v21 == nil then
                    break
                end
                local v23 = v22:FindFirstChild("HumanoidRootPart")
                local v24 = v22:FindFirstChild("Humanoid")
                if v22 ~= v12 and (v23 and (v24 and (v24.Health > 0 and (v23.Position - v13.Position).Magnitude <= 60))) then
                    local v25, v26, v27 = ipairs(v22:GetChildren())
                    while true do
                        local v28
                        v27, v28 = v25(v26, v27)
                        if v27 == nil then
                            break
                        end
                        if v28:IsA("BasePart") and (v23.Position - v13.Position).Magnitude <= 60 then
                            vu17[# vu17 + 1] = {
                                v22,
                                v28
                            }
                        end
                    end
                end
            end
        end
        local v29 = v12:FindFirstChildOfClass("Tool")
        if # vu17 > 0 and (v29 and (v29:GetAttribute("WeaponType") == "Melee" or v29:GetAttribute("WeaponType") == "Sword")) then
            pcall(function()
                require(game.ReplicatedStorage.Modules.Net):RemoteEvent("RegisterHit", true)
                game.ReplicatedStorage.Modules.Net["RE/RegisterAttack"]:FireServer()
                local v30 = vu17[1][1]:FindFirstChild("Head")
                if v30 then
                    game.ReplicatedStorage.Modules.Net["RE/RegisterHit"]:FireServer(v30, vu17, {}, tostring(game.Players.LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15))
                    cloneref(vu4):FireServer(string.gsub("RE/RegisterHit", ".", function(p31)
                        return string.char(bit32.bxor(string.byte(p31), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
                    end), bit32.bxor(vu5 + 909090, game.ReplicatedStorage.Modules.Net.seed:InvokeServer() * 2), v30, vu17)
                end
            end)
        end
    end
end)
