

    local DEBUG = false

    if DEBUG then
        getfenv().getfenv = function()
            return setmetatable({}, { __index = function() return function() return true end end })
        end
    end


    --! Services

    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")


    --! Colour Handler

    local function PackColour(Colour)
        return typeof(Colour) == "Color3" and { R = Colour.R * 255, G = Colour.G * 255, B = Colour.B * 255 } or typeof(Colour) == "table" and Colour or { R = 255, G = 255, B = 255 }
    end

    local function UnpackColour(Colour)
        return typeof(Colour) == "table" and Color3.fromRGB(Colour.R, Colour.G, Colour.B) or typeof(Colour) == "Color3" and Colour or Color3.fromRGB(255, 255, 255)
    end


    --! Importing Configuration

    local ImportedConfiguration = {}

    pcall(function()
        if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile(string.format("%s.ttwizz", game.GameId)) and getfenv().readfile(string.format("%s.ttwizz", game.GameId)) then
            ImportedConfiguration = HttpService:JSONDecode(getfenv().readfile(string.format("%s.ttwizz", game.GameId)))
            for Key, Value in next, ImportedConfiguration do
                if Key == "FoVColour" or Key == "ESPColour" then
                    ImportedConfiguration[Key] = UnpackColour(Value)
                end
            end
        end
    end)


    --! Initializing Configuration

    local Configuration = {}

    --? Aimbot

    Configuration.Aimbot = ImportedConfiguration["Aimbot"] or false
    Configuration.OnePressAimingMode = ImportedConfiguration["OnePressAimingMode"] or false
    Configuration.UseMouseMoving = ImportedConfiguration["UseMouseMoving"] or false
    Configuration.AimKey = ImportedConfiguration["AimKey"] or "RMB"
    Configuration.AimPartDropdownValues = ImportedConfiguration["AimPartDropdownValues"] or { "Head", "HumanoidRootPart" }
    Configuration.AimPart = ImportedConfiguration["AimPart"] or "HumanoidRootPart"
    Configuration.RandomAimPart = ImportedConfiguration["RandomAimPart"] or false
    Configuration.UseOffset = ImportedConfiguration["UseOffset"] or false
    Configuration.OffsetType = ImportedConfiguration["OffsetType"] or "Static"
    Configuration.StaticOffsetIncrement = ImportedConfiguration["StaticOffsetIncrement"] or 10
    Configuration.DynamicOffsetIncrement = ImportedConfiguration["DynamicOffsetIncrement"] or 10
    Configuration.AutoOffset = ImportedConfiguration["AutoOffset"] or false
    Configuration.MaxAutoOffset = ImportedConfiguration["MaxAutoOffset"] or 50
    Configuration.UseSensitivity = ImportedConfiguration["UseSensitivity"] or false
    Configuration.Sensitivity = ImportedConfiguration["Sensitivity"] or 100
    Configuration.UseNoise = ImportedConfiguration["UseNoise"] or false
    Configuration.TriggerBot = ImportedConfiguration["TriggerBot"] or false
    Configuration.OnePressTriggeringMode = ImportedConfiguration["OnePressTriggeringMode"] or false
    Configuration.SmartTriggerBot = ImportedConfiguration["SmartTriggerBot"] or false
    Configuration.TriggerKey = ImportedConfiguration["TriggerKey"] or "V"
    Configuration.TeamCheck = ImportedConfiguration["TeamCheck"] or false
    Configuration.FriendCheck = ImportedConfiguration["FriendCheck"] or false
    Configuration.WallCheck = ImportedConfiguration["WallCheck"] or false
    Configuration.WaterCheck = ImportedConfiguration["WaterCheck"] or false
    Configuration.FoVCheck = ImportedConfiguration["FoVCheck"] or false
    Configuration.FoVRadius = ImportedConfiguration["FoVRadius"] or 100
    Configuration.MagnitudeCheck = ImportedConfiguration["MagnitudeCheck"] or false
    Configuration.TriggerMagnitude = ImportedConfiguration["TriggerMagnitude"] or 500
    Configuration.TransparencyCheck = ImportedConfiguration["TransparencyCheck"] or false
    Configuration.IgnoredTransparency = ImportedConfiguration["IgnoredTransparency"] or 0.5
    Configuration.WhitelistedGroupCheck = ImportedConfiguration["WhitelistedGroupCheck"] or false
    Configuration.WhitelistedGroup = ImportedConfiguration["WhitelistedGroup"] or 0
    Configuration.BlacklistedGroupCheck = ImportedConfiguration["BlacklistedGroupCheck"] or false
    Configuration.BlacklistedGroup = ImportedConfiguration["BlacklistedGroup"] or 0
    Configuration.IgnoredPlayersCheck = ImportedConfiguration["IgnoredPlayersCheck"] or false
    Configuration.IgnoredPlayersDropdownValues = ImportedConfiguration["IgnoredPlayersDropdownValues"] or {}
    Configuration.IgnoredPlayers = ImportedConfiguration["IgnoredPlayers"] or {}
    Configuration.TargetPlayersCheck = ImportedConfiguration["TargetPlayersCheck"] or false
    Configuration.TargetPlayersDropdownValues = ImportedConfiguration["TargetPlayersDropdownValues"] or {}
    Configuration.TargetPlayers = ImportedConfiguration["TargetPlayers"] or {}

    --? Visuals

    Configuration.ShowFoV = ImportedConfiguration["ShowFoV"] or false
    Configuration.FoVThickness = ImportedConfiguration["FoVThickness"] or 2
    Configuration.FoVTransparency = ImportedConfiguration["FoVTransparency"] or 0.8
    Configuration.FoVColour = ImportedConfiguration["FoVColour"] or Color3.fromRGB(255, 255, 255)
    Configuration.SmartESP = ImportedConfiguration["SmartESP"] or false
    Configuration.ESPBox = ImportedConfiguration["ESPBox"] or false
    Configuration.NameESP = ImportedConfiguration["NameESP"] or false
    Configuration.NameESPSize = ImportedConfiguration["NameESPSize"] or 16
    Configuration.TracerESP = ImportedConfiguration["TracerESP"] or false
    Configuration.ESPThickness = ImportedConfiguration["ESPThickness"] or 2
    Configuration.ESPTransparency = ImportedConfiguration["ESPTransparency"] or 0.8
    Configuration.ESPColour = ImportedConfiguration["ESPColour"] or Color3.fromRGB(255, 255, 255)
    Configuration.ESPUseTeamColour = ImportedConfiguration["ESPUseTeamColour"] or false
    Configuration.RainbowVisuals = ImportedConfiguration["RainbowVisuals"] or false


    --! Constants

    local Player = Players.LocalPlayer
    local Mouse = Player:GetMouse()


    --! Name Handler

    local function GetFullName(String)
        if String and #String >= 3 and #String <= 20 then
            for _, _Player in next, Players:GetPlayers() do
                if string.sub(string.lower(_Player.Name), 1, #string.lower(String)) == string.lower(String) then
                    return _Player.Name
                end
            end
            return ""
        else
            return ""
        end
    end


    --! Fields

    local Fluent = nil
    local ShowWarning = false
    local MouseSensitivity = UserInputService.MouseDeltaSensitivity
    local Aiming = false
    local Triggering = false
    local Target = nil
    local Tween = nil

    if typeof(script) == "Instance" and script:FindFirstChild("Fluent") then
        Fluent = require(script:FindFirstChild("Fluent"))
    else
        local Success, Result = pcall(function()
            return game:HttpGet("https://twix.cyou/Fluent.txt", true)
        end)
        if Success and typeof(Result) == "string" and string.find(Result, "dawid") then
            Fluent = getfenv().loadstring(game:HttpGet("https://twix.cyou/Fluent.txt", true))()
        else
            Fluent = getfenv().loadstring(game:HttpGet("https://ttwizz.pages.dev/Fluent.txt", true))()
        end
    end



    --! Interface Manager

    local UISettings = {
        TabWidth = 160,
        Size = { 580, 460 },
        Theme = "Amethyst",
        Acrylic = false,
        Transparency = true,
        MinimizeKey = "RightShift",
        ShowNotifications = true,
        ShowWarnings = true
    }

    local InterfaceManager = {}

    function InterfaceManager:ImportSettings()
        pcall(function()
            if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().isfile("UISettings.ttwizz") and getfenv().readfile("UISettings.ttwizz") then
                for Key, Value in next, HttpService:JSONDecode(getfenv().readfile("UISettings.ttwizz")) do
                    UISettings[Key] = Value
                end
            end
        end)
    end

    function InterfaceManager:ExportSettings()
        pcall(function()
            if not DEBUG and getfenv().isfile and getfenv().readfile and getfenv().writefile then
                getfenv().writefile("UISettings.ttwizz", HttpService:JSONEncode(UISettings))
            end
        end)
    end

    InterfaceManager:ImportSettings()

    UISettings.__LAST_RUN__ = os.date()
    InterfaceManager:ExportSettings()


    --! Initializing UI

    do
        local Window = Fluent:CreateWindow({
            Title = "BlackCat48",
            SubTitle = "Arsenal",
            TabWidth = UISettings.TabWidth,
            Size = UDim2.fromOffset(table.unpack(UISettings.Size)),
            Theme = UISettings.Theme,
            Acrylic = UISettings.Acrylic,
            MinimizeKey = UISettings.MinimizeKey
        })
        local Tabs = { MAIN = Window:AddTab({ Title = "Discord", Icon = "layout-grid" }) }
        local DiscordWikiSection = Tabs.MAIN:AddSection("Discord")
        if getfenv().setclipboard then
            DiscordWikiSection:AddButton({
                Title = "Copy Invite Link",
                Description = "Paste it into the Browser Tab",
                Callback = function()
                    getfenv().setclipboard("SOON")
                    Window:Dialog({
                        Title = "BlackCat48",
                        Content = "Invite Link has been copied to the Clipboard!",
                        Buttons = {
                            {
                                Title = "Confirm"
                            }
                        }
                    })
                end
            })
        end

        Tabs.Aimbot = Window:AddTab({ Title = "Combat", Icon = "crosshair" })
        Window:SelectTab(1)

        

        local AimbotSection = Tabs.Aimbot:AddSection("Aimbot")

    

        local AimbotToggle = AimbotSection:AddToggle("AimbotToggle", { Title = "Aimbot Toggle", Description = "Toggles the Aimbot", Default = Configuration.Aimbot })
        AimbotToggle:OnChanged(function(Value)
            Configuration.Aimbot = Value
        end)

        local OnePressAimingModeToggle = AimbotSection:AddToggle("OnePressAimingModeToggle", { Title = "One-Press Mode", Description = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressAimingMode })
        OnePressAimingModeToggle:OnChanged(function(Value)
            Configuration.OnePressAimingMode = Value
        end)

        if getfenv().mousemoverel then
            local UseMouseMovingToggle = AimbotSection:AddToggle("UseMouseMovingToggle", { Title = "Use Mouse Moving", Description = "Uses the Mouse Moving instead of the Camera Moving", Default = Configuration.UseMouseMoving })
            UseMouseMovingToggle:OnChanged(function(Value)
                Configuration.UseMouseMoving = Value
            end)
        else
            ShowWarning = true
        end

        local AimKeybind = AimbotSection:AddKeybind("AimKeybind", {
            Title = "Aim Key",
            Description = "Changes the Aim Key",
            Mode = "Hold",
            Default = Configuration.AimKey,
            ChangedCallback = function(Value)
                Configuration.AimKey = Value
            end
        })
        if AimKeybind.Value == "RMB" then
            Configuration.AimKey = Enum.UserInputType.MouseButton2
        else
            Configuration.AimKey = Enum.KeyCode[AimKeybind.Value]
        end

        local AimPartDropdown = AimbotSection:AddDropdown("AimPartDropdown", {
            Title = "Aim Part",
            Description = "Changes the Aim Part",
            Values = Configuration.AimPartDropdownValues,
            Multi = false,
            Default = Configuration.AimPart,
            Callback = function(Value)
                Configuration.AimPart = Value
            end
        })
        task.spawn(function()
            while task.wait(1) do
                if not Fluent then
                    break
                end
                if Configuration.RandomAimPart and #Configuration.AimPartDropdownValues > 0 then
                    AimPartDropdown:SetValue(Configuration.AimPartDropdownValues[math.random(1, #Configuration.AimPartDropdownValues)])
                end
            end
        end)

        local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "Random Aim Part", Description = "Selects every second a Random Aim Part from Dropdown", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(Value)
            Configuration.RandomAimPart = Value
        end)
        local AimbotSection = Tabs.Aimbot:AddSection("Kill All")
        local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "Kill All", Description = "Kill All", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(bool)
        getgenv().AutoFarm = bool

        local runServiceConnection
        local mouseDown = false
        local player = game.Players.LocalPlayer
        local camera = game.Workspace.CurrentCamera

        game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = bool and "Infinite Ammo" or ""

        function getClosestEnemyPlayer()
            local closestDistance = math.huge
            local closestPlayer = nil

            for _, enemyPlayer in pairs(game.Players:GetPlayers()) do
                if enemyPlayer ~= player and enemyPlayer.TeamColor ~= player.TeamColor and enemyPlayer.Character then
                    local character = enemyPlayer.Character
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoidRootPart and humanoid and humanoid.Health > 0 then
                        local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if distance < closestDistance and humanoidRootPart.Position.Y >= 0 then
                            closestDistance = distance
                            closestPlayer = enemyPlayer
                        end
                    end
                end
            end

            return closestPlayer
        end

        local function startAutoFarm()
            game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 12

            runServiceConnection = game:GetService("RunService").Stepped:Connect(function()
                if getgenv().AutoFarm then
                    local closestPlayer = getClosestEnemyPlayer()
                    if closestPlayer then
                        local targetPosition = closestPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, -4)
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPlayer.Character.Head.Position)

                            if not mouseDown then
                                mouse1press()
                                mouseDown = true
                            end
                        end
                    else
                        if mouseDown then
                            mouse1release()
                            mouseDown = false
                        end
                    end
                else
                    if runServiceConnection then
                        runServiceConnection:Disconnect()
                        runServiceConnection = nil
                    end
                    if mouseDown then
                        mouse1release()
                        mouseDown = false
                    end
                end
            end)
        end

        local function onCharacterAdded(character)
            wait(0.5)
            startAutoFarm()
        end

        player.CharacterAdded:Connect(onCharacterAdded)

        if bool then
            wait(0.5)
            startAutoFarm()
        else
            game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = ""
            getgenv().AutoFarm = false
            game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 1
            if runServiceConnection then
                runServiceConnection:Disconnect()
                runServiceConnection = nil
            end
            if mouseDown then
                mouse1release()
                mouseDown = false
            end
        end

        end)
        











 local AimbotSection = Tabs.Aimbot:AddSection("Chat")

    local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "IsChad", Description = "IsChad", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(x)
        if game.Players.LocalPlayer:FindFirstChild('IsChad') then
        game.Players.LocalPlayer.IsChad:Destroy()
        return
    end
        if x then
    local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
    IsMod.Name = "IsChad"
    end

        end)

    local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "VIP", Description = "VIP", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(x)
        if game.Players.LocalPlayer:FindFirstChild('VIP') then
        game.Players.LocalPlayer.VIP:Destroy()
        return
    end
    
    if x then
    local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
    IsMod.Name = "VIP"
    end

        end)



    local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "OldVIP", Description = "OldVIP", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(x)
        if game.Players.LocalPlayer:FindFirstChild('OldVIP') then
        game.Players.LocalPlayer.OldVIP:Destroy()
        return
    end
        if x then
    local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
    IsMod.Name = "OldVIP"
    end

        end)



        local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "Romin", Description = "Romin", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(x)
        if game.Players.LocalPlayer:FindFirstChild('Romin') then
        game.Players.LocalPlayer.Romin:Destroy()
        return
    end
        if x then
    local IsAdmin = Instance.new('IntValue', game.Players.LocalPlayer)
    IsAdmin.Name = "Romin"
    end

        end)




        local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "IsAdmin", Description = "IsAdmin", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(x)
        if game.Players.LocalPlayer:FindFirstChild('IsAdmin') then
        game.Players.LocalPlayer.IsAdmin:Destroy()
        return
    end
        if x then
    local IsAdmin = Instance.new('IntValue', game.Players.LocalPlayer)
    IsAdmin.Name = "IsAdmin"
    end

        end)












