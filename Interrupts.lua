local _, ns = ...

-- Blizzard
local IsInInstance = _G.IsInInstance
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local SendChatMessage = C_ChatInfo.SendChatMessage

local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME or 1
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE or 2

----------------------------------------------------------------
-- Interrupt Announce
----------------------------------------------------------------
-- Shared chat channel handling; classic.lua and mainline.lua define Enable.

local Interrupt = CreateFrame("Frame")
Interrupt:RegisterEvent("PLAYER_LOGIN")
Interrupt:RegisterEvent("PLAYER_ENTERING_WORLD")
Interrupt:RegisterEvent("GROUP_ROSTER_UPDATE")
Interrupt:SetScript("OnEvent", function(self, event, ...)
    -- call one of the event handlers
    self[event](self, ...)
end)

ns.Interrupts = Interrupt

function Interrupt:UpdateChatType()
    local isInInstance = IsInInstance()
    local inInstance, inGroup, inRaid = IsInGroup(LE_PARTY_CATEGORY_INSTANCE), IsInGroup(LE_PARTY_CATEGORY_HOME), IsInRaid()

    if isInInstance then
        if inRaid then
            self.chatType = "RAID"
        else
            self.chatType = "SAY"
        end
    elseif inRaid then
        self.chatType = "RAID"
    elseif inGroup then
        self.chatType = "PARTY"
    elseif inInstance then
        self.chatType = "INSTANCE_CHAT"
    else
        -- chat type "SAY" requires a hardware event when in the outdoor world
        self.chatType = nil
    end
end

-- solo outdoors there is no channel: only the player sees the message
function Interrupt:Announce(text)
    if self.chatType then
        SendChatMessage(text, self.chatType)
    else
        print(text)
    end
end

function Interrupt:PLAYER_LOGIN()
    self:Enable()
end

function Interrupt:PLAYER_ENTERING_WORLD()
    self:UpdateChatType()
end

function Interrupt:GROUP_ROSTER_UPDATE()
    self:UpdateChatType()
end
