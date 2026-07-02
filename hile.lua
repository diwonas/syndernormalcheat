-- En kararlı çalışan Kavo Kütüphanesini çekiyoruz
local KavoLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Ana Pencereyi Oluştur (Temalar: Midnight, Charcoal, Darken, Blood, Grape vb.)
local Window = KavoLib.CreateLib("Synder Cheat", "Midnight")

-- SEKMELER (Tabs)
local CombatTab = Window:NewTab("Combat")

-- BÖLÜMLER (Sections)
local CombatSection = CombatTab:NewSection("Ana Özellikler")

-- HİLE DEĞİŞKENLERİ
local SilentAimEnabled = false
local HitboxEnabled = false
local HitboxSize = 2

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- EN YAKIN OYUNCUYU BULMA FONKSİYONU
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- SILENT AIM SİSTEMİ
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Self, Key)
    if SilentAimEnabled and not checkcaller() and Self == Mouse and (Key == "Hit" or Key == "Target") then
        local Target = getClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            if Key == "Hit" then
                return Target.Character.HumanoidRootPart.CFrame
            elseif Key == "Target" then
                return Target.Character.HumanoidRootPart
            end
        end
    end
    return OldIndex(Self, Key)
end)

-- HITBOX SİSTEMİ
game:GetService("RunService").RenderStepped:Connect(function()
    if HitboxEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                hrp.Transparency = 0.5
                hrp.BrickColor = BrickColor.new("Really red")
                hrp.Material = Enum.Material.Neon
                hrp.CanCollide = false
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                hrp.CanCollide = true
            end
        end
    end
end)

-- MENÜ BUTONLARI VE ELEMENTLERİ

-- 1. Silent Aim Toggle
CombatSection:NewToggle("Silent Aim (Sessiz Nişan)", "Mermileri otomatik en yakın düşmana yönlendirir.", function(state)
    SilentAimEnabled = state
end)

-- 2. Hitbox Toggle
CombatSection:NewToggle("Geniş Hitbox", "Düşmanların vurulma alanını büyütür.", function(state)
    HitboxEnabled = state
end)

-- 3. Hitbox Boyut Slider'ı
CombatSection:NewSlider("Hitbox Boyutu", "Hitbox büyüklüğünü ayarlar.", 30, 2, function(s) -- Max: 30, Min: 2
    HitboxSize = s
end)
