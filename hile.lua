local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Synder Cheat",
   LoadingTitle = "Yükleniyor...",
   LoadingSubtitle = "by Diwonas",
   ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat", 4483345998)

-- DEĞİŞKENLER
local SilentAimEnabled = false
local HitboxEnabled = false
local HitboxSize = 2

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- EN YAKIN DÜŞMANI BULAN FONKSİYON
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                -- Fare imlecine en yakın olan oyuncuyu bulur
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

-- SILENT AIM KANCASI (HOOK)
-- Oyunun fare hedefi algıladığı metotları arkada değiştirir
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if SilentAimEnabled and not checkcaller() then
        -- Silahların ateş ederken kullandığı yaygın fonksiyon adları
        if Method == "FindPartOnRayWithIgnoreList" or Method == "FindPartOnRayWithWhitelist" or Method == "Raycast" then
            local Target = getClosestPlayer()
            if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
                -- Merminin gideceği yönü doğrudan en yakın düşmanın gövdesine odaklar
                local TargetPos = Target.Character.HumanoidRootPart.Position
                local Origin = Args[1].Origin
                Args[1] = Ray.new(Origin, (TargetPos - Origin).Unit * 5000)
                return OldNamecall(Self, unpack(Args))
            end
        end
    end
    return OldNamecall(Self, ...)
end)

-- Oyunun Mouse.Hit (Tıklanan Yer) özelliğini manipüle eder
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

-- HITBOX DÖNGÜSÜ
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

-- MENÜ BUTONLARI
CombatTab:CreateToggle({
   Name = "Silent Aim (Sessiz Nişan)",
   CurrentValue = false,
   Callback = function(Value)
      SilentAimEnabled = Value
   end,
})

CombatTab:CreateToggle({
   Name = "Geniş Hitbox",
   CurrentValue = false,
   Callback = function(Value)
      HitboxEnabled = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Hitbox Boyutu",
   Min = 2,
   Max = 30,
   CurrentValue = 2,
   Increment = 1,
   ValueName = "Boyut",
   Callback = function(Value)
      HitboxSize = Value
   end,
})
