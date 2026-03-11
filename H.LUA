-- NullDefense | Key System
local KEY_TO_VERIFY = "Null001"
local DISCORD_LINK = "https://discord.gg/gkSVRQjngv"

local function LoadHUB()
    local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Configuration Table
local Config = {
    Aimbot = {
        CamEnabled = false,
        CamHoldToAim = true,
        CamHoldKey = Enum.UserInputType.MouseButton2,
        CamHitbox = "Head",
        CamVisible = true,
        CamTeam = false,
        CamForceFieldCheck = true,
        CamFOV = 500,
        CamSmooth = 1.0,
        CamDist = 1000,
        CamFOVCircle = false,
        CamPrediction = false,
        CamPredPower = 0.165,

        MouseEnabled = false,
        MouseHoldToAim = true,
        MouseHoldKey = Enum.UserInputType.MouseButton2,
        MouseHitbox = "Head",
        MouseVisible = true,
        MouseTeam = false,
        MouseForceFieldCheck = true,
        MouseFOV = 500,
        MouseSmooth = 1.0,
        MouseDist = 1000,
        MouseFOVCircle = false,
        MousePrediction = false,
        MousePredPower = 0.165,

        TriggerEnabled = false,
        TriggerTeamCheck = false,
        TriggerDelay = 0,
        TargetBots = false,
        
        KnockCheck = true,

        SilentAim = false,
        SilentAimHitbox = "Head",
        SilentAimFOV = 500,
        SilentAimFOVCircle = false,
    },
    ESP = {
        Enabled = false,
        ShowBots = false,
        Box = false,
        Outline = false, 
        Skeleton = false,
        Lines = false,
        Names = false,
        HealthBar = false,
        Radar = false,
        ShowDist = false,
        MaxDist = 1500,
        NameSize = 14,
        VisColor = Color3.fromRGB(0, 255, 0),
        HidColor = Color3.fromRGB(255, 0, 0),
    },
    Misc = {
        Fly = false,
        FlyEnabled = false,
        FlyKey = false,
        FlySpeed = 50,
        WalkSpeed = false,
        WalkSpeedVal = 16,
        WasWalkSpeed = false,
        JumpPower = false,
        JumpPowerVal = 50,
        WasJumpPower = false,
        InfJump = false,
        TeleportKey = false,
        SpinBot = false,
        SpinSpeed = 15,
        FovChanger = false,
        FovVal = 70,
    },
    Fling = {
        AntiFling = false,
        WalkFling = false,
    },
    Settings = {
        MenuKey = Enum.KeyCode.Insert,
        UIColor = Color3.fromRGB(0, 0, 0) 
    }
}

-- Theme Engine
local ThemeObjects = {}
local function BindTheme(instance, property, section, key, dark, microTint)
    table.insert(ThemeObjects, {Inst = instance, Prop = property, Section = section, Key = key, Dark = dark, Micro = microTint})
    local color = Config.Settings.UIColor
    local applyColor
    if microTint then
        applyColor = Color3.fromRGB(16 + color.R*8, 16 + color.G*8, 16 + color.B*8)
    elseif dark then
        applyColor = Color3.fromRGB(color.R*38, color.G*38, color.B*38)
    else
        applyColor = color
    end
    if section and key then
        if Config[section][key] then instance[property] = applyColor end
    else
        instance[property] = applyColor
    end
end

local function UnbindTheme(instance, property)
    for i, item in pairs(ThemeObjects) do
        if item.Inst == instance and item.Prop == property then
            table.remove(ThemeObjects, i)
            break
        end
    end
end

local GlowH, GlowV, GradH, GradV

local function UpdateTheme()
    local color = Config.Settings.UIColor
    local darkColor = Color3.fromRGB(color.R*38, color.G*38, color.B*38)
    local microColor = Color3.fromRGB(16 + color.R*8, 16 + color.G*8, 16 + color.B*8)
    for _, item in pairs(ThemeObjects) do
        if item.Inst and item.Inst.Parent then
            local applyColor = item.Micro and microColor or (item.Dark and darkColor or color)
            if item.Section and item.Key then
                if Config[item.Section][item.Key] then item.Inst[item.Prop] = applyColor end
            else
                if item.Prop == "TextColor3" and item.Inst.Text == "✓" then
                else
                    item.Inst[item.Prop] = applyColor
                end
            end
        end
    end
    -- Update background glow frames to match UIColor
    if GlowH and GradH then
        local r, g, b = color.R, color.G, color.B
        GlowH.BackgroundColor3 = color
        GlowV.BackgroundColor3 = color
        GradH.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(r*200, g*200, b*200)),
            ColorSequenceKeypoint.new(0.5,  color),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(r*200, g*200, b*200)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 0, 0))
        }
        GradV.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(r*180, g*180, b*180)),
            ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(r*230, g*230, b*230)),
            ColorSequenceKeypoint.new(0.65, Color3.fromRGB(r*180, g*180, b*180)),
            ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 0, 0))
        }
    end
end

-- Triggerbot state (global scope so both the loop and can share it)
local canClick = (typeof(mouse1press) == "function") and (typeof(mouse1release) == "function") and (typeof(mouse1click) == "function")
local CurrentlyPressed = false
local CurrentTarget = nil

-- Drawing API Objects
local FOVCircleCam
local FOVCircleMouse
local FOVCircleSilent
local ESPObjects = {}

if Drawing then
    FOVCircleCam = Drawing.new("Circle")
    FOVCircleCam.Color = Color3.fromRGB(255, 40, 40)
    FOVCircleCam.Thickness = 1
    FOVCircleCam.Filled = false
    FOVCircleCam.Transparency = 1
    
    FOVCircleMouse = Drawing.new("Circle")
    FOVCircleMouse.Color = Color3.fromRGB(40, 40, 255)
    FOVCircleMouse.Thickness = 1
    FOVCircleMouse.Filled = false
    FOVCircleMouse.Transparency = 1
    
    FOVCircleSilent = Drawing.new("Circle")
    FOVCircleSilent.Color = Color3.fromRGB(200, 40, 255) -- purple
    FOVCircleSilent.Thickness = 1
    FOVCircleSilent.Filled = false
    FOVCircleSilent.Transparency = 1
end

-- Cleanup ESP on Leave
Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        if Drawing then
            ESPObjects[plr].Box:Remove()
            ESPObjects[plr].Text:Remove()
            if ESPObjects[plr].Line then ESPObjects[plr].Line:Remove() end
            if ESPObjects[plr].Skel then
                for _, l in pairs(ESPObjects[plr].Skel) do l:Remove() end
            end
        end
        if ESPObjects[plr].Highlight then ESPObjects[plr].Highlight:Destroy() end
        ESPObjects[plr] = nil
    end
end)

-- Key States
local KeysDown = {}
local function GetNearestPhysicalPlayer()
    local nearestDist = math.huge
    local nearestTarg = nil
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local pPos = plr.Character.HumanoidRootPart.Position
            local dist = (myPos - pPos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestTarg = plr.Character.HumanoidRootPart
            end
        end
    end
	return nearestTarg
end

local function GetFarthestPhysicalPlayer()
    local farthestDist = 0
    local farthestTarg = nil
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local pPos = plr.Character.HumanoidRootPart.Position
            local dist = (myPos - pPos).Magnitude
            if dist > farthestDist then
                farthestDist = dist
                farthestTarg = plr.Character.HumanoidRootPart
            end
        end
    end
    return farthestTarg
end

local function GetClosestPlayerCameraFOV(fov, hitboxName)
    local closestTarget = nil
    local bestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end

    for _, tgt in pairs(GetTargets(Config.Aimbot.TargetBots)) do
        local char = tgt.Char
        if char then
            local part = GetHitbox(char, hitboxName)
            if part then
                local scrPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    -- Measure from center of screen (Camera Crosshair) instead of Mouse Cursor
                    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(scrPos.X, scrPos.Y) - centerScreen).Magnitude
                    if dist <= fov and dist < bestDist then
                        -- Check visibility
                        local isVis = true
                        local points = {}
                        for _, n in pairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
                            local p = char:FindFirstChild(n)
                            if p then table.insert(points, p.Position) end
                        end
                        if #points > 0 then
                            local obs = Camera:GetPartsObscuringTarget(points, {myChar, char})
                            for _, partObs in pairs(obs) do
                                if IsValidObstacle(partObs) then
                                    isVis = false
                                    break
                                end
                            end
                        end
                        if isVis then
                            bestDist = dist
                            closestTarget = part
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    KeysDown[input.UserInputType] = true
    KeysDown[input.KeyCode] = true

    if Config.Misc.FlyEnabled and input.KeyCode == Config.Misc.FlyKey then Config.Misc.Fly = not Config.Misc.Fly end

    -- Silent Aim: on left click, briefly snap camera AND cursor to target
    if Config.Aimbot.SilentAim and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = GetClosestPlayerCameraFOV(Config.Aimbot.SilentAimFOV, Config.Aimbot.SilentAimHitbox)
        if target then
            local originalCFrame = Camera.CFrame
            local targetPos = target.Position
            
            -- Snap camera to face target (covers camera-based hit detection)
            Camera.CFrame = CFrame.new(originalCFrame.Position, targetPos)
            
            -- Also move mouse cursor to target's screen pos (covers cursor-based games like Hypershot)
            if mousemoverel then
                local scrPos = Camera:WorldToScreenPoint(targetPos)
                local centerX = Camera.ViewportSize.X / 2
                local centerY = Camera.ViewportSize.Y / 2
                local cursorPos = UserInputService:GetMouseLocation()
                local dx = scrPos.X - cursorPos.X
                local dy = scrPos.Y - cursorPos.Y
                mousemoverel(dx, dy)
            end
            
            -- Restore original CFrame after the shot is processed (tiny delay for Roblox Engine physics)
            task.wait()
            Camera.CFrame = originalCFrame
        end
    end
    if input.KeyCode == Config.Misc.TeleportKey then
        local target = GetNearestPhysicalPlayer()
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 3.5)
        end
    end
    if input.KeyCode == Config.Misc.TeleportFarthestKey then
        local target = GetFarthestPhysicalPlayer()
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 0, 3.5)
        end
    end
    if input.KeyCode == Config.Settings.MenuKey then
        local gui = CoreGui:FindFirstChild("MRLHub") or LocalPlayer.PlayerGui:FindFirstChild("MRLHub")
        if gui then
            local mainFrame = gui:FindFirstChild("MainFrame")
            if mainFrame then
                -- Custom Recursive Fader to bypass CanvasGroup rendering bugs
                local function FadeUI(element, isHiding, time)
                    local tInfo = TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                    for _, child in pairs(element:GetDescendants()) do
                        if not child:IsA("GuiObject") then continue end
                        
                        -- Save original transparencies on the very first run
                        if child:GetAttribute("OrigBg") == nil then
                            if child:IsA("CanvasGroup") then
                                child:SetAttribute("OrigGroup", child.GroupTransparency)
                            else
                                child:SetAttribute("OrigBg", child.BackgroundTransparency)
                            end
                            if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                                child:SetAttribute("OrigTxt", child.TextTransparency)
                                child:SetAttribute("OrigStrk", child.TextStrokeTransparency)
                            end
                            if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                                child:SetAttribute("OrigImg", child.ImageTransparency)
                            end
                            if child:IsA("UIStroke") then
                                child:SetAttribute("OrigUIStrk", child.Transparency)
                            end
                            if child:IsA("ScrollingFrame") then
                                child:SetAttribute("OrigScrollBar", child.ScrollBarImageTransparency)
                            end
                        end
                    
                        local props = {}
                        local targetBg = isHiding and 1 or (child:GetAttribute("OrigBg") or 0)
                        
                        if child:IsA("CanvasGroup") then
                            props.GroupTransparency = isHiding and 1 or child:GetAttribute("OrigGroup")
                        elseif child:IsA("Frame") then
                            props.BackgroundTransparency = targetBg
                        elseif child:IsA("ScrollingFrame") then
                            props.BackgroundTransparency = targetBg
                            props.ScrollBarImageTransparency = isHiding and 1 or child:GetAttribute("OrigScrollBar")
                        elseif child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                            props.BackgroundTransparency = targetBg
                            props.TextTransparency = isHiding and 1 or child:GetAttribute("OrigTxt")
                            if child:GetAttribute("OrigStrk") < 1 then
                                props.TextStrokeTransparency = isHiding and 1 or child:GetAttribute("OrigStrk")
                            end
                        elseif child:IsA("ImageLabel") or child:IsA("ImageButton") then
                            props.BackgroundTransparency = targetBg
                            props.ImageTransparency = isHiding and 1 or child:GetAttribute("OrigImg")
                        elseif child:IsA("UIStroke") then 
                            props.Transparency = isHiding and 1 or child:GetAttribute("OrigUIStrk")
                        end
                        if next(props) then TweenService:Create(child, tInfo, props):Play() end
                    end
                    
                    if element:GetAttribute("OrigBg") == nil then element:SetAttribute("OrigBg", element.BackgroundTransparency) end
                    local rootProps = {BackgroundTransparency = isHiding and 1 or element:GetAttribute("OrigBg")}
                    TweenService:Create(element, tInfo, rootProps):Play()
                end

                if gui.Enabled then
                    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -500, 0.5, -280), Size = UDim2.new(0, 950, 0, 550)}):Play()
                    FadeUI(mainFrame, true, 0.25)
                    task.delay(0.25, function() gui.Enabled = false end)
                else
                    gui.Enabled = true
                    
                    if mainFrame:GetAttribute("OrigBg") == nil then
                        -- Instantly hide all elements on the first open so they can fade in instead of popping in
                        FadeUI(mainFrame, true, 0)
                    end
                    
                    mainFrame.Position = UDim2.new(0.5, -500, 0.5, -280)
                    mainFrame.Size = UDim2.new(0, 950, 0, 550)
                    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -500, 0.5, -300), Size = UDim2.new(0, 1000, 0, 600)}):Play()
                    FadeUI(mainFrame, false, 0.25)
                end
            else
                gui.Enabled = not gui.Enabled
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    KeysDown[input.UserInputType] = false
    KeysDown[input.KeyCode] = false
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Misc.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local function isKeyDown(key)
    if not key then return false end
    if KeysDown[key] == true then return true end
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.KeyCode then return UserInputService:IsKeyDown(key)
        elseif key.EnumType == Enum.UserInputType then
            local s, d = pcall(function() return UserInputService:IsMouseButtonPressed(key) end)
            if s and d then return true end
        end
    end
    return false
