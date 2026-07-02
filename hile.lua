local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Synder Cheat",
   LoadingTitle = "Yükleniyor...",
   LoadingSubtitle = "by Diwonas",
   ConfigurationSaving = {
      Enabled = false
   }
})

local CombatTab = Window:CreateTab("Combat", 4483345998)

local AimbotEnabled = false
local HitboxEnabled = false
local HitboxSize = 2

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

game:GetService("RunService").RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

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

CombatTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      AimbotEnabled = Value
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
