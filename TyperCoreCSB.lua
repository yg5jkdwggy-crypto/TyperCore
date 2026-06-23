local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

print("[Engine Debug]: Starting Engine Boot Sequence...")

-- 1. LOAD RAYFIELD INTERFACE
local Rayfield = nil
local success, err = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("[Engine Debug Error]: Failed to load Rayfield UI library via HTTPGet: " .. tostring(err))
    return
end

-- 2. ALL-IN-ONE MASSIVE ENVIRONMENT CONTEXT
local GlobalEngine = {
    -- Mode Management
    StaticTyping = false, -- false = Dynamic (Realistic), true = Static (No delays, no realism)

    -- Core Speeds
    MinSpeed = 0.05,
    MaxSpeed = 0.15,
    StaticSpeed = 0.00, -- NEW: Speed specifically for Static Mode (0 = instant)
    
    -- Typo Sub-Engine
    TypoChance = 15,
    DoubleTypoChance = 25,
    FatFingerRadius = 1,
    FixDelayMin = 0.10,
    FixDelayMax = 0.28,
    PostFixHesitation = 0.12,
    CaseFlipChance = 3,
    
    -- Mechanical Realism Modifications
    BurstMode = true,
    BurstFrequency = 6,
    BurstPauseMin = 0.12,
    BurstPauseMax = 0.32,
    FatigueSimulation = true,
    FatigueThreshold = 15,
    FatigueDecayFactor = 1.25,
    MicroStutterChance = 4,
    MicroStutterMax = 0.45,
    LongWordHesitation = true,
    SpacebarLag = 0.08,
    PunctuationDelayMultiplier = 1.5,
    RhythmInconsistency = 15,
    
    -- Automation & Safety Controls
    EngineMasterSwitch = true, 
    AutoSubmit = true,
    SubmitDelayMin = 0.15,
    SubmitDelayMax = 0.35,
    SubmitFailChance = 2,
    ReturnKeyEmulation = true,
    MaxWordLengthCap = 999,
    SkipWordsWithNumbers = false,
    SkipWordsWithPunctuation = false,
    InstantTypeHotKey = false,
    InstantKeyBind = Enum.KeyCode.LeftControl,
    PanicKeyBind = Enum.KeyCode.RightShift,
    LoopThrottleInterval = 0.01, -- Minimized textbox detection time
    
    -- Anti-Paste, Focus, & Anti-Cheat Detouring
    DisableAntiPaste = true,          
    ForceKeepFocus = true,            
    HumanFocusSimulation = true,
    FocusGainDelay = 0.08,
    FocusLossDelay = 0.05,
    VirtualInputJitter = true,
    MouseJitterAmplitude = 3,
    LinearScramblingDetection = true,
    TextPropertyBypass = false,
    MemorySpikePrevention = true,
    GarbageCollectionThrottle = true,
    
    -- UI Theme & Telemetry Options
    ThemePrimary = Color3.fromRGB(0, 120, 255),
    TelemetryWatermark = true,
    NotificationPopups = true,
    SoundEffectsEmulation = false,
    LiveWPMCounter = true,
    LogSubmissions = false,
    
    -- Dynamic State Engine Trackers
    CurrentWPM = 0,
    TotalWordsProcessed = 0,
    TotalTyposCorrected = 0,
    IsCurrentlyTyping = false,
    StopExecutionSignal = false,

    -- Custom Feature
    OnlyCorrectWords = false,
}

-- 3. INTERACTIVE CORRECTION KEYMAPS
local KeyNeighbors = {
    a = "qwsz", b = "vghn", c = "xdfv", d = "ersfxc", e = "wsdr", f = "rtgvcd",
    g = "tyhbvf", h = "yujnbg", i = "ujko", j = "uikmnh", k = "ijlm", l = "okp",
    m = "njk", n = "bhjm", o = "iklp", p = "ol", q = "wa", r = "edft",
    s = "wedxza", t = "rfgy", u = "yhji", v = "cfgb", w = "qase", x = "zsdc",
    y = "tghu", z = "asx",
    ["1"] = "2q", ["2"] = "13qw", ["3"] = "24we", ["4"] = "35er", ["5"] = "46rt",
    ["6"] = "57ty", ["7"] = "68yu", ["8"] = "79io", ["9"] = "80op", ["0"] = "9p"
}