end

--// UTILITY FUNCTIONS

local function IsValidObstacle(part)
    local s, r = pcall(function()
        if not part or not part:IsA("BasePart") then return false end
        if part.Transparency >= 0.3 then return false end
        if not part.CanCollide and not part.Anchored then return false end
        
        -- Most custom clothes/armor/accessories are unanchored and relatively small or massless
        if not part.Anchored and (part.Massless or part.Size.Magnitude < 15) then return false end
        
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model ~= Workspace then
            if model:FindFirstChildOfClass("Humanoid") then return false end
            local p = Players:GetPlayerFromCharacter(model)
            if p then return false end
        end
        
        local folder = part:FindFirstAncestorOfClass("Folder")
        if folder then
            local fn = string.lower(folder.Name)
            if string.find(fn, "cloth") or string.find(fn, "armor") or string.find(fn, "wear") then return false end
        end

        local ln = string.lower(part.Name)
        if string.find(ln, "armor") or string.find(ln, "cloth") or string.find(ln, "hair") or string.find(ln, "accessory") or string.find(ln, "vest") or string.find(ln, "helmet") then
            return false 
        end
        
        if part.Parent then
            local pn = string.lower(part.Parent.Name)
            if string.find(pn, "hat") or string.find(pn, "accessory") then return false end
        end

        return true
    end)
    return s and r
end

