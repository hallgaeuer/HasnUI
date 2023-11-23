--[[
local E = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

-- Add nicer shadows, but only for Custom Texts (for all texts Toolkit.lua FontTemplate() would need to be hooked somehow)
hooksecurefunc(UF, 'Configure_CustomTexts', function(_,frame)
    if frame.customTexts then
        for _,v in pairs(frame.customTexts) do
            v:SetShadowOffset(2, -2)
            v:SetShadowColor(0, 0, 0, 0.6)
        end
    end
end)
]]--

local HasnUI = CreateFrame("Frame", "HasnUI")
HasnUI.events = {}

function HasnUI:Initialize()
    self:SetScript("OnEvent", self.OnEvent);
    self:RegisterEvents()
end

function HasnUI:RegisterEvents()
    for eventName, v in pairs(self.events) do
        self:RegisterEvent(eventName)
    end
end

function HasnUI:ChangeXPBarSize(newWidth, newHeight)
    local xpBarFrame = _G["MainMenuExpBar"]
    local xpBarFrameTextures = {
        _G["MainMenuXPBarTexture0"],
        _G["MainMenuXPBarTexture1"],
        _G["MainMenuXPBarTexture2"],
        _G["MainMenuXPBarTexture3"],
        _G["ExhaustionLevelFillBar"]
    }

    if not xpBarFrame then
        return
    end

    -- Adjust main frame width
    local oldWidth = xpBarFrame:GetWidth()
    local oldHeight = xpBarFrame:GetHeight()
    xpBarFrame:SetWidth(newWidth)
    xpBarFrame:SetHeight(newHeight)

    local widthMultiplier = newWidth / oldWidth
    local heightMultiplier = newHeight / oldHeight

    -- Adjust width, height and positions of textures
    for _, texture in ipairs(xpBarFrameTextures) do
        local name = texture:GetName()
        point, relativeTo, relativePoint, x, y = texture:GetPoint()

        texture:SetWidth(texture:GetWidth() * widthMultiplier)
        texture:SetHeight(newHeight)
        texture:ClearAllPoints();
        -- Use fixed y offset of "1" instead of the default "3". Otherwise the background textures overflow (yes do overflow in the default blizzard UI, you just cant see it because its hidden by the art bar)
        if (name ~= "ExhaustionLevelFillBar") then
            y = 1
        end
    
        texture:SetPoint(point, relativeTo, relativePoint, x * widthMultiplier, y)
    end

    -- Adjust position of child frames (e.g. tick)
    for _, childFrame in ipairs({xpBarFrame:GetChildren()}) do
        point, relativeTo, relativePoint, x, y = childFrame:GetPoint()
        -- Don't adjust tick width or its texture gets smooshed
        --childFrame:SetWidth(childFrame:GetWidth() * widthMultiplier)
        childFrame:SetHeight(childFrame:GetHeight() * heightMultiplier)
        childFrame:ClearAllPoints();
        childFrame:SetPoint(point, relativeTo, relativePoint, x * widthMultiplier, y)
    end
end

function HasnUI:FixXpBarFrameLevel()
    local xpBarFrame = _G["MainMenuExpBar"]

    if not xpBarFrame then
        return
    end

    _G["MainMenuExpBar"]:SetFrameLevel(1)
end

function HasnUI.OnEvent(frame, event, ...)
    HasnUI.events[event](frame, ...)
end

function HasnUI.events.PLAYER_ENTERING_WORLD()
    if (_G["MainMenuExpBar"]) then
        HasnUI:FixXpBarFrameLevel()
        HasnUI:ChangeXPBarSize(_G["MainMenuExpBar"]:GetWidth() / 2, 10)
    end
end

HasnUI:Initialize()