local SettingsInfinite = false
 local RandomAimPartToggle = AimbotSection:AddToggle("RandomAimPartToggle", { Title = "Infinite Ammo", Description = "Infinite Ammo", Default = Configuration.RandomAimPart })
        RandomAimPartToggle:OnChanged(function(K)
         SettingsInfinite = K
    if SettingsInfinite then
        game:GetService("RunService").Stepped:connect(function()
            pcall(function()
                if SettingsInfinite then
                    local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
                    playerGui.GUI.Client.Variables.ammocount.Value = 99
                    playerGui.GUI.Client.Variables.ammocount2.Value = 99
                end
            end)
        end)
    end
        end)
























































        


        if getfenv().mouse1click then
            Tabs.TriggerBot = Window:AddTab({ Title = "TriggerBot", Icon = "target" })

            local TriggerBotSection = Tabs.TriggerBot:AddSection("TriggerBot")

            local TriggerBotToggle = TriggerBotSection:AddToggle("TriggerBotToggle", { Title = "TriggerBot Toggle", Description = "Toggles the TriggerBot", Default = Configuration.TriggerBot })
            TriggerBotToggle:OnChanged(function(Value)
                Configuration.TriggerBot = Value
            end)

            local OnePressTriggeringModeToggle = TriggerBotSection:AddToggle("OnePressTriggeringModeToggle", { Title = "One-Press Mode", Description = "Uses the One-Press Mode instead of the Holding Mode", Default = Configuration.OnePressTriggeringMode })
            OnePressTriggeringModeToggle:OnChanged(function(Value)
                Configuration.OnePressTriggeringMode = Value
            end)

            local SmartTriggerBotToggle = TriggerBotSection:AddToggle("SmartTriggerBotToggle", { Title = "Smart TriggerBot", Description = "Uses the TriggerBot only when Aiming", Default = Configuration.SmartTriggerBot })
            SmartTriggerBotToggle:OnChanged(function(Value)
                Configuration.SmartTriggerBot = Value
            end)

            local TriggerKeybind = TriggerBotSection:AddKeybind("TriggerKeybind", {
                Title = "Trigger Key",
                Description = "Changes the Trigger Key",
                Mode = "Hold",
                Default = Configuration.TriggerKey,
                ChangedCallback = function(Value)
                    Configuration.TriggerKey = Value
                end
            })
            if TriggerKeybind.Value == "RMB" then
                Configuration.TriggerKey = Enum.UserInputType.MouseButton2
            else
                Configuration.TriggerKey = Enum.KeyCode[TriggerKeybind.Value]
            end
        else
            ShowWarning = true
        end

        Tabs.Checks = Window:AddTab({ Title = "Checks", Icon = "list-checks" })

        local SimpleChecksSection = Tabs.Checks:AddSection("Simple Checks")

        local TeamCheckToggle = SimpleChecksSection:AddToggle("TeamCheckToggle", { Title = "Team Check", Description = "Toggles the Team Check", Default = Configuration.TeamCheck })
        TeamCheckToggle:OnChanged(function(Value)
            Configuration.TeamCheck = Value
        end)

        local FriendCheckToggle = SimpleChecksSection:AddToggle("FriendCheckToggle", { Title = "Friend Check", Description = "Toggles the Friend Check", Default = Configuration.FriendCheck })
        FriendCheckToggle:OnChanged(function(Value)
            Configuration.FriendCheck = Value
        end)

        local WallCheckToggle = SimpleChecksSection:AddToggle("WallCheckToggle", { Title = "Wall Check", Description = "Toggles the Wall Check", Default = Configuration.WallCheck })
        WallCheckToggle:OnChanged(function(Value)
            Configuration.WallCheck = Value
        end)

        local WaterCheckToggle = SimpleChecksSection:AddToggle("WaterCheckToggle", { Title = "Water Check", Description = "Toggles the Water Check if Wall Check is enabled", Default = Configuration.WaterCheck })
        WaterCheckToggle:OnChanged(function(Value)
            Configuration.WaterCheck = Value
        end)

        local AdvancedChecksSection = Tabs.Checks:AddSection("Advanced Checks")

        local FoVCheckToggle = AdvancedChecksSection:AddToggle("FoVCheckToggle", { Title = "FoV Check", Description = "Toggles the FoV Check", Default = Configuration.FoVCheck })
        FoVCheckToggle:OnChanged(function(Value)
            Configuration.FoVCheck = Value
        end)

        AdvancedChecksSection:AddSlider("FoVRadiusSlider", {
            Title = "FoV Radius",
            Description = "Changes the FoV Radius",
            Default = Configuration.FoVRadius,
            Min = 10,
            Max = 1000,
            Rounding = 1,
            Callback = function(Value)
                Configuration.FoVRadius = Value
            end
        })

        local MagnitudeCheckToggle = AdvancedChecksSection:AddToggle("MagnitudeCheckToggle", { Title = "Magnitude Check", Description = "Toggles the Magnitude Check", Default = Configuration.MagnitudeCheck })
        MagnitudeCheckToggle:OnChanged(function(Value)
            Configuration.MagnitudeCheck = Value
        end)

        AdvancedChecksSection:AddSlider("TriggerMagnitudeSlider", {
            Title = "Trigger Magnitude",
            Description = "Distance between the Native and the Target Character",
            Default = Configuration.TriggerMagnitude,
            Min = 10,
            Max = 1000,
            Rounding = 1,
            Callback = function(Value)
                Configuration.TriggerMagnitude = Value
            end
        })

        local TransparencyCheckToggle = AdvancedChecksSection:AddToggle("TransparencyCheckToggle", { Title = "Transparency Check", Description = "Toggles the Transparency Check", Default = Configuration.TransparencyCheck })
        TransparencyCheckToggle:OnChanged(function(Value)
            Configuration.TransparencyCheck = Value
        end)

        AdvancedChecksSection:AddSlider("IgnoredTransparencySlider", {
            Title = "Ignored Transparency",
            Description = "Target is ignored if its Transparency is > than / = to the set one",
            Default = Configuration.IgnoredTransparency,
            Min = 0.1,
            Max = 1,
            Rounding = 1,
            Callback = function(Value)
                Configuration.IgnoredTransparency = Value
            end
        })

        local WhitelistedGroupCheckToggle = AdvancedChecksSection:AddToggle("WhitelistedGroupCheckToggle", { Title = "Whitelisted Group Check", Description = "Toggles the Whitelisted Group Check", Default = Configuration.WhitelistedGroupCheck })
        WhitelistedGroupCheckToggle:OnChanged(function(Value)
            Configuration.WhitelistedGroupCheck = Value
        end)

        AdvancedChecksSection:AddInput("WhitelistedGroupInput", {
            Title = "Whitelisted Group",
            Description = "After typing, press Enter",
            Default = Configuration.WhitelistedGroup,
            Numeric = true,
            Finished = true,
            Placeholder = "Group Id",
            Callback = function(Value)
                Configuration.WhitelistedGroup = #Value > 0 and Value or 0
            end
        })

        local BlacklistedGroupCheckToggle = AdvancedChecksSection:AddToggle("BlacklistedGroupCheckToggle", { Title = "Blacklisted Group Check", Description = "Toggles the Blacklisted Group Check", Default = Configuration.BlacklistedGroupCheck })
        BlacklistedGroupCheckToggle:OnChanged(function(Value)
            Configuration.BlacklistedGroupCheck = Value
        end)

        AdvancedChecksSection:AddInput("BlacklistedGroupInput", {
            Title = "Blacklisted Group",
            Description = "After typing, press Enter",
            Default = Configuration.BlacklistedGroup,
            Numeric = true,
            Finished = true,
            Placeholder = "Group Id",
            Callback = function(Value)
                Configuration.BlacklistedGroup = #Value > 0 and Value or 0
            end
        })
        if getfenv().Drawing then
            Tabs.Visuals = Window:AddTab({ Title = "Visuals", Icon = "view" })
            local FoVSection = Tabs.Visuals:AddSection("FoV")

            local ShowFoVToggle = FoVSection:AddToggle("ShowFoVToggle", { Title = "Show FoV", Description = "Toggles the FoV Show", Default = Configuration.ShowFoV })
            ShowFoVToggle:OnChanged(function(Value)
                Configuration.ShowFoV = Value
            end)

            FoVSection:AddSlider("FoVThicknessSlider", {
                Title = "FoV Thickness",
                Description = "Changes the FoV Thickness",
                Default = Configuration.FoVThickness,
                Min = 1,
                Max = 10,
                Rounding = 1,
                Callback = function(Value)
                    Configuration.FoVThickness = Value
                end
            })

            FoVSection:AddSlider("FoVTransparencySlider", {
                Title = "FoV Transparency",
                Description = "Changes the FoV Transparency",
                Default = Configuration.FoVTransparency,
                Min = 0.1,
                Max = 1,
                Rounding = 1,
                Callback = function(Value)
                    Configuration.FoVTransparency = Value
                end
            })

            local FoVColourPicker = FoVSection:AddColorpicker("FoVColourPicker", {
                Title = "FoV Colour",
                Description = "Changes the FoV Colour",
                Transparency = 0,
                Default = Configuration.FoVColour,
                Callback = function(Value)
                    Configuration.FoVColour = Value
                end
            })

            local ESPSection = Tabs.Visuals:AddSection("ESP")

            local SmartESPToggle = ESPSection:AddToggle("SmartESPToggle", { Title = "Smart ESP", Description = "Does not ESP the Whitelisted Players", Default = Configuration.SmartESP })
            SmartESPToggle:OnChanged(function(Value)
                Configuration.SmartESP = Value
            end)

            local ESPBoxToggle = ESPSection:AddToggle("ESPBoxToggle", { Title = "ESP Box", Description = "Creates the ESP Box around the Players", Default = Configuration.ESPBox })
            ESPBoxToggle:OnChanged(function(Value)
                Configuration.ESPBox = Value
            end)

            local NameESPToggle = ESPSection:AddToggle("NameESPToggle", { Title = "Name ESP", Description = "Creates the Name ESP above the Players", Default = Configuration.NameESP })
            NameESPToggle:OnChanged(function(Value)
                Configuration.NameESP = Value
            end)

            ESPSection:AddSlider("NameESPSizeSlider", {
                Title = "Name ESP Size",
                Description = "Changes the Name ESP Size",
                Default = Configuration.NameESPSize,
                Min = 8,
                Max = 28,
                Rounding = 1,
                Callback = function(Value)
                    Configuration.NameESPSize = Value
                end
            })

            local TracerESPToggle = ESPSection:AddToggle("TracerESPToggle", { Title = "Tracer ESP", Description = "Creates the Tracer ESP in the direction of the Players", Default = Configuration.TracerESP })
            TracerESPToggle:OnChanged(function(Value)
                Configuration.TracerESP = Value
            end)

            ESPSection:AddSlider("ESPThicknessSlider", {
                Title = "ESP Thickness",
                Description = "Changes the ESP Thickness",
                Default = Configuration.ESPThickness,
                Min = 1,
                Max = 10,
                Rounding = 1,
                Callback = function(Value)
                    Configuration.ESPThickness = Value
                end
            })

            ESPSection:AddSlider("ESPTransparencySlider", {
                Title = "ESP Transparency",
                Description = "Changes the ESP Transparency",
                Default = Configuration.ESPTransparency,
                Min = 0.1,
                Max = 1,
                Rounding = 1,
                Callback = function(Value)
                    Configuration.ESPTransparency = Value
                end
            })

            local ESPColourPicker = ESPSection:AddColorpicker("ESPColourPicker", {
                Title = "ESP Colour",
                Description = "Changes the ESP Colour",
                Transparency = 0,
                Default = Configuration.ESPColour,
                Callback = function(Value)
                    Configuration.ESPColour = Value
                end
            })

            local ESPUseTeamColourToggle = ESPSection:AddToggle("ESPUseTeamColourToggle", { Title = "Use Team Colour", Description = "Makes the ESP Colour match the Target Player Team", Default = Configuration.ESPUseTeamColour })
            ESPUseTeamColourToggle:OnChanged(function(Value)
                Configuration.ESPUseTeamColour = Value
            end)

            local VisualsSection = Tabs.Visuals:AddSection("Visuals")

            local RainbowVisualsToggle = VisualsSection:AddToggle("RainbowVisualsToggle", { Title = "Rainbow Visuals", Description = "Makes the Visuals Rainbow", Default = Configuration.RainbowVisuals })
            RainbowVisualsToggle:OnChanged(function(Value)
                Configuration.RainbowVisuals = Value
            end)
            task.spawn(function()
                while task.wait() do
                    for Index = 1, 230 do
                        if not Fluent then
                            break
                        elseif Configuration.RainbowVisuals then
                            FoVColourPicker:SetValue({ Index / 230, 1, 1 }, FoVColourPicker.Transparency)
                            ESPColourPicker:SetValue({ Index / 230, 1, 1 }, ESPColourPicker.Transparency)
                        end
                        task.wait()
                    end
                end
            end)
        else
            ShowWarning = true
        end


        Tabs.player = Window:AddTab({ Title = "Player", Icon = "bot" })
        Tabs.player:AddButton({
            Title = "FLY/e",
            Description = "Press e and it turns off, press it again and it turns on",
            Callback = function()
                repeat 
                    wait() 
                until game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:findFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character:findFirstChild("Humanoid")
                
                local mouse = game.Players.LocalPlayer:GetMouse() 
                repeat 
                    wait() 
                until mouse
                
                local plr = game.Players.LocalPlayer 
                local torso = plr.Character.HumanoidRootPart 
                local flying = true
                local deb = true 
                local ctrl = {f = 0, b = 0, l = 0, r = 0} 
                local lastctrl = {f = 0, b = 0, l = 0, r = 0} 
                local maxspeed = 50 
                local speed = 0 
                
                function Fly() 
                    local bg = Instance.new("BodyGyro", torso) 
                    bg.P = 9e4 
                    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) 
                    bg.cframe = torso.CFrame 
                    local bv = Instance.new("BodyVelocity", torso) 
                    bv.velocity = Vector3.new(0,0.1,0) 
                    bv.maxForce = Vector3.new(9e9, 9e9, 9e9) 
                    repeat 
                        wait() 
                        plr.Character.Humanoid.PlatformStand = true 
                        if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then 
                            speed = speed + .5 + (speed / maxspeed) 
                            if speed > maxspeed then 
                                speed = maxspeed 
                            end 
                        elseif not (ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0) and speed ~= 0 then 
                            speed = speed - 1 
                            if speed < 0 then 
                                speed = 0 
                            end 
                        end 
                        if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then 
                            bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed 
                            lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r} 
                        elseif (ctrl.l + ctrl.r) == 0 and (ctrl.f + ctrl.b) == 0 and speed ~= 0 then 
                            bv.velocity = ((game.Workspace.CurrentCamera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((game.Workspace.CurrentCamera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * .2, 0).p) - game.Workspace.CurrentCamera.CoordinateFrame.p)) * speed 
                        else 
                            bv.velocity = Vector3.new(0,0.1,0) 
                        end 
                        bg.cframe = game.Workspace.CurrentCamera.CoordinateFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0) 
                    until not flying 
                    ctrl = {f = 0, b = 0, l = 0, r = 0} 
                    lastctrl = {f = 0, b = 0, l = 0, r = 0} 
                    speed = 0 
                    bg:Destroy() 
                    bv:Destroy() 
                    plr.Character.Humanoid.PlatformStand = false 
                end 
                
                mouse.KeyDown:connect(function(key) 
                    if key:lower() == "e" then 
                        if flying then 
                            flying = false 
                        else 
                            flying = true 
                            Fly() 
                        end 
                    elseif key:lower() == "w" then 
                        ctrl.f = 1 
                    elseif key:lower() == "s" then 
                        ctrl.b = -1 
                    elseif key:lower() == "a" then 
                        ctrl.l = -1 
                    elseif key:lower() == "d" then 
                        ctrl.r = 1 
                    end 
                end) 
                
                mouse.KeyUp:connect(function(key) 
                    if key:lower() == "w" then 
                        ctrl.f = 0 
                    elseif key:lower() == "s" then 
                        ctrl.b = 0 
                    elseif key:lower() == "a" then 
                        ctrl.l = 0 
                    elseif key:lower() == "d" then 
                        ctrl.r = 0 
                    end 
                end)
                
                Fly()
            end
        })






        

        Tabs.player:AddButton({
            Title = "İnfinite Ammo",
            Description = "Do not press more than 1, the game may crash or break",
            Callback = function()
                while wait() do
                    game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount.Value = 999
                    game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount2.Value = 999
                end
            end
        })











        
        Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
        local UISection = Tabs.Settings:AddSection("UI")

        UISection:AddDropdown("ThemeDropdown", {
            Title = "Theme",
            Description = "Changes the UI Theme",
            Values = Fluent.Themes,
            Default = Fluent.Theme,
            Callback = function(Value)
                Fluent:SetTheme(Value)
                UISettings.Theme = Value
                InterfaceManager:ExportSettings()
            end
        })

        if Fluent.UseAcrylic then
            UISection:AddToggle("AcrylicToggle", {
                Title = "Acrylic",
                Description = "Blurred Background requires Graphic Quality >= 8",
                Default = Fluent.Acrylic,
                Callback = function(Value)
                    if not Value or not UISettings.ShowWarnings then
                        Fluent:ToggleAcrylic(Value)
                    elseif UISettings.ShowWarnings then
                        Window:Dialog({
                            Title = "Warning",
                            Content = "This Option can be detected! Activate it anyway?",
                            Buttons = {
                                {
                                    Title = "Confirm",
                                    Callback = function()
                                        Fluent:ToggleAcrylic(Value)
                                    end
                                },
                                {
                                    Title = "Cancel",
                                    Callback = function()
                                        Fluent.Options.AcrylicToggle:SetValue(false)
                                    end
                                }
                            }
                        })
                    end
                end
            })
        end

        UISection:AddToggle("TransparencyToggle", {
            Title = "Transparency",
            Description = "Makes the UI Transparent",
            Default = UISettings.Transparency,
            Callback = function(Value)
                Fluent:ToggleTransparency(Value)
                UISettings.Transparency = Value
                InterfaceManager:ExportSettings()
            end
        })

        UISection:AddKeybind("MinimizeKeybind", {
            Title = "Minimize Key",
            Description = "Changes the Minimize Key",
            Default = Fluent.MinimizeKey,
            ChangedCallback = function(Value)
                UISettings.MinimizeKey = Value ~= Enum.UserInputType.MouseButton2 and UserInputService:GetStringForKeyCode(Value) or "RMB"
                InterfaceManager:ExportSettings()
            end
        })
        Fluent.MinimizeKeybind = Fluent.Options.MinimizeKeybind

        local NotificationsSection = Tabs.Settings:AddSection("Notifications")

        local NotificationsToggle = NotificationsSection:AddToggle("NotificationsToggle", { Title = "Show Notifications", Description = "Toggles the Notifications Show", Default = UISettings.ShowNotifications })
        NotificationsToggle:OnChanged(function(Value)
            Fluent.ShowNotifications = Value
            UISettings.ShowNotifications = Value
            InterfaceManager:ExportSettings()
        end)

        local WarningsToggle = NotificationsSection:AddToggle("WarningsToggle", { Title = "Show Warnings", Description = "Toggles the Security Warnings Show", Default = UISettings.ShowWarnings })
        WarningsToggle:OnChanged(function(Value)
            UISettings.ShowWarnings = Value
            InterfaceManager:ExportSettings()
        end)

        if getfenv().isfile and getfenv().readfile and getfenv().writefile and getfenv().delfile then
        end


        if UISettings.ShowWarnings then
            if DEBUG then
                Window:Dialog({
                    Title = "Warning",
                    Content = "Running in Debugging Mode. Some Features may not work properly.",
                    Buttons = {
                        {
                            Title = "Confirm"
                        }
                    }
                })
            elseif ShowWarning then
                Window:Dialog({
                    Title = "Warning",
                    Content = "Your Software does not support all the Features of !",
                    Buttons = {
                        {
                            Title = "Confirm"
                        }
                    }
                })
            end
        end
    end


    --! Notification Handler

    local function Notify(Message)
        if Fluent and Message then
            Fluent:Notify({
                Title = "BlackCat48",
                Content = Message,
                SubContent = "BlackCat48",
                Duration = 1.5
            })
        end
    end

    Notify("Successfully initialized!")


    --! Resetting Fields

    local function ResetAimbotFields(SaveAiming, SaveTarget)
        Aiming = SaveAiming and Aiming or false
        Target = SaveTarget and Target or nil
        if Tween then
            Tween:Cancel()
            Tween = nil
        end
        UserInputService.MouseDeltaSensitivity = MouseSensitivity
    end


    --! Binding Key

    local InputBegan; InputBegan = UserInputService.InputBegan:Connect(function(Input)
        if not Fluent then
            InputBegan:Disconnect()
        elseif not UserInputService:GetFocusedTextBox() then
            if Configuration.Aimbot and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
                if Aiming then
                    ResetAimbotFields()
                    Notify("[Aiming Mode]: OFF")
                else
                    Aiming = true
                    Notify("[Aiming Mode]: ON")
                end
            elseif Configuration.TriggerBot and (Input.KeyCode == Configuration.TriggerKey or Input.UserInputType == Configuration.TriggerKey) then
                if Triggering then
                    Triggering = false
                    Notify("[Triggering Mode]: OFF")
                else
                    Triggering = true
                    Notify("[Triggering Mode]: ON")
                end
            end
        end
    end)

    local InputEnded; InputEnded = UserInputService.InputEnded:Connect(function(Input)
        if not Fluent then
            InputEnded:Disconnect()
        elseif not UserInputService:GetFocusedTextBox() then
            if Aiming and not Configuration.OnePressAimingMode and (Input.KeyCode == Configuration.AimKey or Input.UserInputType == Configuration.AimKey) then
                ResetAimbotFields()
                Notify("[Aiming Mode]: OFF")
            elseif Triggering and not Configuration.OnePressTriggeringMode and (Input.KeyCode == Configuration.TriggerKey or Input.UserInputType == Configuration.TriggerKey) then
                Triggering = false
                Notify("[Triggering Mode]: OFF")
            end
        end
    end)


    --! Checking Target

    local function IsReady(Target)
        if Target and Target:FindFirstChildWhichIsA("Humanoid") and Target:FindFirstChildWhichIsA("Humanoid").Health > 0 and not Target:FindFirstChildWhichIsA("ForceField") and Configuration.AimPart and Target:FindFirstChild(Configuration.AimPart) and Target:FindFirstChild(Configuration.AimPart):IsA("BasePart") and Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid") and Player.Character:FindFirstChildWhichIsA("Humanoid").Health > 0 and Player.Character:FindFirstChild(Configuration.AimPart) and Player.Character:FindFirstChild(Configuration.AimPart):IsA("BasePart") then
            local _Player = Players:GetPlayerFromCharacter(Target)
            if _Player == Player then
                return false
            end
            local TargetPart = Target:FindFirstChild(Configuration.AimPart)
            local NativePart = Player.Character:FindFirstChild(Configuration.AimPart)
            if Configuration.TeamCheck and _Player.TeamColor == Player.TeamColor then
                return false
            elseif Configuration.FriendCheck and _Player:IsFriendsWith(Player.UserId) then
                return false
            elseif Configuration.WallCheck then
                local RayDirection = (TargetPart.Position - NativePart.Position).Unit * (TargetPart.Position - NativePart.Position).Magnitude
                local RaycastParameters = RaycastParams.new()
                RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
                RaycastParameters.FilterDescendantsInstances = { Player.Character }
                RaycastParameters.IgnoreWater = not Configuration.WaterCheck
                local RaycastResult = workspace:Raycast(NativePart.Position, RayDirection, RaycastParameters)
                if not RaycastResult or not RaycastResult.Instance or not RaycastResult.Instance:FindFirstAncestor(_Player.Name) then
                    return false
                end
            elseif Configuration.MagnitudeCheck and (TargetPart.Position - NativePart.Position).Magnitude > Configuration.TriggerMagnitude then
                return false
            elseif Configuration.TransparencyCheck and Target:FindFirstChild("Head") and Target:FindFirstChild("Head"):IsA("BasePart") and Target:FindFirstChild("Head").Transparency >= Configuration.IgnoredTransparency then
                return false
            elseif Configuration.WhitelistedGroupCheck and _Player:IsInGroup(Configuration.WhitelistedGroup) or Configuration.BlacklistedGroupCheck and not _Player:IsInGroup(Configuration.BlacklistedGroup) then
                return false
            elseif Configuration.IgnoredPlayersCheck and table.find(Configuration.IgnoredPlayers, _Player.Name) or Configuration.TargetPlayersCheck and not table.find(Configuration.TargetPlayers, _Player.Name) then
                return false
            end
            local OffsetIncrement = Configuration.UseOffset and (Configuration.AutoOffset and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 1000 <= Configuration.MaxAutoOffset and TargetPart.Position.Y * Configuration.StaticOffsetIncrement * (TargetPart.Position - NativePart.Position).Magnitude / 1000 or Configuration.MaxAutoOffset, 0) + Target:FindFirstChildWhichIsA("Humanoid").MoveDirection * Configuration.DynamicOffsetIncrement / 10 or Configuration.OffsetType == "Static" and Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement / 10, 0) or Configuration.OffsetType == "Dynamic" and Target:FindFirstChildWhichIsA("Humanoid").MoveDirection * Configuration.DynamicOffsetIncrement / 10 or Vector3.new(0, TargetPart.Position.Y * Configuration.StaticOffsetIncrement / 10, 0) + Target:FindFirstChildWhichIsA("Humanoid").MoveDirection * Configuration.DynamicOffsetIncrement / 10) or Vector3.zero
            local NoiseFrequency = Configuration.UseNoise and Vector3.new(math.random(0.5, 1), math.random(0.5, 1), math.random(0.5, 1)) or Vector3.zero
            return true, Target, { workspace.CurrentCamera:WorldToViewportPoint(TargetPart.Position + OffsetIncrement + NoiseFrequency) }, TargetPart.Position + OffsetIncrement + NoiseFrequency
        else
            return false
        end
    end


    --! TriggerBot Handler

    local function HandleTriggerBot()
        if not DEBUG and Fluent and getfenv().mouse1click and Triggering and (Configuration.SmartTriggerBot and Aiming or not Configuration.SmartTriggerBot) and Mouse.Target and IsReady(Mouse.Target.Parent) then
            getfenv().mouse1click()
        end
    end


    --! Visuals Handler

    local function Visualize(Object)
        if DEBUG or not Fluent or not getfenv().Drawing or not Object then
            return nil
        elseif string.lower(Object) == "fov" then
            local FoV = getfenv().Drawing.new("Circle")
            FoV.Visible = false
            if FoV.ZIndex then
                FoV.ZIndex = 2
            end
            FoV.Filled = false
            FoV.NumSides = 1000
            FoV.Radius = Configuration.FoVRadius
            FoV.Thickness = Configuration.FoVThickness
            FoV.Transparency = Configuration.FoVTransparency
            FoV.Color = Configuration.FoVColour
            return FoV
        elseif string.lower(Object) == "espbox" then
            local ESPBox = getfenv().Drawing.new("Square")
            ESPBox.Visible = false
            if ESPBox.ZIndex then
                ESPBox.ZIndex = 1
            end
            ESPBox.Filled = false
            ESPBox.Thickness = Configuration.ESPThickness
            ESPBox.Transparency = Configuration.ESPTransparency
            ESPBox.Color = Configuration.ESPColour
            return ESPBox
        elseif string.lower(Object) == "nameesp" then
            local NameESP = getfenv().Drawing.new("Text")
            NameESP.Visible = false
            if NameESP.ZIndex then
                NameESP.ZIndex = 1
            end
            NameESP.Center = true
            NameESP.Outline = true
            NameESP.Size = Configuration.NameESPSize
            NameESP.Transparency = Configuration.ESPTransparency
            NameESP.Color = Configuration.ESPColour
            return NameESP
        elseif string.lower(Object) == "traceresp" then
            local TracerESP = getfenv().Drawing.new("Line")
            TracerESP.Visible = false
            if TracerESP.ZIndex then
                TracerESP.ZIndex = 1
            end
            TracerESP.Thickness = Configuration.ESPThickness
            TracerESP.Transparency = Configuration.ESPTransparency
            TracerESP.Color = Configuration.ESPColour
            return TracerESP
        else
            return nil
        end
    end

    local Visuals = { FoV = Visualize("FoV") }

    local function ClearVisual(Visual, Key)
        local FoundVisual = table.find(Visuals, Visual)
        if Visual and (FoundVisual or Key and Key == "FoV") then
            if Visual.Destroy then
                Visual:Destroy()
            elseif Visual.Remove then
                Visual:Remove()
            end
            if FoundVisual then
                table.remove(Visuals, FoundVisual)
            elseif Key and Key == "FoV" then
                Visuals["FoV"] = nil
            end
        end
    end

    local function ClearVisuals()
        for Key, Visual in next, Visuals do
            ClearVisual(Visual, Key)
        end
    end

    local function VisualizeFoV()
        if not Fluent then
            return ClearVisuals()
        end
        local MouseLocation = UserInputService:GetMouseLocation()
        Visuals.FoV.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
        Visuals.FoV.Radius = Configuration.FoVRadius
        Visuals.FoV.Thickness = Configuration.FoVThickness
        Visuals.FoV.Transparency = Configuration.FoVTransparency
        Visuals.FoV.Color = Configuration.FoVColour
        Visuals.FoV.Visible = Configuration.ShowFoV
    end


    --! ESP Library

    local ESPLibrary = {}

    function ESPLibrary:Initialize(Target)
        if not Fluent then
            ClearVisuals()
            return nil
        elseif not Target then
            return nil
        end
        local self = setmetatable({}, { __index = ESPLibrary })
        self.Player = Players:GetPlayerFromCharacter(Target)
        self.Character = Target
        self.ESPBox = Visualize("ESPBox")
        self.NameESP = Visualize("NameESP")
        self.TracerESP = Visualize("TracerESP")
        table.insert(Visuals, self.ESPBox)
        table.insert(Visuals, self.NameESP)
        table.insert(Visuals, self.TracerESP)
        local Head = self.Character:FindFirstChild("Head")
        local HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
        if Head and Head:IsA("BasePart") and HumanoidRootPart and HumanoidRootPart:IsA("BasePart") and Humanoid then
            local IsCharacterReady = true
            if Configuration.SmartESP then
                IsCharacterReady = IsReady(self.Character)
            end
            local HumanoidRootPartPosition, IsInViewport = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
            local TopPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
            local BottomPosition = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
            if IsInViewport then
                self.ESPBox.Size = Vector2.new(2350 / HumanoidRootPartPosition.Z, TopPosition.Y - BottomPosition.Y)
                self.ESPBox.Position = Vector2.new(HumanoidRootPartPosition.X - self.ESPBox.Size.X / 2, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
                self.NameESP.Text = string.format("@%s | %s HP | %s studs", self.Player.Name, tostring(math.round(Humanoid.Health)), Player.Character and Player.Character:FindFirstChild("Head") and Player.Character:FindFirstChild("Head"):IsA("BasePart") and tostring(math.round((Head.Position - Player.Character:FindFirstChild("Head").Position).Magnitude)) or "N/A")
                self.NameESP.Position = Vector2.new(HumanoidRootPartPosition.X, (HumanoidRootPartPosition.Y + self.ESPBox.Size.Y / 2) - 25)
                self.TracerESP.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                self.TracerESP.To = Vector2.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
                if Configuration.ESPUseTeamColour and not Configuration.RainbowVisuals then
                    local TeamColour = self.Player.TeamColor.Color
                    self.ESPBox.Color = TeamColour
                    self.NameESP.Color = TeamColour
                    self.TracerESP.Color = TeamColour
                end
            end
            self.ESPBox.Visible = Configuration.ESPBox and IsCharacterReady and IsInViewport
            self.NameESP.Visible = Configuration.NameESP and IsCharacterReady and IsInViewport
            self.TracerESP.Visible = Configuration.TracerESP and IsCharacterReady and IsInViewport
        end
        return self
    end

    function ESPLibrary:Visualize()
        if not Fluent then
            return ClearVisuals()
        elseif not self.Character then
            return self:Disconnect()
        end
        local Head = self.Character:FindFirstChild("Head")
        local HumanoidRootPart = self.Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = self.Character:FindFirstChildWhichIsA("Humanoid")
        if Head and Head:IsA("BasePart") and HumanoidRootPart and HumanoidRootPart:IsA("BasePart") and Humanoid then
            local IsCharacterReady = true
            if Configuration.SmartESP then
                IsCharacterReady = IsReady(self.Character)
            end
            local HumanoidRootPartPosition, IsInViewport = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position)
            local TopPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
            local BottomPosition = workspace.CurrentCamera:WorldToViewportPoint(HumanoidRootPart.Position - Vector3.new(0, 3, 0))
            if IsInViewport then
                self.ESPBox.Size = Vector2.new(2350 / HumanoidRootPartPosition.Z, TopPosition.Y - BottomPosition.Y)
                self.ESPBox.Position = Vector2.new(HumanoidRootPartPosition.X - self.ESPBox.Size.X / 2, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
                self.ESPBox.Thickness = Configuration.ESPThickness
                self.ESPBox.Transparency = Configuration.ESPTransparency
                self.NameESP.Text = string.format("@%s | %s HP | %s studs", self.Player.Name, tostring(math.round(Humanoid.Health)), Player.Character and Player.Character:FindFirstChild("Head") and Player.Character:FindFirstChild("Head"):IsA("BasePart") and tostring(math.round((Head.Position - Player.Character:FindFirstChild("Head").Position).Magnitude)) or "N/A")
                self.NameESP.Size = Configuration.NameESPSize
                self.NameESP.Transparency = Configuration.ESPTransparency
                self.NameESP.Position = Vector2.new(HumanoidRootPartPosition.X, (HumanoidRootPartPosition.Y + self.ESPBox.Size.Y / 2) - 25)
                self.TracerESP.Thickness = Configuration.ESPThickness
                self.TracerESP.Transparency = Configuration.ESPTransparency
                self.TracerESP.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                self.TracerESP.To = Vector2.new(HumanoidRootPartPosition.X, HumanoidRootPartPosition.Y - self.ESPBox.Size.Y / 2)
                if Configuration.ESPUseTeamColour and not Configuration.RainbowVisuals then
                    local TeamColour = self.Player.TeamColor.Color
                    self.ESPBox.Color = TeamColour
                    self.NameESP.Color = TeamColour
                    self.TracerESP.Color = TeamColour
                else
                    self.ESPBox.Color = Configuration.ESPColour
                    self.NameESP.Color = Configuration.ESPColour
                    self.TracerESP.Color = Configuration.ESPColour
                end
            end
            self.ESPBox.Visible = Configuration.ESPBox and IsCharacterReady and IsInViewport
            self.NameESP.Visible = Configuration.NameESP and IsCharacterReady and IsInViewport
            self.TracerESP.Visible = Configuration.TracerESP and IsCharacterReady and IsInViewport
        else
            self.ESPBox.Visible = false
            self.NameESP.Visible = false
            self.TracerESP.Visible = false
        end
    end

    function ESPLibrary:Disconnect()
        self.Player = nil
        self.Character = nil
        ClearVisual(self.ESPBox)
        ClearVisual(self.NameESP)
        ClearVisual(self.TracerESP)
    end


    --! Tracking Handler

    local Tracking = {}
    local Connections = {}

    local function VisualizeESP()
        for _, Tracked in next, Tracking do
            Tracked:Visualize()
        end
    end

    local function DisconnectTracking(Key)
        if Key and Tracking[Key] then
            Tracking[Key]:Disconnect()
            table.remove(Tracking, Key)
        end
    end

    local function DisconnectConnection(Key)
        if Key and Connections[Key] then
            for _, Connection in next, Connections[Key] do
                Connection:Disconnect()
            end
            table.remove(Connections, Key)
        end
    end

    local function DisconnectConnections()
        for Key, _ in next, Connections do
            DisconnectConnection(Key)
        end
        for Key, _ in next, Tracking do
            DisconnectTracking(Key)
        end
    end

    local function DisconnectAimbot()
        ResetAimbotFields()
        Triggering = false
        DisconnectConnections()
        ClearVisuals()
    end

    local function CharacterAdded(_Character)
        if _Character then
            local _Player = Players:GetPlayerFromCharacter(_Character)
            Tracking[_Player.UserId] = ESPLibrary:Initialize(_Character)
        end
    end

    local function CharacterRemoving(_Character)
        if _Character then
            for Key, Tracked in next, Tracking do
                if Tracked.Character == _Character then
                    DisconnectTracking(Key)
                end
            end
        end
    end

    local function InitializePlayers()
        if not DEBUG and getfenv().Drawing then
            for _, _Player in next, Players:GetPlayers() do
                if _Player ~= Player and _Player.Character then
                    local _Character = _Player.Character
                    CharacterAdded(_Character)
                    Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded), _Player.CharacterRemoving:Connect(CharacterRemoving) }
                end
            end
        end
    end

    task.spawn(InitializePlayers)


    --! Player Events

    local OnTeleport; OnTeleport = Player.OnTeleport:Connect(function()
        if DEBUG or not Fluent or not getfenv().queue_on_teleport then
            OnTeleport:Disconnect()
        else
            getfenv().queue_on_teleport("getfenv().loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ttwizz/Open-Aimbot/master/source.lua\", true))()")
            OnTeleport:Disconnect()
        end
    end)

    local PlayerAdded; PlayerAdded = Players.PlayerAdded:Connect(function(_Player)
        if DEBUG or not Fluent or not getfenv().Drawing then
            PlayerAdded:Disconnect()
        elseif _Player ~= Player then
            Connections[_Player.UserId] = { _Player.CharacterAdded:Connect(CharacterAdded), _Player.CharacterRemoving:Connect(CharacterRemoving) }
        end
    end)

    local PlayerRemoving; PlayerRemoving = Players.PlayerRemoving:Connect(function(_Player)
        if Fluent then
            if _Player == Player then
                Fluent:Destroy()
                DisconnectAimbot()
                PlayerRemoving:Disconnect()
            else
                DisconnectConnection(_Player.UserId)
                DisconnectTracking(_Player.UserId)
            end
        else
            PlayerRemoving:Disconnect()
        end
    end)


    --! Aimbot Loop

    local AimbotLoop; AimbotLoop = RunService.RenderStepped:Connect(function()
        if Fluent.Unloaded then
            Fluent = nil
            DisconnectAimbot()
            AimbotLoop:Disconnect()
        elseif not Configuration.Aimbot then
            ResetAimbotFields()
        elseif not Configuration.TriggerBot then
            Triggering = false
        end
        HandleTriggerBot()
        if not DEBUG and getfenv().Drawing then
            VisualizeFoV()
            VisualizeESP()
        end
        if Aiming then
            local OldTarget = Target
            local Closest = math.huge
            if not IsReady(OldTarget) then
                for _, _Player in next, Players:GetPlayers() do
                    local IsCharacterReady, Character, PartViewportPosition = IsReady(_Player.Character)
                    if IsCharacterReady and PartViewportPosition[2] then
                        local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(PartViewportPosition[1].X, PartViewportPosition[1].Y)).Magnitude
                        if Magnitude <= Closest and Magnitude <= (Configuration.FoVCheck and Configuration.FoVRadius or Closest) then
                            Target = Character
                            Closest = Magnitude
                        end
                    end
                end
            end
            local IsTargetReady, _, PartViewportPosition, PartWorldPosition = IsReady(Target)
            if IsTargetReady then
                if not DEBUG and getfenv().mousemoverel and Configuration.UseMouseMoving then
                    if PartViewportPosition[2] then
                        ResetAimbotFields(true, true)
                        local MouseLocation = UserInputService:GetMouseLocation()
                        local Sensitivity = Configuration.UseSensitivity and Configuration.Sensitivity / 10 or 10
                        getfenv().mousemoverel((PartViewportPosition[1].X - MouseLocation.X) / Sensitivity, (PartViewportPosition[1].Y - MouseLocation.Y) / Sensitivity)
                    else
                        ResetAimbotFields(true)
                    end
                else
                    UserInputService.MouseDeltaSensitivity = 0
                    if Configuration.UseSensitivity then
                        Tween = TweenService:Create(workspace.CurrentCamera, TweenInfo.new(math.clamp(Configuration.Sensitivity, 9, 99) / 100, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition) })
                        Tween:Play()
                    else
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, PartWorldPosition)
                    end
                end
            else
                ResetAimbotFields(true)
            end
        end
    end)