local function GetHitbox(char, partName)
    if partName == "Closest" then
        local parts = {"Head", "UpperTorso", "Torso", "HumanoidRootPart", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg"}
        local closest = nil
        local dist = math.huge
        local mousePos = UserInputService:GetMouseLocation()
        for _, p in pairs(parts) do
            local part = char:FindFirstChild(p)
            if part then
                local sPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sPos.X, sPos.Y) - mousePos).Magnitude
                    if d < dist then dist = d; closest = part end
                end
            end
        end
        if closest then return closest end
    end

    if partName == "Torso" then return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart") end
    if partName == "Left Arm" then return char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm") end
    if partName == "Right Arm" then return char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm") end
    if partName == "Left Leg" then return char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg") end
    if partName == "Right Leg" then return char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg") end
    return char:FindFirstChild(partName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function IsVisible(part, targetChar)
    local origin = Camera.CFrame.Position
    local target = part.Position
    local dir = target - origin
    
    local params = RaycastParams.new()
    local ignoreList = {Camera}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    if targetChar then table.insert(ignoreList, targetChar) end
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    
    local castCount = 0
    while castCount < 25 do
        params.FilterDescendantsInstances = ignoreList
        local result = Workspace:Raycast(origin, dir, params)
        if not result then return true end
        
        if IsValidObstacle(result.Instance) then
            return false
        else
            table.insert(ignoreList, result.Instance)
            castCount = castCount + 1
        end
    end
    return false -- Max casts reached, assume blocked
end

local TargetFolders = {"mobs", "npcs", "enemies", "zombies", "bots", "monsters", "zombie", "mob", "npc", "enemy", "monster"}
local function GetTargets(includeBots)
    local targets = {}
    local plrs = Players:GetPlayers()

    -- 1. Standard Roblox Characters
    for _, plr in pairs(plrs) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local isAlive = (hum and hum.Health > 0)
            -- Fallback for custom games (like Hypershot) with no standard Humanoid
            if not hum and (plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character:FindFirstChild("Torso")) then
                isAlive = true
            end
            if isAlive then
                table.insert(targets, { Char = plr.Character, Team = plr.Team, IsBot = false, Name = plr.Name })
            end
        end
    end

    -- 2. Custom Game Character Fallback (e.g., Hypershot, Arsenal)
    -- Searches Workspace for Models named after other players that might not be linked to plr.Character
    for _, plr in pairs(plrs) do
        if plr ~= LocalPlayer then
            local customChar = Workspace:FindFirstChild(plr.Name)
            -- If it's a model in workspace with the player's name and it has essential parts
            if customChar and customChar:IsA("Model") and customChar ~= plr.Character then
                local isValid = customChar:FindFirstChild("Head") or customChar:FindFirstChild("HumanoidRootPart") or customChar:FindFirstChild("Torso")
                local hum = customChar:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then isValid = false end
                
                -- Check if we haven't already added this player
                local alreadyAdded = false
                for _, t in pairs(targets) do
                    if t.Name == plr.Name then alreadyAdded = true; break end
                end

                if isValid and not alreadyAdded then
                    table.insert(targets, { Char = customChar, Team = plr.Team, IsBot = false, Name = plr.Name })
                end
            end
        end
    end

    if includeBots then
        local function scan(folder)
            for _, obj in pairs(folder:GetChildren()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                    -- If it's a model in a target folder, or we find a humanoid/body part
                    local isBot = false
                    
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        isBot = true
                    elseif not hum and (obj:FindFirstChild("Head") or obj:FindFirstChild("Torso") or obj:FindFirstChild("HumanoidRootPart")) then
                        isBot = true
                    elseif string.find(string.lower(obj.Name), "zombie") or string.find(string.lower(obj.Name), "bot") then
                        -- Game specific fallback (some games don't use standard rigs)
                        isBot = true
                    end
                    
                    if isBot and not Players:GetPlayerFromCharacter(obj) then
                        table.insert(targets, { Char = obj, Team = nil, IsBot = true, Name = obj.Name })
                    end
                elseif obj:IsA("Folder") or obj:IsA("Model") then
                    if table.find(TargetFolders, string.lower(obj.Name)) then scan(obj) end
                end
            end
        end
        scan(Workspace)
    end
    return targets
end

local function GetClosestPlayer(fov, teamCheck, visCheck, distCheck, hitboxName, ffCheck)
    local closestDist = math.huge
    local closestTarget = nil
    
    for _, tgt in pairs(GetTargets(Config.Aimbot.TargetBots)) do
        local char = tgt.Char
        if teamCheck and not tgt.IsBot and tgt.Team ~= nil and LocalPlayer.Team ~= nil and tgt.Team == LocalPlayer.Team then continue end
        if ffCheck and char:FindFirstChildOfClass("ForceField") then continue end
        
        local be = char:FindFirstChild("BodyEffects")
        if be and be:FindFirstChild("Dead") and be.Dead.Value then continue end
        if Config.Aimbot.KnockCheck and be and be:FindFirstChild("K.O") and be["K.O"].Value then continue end
        if char:FindFirstChild("GRABBING_CONSTRAINT") then continue end
        
        local part = GetHitbox(char, hitboxName)
        if not part then continue end
        if visCheck and not IsVisible(part, char) then continue end
        
        local scrPos, onScreen = Camera:WorldToScreenPoint(part.Position)
        if onScreen then
            local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
            if dist3D <= distCheck then
                local dist2D = (Vector2.new(scrPos.X, scrPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist2D <= fov and dist2D < closestDist then
                    closestDist = dist2D
                    closestTarget = part
                end
            end
        end
    end
    return closestTarget
end

local function inFOVV2(pos, fov)
    local dir = (pos - Camera.CFrame.Position).Unit
    local dot = Camera.CFrame.LookVector:Dot(dir)
    return math.deg(math.acos(math.clamp(dot, -1, 1))) <= fov / 2
end

local function isVisibleV2(targetChar, localChar)
    if not targetChar or not localChar then return false end
    local points = {}
    for _, n in {"Head", "UpperTorso", "Torso", "HumanoidRootPart"} do
        local p = targetChar:FindFirstChild(n)
        if p then table.insert(points, p.Position) end
    end
    if #points == 0 then return false end
    local obs = Camera:GetPartsObscuringTarget(points, {localChar, targetChar})
    for _, partObs in pairs(obs) do
        if IsValidObstacle(partObs) then
            return false
        end
    end
    return true
end

local function GetClosestPlayerV2(fov, teamCheck, visCheck, hitboxName)
    local closestTarget = nil
    local bestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    for _, tgt in pairs(GetTargets(Config.Aimbot.TargetBots)) do
        local char = tgt.Char
        if teamCheck and not tgt.IsBot and tgt.Team ~= nil and LocalPlayer.Team ~= nil and tgt.Team == LocalPlayer.Team then continue end
        if char then
            local part = GetHitbox(char, hitboxName)
            if part and inFOVV2(part.Position, fov) then
                if visCheck and not isVisibleV2(char, myChar) then continue end
                local scrPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(scrPos.X, scrPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        closestTarget = part
                    end
                end
            end
        end
    end
    return closestTarget
end

--// EXPLOIT LOGIC LOOP
local FlyBodyVel, FlyBodyGyro
local flyActive = false
local espContainer = Instance.new("Folder")
espContainer.Name = "MRL_ESP"
pcall(function() espContainer.Parent = CoreGui end)
if not espContainer.Parent then espContainer.Parent = LocalPlayer.PlayerGui end

local RadarGui = Instance.new("ScreenGui")
RadarGui.Name = "MRL_Radar"
RadarGui.ResetOnSpawn = false
pcall(function() RadarGui.Parent = CoreGui end)
if not RadarGui.Parent then RadarGui.Parent = LocalPlayer.PlayerGui end

local RadarFrame = Instance.new("Frame")
RadarFrame.Size = UDim2.new(0, 200, 0, 200)
RadarFrame.Position = UDim2.new(0, 15, 0, 15)
RadarFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RadarFrame.BorderSizePixel = 0
RadarFrame.Visible = false
RadarFrame.Parent = RadarGui
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(0, 6)
local RadarStroke = Instance.new("UIStroke", RadarFrame)
RadarStroke.Color = Color3.fromRGB(15, 15, 15); RadarStroke.Thickness = 1
local RadarCrossX = Instance.new("Frame"); RadarCrossX.Size = UDim2.new(1, 0, 0, 1); RadarCrossX.Position = UDim2.new(0, 0, 0.5, 0); RadarCrossX.BackgroundColor3 = Color3.fromRGB(30, 30, 30); RadarCrossX.BorderSizePixel = 0; RadarCrossX.Parent = RadarFrame
local RadarCrossY = Instance.new("Frame"); RadarCrossY.Size = UDim2.new(0, 1, 1, 0); RadarCrossY.Position = UDim2.new(0.5, 0, 0, 0); RadarCrossY.BackgroundColor3 = Color3.fromRGB(30, 30, 30); RadarCrossY.BorderSizePixel = 0; RadarCrossY.Parent = RadarFrame
local RadarCenter = Instance.new("Frame"); RadarCenter.Size = UDim2.new(0, 4, 0, 4); RadarCenter.Position = UDim2.new(0.5, -2, 0.5, -2); RadarCenter.BackgroundColor3 = Color3.fromRGB(200, 200, 200); RadarCenter.Parent = RadarFrame; Instance.new("UICorner", RadarCenter).CornerRadius = UDim.new(1, 0)
RadarCrossX.ZIndex = 0; RadarCrossY.ZIndex = 0; RadarCenter.ZIndex = 2

-- Accurate Prediction Math from Source
local function GetShootPos(targetPart, usePrediction, predPower)
    local pos = targetPart.Position
    if usePrediction and targetPart.AssemblyLinearVelocity then
        local vel = targetPart.AssemblyLinearVelocity
        local p = predPower or 0.165
        -- Dynamic prediction scaling based on distance helps in fast FPS games
        -- Hypershot tweak: apply a multiplier to the velocity to compensate for their specific projectile speeds
        local dist = (Camera.CFrame.Position - pos).Magnitude
        local dynamicP = p + (dist / 15000) -- Tuned for hypershot speeds
        -- Gravity compensation could also be added here if projectiles have drop
        return pos + (vel * dynamicP)
    end
    return pos
end

-- Camera Aimbot loop hooked specifically to Camera step
RunService:BindToRenderStep("MRL_CameraAim", Enum.RenderPriority.Camera.Value + 1, function()
    if Config.Aimbot.CamEnabled then
        local doAim = true
        if Config.Aimbot.CamHoldToAim and not isKeyDown(Config.Aimbot.CamHoldKey) then doAim = false end
        if doAim then
            local target = GetClosestPlayer(Config.Aimbot.CamFOV, Config.Aimbot.CamTeam, Config.Aimbot.CamVisible, Config.Aimbot.CamDist, Config.Aimbot.CamHitbox, Config.Aimbot.CamForceFieldCheck)
            if target then
                local aimPos = GetShootPos(target, Config.Aimbot.CamPrediction, Config.Aimbot.CamPredPower)
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, aimPos)
                local smoothness = Config.Aimbot.CamSmooth
                
                -- Improved sticky smoothing algorithm
                if smoothness < 1.0 then 
                    local tension = math.clamp(smoothness, 0.01, 0.99)
                    Camera.CFrame = currentCFrame:Lerp(targetCFrame, tension)
                else 
                    Camera.CFrame = targetCFrame 
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    
    -- Update FOV Circles
    if Drawing then
        if Config.Aimbot.CamFOVCircle and Config.Aimbot.CamEnabled then
            FOVCircleCam.Visible = true; FOVCircleCam.Radius = Config.Aimbot.CamFOV; FOVCircleCam.Position = mousePos
        else FOVCircleCam.Visible = false end

        if Config.Aimbot.MouseFOVCircle and Config.Aimbot.MouseEnabled then
            FOVCircleMouse.Visible = true; FOVCircleMouse.Radius = Config.Aimbot.MouseFOV; FOVCircleMouse.Position = mousePos
        else FOVCircleMouse.Visible = false end

        if Config.Aimbot.SilentAimFOVCircle and Config.Aimbot.SilentAim then
            FOVCircleSilent.Visible = true; FOVCircleSilent.Radius = Config.Aimbot.SilentAimFOV
            FOVCircleSilent.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        else FOVCircleSilent.Visible = false end
    end

    -- Mouse Aimbot logic (Relative Mouse movement)
    if Config.Aimbot.MouseEnabled and mousemoverel then
        local doAim = true
        if Config.Aimbot.MouseHoldToAim and not isKeyDown(Config.Aimbot.MouseHoldKey) then doAim = false end
        if doAim then
            local target = GetClosestPlayer(Config.Aimbot.MouseFOV, Config.Aimbot.MouseTeam, Config.Aimbot.MouseVisible, Config.Aimbot.MouseDist, Config.Aimbot.MouseHitbox, Config.Aimbot.MouseForceFieldCheck)
            if target then
                local aimPos = GetShootPos(target, Config.Aimbot.MousePrediction, Config.Aimbot.MousePredPower)
                local scrPos, onScreen = Camera:WorldToViewportPoint(aimPos)
                if onScreen then
                    local tension = Config.Aimbot.MouseSmooth
                    -- Use screen CENTER as reference, not cursor position.
                    -- In mouse-lock/first-person games, the OS cursor is always
                    -- re-centered by Roblox every frame. Using cursor pos as
                    -- reference causes snap-back on release because the game
                    -- resets it independently of where we moved the mouse.
                    local centerX = Camera.ViewportSize.X / 2
                    local centerY = Camera.ViewportSize.Y / 2
                    local dx = scrPos.X - centerX
                    local dy = scrPos.Y - centerY
                    
                    if math.abs(dx) > 1 or math.abs(dy) > 1 then
                        mousemoverel(dx * tension, dy * tension)
                    end
                end
            end
        end
    end

    -- Triggerbot
    if Config.Aimbot.TriggerEnabled then
        local target = Mouse.Target
        local char = target and target:FindFirstAncestorWhichIsA("Model")
        local humanoid = char and char:FindFirstChild("Humanoid")
        local player = char and Players:GetPlayerFromCharacter(char)
        
        local valid = humanoid and humanoid.Health > 0 and player and player ~= LocalPlayer
        
        if valid and Config.Aimbot.TriggerTeamCheck then
            if player.Team == LocalPlayer.Team then
                valid = false
            end
        end

        if valid then
            CurrentTarget = char
            if not CurrentlyPressed then
                CurrentlyPressed = true
                if canClick then mouse1press() end
            end
        else
            if CurrentTarget then
                local stillAiming = Mouse.Target and Mouse.Target:IsDescendantOf(CurrentTarget)
                if not stillAiming then
                    CurrentTarget = nil
                    if CurrentlyPressed then
                        CurrentlyPressed = false
                        if canClick then mouse1release() end
                    end
                end
            end
        end
    else
        CurrentTarget = nil
        if CurrentlyPressed then
            CurrentlyPressed = false
            if canClick then mouse1release() end
        end
    end
    
    -- Misc Logic (WalkSpeed / JumpPower / SpinBot handled below)
    local char = LocalPlayer.Character
    if not Config.Misc.FlyEnabled then Config.Misc.Fly = false end
    
    if Config.Misc.Fly and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not FlyBodyVel then
            FlyBodyVel = Instance.new("BodyVelocity")
            FlyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyVel.Velocity = Vector3.new(0, 0, 0)
            FlyBodyVel.Parent = hrp
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyGyro.P = 10000
            FlyBodyGyro.CFrame = Camera.CFrame
            FlyBodyGyro.Parent = hrp
            flyActive = true
            char.Humanoid.PlatformStand = true
        end
        FlyBodyGyro.CFrame = Camera.CFrame
        local moveDir = Vector3.new()
        if isKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if isKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if isKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if isKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if isKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if isKeyDown(Enum.KeyCode.LeftControl) or isKeyDown(Enum.KeyCode.RightControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        FlyBodyVel.Velocity = moveDir * Config.Misc.FlySpeed
    else
        if flyActive then
            if FlyBodyVel then FlyBodyVel:Destroy(); FlyBodyVel = nil end
            if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end
            if char and char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
            flyActive = false
        end
    end
    
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if Config.Misc.WalkSpeed then 
            hum.WalkSpeed = Config.Misc.WalkSpeedVal
            Config.Misc.WasWalkSpeed = true
        elseif Config.Misc.WasWalkSpeed then
            hum.WalkSpeed = 16
            Config.Misc.WasWalkSpeed = false
        end

        if Config.Misc.JumpPower then 
            hum.JumpPower = Config.Misc.JumpPowerVal
            hum.UseJumpPower = true 
            Config.Misc.WasJumpPower = true
        elseif Config.Misc.WasJumpPower then
            hum.JumpPower = 50
            Config.Misc.WasJumpPower = false
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and Config.Misc.SpinBot then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.Misc.SpinSpeed), 0)
        end
    end

    if Config.Misc.FovChanger then
        Camera.FieldOfView = Config.Misc.FovVal
    end
end)

-- Skeleton Drawing Function
local R15Joints = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6Joints = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function DrawSkeleton(char, skelData, col)
    local joints = char:FindFirstChild("UpperTorso") and R15Joints or R6Joints
    local lineIndex = 1
    
    for _, joint in ipairs(joints) do
        local p1 = char:FindFirstChild(joint[1])
        local p2 = char:FindFirstChild(joint[2])
        if p1 and p2 then
            local s1, v1 = Camera:WorldToViewportPoint(p1.Position)
            if v1 then
                local s2, v2 = Camera:WorldToViewportPoint(p2.Position)
                if v2 then
                    local l = skelData[lineIndex]
                    if not l then
                        l = Drawing.new("Line")
                        l.Thickness = 1.5
                        skelData[lineIndex] = l
                    end
                    
                    l.From = Vector2.new(s1.X, s1.Y)
                    l.To = Vector2.new(s2.X, s2.Y)
                    if l.Color ~= col then l.Color = col end
                    if not l.Visible then l.Visible = true end
                    lineIndex = lineIndex + 1
                end
            end
        end
    end
    -- hide rest
    for i = lineIndex, #skelData do
        local l = skelData[i]
        if l and l.Visible then l.Visible = false end
    end
end

-- ESP Engine Wrapper
local function DrawESP()
    if RadarFrame then RadarFrame.Visible = Config.ESP.Enabled and Config.ESP.Radar end
    
    local activeTargets = {}
    if Config.ESP.Enabled then
        for _, tgt in pairs(GetTargets(Config.ESP.ShowBots)) do
            activeTargets[tgt.Char] = tgt
        end
    end

    for key, objs in pairs(ESPObjects) do
        if not activeTargets[key] then
            if objs.Highlight then objs.Highlight:Destroy() end
            if Drawing then
                if objs.Box then objs.Box:Remove() end
                if objs.Text then objs.Text:Remove() end
                if objs.Line then objs.Line:Remove() end
                if objs.HealthBg then objs.HealthBg:Remove() end
                if objs.HealthBar then objs.HealthBar:Remove() end
                for _, l in pairs(objs.Skel) do l:Remove() end
            end
            if objs.RadarDot then objs.RadarDot:Destroy() end
            ESPObjects[key] = nil
        end
    end

    for char, tgt in pairs(activeTargets) do
        if not ESPObjects[char] then
            ESPObjects[char] = { Skel = {}, LastVis = 0, IsVis = false }
            if Drawing then
                ESPObjects[char].Box = Drawing.new("Square"); ESPObjects[char].Box.Thickness = 1; ESPObjects[char].Box.Filled = false
                ESPObjects[char].Text = Drawing.new("Text"); ESPObjects[char].Text.Center = true; ESPObjects[char].Text.Outline = true
                ESPObjects[char].Line = Drawing.new("Line"); ESPObjects[char].Line.Thickness = 2
                ESPObjects[char].HealthBg = Drawing.new("Square"); ESPObjects[char].HealthBg.Thickness = 0; ESPObjects[char].HealthBg.Filled = true; ESPObjects[char].HealthBg.Color = Color3.fromRGB(0,0,0)
                ESPObjects[char].HealthBar = Drawing.new("Square"); ESPObjects[char].HealthBar.Thickness = 0; ESPObjects[char].HealthBar.Filled = true
            end
            local hl = Instance.new("Highlight")
            hl.Name = (tgt.Name or "Bot").."_ESP"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency = 1
            hl.Parent = espContainer
            ESPObjects[char].Highlight = hl
            
            local rDot = Instance.new("Frame")
            rDot.Size = UDim2.new(0, 4, 0, 4)
            rDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            rDot.Visible = false
            rDot.ZIndex = 3
            rDot.Parent = RadarFrame
            Instance.new("UICorner", rDot).CornerRadius = UDim.new(1, 0)
            ESPObjects[char].RadarDot = rDot
        end
        
        local objs = ESPObjects[char]
        local isVis = false
        local onScreen = false
        local scrPos
        
        if Config.ESP.Enabled and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local dist3D = (Camera.CFrame.Position - hrp.Position).Magnitude
            
            if tick() - objs.LastVis > 0.1 then
                objs.IsVis = IsVisible(hrp, char)
                objs.LastVis = tick()
            end
            local col = objs.IsVis and Config.ESP.VisColor or Config.ESP.HidColor
            
            local myChar = LocalPlayer.Character
            if Config.ESP.Radar and myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myLoc = myChar.HumanoidRootPart.Position
                local offset = hrp.Position - myLoc
                local relCFrame = CFrame.new(Vector3.zero, Camera.CFrame.LookVector * Vector3.new(1,0,1))
                local relPos = relCFrame:VectorToObjectSpace(offset)
                local rx = math.clamp(relPos.X / 1.5, -100, 100)
                local ry = math.clamp(relPos.Z / 1.5, -100, 100)
                objs.RadarDot.Visible = true
                objs.RadarDot.BackgroundColor3 = col
                objs.RadarDot.Position = UDim2.new(0.5, rx - 2, 0.5, ry - 2)
            else
                objs.RadarDot.Visible = false
            end
            
            if dist3D > Config.ESP.MaxDist then
                objs.Highlight.Enabled = false
                if Drawing then
                    objs.Box.Visible = false; objs.Text.Visible = false; objs.Line.Visible = false
                    objs.HealthBg.Visible = false; objs.HealthBar.Visible = false
                    for _, l in pairs(objs.Skel) do l.Visible = false end
                end
                continue
            end
            
            scrPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            -- Highlight (Outline)
            if Config.ESP.Outline then
                objs.Highlight.Enabled = true
                objs.Highlight.Adornee = char
                objs.Highlight.OutlineColor = col
            else
                objs.Highlight.Enabled = false
            end
            
            if Drawing then
                if onScreen then
                    local head = GetHitbox(char, "Head")
                    if head then
                        local headPos, _ = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                        local legPos, _ = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height * 0.6
                        
                        -- Box
                        if Config.ESP.Box then
                            objs.Box.Visible = true; objs.Box.Size = Vector2.new(width, height)
                            objs.Box.Position = Vector2.new(scrPos.X - width/2, headPos.Y); objs.Box.Color = col
                        else objs.Box.Visible = false end
                        
                        -- Name
                        if Config.ESP.Names then
                            objs.Text.Visible = true;
                            local dispName = tgt.IsBot and string.format("[BOT] %s", tgt.Name) or tgt.Name
                            if Config.ESP.ShowDist then
                                objs.Text.Text = string.format("%s [%d]", dispName, math.floor(dist3D))
                            else objs.Text.Text = dispName end
                            objs.Text.Size = Config.ESP.NameSize
                            objs.Text.Position = Vector2.new(scrPos.X, headPos.Y - objs.Text.Size - 2); objs.Text.Color = col
                        else objs.Text.Visible = false end
                        
                        -- Health Bar
                        if Config.ESP.HealthBar then
                            local health = char.Humanoid.Health
                            local maxHealth = math.max(char.Humanoid.MaxHealth, 1)
                            local pct = math.clamp(health / maxHealth, 0, 1)
                            if pct ~= pct then pct = 1 end
                            objs.HealthBg.Visible = true; objs.HealthBar.Visible = true
                            objs.HealthBg.Size = Vector2.new(3, height)
                            objs.HealthBg.Position = Vector2.new(scrPos.X - width/2 - 5, headPos.Y)
                            local barHeight = height * pct
                            objs.HealthBar.Size = Vector2.new(1, barHeight)
                            objs.HealthBar.Position = Vector2.new(scrPos.X - width/2 - 4, headPos.Y + (height - barHeight))
                            objs.HealthBar.Color = Color3.fromRGB(255 - (pct * 255), pct * 255, 0)
                        else
                            objs.HealthBg.Visible = false; objs.HealthBar.Visible = false
                        end
                    else
                        objs.Box.Visible = false; objs.Text.Visible = false; objs.HealthBg.Visible = false; objs.HealthBar.Visible = false
                    end
                else
                    objs.Box.Visible = false; objs.Text.Visible = false; objs.HealthBg.Visible = false; objs.HealthBar.Visible = false
                end
                
                -- Skeleton
                if Config.ESP.Skeleton and onScreen then DrawSkeleton(char, objs.Skel, col)
                else for _, l in pairs(objs.Skel) do l.Visible = false end end

                -- Lines (Z > 0 ensures they are physically in front of camera plane)
                if Config.ESP.Lines then
                    if scrPos.Z > 0 then
                        objs.Line.Visible = true
                        objs.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        objs.Line.To = Vector2.new(scrPos.X, scrPos.Y)
                        objs.Line.Color = col
                    else
                        objs.Line.Visible = false
                    end
                else
                    objs.Line.Visible = false
                end
            end
        else
            if objs.RadarDot then objs.RadarDot.Visible = false end
            objs.Highlight.Enabled = false
            if Drawing then
                objs.Box.Visible = false; objs.Text.Visible = false; objs.Line.Visible = false
                objs.HealthBg.Visible = false; objs.HealthBar.Visible = false
                for _, l in pairs(objs.Skel) do l.Visible = false end
            end
        end
    end
end
RunService.RenderStepped:Connect(DrawESP)


--// FLING LOGIC
RunService.Heartbeat:Connect(function()
    local lp = Players.LocalPlayer
    if not lp or not lp.Character then return end

    if Config.Fling.AntiFling then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character and plr.Character.PrimaryPart then
                for _, part in pairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.AssemblyLinearVelocity = Vector3.zero
                        part.AssemblyAngularVelocity = Vector3.zero
                    end
                end
            end
        end
    end

    if Config.Fling.WalkFling then
        if not getgenv()._isWalkFlinging then
            getgenv()._isWalkFlinging = true
            task.spawn(function()
                local r = lp.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local v = r.AssemblyLinearVelocity
                    r.AssemblyLinearVelocity = v * 10000 + Vector3.new(0, 10000, 0)
                    
                    RunService.RenderStepped:Wait()
                    if r then r.AssemblyLinearVelocity = v end
                    
                    RunService.RenderStepped:Wait()
                    if r then r.AssemblyLinearVelocity = v + Vector3.new(0, 0.1, 0) end
                end
                getgenv()._isWalkFlinging = false
            end)
        end
    end
end)


--// UI BUILDING
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MRLHub"
ScreenGui.ResetOnSpawn = false
local success = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

--// Main Frame
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.ClipsDescendants = false
Main.Size = UDim2.new(0, 1000, 0, 600)
Main.Position = UDim2.new(0.5, -500, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Main.Active = true
Main.Draggable = true
local MainDropShadow = Instance.new("ImageLabel"); MainDropShadow.Size = UDim2.new(1, 40, 1, 40); MainDropShadow.Position = UDim2.new(0, -20, 0, -20); MainDropShadow.BackgroundTransparency = 1; MainDropShadow.Image = "rbxassetid://13165239999"; MainDropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0); MainDropShadow.ImageTransparency = 0.5; MainDropShadow.ScaleType = Enum.ScaleType.Slice; MainDropShadow.SliceCenter = Rect.new(70, 70, 70, 70); MainDropShadow.Parent = Main; MainDropShadow.ZIndex = -1

local MainContainer = Instance.new("CanvasGroup")
MainContainer.Size = UDim2.new(1, 0, 1, 0)
MainContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainContainer.BorderSizePixel = 0
MainContainer.Parent = Main
local MainCorner = Instance.new("UICorner", MainContainer)
MainCorner.CornerRadius = UDim.new(0, 8)

-- Base dark background gradient (edges darker)
local Gradient = Instance.new("UIGradient", MainContainer)
Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 0, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(16, 16, 16)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 0, 0))
}
Gradient.Rotation = 0

-- Radial glow simulation: horizontal band
GlowH = Instance.new("Frame")
GlowH.Name = "GlowH"
GlowH.Size = UDim2.new(1, 0, 1, 0)
GlowH.BackgroundColor3 = Config.Settings.UIColor
GlowH.BackgroundTransparency = 0.72
GlowH.BorderSizePixel = 0
GlowH.ZIndex = 1
GlowH.Parent = MainContainer
GradH = Instance.new("UIGradient", GlowH)
GradH.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(160, 0, 0)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(200, 0, 0)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(160, 0, 0)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 0, 0))
}
GradH.Rotation = 0

