-- UnitedUI authentication layout example (UI structure only, no backend auth)

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/tym487ty78/RobloxUnitedUI/refs/heads/main/main.lua"))()

local authWin = UI.Window("Authentication", 520, 260, 130, 420, {
    SaveConfigs = false,
    Background = "blurr",
    BlurSize = 14,
    Theme = "purple",
})

authWin:SetToggleKeybind(Enum.KeyCode.RightShift)

-- Single-container mode (no tabs)
local root = authWin:CreateContainer("Account Access")

root:Label("<b>Welcome</b>")
root:MultiLabel({
    "Sign in to continue.",
    "This is UI skeleton only.",
})
root:Separator()

-- Login section
root:Label("Login")
local loginEmail = root:Input("Email or username", "")
local loginPassword = root:Input("Password", "")
local rememberMe = root:Toggle("Remember me", true, function() end)
local staySignedIn = root:Toggle("Stay signed in", false, function() end)

root:Button("Sign In", function()
    UI.Notification({
        Delay = 3,
        Location = "bb",
        Mode = "Info",
        Title = "Authentication",
        Text = "Sign in clicked (no backend)",
    })
end)

root:Button("Forgot Password", function()
    UI.Notification({
        Delay = 3,
        Location = "bb",
        Mode = "Warning",
        Title = "Authentication",
        Text = "Password reset flow placeholder",
    })
end)

root:Separator()

-- Register section
root:Label("Create Account")
local regUsername = root:Input("Username", "")
local regEmail = root:Input("Email", "")
local regPassword = root:Input("Password", "")
local regConfirmPassword = root:Input("Confirm password", "")
local roleDropdown = root:Dropdown("Role", {"User", "Moderator", "Admin"}, "User", function() end)
local interests = root:MultiDropdown("Interests", {"Shooter", "RPG", "PvP", "Trading"}, {"Shooter"}, function() end)

root:Button("Create Account", function()
    UI.Notification({
        Delay = 3,
        Location = "bb",
        Mode = "Success",
        Title = "Authentication",
        Text = "Create account clicked (no backend)",
    })
end)

root:Separator()

-- Security/preferences
root:Label("Security and Preferences")
local twoFA = root:Toggle("Enable 2FA", false, function() end)
local securityKeybind = root:Keybind("Quick Lock Key", Enum.KeyCode.L, function(state, key)
    print("Quick lock:", state, key)
end, nil, "toggle")
local accentColor = root:ColorPicker("Accent Color", Color3.fromRGB(180, 130, 235), function() end)
local sessionTimeout = root:Slider("Session Timeout (min)", 5, 180, 30, function() end)

root:Button("Apply UI Settings", function()
    print("Email:", loginEmail:GetText())
    print("Remember:", rememberMe:GetValue(), "Stay signed in:", staySignedIn:GetValue())
    print("Role:", roleDropdown:GetValue())
    print("Interests:", table.concat(interests:GetValues(), ", "))
    print("2FA:", twoFA:GetValue())
    print("Timeout:", sessionTimeout:GetValue())
    print("Keybind mode:", securityKeybind:GetMode())
    authWin:ChangeColor(accentColor, Color3.fromRGB(130, 190, 255))
end)

root:Button("Close Panel", function()
    authWin:Destroy()
end)

-- Keep variables referenced to show structure
local _ = {
    loginPassword = loginPassword,
    regUsername = regUsername,
    regEmail = regEmail,
    regPassword = regPassword,
    regConfirmPassword = regConfirmPassword,
}

