local _, ns = ...

-- Blizzard
local IsInInstance = _G.IsInInstance
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local GetSpellLink = _G.GetSpellLink
local CombatLog_Object_IsA = _G.CombatLog_Object_IsA
local COMBATLOG_FILTER_ME = _G.COMBATLOG_FILTER_ME
local COMBATLOG_FILTER_MINE = _G.COMBATLOG_FILTER_MINE
local COMBATLOG_FILTER_MY_PET = _G.COMBATLOG_FILTER_MY_PET

-- Constants
local STRING_INTERRUPT = "Interrupted %s %s!"

----------------------------------------------------------------
-- Interrupt Announce
----------------------------------------------------------------

-- configurations
local chatChannels = {
    ["SAY"] = true,
    ["PARTY"] = true,
    ["RAID"] = true,
    ["RAID_WARNNING"] = false,
    ["INSTANCE_CHAT"] = false
}

local DisplaySpellLink = true

-- variables used to prevent AoE spam interrupts
local lastTimestamp, lastSpellID = 0, nil

-- create a possesion form by appending ('s) to the string, unless it ends
-- with s, x or z, in which only (') is added.
local function StringPossesion(s)
    if (s:sub(-1):find("[sxzSXZ]")) then
        return s .. "\'"
    end
    return s .. "\'s"
end

local Interrupt = CreateFrame("Frame")
Interrupt:RegisterEvent("PLAYER_LOGIN")
Interrupt:RegisterEvent("PLAYER_ENTERING_WORLD")
Interrupt:SetScript("OnEvent", function(self, event, ...)
    -- call one of the event handlers
    self[event](self, ...)
end)

function Interrupt:PLAYER_LOGIN()
    self.unit = "player"
    self.guid = UnitGUID("player")
    self.chatType = "SAY"
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Interrupt:PLAYER_ENTERING_WORLD()
    local _, instanceType = IsInInstance()
    local inInstance, inGroup, inRaid = IsInGroup(LE_PARTY_CATEGORY_INSTANCE), IsInGroup(), IsInRaid()

    -- check group status
    if (instanceType == "raid") or (instanceType == "party") then
        if (inInstance) then
            self.chatType = "INSTANCE_CHAT"
        elseif (inRaid) then
            self.chatType = "RAID"
        elseif (inGroup) then
            self.chatType = "PARTY"
        else
            self.chatType = "SAY"
        end
    else
        self.chatType = "SAY"
    end

    -- check if channel is enable for announcing
    if (not chatChannels[self.chatType]) then
        self.chatType = "SAY"
    end
end

function Interrupt:SendChatMessage(destName, extraSpellText)
    SendChatMessage(STRING_INTERRUPT:format(StringPossesion(destName or "?"), extraSpellText), self.chatType)
end

function Interrupt:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    -- check if event type was a spell interrupt
    if (eventType == "SPELL_INTERRUPT") then
        -- spell standard
        local spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = select(12, CombatLogGetCurrentEventInfo())
        
        -- ignore self interrupts (quake from mythic affixes)
        if (sourceGUID == destGUID and destGUID == self.guid) then return end

        -- prevents spam announcements
        if (spellID == lastSpellID) and (timestamp - lastTimestamp <= 1) then return end

        -- update last timestamp e spellID
        lastTimestamp, lastSpellID = timestamp, spellID

        -- check if source is the player or belong to player
        if (CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_ME) or
            CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE) or
            CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET)) then
            if (DisplaySpellLink) then
                local extraSpellLink = GetSpellLink(extraSpellID)
                self:SendChatMessage(destName, extraSpellLink or extraSpellName)
            else
                self:SendChatMessage(destName, extraSpellName)
            end
        end
    end
end

ns.Interrupts = Interrupts