-- Vertical band
GlowV = Instance.new("Frame")
GlowV.Name = "GlowV"
GlowV.Size = UDim2.new(1, 0, 1, 0)
GlowV.BackgroundColor3 = Config.Settings.UIColor
GlowV.BackgroundTransparency = 0.75
GlowV.BorderSizePixel = 0
GlowV.ZIndex = 1
GlowV.Parent = MainContainer
GradV = Instance.new("UIGradient", GlowV)
GradV.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,    Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(150, 0, 0)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(190, 0, 0)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(150, 0, 0)),
    ColorSequenceKeypoint.new(1,    Color3.fromRGB(0, 0, 0))
}
GradV.Rotation = 90






-- Full-width header glow wash - left panel (behind MODY_)
local MODYGlow = Instance.new("Frame")
MODYGlow.Name = "MODYGlow"
MODYGlow.Size = UDim2.new(0, 280, 0, 82)
MODYGlow.Position = UDim2.new(0, 0, 0, 0)
MODYGlow.BackgroundColor3 = Config.Settings.UIColor
MODYGlow.BackgroundTransparency = 0.78
MODYGlow.BorderSizePixel = 0
MODYGlow.ZIndex = 1
MODYGlow.Parent = MainContainer
local MODYGlowCorner = Instance.new("UICorner", MODYGlow)
MODYGlowCorner.CornerRadius = UDim.new(0, 8)
local MODYGlowGrad = Instance.new("UIGradient", MODYGlow)
MODYGlowGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 80, 80))
}
MODYGlowGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 0.6)
}
MODYGlowGrad.Rotation = 90 -- top bright, bottom fades
BindTheme(MODYGlow, "BackgroundColor3")

-- Full-width header glow wash - right panel (behind MRL HUB)
local TitleGlow = Instance.new("Frame")
TitleGlow.Name = "TitleGlow"
TitleGlow.Size = UDim2.new(1, -280, 0, 82)
TitleGlow.Position = UDim2.new(0, 280, 0, 0)
TitleGlow.BackgroundColor3 = Config.Settings.UIColor
TitleGlow.BackgroundTransparency = 0.78
TitleGlow.BorderSizePixel = 0
TitleGlow.ZIndex = 1
TitleGlow.Parent = Main
local TitleGlowCorner = Instance.new("UICorner", TitleGlow)
TitleGlowCorner.CornerRadius = UDim.new(0, 8)
local TitleGlowGrad = Instance.new("UIGradient", TitleGlow)
TitleGlowGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(80, 80, 80))
}
TitleGlowGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0,   0),
    NumberSequenceKeypoint.new(1,   0.6)
}
TitleGlowGrad.Rotation = 90 -- top bright, bottom fades
BindTheme(TitleGlow, "BackgroundColor3")