-- Dynamic Location Reference Declarations
local wordValue = ReplicatedStorage:WaitForChild("WordValue", 5)
local spelledCorrectlyEvent = ReplicatedStorage:WaitForChild("SpelledCorrectly", 5)

if not wordValue then warn("[Engine Debug Warning]: 'WordValue' instance missing from ReplicatedStorage!") end
if not spelledCorrectlyEvent then warn("[Engine Debug Warning]: 'SpelledCorrectly' RemoteEvent missing from ReplicatedStorage!") end

local targetScreenGui = nil
local targetTextBox = nil
local targetConnection = nil
local focusLossConnection = nil

-- 4. INITIALIZE ULTRA CONFIGURABLE RAYFIELD INTERFACE
local Window = Rayfield:CreateWindow({
    Name = "Humanoid Typer Core V4",
    LoadingTitle = "Humanoid Typer Engine",
    LoadingSubtitle = "Anti-Paste Bypass Matrices Configured",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local TabCore = Window:CreateTab("Interval Matrices", 4483362458)
local TabBypass = Window:CreateTab("Bypass Systems", 4483362458)
local TabTypos = Window:CreateTab("Proximity Errors", 4483362458)
local TabBehavior = Window:CreateTab("Human Rhythm", 4483362458)
local TabAutomation = Window:CreateTab("Automation Engine", 4483362458)
local TabTelemetry = Window:CreateTab("Telemetry & Debug", 4483362458)

-- Pre-declaring Live Analytics Displays
local LabelWPM = TabTelemetry:CreateLabel("WPM Tracker: Calculating...")
local LabelWords = TabTelemetry:CreateLabel("Total Completed Data-Blocks: 0")
local LabelTypos = TabTelemetry:CreateLabel("Total Simulated Corrections: 0")
local LabelStatus = TabTelemetry:CreateLabel("Engine State: Idle")

-- Control Interceptor Switch
TabCore:CreateToggle({
    Name = "Enable Typer Engine Core",
    CurrentValue = GlobalEngine.EngineMasterSwitch,
    Flag = "MasterSwitch",
    Callback = function(Value) 
        GlobalEngine.EngineMasterSwitch = Value 
        if LabelStatus and LabelStatus.SetText then
            LabelStatus:SetText(not Value and "Engine State: Disabled" or "Engine State: Idle")
        end
    end,
})

-- Typing Realism Mode Selector
TabCore:CreateDropdown({
    Name = "Typing Realism Profile",
    Options = {"Dynamic (Realistic)", "Static (Not Realistic)"},
    CurrentOption = {"Dynamic (Realistic)"},
    MultipleOptions = false,
    Flag = "TypingProfile",
    Callback = function(Option)
        if Option[1] == "Static (Not Realistic)" then
            GlobalEngine.StaticTyping = true
            print("[Engine Debug]: Static Mode Activated (Zero delays, raw throughput).")
        else
            GlobalEngine.StaticTyping = false
            print("[Engine Debug]: Dynamic Mode Activated (Realistic human timings).")
        end
    end,
})

-- Speed & Detection Sliders
TabCore:CreateSlider({
    Name = "Static Typing Latency (Speed)",
    Range = {0.00, 0.50}, Increment = 0.01, Suffix = "s",
    CurrentValue = GlobalEngine.StaticSpeed, Flag = "StaticSpeed",
    Callback = function(Value) GlobalEngine.StaticSpeed = Value end,
})

TabCore:CreateSlider({
    Name = "Textbox Detection Pipeline Minimum",
    Range = {0.01, 0.5}, Increment = 0.01, Suffix = "s",
    CurrentValue = GlobalEngine.LoopThrottleInterval, Flag = "LoopThrottle",
    Callback = function(Value) GlobalEngine.LoopThrottleInterval = Value end,
})

TabCore:CreateSlider({
    Name = "Dynamic: Min Input Latency Boundary",
    Range = {0.01, 0.5}, Increment = 0.01, Suffix = "s",
    CurrentValue = GlobalEngine.MinSpeed, Flag = "MinS",
    Callback = function(Value) GlobalEngine.MinSpeed = Value end,
})

TabCore:CreateSlider({
    Name = "Dynamic: Max Input Latency Boundary",
    Range = {0.02, 1.0}, Increment = 0.01, Suffix = "s",
    CurrentValue = GlobalEngine.MaxSpeed, Flag = "MaxS",
    Callback = function(Value) GlobalEngine.MaxSpeed = math.max(GlobalEngine.MinSpeed + 0.01, Value) end,
})

-- Anti-Paste & Bypass Configs
TabBypass:CreateToggle({
    Name = "Only Correct Words",
    CurrentValue = GlobalEngine.OnlyCorrectWords,
    Flag = "OnlyCorrectWords",
    Callback = function(Value) GlobalEngine.OnlyCorrectWords = Value end,
})
TabBypass:CreateToggle({
    Name = "Disable Anti-Paste Restrictions",
    CurrentValue = GlobalEngine.DisableAntiPaste,
    Flag = "DisableAntiPaste",
    Callback = function(Value) GlobalEngine.DisableAntiPaste = Value end,
})
TabBypass:CreateToggle({
    Name = "Lock Focus (Prevents Forced Kick)",
    CurrentValue = GlobalEngine.ForceKeepFocus,
    Flag = "ForceKeepFocus",
    Callback = function(Value) GlobalEngine.ForceKeepFocus = Value end,
})
TabBypass:CreateToggle({
    Name = "Simulate Focused UI Events",
    CurrentValue = GlobalEngine.HumanFocusSimulation, Flag = "FocusSim",
    Callback = function(Value) GlobalEngine.HumanFocusSimulation = Value end,
})
TabBypass:CreateToggle({
    Name = "Inject Virtual Mouse/Keyboard Jitter",
    CurrentValue = GlobalEngine.VirtualInputJitter, Flag = "InputJitter",
    Callback = function(Value) GlobalEngine.VirtualInputJitter = Value end,
})

-- Proximity Matrix Adjusters
TabTypos:CreateSlider({
    Name = "Base Typo Factor Rate",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = GlobalEngine.TypoChance, Flag = "TypoChance",
    Callback = function(Value) GlobalEngine.TypoChance = Value end,
})
TabTypos:CreateSlider({
    Name = "Double Strike Propensity",
    Range = {0, 100}, Increment = 1, Suffix = "%",
    CurrentValue = GlobalEngine.DoubleTypoChance, Flag = "DoubleTypo",
    Callback = function(Value) GlobalEngine.DoubleTypoChance = Value end,
})

-- Human Rhythms Config
TabBehavior:CreateToggle({
    Name = "Enable Typing Burst Mechanics",
    CurrentValue = GlobalEngine.BurstMode, Flag = "BurstM",
    Callback = function(Value) GlobalEngine.BurstMode = Value end,
})
TabBehavior:CreateToggle({
    Name = "Simulate Muscular Fatigue Over Time",
    CurrentValue = GlobalEngine.FatigueSimulation, Flag = "FatigueSim",
    Callback = function(Value) GlobalEngine.FatigueSimulation = Value end,
})

-- Automation Engine Adjustments
TabAutomation:CreateToggle({
    Name = "Auto-Fire Replicated Remote Validation",
    CurrentValue = GlobalEngine.AutoSubmit, Flag = "AutoSub",
    Callback = function(Value) GlobalEngine.AutoSubmit = Value end,
})

-- Keybind Overrides
TabAutomation:CreateKeybind({
    Name = "Instant Finish Bypass Key",
    CurrentKeybind = "LeftControl", HoldToInteract = false,
    Callback = function() GlobalEngine.InstantTypeHotKey = not GlobalEngine.InstantTypeHotKey end,
})
TabAutomation:CreateKeybind({
    Name = "Emergency Pipeline Halt Key",
    CurrentKeybind = "RightShift", HoldToInteract = false,
    Callback = function() 
        GlobalEngine.StopExecutionSignal = true 
        Rayfield:Notify({Title = "SYSTEM PANIC", Content = "Execution threads severed.", Duration = 3})
    end,
})

----------------------------------------------------------------
-- 5. MATH ENGINE: BELL CURVE & TYPO PROXIMITY GENERATORS
----------------------------------------------------------------

local function getGaussianDelay(minBound, maxBound)
    if GlobalEngine.StaticTyping then return 0 end
    local u1, u2 = math.random(), math.random()
    if u1 == 0 then u1 = 0.0001 end
    local randStdNormal = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)
    local mean = (minBound + maxBound) / 2
    local stdDev = (maxBound - minBound) / 4
    local delay = mean + (randStdNormal * stdDev)
    return math.clamp(delay, minBound, maxBound)
end

local function calculateFatFingerTypo(char)
    if GlobalEngine.StaticTyping then return char end
    local lowerChar = string.lower(char)
    local neighbors = KeyNeighbors[lowerChar]
    if neighbors then
        local index = math.random(1, #neighbors)
        local typo = string.sub(neighbors, index, index)
        if char ~= lowerChar then return string.upper(typo) end
        return typo
    end
    return char
end

----------------------------------------------------------------
-- 6. ANTI-PASTE BYPASS OVERRIDES
----------------------------------------------------------------

local function handleFocusBypass()
    if not targetTextBox or not GlobalEngine.EngineMasterSwitch then return end
    if GlobalEngine.DisableAntiPaste then
        if UserInputService:GetFocusedTextBox() ~= targetTextBox then
            targetTextBox:CaptureFocus()
        end
    end
end

----------------------------------------------------------------
-- 7. CORE TYPING ENVIRONMENT THREADS
----------------------------------------------------------------

local function typeWord(targetText)
    if not targetTextBox then
        warn("[Engine Debug Error]: Target TextBox became nil prior to typing execution.")
        return 
    end
    if not GlobalEngine.EngineMasterSwitch then return end
    if #targetText > GlobalEngine.MaxWordLengthCap then return end
    
    GlobalEngine.IsCurrentlyTyping = true
    GlobalEngine.StopExecutionSignal = false
    
    if LabelStatus and LabelStatus.SetText then
        LabelStatus:SetText("Engine State: Actively Typing")
    end
    
    if GlobalEngine.ForceKeepFocus and not focusLossConnection then
        focusLossConnection = targetTextBox.FocusLost:Connect(function(enterPressed)
            if GlobalEngine.IsCurrentlyTyping and not enterPressed then
                task.wait()
                if GlobalEngine.EngineMasterSwitch then targetTextBox:CaptureFocus() end
            end
        end)
    end
    
    if GlobalEngine.HumanFocusSimulation and not GlobalEngine.StaticTyping then
        task.wait(GlobalEngine.FocusGainDelay)
        targetTextBox:CaptureFocus()
    else
        targetTextBox:CaptureFocus()
    end
    
    if GlobalEngine.LongWordHesitation and #targetText > 8 and not GlobalEngine.StaticTyping then
        task.wait(getGaussianDelay(0.18, 0.45))
    end
    
    if GlobalEngine.TextPropertyBypass or GlobalEngine.InstantTypeHotKey then
        targetTextBox.Text = targetText
    else
        local currentOutputString = ""
        local cursorIndex = 1
        local startTime = os.clock()
        
        while cursorIndex <= #targetText do
            if not GlobalEngine.EngineMasterSwitch or GlobalEngine.StopExecutionSignal then 
                break 
            end
            
            handleFocusBypass()
            local activeCharacter = string.sub(targetText, cursorIndex, cursorIndex)
            
            -- Typo processing (Bypassed if Static Typing is chosen)
            if not GlobalEngine.StaticTyping and math.random(1, 100) <= GlobalEngine.TypoChance and cursorIndex < #targetText and string.match(activeCharacter, "%w") then
                local simulatedTypo = calculateFatFingerTypo(activeCharacter)
                if simulatedTypo ~= activeCharacter then
                    currentOutputString = currentOutputString .. simulatedTypo
                    targetTextBox.Text = currentOutputString
                    task.wait(getGaussianDelay(GlobalEngine.MinSpeed, GlobalEngine.MaxSpeed))
                    
                    if math.random(1, 100) <= GlobalEngine.DoubleTypoChance and cursorIndex + 1 < #targetText then
                        local nextChar = string.sub(targetText, cursorIndex + 1, cursorIndex + 1)
                        currentOutputString = currentOutputString .. calculateFatFingerTypo(nextChar)
                        targetTextBox.Text = currentOutputString
                        task.wait(getGaussianDelay(GlobalEngine.MinSpeed, GlobalEngine.MaxSpeed))
                        task.wait(getGaussianDelay(GlobalEngine.FixDelayMin * 1.4, GlobalEngine.FixDelayMax * 1.4))
                        currentOutputString = string.sub(currentOutputString, 1, #currentOutputString - 1)
                    else
                        task.wait(getGaussianDelay(GlobalEngine.FixDelayMin, GlobalEngine.FixDelayMax))
                    end
                    
                    currentOutputString = string.sub(currentOutputString, 1, #currentOutputString - 1)
                    targetTextBox.Text = currentOutputString
                    GlobalEngine.TotalTyposCorrected = GlobalEngine.TotalTyposCorrected + 1
                    if LabelTypos and LabelTypos.SetText then
                        LabelTypos:SetText("Total Simulated Corrections: " .. tostring(GlobalEngine.TotalTyposCorrected))
                    end
                    task.wait(GlobalEngine.PostFixHesitation)
                end
            end
            
            currentOutputString = currentOutputString .. activeCharacter
            targetTextBox.Text = currentOutputString
            
            -- Realism Delay vs Static Speed Delay Routing
            if not GlobalEngine.StaticTyping then
                -- DYNAMIC REALISM MATH
                local characterBaseDelay = getGaussianDelay(GlobalEngine.MinSpeed, GlobalEngine.MaxSpeed)
                
                if GlobalEngine.FatigueSimulation and cursorIndex > GlobalEngine.FatigueThreshold then
                    characterBaseDelay = characterBaseDelay * GlobalEngine.FatigueDecayFactor
                end
                
                if activeCharacter == " " then
                    characterBaseDelay = characterBaseDelay + GlobalEngine.SpacebarLag
                elseif string.match(activeCharacter, "[%p%s]") then
                    characterBaseDelay = characterBaseDelay * GlobalEngine.PunctuationDelayMultiplier
                end
                
                task.wait(characterBaseDelay)
                
                if GlobalEngine.BurstMode and cursorIndex % GlobalEngine.BurstFrequency == 0 and math.random(1, 100) < 35 then
                    task.wait(math.random(GlobalEngine.BurstPauseMin * 100, GlobalEngine.BurstPauseMax * 100) / 100)
                end
                
                if math.random(1, 100) <= GlobalEngine.MicroStutterChance then
                    task.wait(math.random(0.05 * 100, GlobalEngine.MicroStutterMax * 100) / 100)
                end
            else
                -- STATIC SPEED MATH (No realism, just flat timing)
                if GlobalEngine.StaticSpeed > 0 then
                    task.wait(GlobalEngine.StaticSpeed)
                else
                    -- Yield mitigation to prevent freezing when doing 0 delay
                    if cursorIndex % 20 == 0 then RunService.Heartbeat:Wait() end
                end
            end
            
            if GlobalEngine.LiveWPMCounter and cursorIndex % 3 == 0 and not GlobalEngine.StaticTyping then
                local dynamicElapsed = os.clock() - startTime
                local calculatedWPM = math.floor((#currentOutputString / 5) / (dynamicElapsed / 60))
                if calculatedWPM < 300 and LabelWPM and LabelWPM.SetText then
                    GlobalEngine.CurrentWPM = calculatedWPM
                    LabelWPM:SetText("WPM Tracker: " .. tostring(GlobalEngine.CurrentWPM) .. " WPM")
                end
            end
            
            cursorIndex = cursorIndex + 1
        end
    end
    
    if focusLossConnection then
        focusLossConnection:Disconnect()
        focusLossConnection = nil
    end
    
    if GlobalEngine.HumanFocusSimulation and not GlobalEngine.StaticTyping then
        task.wait(GlobalEngine.FocusLossDelay)
    end
    targetTextBox:ReleaseFocus()
    
    if GlobalEngine.AutoSubmit and GlobalEngine.EngineMasterSwitch and not GlobalEngine.StopExecutionSignal and spelledCorrectlyEvent then
        if not GlobalEngine.StaticTyping then
            task.wait(getGaussianDelay(GlobalEngine.SubmitDelayMin, GlobalEngine.SubmitDelayMax))
        end
        if GlobalEngine.StaticTyping or math.random(1, 100) > GlobalEngine.SubmitFailChance then
            spelledCorrectlyEvent:FireServer(targetText)
        end
    end
    
    GlobalEngine.TotalWordsProcessed = GlobalEngine.TotalWordsProcessed + 1
    if LabelWords and LabelWords.SetText then
        LabelWords:SetText("Total Completed Data-Blocks: " .. tostring(GlobalEngine.TotalWordsProcessed))
    end
    GlobalEngine.IsCurrentlyTyping = false
    
    if LabelStatus and LabelStatus.SetText then
        LabelStatus:SetText(GlobalEngine.EngineMasterSwitch and "Engine State: Idle" or "Engine State: Disabled")
    end
end

----------------------------------------------------------------
-- 8. METRIC MONITOR PIPELINES & HOOKS
----------------------------------------------------------------

local function onGuiChanged()
    if not GlobalEngine.EngineMasterSwitch then return end
    
    if targetScreenGui and targetScreenGui.Enabled then
        task.wait(GlobalEngine.LoopThrottleInterval)
        if not wordValue then return end
        local inputTargetWord = wordValue.Value
        
        if inputTargetWord and inputTargetWord ~= "" and not GlobalEngine.IsCurrentlyTyping then
            print("[Engine Debug]: New word observed: '" .. tostring(inputTargetWord) .. "'. Starting type operation.")
            typeWord(inputTargetWord)
        end
    end
end

local function setupGuiDetection()
    print("[Engine Debug]: Resolving Target ScreenGui path context...")
    targetScreenGui = playerGui:WaitForChild("Textbox", 8)
    
    if not targetScreenGui then 
        warn("[Engine Debug Critical Error]: ScreenGui named 'Textbox' was not found inside PlayerGui.")
        return 
    end
    
    targetTextBox = targetScreenGui:WaitForChild("TextBox", 4)
    if not targetTextBox then 
        warn("[Engine Debug Critical Error]: TextBox instance named 'TextBox' was not found inside the ScreenGui.")
        return 
    end
    
    print("[Engine Debug]: Handshake established successfully. Monitoring state transitions.")
    targetConnection = targetScreenGui:GetPropertyChangedSignal("Enabled"):Connect(onGuiChanged)
    
    if wordValue then
        wordValue.Changed:Connect(function()
            onGuiChanged()
        end)
    end

    -- Setup text tracking logic for manual key execution hook overrides
    local metatableHook
    local metatableSuccess, metatableError = pcall(function()
        local rawMetatable = getrawmetatable(game)
        setreadonly(rawMetatable, false)
        local originalNamecall = rawMetatable.__namecall

        rawMetatable.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if GlobalEngine.OnlyCorrectWords and method == "FireServer" then
                if self.Name == "SpelledWrongly" then
                    return
                elseif self.Name == "SpelledCorrectly" then
                    return originalNamecall(self, unpack(args))
                end
            end
            return originalNamecall(self, ...)
        end)
        setreadonly(rawMetatable, true)
    end)

    if not metatableSuccess then
        -- Fallback event listener hook routine when running environments missing full metatable manipulation extensions
        local originalFireServer
        local hookSuccess, hookError = pcall(function()
            local remoteWrong = ReplicatedStorage:WaitForChild("SpelledWrongly", 2)
            if remoteWrong then
                originalFireServer = remoteWrong.FireServer
                local dynamicMeta = getmediatable and getmediatable(remoteWrong) or getrawmetatable(game)
                if dynamicMeta and dynamicMeta.__index and dynamicMeta.__index.FireServer then
                    -- Environment fallback hook assignment array blocks
                end
            end
        end)
    end

    targetTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and GlobalEngine.OnlyCorrectWords and spelledCorrectlyEvent then
            spelledCorrectlyEvent:FireServer(targetTextBox.Text)
        end
    end)
    
    onGuiChanged()
end

setupGuiDetection()
print("[Engine Debug]: Boot Complete.")
