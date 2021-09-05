local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Markdownify = require(script.Parent.Markdownify)

local module = {}
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "Subtitles"
gui.Enabled = false
gui.Parent = player == nil and CoreGui or player.PlayerGui

local container = Instance.new("Frame")
local label = Instance.new("TextLabel")
local padding = Instance.new("UIPadding")
local corner = Instance.new("UICorner")

for _, v in pairs{"PaddingBottom","PaddingLeft","PaddingRight","PaddingTop"} do
    padding[v] = UDim.new(0, 5)
end

corner.CornerRadius = UDim.new(0, 3)
padding.Parent = container
corner.Parent = container

label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1, 1, 1)
label.AutomaticSize = Enum.AutomaticSize.XY
label.TextSize = 14
label.RichText = true
label.Parent = container

container.BackgroundTransparency = .6
container.AnchorPoint = Vector2.new(.5, 1)
container.Position = UDim2.new(.5, 0, 1, -10)
container.BackgroundColor3 = Color3.new(.1,.1,.1)
container.AutomaticSize = Enum.AutomaticSize.XY
container.Parent = gui

function module:SetSubtitlesEnabled(state: boolean)
    container.Visible = state
end

function module:SetSubtitleAppearance(options)
    for prop, val in pairs(options) do
        if prop == "Font" then
            label.Font = val
        elseif prop == "TextSize" then
            label.TextSize = val
        elseif prop == "CornerRadius" then
            corner.CornerRadius = val
        elseif prop == "TextColor" then
            label.TextColor3 = val
        elseif prop == "AnchorPoint" then
            container.AnchorPoint = val
        elseif prop == "Position" then
            container.Position = val
        elseif prop == "BackgroundColor" then
            container.BackgroundColor3 = val
        elseif prop == "BackgroundTransparency" then
            container.BackgroundTransparency = val
        elseif prop == "TextStrokeColor" then
            label.TextStrokeColor3 = val
        elseif prop == "TextStrokeTransparency" then
            label.TextStrokeTransparency = val
        end
    end
end

function module:SetText(text: string?)
    if text and text ~= "" then
        gui.Enabled = true
        label.Text = Markdownify(text)
    else
        gui.Enabled = false
    end
end

return module