local MadeBy = Instance.new("TextLabel"); MadeBy.Size = UDim2.new(0, 200, 0, 20); MadeBy.Position = UDim2.new(0, 25, 0, 15); MadeBy.BackgroundTransparency = 1; MadeBy.Text = "NullDefense | Client"; MadeBy.Font = Enum.Font.GothamBold; MadeBy.TextSize = 20; MadeBy.TextColor3 = Color3.fromRGB(255, 0, 0); MadeBy.TextXAlignment = Enum.TextXAlignment.Left; MadeBy.Parent = Main
local MODYText = Instance.new("TextLabel"); MODYText.Size = UDim2.new(0, 260, 0, 40); MODYText.Position = UDim2.new(0, 25, 0, 30); MODYText.BackgroundTransparency = 1; MODYText.Text = ""; MODYText.Font = Enum.Font.GothamBlack; MODYText.TextSize = 42; MODYText.TextColor3 = Config.Settings.UIColor; MODYText.TextStrokeTransparency = 0.4; MODYText.TextStrokeColor3 = Config.Settings.UIColor; MODYText.TextXAlignment = Enum.TextXAlignment.Left; MODYText.Parent = Main
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -280, 0, 80); Title.Position = UDim2.new(0, 280, 0, 0); Title.BackgroundTransparency = 1; Title.Text = ""; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 46; Title.TextColor3 = Config.Settings.UIColor; Title.TextStrokeTransparency = 0.4; Title.TextStrokeColor3 = Config.Settings.UIColor; Title.Parent = Main

--// LIVE COUNTER
local LiveCounterBg = Instance.new("Frame")
LiveCounterBg.Size = UDim2.new(0, 120, 0, 26)
LiveCounterBg.Position = UDim2.new(1, -140, 0, 27)
LiveCounterBg.BackgroundColor3 = Color3.fromRGB(15, 25, 20)
LiveCounterBg.BorderSizePixel = 0
LiveCounterBg.Parent = Main
Instance.new("UICorner", LiveCounterBg).CornerRadius = UDim.new(1, 0)

local LiveDot = Instance.new("Frame")
LiveDot.Size = UDim2.new(0, 8, 0, 8)
LiveDot.Position = UDim2.new(0, 10, 0.5, -4)
LiveDot.BackgroundColor3 = Color3.fromRGB(45, 215, 100)
LiveDot.BorderSizePixel = 0
LiveDot.Parent = LiveCounterBg
Instance.new("UICorner", LiveDot).CornerRadius = UDim.new(1, 0)

local LiveText = Instance.new("TextLabel")
LiveText.Size = UDim2.new(1, -25, 1, 0)
LiveText.Position = UDim2.new(0, 24, 0, 0)
LiveText.BackgroundTransparency = 1
LiveText.Font = Enum.Font.GothamBold
LiveText.TextSize = 12
LiveText.TextColor3 = Color3.fromRGB(45, 215, 100)
LiveText.TextXAlignment = Enum.TextXAlignment.Left
LiveText.Parent = LiveCounterBg

local PlayerDropDown = Instance.new("ScrollingFrame")
PlayerDropDown.Size = UDim2.new(0, 200, 0, 0)
PlayerDropDown.Position = UDim2.new(1, 15, 0, 27) -- Appears to the right of the main GUI
PlayerDropDown.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
PlayerDropDown.BorderSizePixel = 0
PlayerDropDown.ScrollBarThickness = 2
PlayerDropDown.ZIndex = 10
PlayerDropDown.Visible = false
PlayerDropDown.Parent = Main
Instance.new("UICorner", PlayerDropDown).CornerRadius = UDim.new(0, 6)
local pdStroke = Instance.new("UIStroke", PlayerDropDown)
pdStroke.Color = Color3.fromRGB(45, 215, 100)
pdStroke.Thickness = 1
pdStroke.Transparency = 0.5

local pdListLayout = Instance.new("UIListLayout", PlayerDropDown)
pdListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local isHovering = false
LiveCounterBg.MouseEnter:Connect(function()
    isHovering = true
    PlayerDropDown.Visible = true
    local targetHeight = math.min(#PlayerDropDown:GetChildren() - 1, 15) * 30
    TweenService:Create(PlayerDropDown, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, targetHeight)}):Play()
end)

LiveCounterBg.MouseLeave:Connect(function()
    isHovering = false
    TweenService:Create(PlayerDropDown, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 200, 0, 0)}):Play()
    task.delay(0.25, function() if not isHovering then PlayerDropDown.Visible = false end end)
end)

-- Use a realistic small number for a new script (1 to 5 players)
LiveText.Text = "Connecting..."

-- [REAL LIVE COUNTER LOGIC]
-- 1. Go to firebase.google.com -> Console -> Add Project
-- 2. Build -> Realtime Database -> Create Database (Start in Test Mode!)
-- 3. Copy the database URL (it looks like https://YOUR-PROJECT.firebaseio.com/) and paste it below:
local FIREBASE_URL = "https://mrl-hub-live-adca0-default-rtdb.firebaseio.com/"    -- Real Live Tracker GUI Logic

task.spawn(function()
    local requestFunc = request or http_request or (syn and syn.request)
    if not requestFunc then return end
    


    -- [2] REAL LIVE COUNTER LOGIC
    local lastPlayersString = ""
    while task.wait(1) do -- Ping server every 1 second for instant updates
        pcall(function()
            local plrId = Players.LocalPlayer.UserId
            
            -- Step 1: Tell Firebase this specific player is online right now (timestamp)
            local myPingUrl = FIREBASE_URL .. "active_users/" .. tostring(plrId) .. ".json"
            local myData = game:GetService("HttpService"):JSONEncode({
                time = os.time(),
                name = Players.LocalPlayer.Name,
                id = plrId
            })
            if requestFunc then
                requestFunc({
                    Url = myPingUrl, 
                    Method = "PUT", 
                    Headers = {["Content-Type"] = "application/json"},
                    Body = myData
                })
            end
            
            -- Step 2: Ask Firebase for the entire list of active players
            local getUrl = FIREBASE_URL .. "active_users.json"
            local getRes = nil
            if requestFunc then
                local res = requestFunc({Url = getUrl, Method = "GET"})
                if res and res.Body then getRes = res.Body end
            else
                getRes = game:HttpGet(getUrl)
            end
            
            -- Step 3: Count everyone who pinged within the last 4 seconds
            if getRes and getRes ~= "null" then
                local success, decoded = pcall(function() return game:GetService("HttpService"):JSONDecode(getRes) end)
                if not success then return end
                
                local count = 0
                local now = os.time()
                local activePlayersList = {}
                
                for id, data in pairs(decoded) do
                    local lastPing = type(data) == "table" and data.time or tonumber(data)
                    local pName = type(data) == "table" and data.name or "Unknown"
                    local pId = type(data) == "table" and data.id or id
                    
                    if lastPing and (now - tonumber(lastPing) <= 4) then
                        count = count + 1
                        table.insert(activePlayersList, {name=pName, id=pId})
                    else
                        -- Cleanup: delete users who haven't pinged in over 4 seconds
                        if requestFunc then
                            requestFunc({Url = FIREBASE_URL .. "active_users/" .. id .. ".json", Method = "DELETE"})
                        end
                    end
                end
                
                -- Sort by ID so the list order is mathematically stable (prevents flickering)
                -- BUT always force the LocalPlayer to the very top!
                local myId = tostring(Players.LocalPlayer.UserId)
                table.sort(activePlayersList, function(a, b)
                    if tostring(a.id) == myId then return true end
                    if tostring(b.id) == myId then return false end
                    return tonumber(a.id or 0) < tonumber(b.id or 0) 
                end)
                
                local currentListStr = ""
                for _, p in ipairs(activePlayersList) do
                    currentListStr = currentListStr .. tostring(p.id) .. ","
                end
                
                if count > 0 then
                    LiveText.Text = tostring(count) .. " players live"
                    
                    if currentListStr ~= lastPlayersString then
                        lastPlayersString = currentListStr
                        

                        
                        -- Destroy old frames
                        for _, child in pairs(PlayerDropDown:GetChildren()) do
                            if child:IsA("Frame") then child:Destroy() end
                        end
                        
                        -- Create new frames
                        for _, p in ipairs(activePlayersList) do
                            local pFrame = Instance.new("Frame")
                            pFrame.Size = UDim2.new(1, 0, 0, 30)
                            pFrame.BackgroundTransparency = 1
                            pFrame.ZIndex = 15
                            pFrame.Parent = PlayerDropDown
                            
                            local pImg = Instance.new("ImageLabel")
                            pImg.Size = UDim2.new(0, 22, 0, 22)
                            pImg.Position = UDim2.new(0, 6, 0.5, -11)
                            pImg.BackgroundTransparency = 1
                            pImg.ZIndex = 16
                            pImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.id) .. "&w=48&h=48"
                            pImg.Parent = pFrame
                            Instance.new("UICorner", pImg).CornerRadius = UDim.new(1, 0)
                            
                            local pDot = Instance.new("Frame")
                            pDot.Size = UDim2.new(0, 8, 0, 8)
                            pDot.Position = UDim2.new(1, -20, 0.5, -4) -- Pinned to the right side
                            pDot.BackgroundColor3 = Color3.fromRGB(45, 215, 100) -- Green online dot
                            pDot.ZIndex = 16
                            pDot.Parent = pFrame
                            Instance.new("UICorner", pDot).CornerRadius = UDim.new(1, 0)
                            
                            local pText = Instance.new("TextLabel")
                            pText.Size = UDim2.new(1, -60, 1, 0)
                            pText.Position = UDim2.new(0, 36, 0, 0)
                            pText.BackgroundTransparency = 1
                            pText.ZIndex = 16
                            pText.Text = p.name
                            pText.Font = Enum.Font.GothamBold
                            pText.TextSize = 12
                            pText.TextColor3 = Color3.fromRGB(220, 220, 220)
                            pText.TextXAlignment = Enum.TextXAlignment.Left
                            pText.Parent = pFrame
                            
                            -- DO NOT yield the main thread while retrieving additional data!
                            task.spawn(function()
                                pcall(function()
                                    -- Fallback if the user is using the older script version that didn't upload names
                                    if p.name == "Unknown" then
                                        local actualName = Players:GetNameFromUserIdAsync(tonumber(p.id))
                                        if actualName then
                                            pText.Text = actualName
                                        end
                                    end
                                end)
                                
                                pcall(function()
                                    local isFriend = Players.LocalPlayer:IsFriendsWith(tonumber(p.id))
                                    if isFriend then
                                        pText.TextColor3 = Color3.fromRGB(45, 215, 100) -- Green for friends
                                    end
                                end)
                            end)
                        end
                        
                        PlayerDropDown.CanvasSize = UDim2.new(0, 0, 0, #activePlayersList * 30)
                        
                        if isHovering then
                            local targetHeight = math.min(#activePlayersList, 15) * 30
                            TweenService:Create(PlayerDropDown, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, targetHeight)}):Play()
                        end
                    end
                end
            end
        end)
    end
end)

BindTheme(MODYText, "TextColor3", nil, nil, true)   -- dark tint of theme color
BindTheme(MODYText, "TextStrokeColor3")              -- full bright theme stroke
BindTheme(Title, "TextColor3", nil, nil, true)         -- dark tint of theme color
BindTheme(Title, "TextStrokeColor3")                   -- full bright theme stroke
BindTheme(MadeBy, "TextColor3")


local Sidebar = Instance.new("Frame"); Sidebar.Size = UDim2.new(0, 280, 1, -80); Sidebar.Position = UDim2.new(0, 0, 0, 80); Sidebar.BackgroundTransparency = 1; Sidebar.Parent = Main
local Container = Instance.new("Frame"); Container.Size = UDim2.new(1, -280, 1, -110); Container.Position = UDim2.new(0, 280, 0, 80); Container.BackgroundTransparency = 1; Container.Parent = Main

local BottomText = Instance.new("TextButton"); BottomText.Size = UDim2.new(1, 0, 0, 30); BottomText.Position = UDim2.new(0, 0, 1, -30); BottomText.BackgroundTransparency = 1; BottomText.Text = "NullDefence Client | https://discord.gg/gkSVRQjngv (Click to Copy URL)"; BottomText.Font = Enum.Font.GothamBold; BottomText.TextSize = 14; BottomText.TextColor3 = Color3.fromRGB(220, 220, 220); BottomText.Parent = Main; BottomText.AutoButtonColor = false
local UrlLine = Instance.new("Frame"); UrlLine.Size = UDim2.new(0, 185, 0, 1); UrlLine.Position = UDim2.new(0.5, -92, 1, -7); UrlLine.BackgroundColor3 = Color3.fromRGB(220, 220, 220); UrlLine.BorderSizePixel = 0; UrlLine.Parent = BottomText

BottomText.MouseButton1Click:Connect(function()
    local ok = pcall(function() game:GetService("GuiService"):OpenBrowserWindow("https://discord.gg/gkSVRQjngv") end)
    if not ok then pcall(function() setclipboard("https://discord.gg/MODY") end) end
end)
BottomText.MouseEnter:Connect(function()
    TweenService:Create(BottomText, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    TweenService:Create(UrlLine, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
BottomText.MouseLeave:Connect(function()
    TweenService:Create(BottomText, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    TweenService:Create(UrlLine, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play()
end)


--// INTERACTIVE UI LIBRARY
local Tabs = {}; local Buttons = {}
local function CreateTab(name, order, iconId)
	local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(1, -40, 0, 45); TabBtn.Position = UDim2.new(0, 20, 0, 20 + (order * 52)); TabBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 16); TabBtn.BackgroundTransparency = 0.45; TabBtn.BorderSizePixel = 0; TabBtn.Text = ""; TabBtn.Parent = Sidebar; Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
	local Indicator = Instance.new("Frame"); Indicator.Name = "Indicator"; Indicator.Size = UDim2.new(0, 4, 0, 24); Indicator.Position = UDim2.new(0, 0, 0.5, -12); Indicator.BackgroundColor3 = Color3.fromRGB(255, 30, 30); Indicator.BorderSizePixel = 0; Indicator.Visible = false; Indicator.Parent = TabBtn; Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)
	local Icon = Instance.new("ImageLabel"); Icon.Name = "Icon"; Icon.Size = UDim2.new(0, 18, 0, 18); Icon.Position = UDim2.new(0, 30, 0.5, -9); Icon.BackgroundTransparency = 1; Icon.Image = iconId; Icon.ImageColor3 = Color3.fromRGB(100, 100, 100); Icon.Parent = TabBtn
	local NameLabel = Instance.new("TextLabel"); NameLabel.Name = "NameLabel"; NameLabel.Size = UDim2.new(1, -70, 1, 0); NameLabel.Position = UDim2.new(0, 60, 0, 0); NameLabel.BackgroundTransparency = 1; NameLabel.Text = name; NameLabel.TextColor3 = Color3.fromRGB(100, 100, 100); NameLabel.Font = Enum.Font.GothamBold; NameLabel.TextSize = 14; NameLabel.TextXAlignment = Enum.TextXAlignment.Left; NameLabel.Parent = TabBtn
	local TabFrame = Instance.new("ScrollingFrame"); TabFrame.Size = UDim2.new(1, -20, 1, -20); TabFrame.Position = UDim2.new(0, 10, 0, 10); TabFrame.BackgroundTransparency = 1; TabFrame.Visible = false; TabFrame.ScrollBarThickness = 0; TabFrame.CanvasSize = UDim2.new(0,0,3,0); TabFrame.Parent = Container
	Tabs[name] = TabFrame; Buttons[name] = TabBtn
	BindTheme(Indicator, "BackgroundColor3")
	BindTheme(TabBtn, "BackgroundColor3", nil, nil, false, true) -- micro tint
	
	TabBtn.MouseButton1Click:Connect(function()
		for n, tab in pairs(Tabs) do
			tab.Visible = false; local btn = Buttons[n]; 
			TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.45}):Play()
			btn:FindFirstChild("Indicator").Visible = false
			TweenService:Create(btn:FindFirstChild("NameLabel"), TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100), Position = UDim2.new(0, 60, 0, 0)}):Play()
			
			if n == "Settings" then
			    UnbindTheme(btn:FindFirstChild("Icon"), "ImageColor3")
			end
			TweenService:Create(btn:FindFirstChild("Icon"), TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Color3.fromRGB(100, 100, 100)}):Play()
		end
		TabFrame.Visible = true; 
		TweenService:Create(TabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1}):Play()
		Indicator.Visible = true; Indicator.Size = UDim2.new(0,0,0,0)
		TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 4, 0, 24)}):Play()
		TweenService:Create(NameLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(220, 220, 220), Position = UDim2.new(0, 65, 0, 0)}):Play()
		TweenService:Create(Icon, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageColor3 = Config.Settings.UIColor}):Play()
		if name == "Settings" then
		    BindTheme(Icon, "ImageColor3")
		end
	end)
	
	TabBtn.MouseEnter:Connect(function()
		if not TabFrame.Visible then
			TweenService:Create(TabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25}):Play()
			TweenService:Create(NameLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150), Position = UDim2.new(0, 65, 0, 0)}):Play()
		end
	end)
	TabBtn.MouseLeave:Connect(function()
		if not TabFrame.Visible then
			TweenService:Create(TabBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.45}):Play()
			TweenService:Create(NameLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100), Position = UDim2.new(0, 60, 0, 0)}):Play()
		end
	end)
	
	return TabFrame
end

local function CreateCard(parent, title, iconId, x, y, w, h, toggleSection, toggleKey)
	local Card = Instance.new("Frame"); Card.Size = UDim2.new(0, w, 0, h); Card.Position = UDim2.new(0, x, 0, y); Card.BackgroundColor3 = Color3.fromRGB(16, 16, 16); Card.BackgroundTransparency = 0.45; Card.Parent = parent; Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
	local TitleArea = Instance.new("Frame"); TitleArea.Size = UDim2.new(1, 0, 0, 40); TitleArea.BackgroundTransparency = 1; TitleArea.Parent = Card
	local Icon = Instance.new("ImageLabel"); Icon.Size = UDim2.new(0, 16, 0, 16); Icon.Position = UDim2.new(0, 12, 0.5, -8); Icon.BackgroundTransparency = 1; Icon.Image = iconId; Icon.ImageColor3 = Color3.fromRGB(255, 30, 30); Icon.Parent = TitleArea
	local TitleLabel = Instance.new("TextLabel"); TitleLabel.Size = UDim2.new(1, -80, 1, 0); TitleLabel.Position = UDim2.new(0, 35, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = title; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 14; TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 230); TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TitleArea
	local line = Instance.new("Frame"); line.Size = UDim2.new(1, -24, 0, 1); line.Position = UDim2.new(0, 12, 1, 0); line.BackgroundColor3 = Color3.fromRGB(35, 35, 35); line.BorderSizePixel = 0; line.Parent = TitleArea
	BindTheme(Icon, "ImageColor3")
	BindTheme(Card, "BackgroundColor3", nil, nil, false, true) -- micro tint

    if toggleSection and toggleKey then
        local toggleBg = Instance.new("TextButton"); toggleBg.Text = ""; toggleBg.Size = UDim2.new(0, 34, 0, 18); toggleBg.Position = UDim2.new(1, -46, 0.5, -9); toggleBg.BackgroundColor3 = Config[toggleSection][toggleKey] and Config.Settings.UIColor or Color3.fromRGB(30, 30, 30); toggleBg.Parent = TitleArea; Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)
        local toggleKnob = Instance.new("Frame"); toggleKnob.Size = UDim2.new(0, 14, 0, 14); toggleKnob.Position = UDim2.new(Config[toggleSection][toggleKey] and 1 or 0, Config[toggleSection][toggleKey] and -16 or 2, 0.5, -7); toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); toggleKnob.Parent = toggleBg; Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)
        BindTheme(toggleBg, "BackgroundColor3", toggleSection, toggleKey)
		
        toggleBg.MouseButton1Click:Connect(function()
            Config[toggleSection][toggleKey] = not Config[toggleSection][toggleKey]
            local state = Config[toggleSection][toggleKey]
            TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = state and Config.Settings.UIColor or Color3.fromRGB(30,30,30)}):Play()
            TweenService:Create(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, -7)}):Play()
        end)
		
		toggleBg.MouseEnter:Connect(function()
			TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -47, 0.5, -10)}):Play()
		end)
		toggleBg.MouseLeave:Connect(function()
			TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -46, 0.5, -9)}):Play()
		end)
    end
	return Card
end

local function CreateCheckbox(parent, text, yPos, section, key)
	local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -24, 0, 20); Label.Position = UDim2.new(0, 12, 0, yPos); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Color3.fromRGB(160, 160, 160); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = parent
	local Btn = Instance.new("TextButton"); Btn.Text = ""; Btn.Size = UDim2.new(0, 16, 0, 16); Btn.Position = UDim2.new(1, -16, 0.5, -8); Btn.BackgroundColor3 = Config[section][key] and Config.Settings.UIColor or Color3.fromRGB(40, 40, 40); Btn.BorderSizePixel = 0; Btn.Parent = Label; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)
	local Check = Instance.new("TextLabel"); Check.Size = UDim2.new(1, 0, 1, 0); Check.BackgroundTransparency = 1; Check.Text = "✓"; Check.TextColor3 = Color3.fromRGB(255, 255, 255); Check.TextSize = 12; Check.Font = Enum.Font.GothamBold; Check.Visible = Config[section][key]; Check.Parent = Btn
	
    Btn.MouseButton1Click:Connect(function()
        Config[section][key] = not Config[section][key]
        local state = Config[section][key]
        if state then
            Check.Visible = true
            Check.TextTransparency = 1
            TweenService:Create(Check, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Config.Settings.UIColor}):Play()
        else
            TweenService:Create(Check, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
            task.delay(0.25, function() if not Config[section][key] then Check.Visible = false end end)
            TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end
    end)
	
	Btn.MouseEnter:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -17, 0.5, -9)}):Play()
		TweenService:Create(Label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
	end)
	Btn.MouseLeave:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -16, 0.5, -8)}):Play()
		TweenService:Create(Label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(160, 160, 160)}):Play()
	end)
    BindTheme(Btn, "BackgroundColor3", section, key)
end

local function CreateSlider(parent, text, yPos, min, max, section, key, isFloat, trackWidth)
	trackWidth = trackWidth or 120
	local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -24, 0, 20); Label.Position = UDim2.new(0, 12, 0, yPos); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Color3.fromRGB(160, 160, 160); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = parent
	
    local ValLabel = Instance.new("TextLabel"); ValLabel.Size = UDim2.new(0, trackWidth, 0, 15); ValLabel.Position = UDim2.new(1, -trackWidth, 0, -4); ValLabel.BackgroundTransparency = 1; ValLabel.TextColor3 = Color3.fromRGB(150,150,150); ValLabel.Font = Enum.Font.GothamBold; ValLabel.TextSize = 10; ValLabel.TextXAlignment = Enum.TextXAlignment.Right; ValLabel.Parent = Label
    local function UpdateValText(val) if isFloat then ValLabel.Text = string.format("%.3f", val) else ValLabel.Text = tostring(val) end end
    UpdateValText(Config[section][key])

	local Track = Instance.new("TextButton"); Track.Size = UDim2.new(0, trackWidth, 0, 4); Track.Position = UDim2.new(1, -trackWidth, 0.5, 4); Track.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Track.BorderSizePixel = 0; Track.Text = ""; Track.Parent = Label; local trackStroke = Instance.new("UIStroke", Track); trackStroke.Color = Color3.fromRGB(50, 50, 50); trackStroke.Thickness = 1
    local initialPercent = (Config[section][key] - min) / (max - min)
	local Fill = Instance.new("Frame"); Fill.Size = UDim2.new(0, math.floor(trackWidth * initialPercent), 1, 0); Fill.BackgroundColor3 = Config.Settings.UIColor; Fill.BorderSizePixel = 0; Fill.Parent = Track
	local Knob = Instance.new("Frame"); Knob.Size = UDim2.new(0, 8, 0, 10); Knob.Position = UDim2.new(0, math.floor(trackWidth*initialPercent) - 4, 0.5, -5); Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180); Knob.BorderSizePixel = 0; Knob.Parent = Track; Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
    BindTheme(Fill, "BackgroundColor3")

    local dragging = false
    Track.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local relX = mousePos - Track.AbsolutePosition.X
            local percent = math.clamp(relX / trackWidth, 0, 1)
            TweenService:Create(Fill, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Size = UDim2.new(0, percent * trackWidth, 1, 0)}):Play()
            TweenService:Create(Knob, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Position = UDim2.new(0, (percent * trackWidth) - 4, 0.5, -5)}):Play()
            local val = (percent * (max - min)) + min
            if not isFloat then val = math.floor(val) end
            Config[section][key] = val
            UpdateValText(val)
        end
    end)
	
	Track.MouseEnter:Connect(function()
		TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 10, 0, 12), Position = UDim2.new(0, Knob.Position.X.Offset - 1, 0.5, -6)}):Play()
		TweenService:Create(Label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	end)
	Track.MouseLeave:Connect(function()
		TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 8, 0, 10), Position = UDim2.new(0, Knob.Position.X.Offset + 1, 0.5, -5)}):Play()
		TweenService:Create(Label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(160, 160, 160)}):Play()
	end)
    return Label
end

local function CreateKeybind(parent, text, yPos, section, key)
	local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -24, 0, 20); Label.Position = UDim2.new(0, 12, 0, yPos); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Color3.fromRGB(160, 160, 160); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = parent
	local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0, key ~= "MenuKey" and 80 or 100, 0, 20); Btn.Position = UDim2.new(1, -100, 0, 0); Btn.BackgroundTransparency = 1; Btn.Text = Config[section][key] and Config[section][key].Name or "None"; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13; Btn.TextColor3 = Color3.fromRGB(120, 120, 120); Btn.TextXAlignment = Enum.TextXAlignment.Right; Btn.Parent = Label
    
    local binding = false
    Btn.MouseButton1Click:Connect(function() binding = true; Btn.Text = "..." end)
    
    if key ~= "MenuKey" then
        local ClearBtn = Instance.new("TextButton"); ClearBtn.Size = UDim2.new(0, 16, 0, 16); ClearBtn.Position = UDim2.new(1, -16, 0.5, -8); ClearBtn.BackgroundTransparency = 1; ClearBtn.Text = "X"; ClearBtn.Font = Enum.Font.GothamBold; ClearBtn.TextSize = 13; ClearBtn.TextColor3 = Color3.fromRGB(200, 50, 50); ClearBtn.Parent = Label
        ClearBtn.MouseButton1Click:Connect(function()
            Config[section][key] = nil
            Btn.Text = "None"
            binding = false
        end)
    end
    
    UserInputService.InputBegan:Connect(function(inp)
        if binding then
            if inp.UserInputType == Enum.UserInputType.Keyboard then 
                Config[section][key] = inp.KeyCode; Btn.Text = inp.KeyCode.Name
                task.delay(0.1, function() binding = false end)
            elseif inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Focus then 
                Config[section][key] = inp.UserInputType; Btn.Text = inp.UserInputType.Name
                task.delay(0.1, function() binding = false end)
            end
        end
    end)
end

local function CreateDropdown(parent, text, options, yPos, section, key)
	local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -24, 0, 20); Label.Position = UDim2.new(0, 12, 0, yPos); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Color3.fromRGB(160, 160, 160); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.ZIndex = 2; Label.Parent = parent
	local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0, 120, 0, 18); Btn.Position = UDim2.new(1, -120, 0.5, -9); Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); Btn.BorderSizePixel = 0; Btn.Text = ""; Btn.ZIndex = 2; Btn.Parent = Label; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)
	local Val = Instance.new("TextLabel"); Val.Size = UDim2.new(1, -20, 1, 0); Val.Position = UDim2.new(0, 5, 0, 0); Val.BackgroundTransparency = 1; Val.Text = Config[section][key] or options[1]; Val.Font = Enum.Font.GothamBold; Val.TextSize = 12; Val.TextColor3 = Color3.fromRGB(120, 120, 120); Val.TextXAlignment = Enum.TextXAlignment.Left; Val.ZIndex = 2; Val.Parent = Btn
	
    local DropFrame = Instance.new("ScrollingFrame")
    DropFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 20, 100))
    DropFrame.Position = UDim2.new(0, 0, 1, 0)
    DropFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    DropFrame.BorderSizePixel = 0
    DropFrame.ScrollBarThickness = 2
    DropFrame.ZIndex = 5
    DropFrame.Visible = false
    DropFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
    DropFrame.Parent = Btn
    Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 3)
    
    local listLayout = Instance.new("UIListLayout", DropFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 20)
        optBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        optBtn.BackgroundTransparency = 1
        optBtn.BorderSizePixel = 0
        optBtn.Text = "  " .. opt
        optBtn.Font = Enum.Font.GothamBold
        optBtn.TextSize = 11
        optBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.ZIndex = 6
        optBtn.Parent = DropFrame
        
        optBtn.MouseButton1Click:Connect(function()
            Config[section][key] = opt
            Val.Text = opt
            TweenService:Create(DropFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(0.25, function() DropFrame.Visible = false end)
        end)
    end
    
    Btn.MouseButton1Click:Connect(function()
        if not DropFrame.Visible then
            DropFrame.Size = UDim2.new(1, 0, 0, 0)
            DropFrame.Visible = true
            TweenService:Create(DropFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, math.min(#options * 20, 100))}):Play()
        else
            TweenService:Create(DropFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.delay(0.25, function() DropFrame.Visible = false end)
        end
    end)
	
	Btn.MouseEnter:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
		TweenService:Create(Val, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
		TweenService:Create(Label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
	end)
	Btn.MouseLeave:Connect(function()
		TweenService:Create(Btn, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
		TweenService:Create(Val, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play()
		TweenService:Create(Label, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(100, 100, 100)}):Play()
	end)
end

local function CreateColorPicker(parent, text, yPos, section, key, isUITheme)
	local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1, -24, 0, 20); Label.Position = UDim2.new(0, 12, 0, yPos); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13; Label.TextColor3 = Color3.fromRGB(100, 100, 100); Label.TextXAlignment = Enum.TextXAlignment.Left; Label.Parent = parent
	
    local trackWidth = 80
	local Track = Instance.new("TextButton"); Track.Size = UDim2.new(0, trackWidth, 0, 8); Track.Position = UDim2.new(1, -trackWidth, 0.5, -4); Track.BorderSizePixel = 0; Track.Text = ""; Track.Parent = Label; local trackStroke = Instance.new("UIStroke", Track); trackStroke.Color = Color3.fromRGB(50, 50, 50); trackStroke.Thickness = 1
	local UIGradient = Instance.new("UIGradient", Track)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })

	local Knob = Instance.new("Frame"); Knob.Size = UDim2.new(0, 6, 0, 12); Knob.Position = UDim2.new(0, 0, 0.5, -6); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Knob.BorderSizePixel = 0; Knob.Parent = Track;
    
    local function setHue(percent)
        local color = Color3.fromHSV(percent, 1, 1)
        Config[section][key] = color
        if isUITheme then UpdateTheme() end
    end

    local dragging = false
    Track.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation().X
            local relX = mousePos - Track.AbsolutePosition.X
            local percent = math.clamp(relX / trackWidth, 0, 1)
            Knob.Position = UDim2.new(0, (percent * trackWidth) - 3, 0.5, -6)
            setHue(percent)
        end
    end)
end

--// INITIALIZE TABS
local AimbotTab = CreateTab("Aimbot", 0, "rbxassetid://11162755592")
local ESPTab = CreateTab("ESP", 1, "rbxassetid://12120698352")
local MiscTab = CreateTab("Misc", 2, "rbxassetid://12120687742")
local SettingsTab = CreateTab("Settings", 3, "rbxassetid://6031280882")

Tabs["Aimbot"].Visible = true
Buttons["Aimbot"].BackgroundTransparency = 0
Buttons["Aimbot"]:FindFirstChild("Indicator").Visible = true
Buttons["Aimbot"]:FindFirstChild("NameLabel").TextColor3 = Color3.fromRGB(220, 220, 220)
Buttons["Aimbot"]:FindFirstChild("Icon").ImageColor3 = Config.Settings.UIColor

-- AIMBOT TAB SETUP
local CamCard = CreateCard(AimbotTab, "Camera Aimbot", "rbxassetid://9266631404", 0, 0, 330, 460, "Aimbot", "CamEnabled")
local MouseCard = CreateCard(AimbotTab, "Mouse Aimbot", "rbxassetid://9266631404", 350, 0, 330, 460, "Aimbot", "MouseEnabled")
local TriggerCard = CreateCard(AimbotTab, "Triggerbot", "rbxassetid://6031139156", 350, 470, 330, 130, "Aimbot", "TriggerEnabled")

local function populateAimbotCard(card, prefix)
	local y = 45; local step = 25
	CreateCheckbox(card, "Hold to Aim", y, "Aimbot", prefix.."HoldToAim"); y = y + step
	CreateKeybind(card, "Hold Key:", y, "Aimbot", prefix.."HoldKey"); y = y + step
	CreateDropdown(card, "Hitbox", {"Closest", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, y, "Aimbot", prefix.."Hitbox"); y = y + step
	y = y + 5
	CreateCheckbox(card, "Visible Check", y, "Aimbot", prefix.."Visible"); y = y + step
	CreateCheckbox(card, "Team Check", y, "Aimbot", prefix.."Team"); y = y + step
	CreateCheckbox(card, "ForceField / Grab Check", y, "Aimbot", prefix.."ForceFieldCheck"); y = y + step
    CreateCheckbox(card, "Target Bots (NPCs)", y, "Aimbot", "TargetBots"); y = y + step
	y = y + 5
	CreateSlider(card, "Field Of View", y, 10, 800, "Aimbot", prefix.."FOV", false, 120); y = y + step
	CreateSlider(card, "Smooth", y, 0.05, 1, "Aimbot", prefix.."Smooth", true, 120); y = y + step
	y = y + 5
	CreateSlider(card, "Aim Distance", y, 50, 5000, "Aimbot", prefix.."Dist", false, 120); y = y + step
	CreateCheckbox(card, "FOV Circle", y, "Aimbot", prefix.."FOVCircle"); y = y + step
	y = y + 5
	CreateCheckbox(card, "Velocity Prediction", y, "Aimbot", prefix.."Prediction"); y = y + step
	CreateSlider(card, "Prediction Power", y, 0.000, 1.000, "Aimbot", prefix.."PredPower", true, 120); y = y + step
end

populateAimbotCard(CamCard, "Cam")
populateAimbotCard(MouseCard, "Mouse")
CreateSlider(TriggerCard, "Delay (ms)", 48, 0, 1000, "Aimbot", "TriggerDelay", false, 120)
CreateCheckbox(TriggerCard, "Team Check", 80, "Aimbot", "TriggerTeamCheck")
CreateCheckbox(TriggerCard, "Target Bots (NPCs)", 105, "Aimbot", "TargetBots")

local SilentCard = CreateCard(AimbotTab, "Silent Aim", "rbxassetid://9266631404", 0, 470, 330, 150, "Aimbot", "SilentAim")
CreateDropdown(SilentCard, "Hitbox", {"Head", "Torso", "Closest"}, 48, "Aimbot", "SilentAimHitbox")
CreateSlider(SilentCard, "FOV Size", 82, 10, 800, "Aimbot", "SilentAimFOV", false, 120)
CreateCheckbox(SilentCard, "Show FOV Circle", 116, "Aimbot", "SilentAimFOVCircle")

-- ESP TAB SETUP
local ESPCard = CreateCard(ESPTab, "Player ESP", "rbxassetid://7992557358", 0, 0, 330, 470, "ESP", "Enabled")
CreateCheckbox(ESPCard, "Show Bots (NPCs)", 50, "ESP", "ShowBots")
CreateCheckbox(ESPCard, "Box", 75, "ESP", "Box")
CreateCheckbox(ESPCard, "Outline", 100, "ESP", "Outline")
CreateCheckbox(ESPCard, "Skeleton", 125, "ESP", "Skeleton")
CreateCheckbox(ESPCard, "Lines (Tracers)", 150, "ESP", "Lines")
CreateCheckbox(ESPCard, "Names", 175, "ESP", "Names")
CreateCheckbox(ESPCard, "Health Bar", 200, "ESP", "HealthBar")
CreateCheckbox(ESPCard, "2D Radar", 225, "ESP", "Radar")
CreateCheckbox(ESPCard, "Show Distance", 250, "ESP", "ShowDist")
CreateSlider(ESPCard, "Max Distance", 285, 50, 10000, "ESP", "MaxDist", false, 100)
CreateSlider(ESPCard, "Name Size", 320, 8, 32, "ESP", "NameSize", false, 100)
CreateColorPicker(ESPCard, "Visible Color", 360, "ESP", "VisColor", false)
CreateColorPicker(ESPCard, "Hidden Color", 390, "ESP", "HidColor", false)

-- MISC TAB SETUP
local MiscFlyCard = CreateCard(MiscTab, "Fly Mode", "rbxassetid://8763582733", 0, 0, 330, 120, "Misc", "FlyEnabled")
CreateKeybind(MiscFlyCard, "Fly Key", 50, "Misc", "FlyKey")
CreateSlider(MiscFlyCard, "Fly Speed", 85, 10, 500, "Misc", "FlySpeed", false, 120)

local TeleportCard = CreateCard(MiscTab, "Teleport", "rbxassetid://12941020168", 350, 0, 330, 200, nil, nil)
CreateKeybind(TeleportCard, "TP To Nearest", 45, "Misc", "TeleportKey")
CreateKeybind(TeleportCard, "TP To Farthest", 75, "Misc", "TeleportFarthestKey")

local MiscWalkCard = CreateCard(MiscTab, "Walk Module", "rbxassetid://9525534183", 0, 130, 330, 120, nil, nil)
CreateCheckbox(MiscWalkCard, "Enable Walk Speed Override", 50, "Misc", "WalkSpeed")
CreateSlider(MiscWalkCard, "Speed Value", 85, 16, 250, "Misc", "WalkSpeedVal", false, 120)

local MiscJumpCard = CreateCard(MiscTab, "Jump Module", "rbxassetid://6684647765", 0, 260, 330, 150, nil, nil)
CreateCheckbox(MiscJumpCard, "Enable Jump Power Override", 50, "Misc", "JumpPower")
CreateSlider(MiscJumpCard, "Jump Value", 85, 50, 500, "Misc", "JumpPowerVal", false, 120)
CreateCheckbox(MiscJumpCard, "Infinite Jump", 115, "Misc", "InfJump")

local MiscFovCard = CreateCard(MiscTab, "FOV Changer", "rbxassetid://81123796770252", 0, 420, 330, 90, "Misc", "FovChanger")
CreateSlider(MiscFovCard, "Field of View", 50, 20, 120, "Misc", "FovVal", false, 120)

local FlingCard = CreateCard(MiscTab, "Fling Players", "rbxassetid://11826620708", 350, 210, 330, 95, nil, nil)
CreateCheckbox(FlingCard, "Anti Fling", 45, "Fling", "AntiFling")
CreateCheckbox(FlingCard, "Walk Fling", 65, "Fling", "WalkFling")

local MiscSpinCard = CreateCard(MiscTab, "Spinbot", "rbxassetid://11769204090", 350, 315, 330, 90, "Misc", "SpinBot")
CreateSlider(MiscSpinCard, "Spin Speed", 50, 1, 100, "Misc", "SpinSpeed", false, 120)
local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, -24, 0, 85) -- Show approx 3 rows
PlayerScroll.Position = UDim2.new(0, 12, 0, 105)
PlayerScroll.BackgroundTransparency = 1
PlayerScroll.ScrollBarThickness = 2
PlayerScroll.Parent = TeleportCard

local UIGridLayout = Instance.new("UIGridLayout", PlayerScroll)
UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
UIGridLayout.CellSize = UDim2.new(0, 95, 0, 24)

local function RefreshPlayerList()
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            btn.BackgroundTransparency = 0.45
            btn.BorderSizePixel = 0
            btn.Text = "       " .. string.sub(plr.Name, 1, 8)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = PlayerScroll
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
            
            task.spawn(function()
                local success, isFriend = pcall(function() return LocalPlayer:IsFriendsWith(plr.UserId) end)
                if success and isFriend then
                    btn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
                    btn.BackgroundTransparency = 0.25
                else
                    BindTheme(btn, "BackgroundColor3", nil, nil, false, true) -- micro tint
                end
            end)
            
            pcall(function()
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(0, 16, 0, 16)
                img.Position = UDim2.new(0, 4, 0.5, -8)
                img.BackgroundTransparency = 1
                img.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                img.Parent = btn
                Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
            end)
            
            btn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3.5)
                end
            end)
            count = count + 1
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(count / 3) * 29)
end

RefreshPlayerList()
Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(RefreshPlayerList)


-- SETTINGS TAB SETUP
local SettingsCard = CreateCard(SettingsTab, "Menu Setup", "rbxassetid://6031280882", 0, 0, 330, 120, nil, nil)
CreateKeybind(SettingsCard, "Menu Toggle Key", 50, "Settings", "MenuKey")
CreateColorPicker(SettingsCard, "UI Color Theme", 80, "Settings", "UIColor", true)

-- Init Theme Colors
UpdateTheme()

-- Cleanup ESP on Leave
Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        local objs = ESPObjects[plr]
        if objs.Highlight then objs.Highlight:Destroy() end
        if Drawing then
            if objs.Box then objs.Box:Remove() end
            if objs.Text then objs.Text:Remove() end
            if objs.Line then objs.Line:Remove() end
            if objs.HealthBg then objs.HealthBg:Remove() end
            if objs.HealthBar then objs.HealthBar:Remove() end
            for _, l in pairs(objs.Skel) do l:Remove() end
        end
        if objs.RadarDot then objs.RadarDot:Destroy() end
        ESPObjects[plr] = nil
    end
end)
end

--// KEY SYSTEM UI
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "NullDefenseKeySystem"
KeyGui.ResetOnSpawn = false
pcall(function() KeyGui.Parent = CoreGui end)
if not KeyGui.Parent then KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 400, 0, 250)
Main.Position = UDim2.new(0.5, -200, 0.5, -125)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Main.BorderSizePixel = 0
Main.Parent = KeyGui
Main.Active = true
Main.Draggable = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 8)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(30, 30, 30)
MainStroke.Thickness = 1

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "NullDefense | Key System"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(220, 220, 220)
Title.Parent = Main

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -40, 0, 60)
Info.Position = UDim2.new(0, 20, 0, 40)
Info.BackgroundTransparency = 1
Info.Text = "Join the Discord for the key!"
Info.Font = Enum.Font.GothamBold
Info.TextSize = 14
Info.TextColor3 = Color3.fromRGB(150, 150, 150)
Info.TextWrapped = true
Info.Parent = Main

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Size = UDim2.new(1, -60, 0, 25)
GetKeyBtn.Position = UDim2.new(0, 30, 0, 95)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GetKeyBtn.BorderSizePixel = 0
GetKeyBtn.Text = "Get Key (Click to Copy Discord)"
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 12
GetKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
GetKeyBtn.AutoButtonColor = false
GetKeyBtn.Parent = Main

local GetKeyCorner = Instance.new("UICorner", GetKeyBtn)
GetKeyCorner.CornerRadius = UDim.new(0, 6)

local GetKeyStroke = Instance.new("UIStroke", GetKeyBtn)
GetKeyStroke.Color = Color3.fromRGB(35, 35, 35)
GetKeyStroke.Thickness = 1

GetKeyBtn.MouseEnter:Connect(function()
    TweenService:Create(GetKeyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
    TweenService:Create(GetKeyStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(50, 50, 50)}):Play()
end)

GetKeyBtn.MouseLeave:Connect(function()
    TweenService:Create(GetKeyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}):Play()
    TweenService:Create(GetKeyStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(35, 35, 35)}):Play()
end)

GetKeyBtn.MouseButton1Click:Connect(function()
    local oldText = GetKeyBtn.Text
    local success, err = pcall(function()
        if setclipboard then
            setclipboard(DISCORD_LINK)
            GetKeyBtn.Text = "Copied to Clipboard!"
        else
            GetKeyBtn.Text = "Executor doesn't support clipboard"
        end
    end)
    if not success then GetKeyBtn.Text = "Error copying!" end
    
    task.delay(1.5, function()
        GetKeyBtn.Text = oldText
    end)
end)

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -60, 0, 40)
KeyBox.Position = UDim2.new(0, 30, 0, 130)
KeyBox.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
KeyBox.BorderSizePixel = 0
KeyBox.Text = ""
KeyBox.PlaceholderText = "Enter Key Here..."
KeyBox.Font = Enum.Font.GothamBold
KeyBox.TextSize = 14
KeyBox.TextColor3 = Color3.fromRGB(220, 220, 220)
KeyBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
KeyBox.Parent = Main

local BoxCorner = Instance.new("UICorner", KeyBox)
BoxCorner.CornerRadius = UDim.new(0, 6)

local BoxStroke = Instance.new("UIStroke", KeyBox)
BoxStroke.Color = Color3.fromRGB(35, 35, 35)
BoxStroke.Thickness = 1

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(1, -60, 0, 40)
VerifyBtn.Position = UDim2.new(0, 30, 0, 170)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
VerifyBtn.BorderSizePixel = 0
VerifyBtn.Text = "Verify Key"
VerifyBtn.Font = Enum.Font.GothamBlack
VerifyBtn.TextSize = 16
VerifyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
VerifyBtn.AutoButtonColor = false
VerifyBtn.Parent = Main

local BtnCorner = Instance.new("UICorner", VerifyBtn)
BtnCorner.CornerRadius = UDim.new(0, 6)

local BtnStroke = Instance.new("UIStroke", VerifyBtn)
BtnStroke.Color = Color3.fromRGB(40, 40, 40)
BtnStroke.Thickness = 1

-- Smooth Effects
VerifyBtn.MouseEnter:Connect(function()
    TweenService:Create(VerifyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    TweenService:Create(BtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(60, 60, 60)}):Play()
end)

VerifyBtn.MouseLeave:Connect(function()
    TweenService:Create(VerifyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
    TweenService:Create(BtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Color3.fromRGB(40, 40, 40)}):Play()
end)

local function Notify(msg, col)
    local oldText = VerifyBtn.Text
    VerifyBtn.Text = msg
    local oldCol = VerifyBtn.TextColor3
    VerifyBtn.TextColor3 = col
    task.delay(1.5, function()
        VerifyBtn.Text = oldText
        VerifyBtn.TextColor3 = oldCol
    end)
end

VerifyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == KEY_TO_VERIFY then
        Notify("Correct!", Color3.fromRGB(0, 255, 100))
        task.wait(0.5)
        
        -- Smooth Fade Out
        local tInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        for _, obj in pairs(Main:GetDescendants()) do
            if obj:IsA("GuiObject") then
                if obj:IsA("TextLabel") or obj:IsA("TextBox") or obj:IsA("TextButton") then
                    TweenService:Create(obj, tInfo, {TextTransparency = 1}):Play()
                end
                if obj:IsA("ImageLabel") then
                    TweenService:Create(obj, tInfo, {ImageTransparency = 1}):Play()
                end
                TweenService:Create(obj, tInfo, {BackgroundTransparency = 1}):Play()
            elseif obj:IsA("UIStroke") then
                TweenService:Create(obj, tInfo, {Transparency = 1}):Play()
            end
        end
        TweenService:Create(Main, tInfo, {BackgroundTransparency = 1, Size = UDim2.new(0, 380, 0, 230), Position = UDim2.new(0.5, -190, 0.5, -115)}):Play()
        
        task.wait(0.5)
        KeyGui:Destroy()
        LoadHUB()
    else
        Notify("Invalid Key", Color3.fromRGB(255, 50, 50))
    end
end)
