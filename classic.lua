local _, ns = ...
local Interrupt = ns.Interrupts

-- Blizzard
local GetSpellLink = C_Spell and C_Spell.GetSpellLink or _G.GetSpellLink
local CombatLogGetCurrentEventInfo = C_CombatLog.GetCurrentEventInfo
local CombatLog_Object_IsA = C_CombatLog.DoesObjectMatchFilter
local COMBATLOG_FILTER_ME = _G.COMBATLOG_FILTER_ME
local COMBATLOG_FILTER_MINE = _G.COMBATLOG_FILTER_MINE
local COMBATLOG_FILTER_MY_PET = _G.COMBATLOG_FILTER_MY_PET

-- Constants
local INTERRUPT = "Interrupted %s %s!"

----------------------------------------------------------------
-- Interrupt Announce (Classic)
----------------------------------------------------------------

-- configurations
local cfg = {
    ["spell_link"] = true
}

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

function Interrupt:Enable()
    self.guid = UnitGUID("player")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Interrupt:SendChatMessage(destName, spellText)
    self:Announce(INTERRUPT:format(StringPossesion(destName or "?"), spellText))
end

function Interrupt:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, eventType, _, sourceGUID, _, sourceFlags, _, destGUID, destName, _, _,
        spellID, _, _, extraSpellID, extraSpellName = CombatLogGetCurrentEventInfo()

    -- check if event type was a spell interrupt
    if (eventType == "SPELL_INTERRUPT") then
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
            if (cfg.spell_link) then
                local extraSpellLink = GetSpellLink(extraSpellID)
                self:SendChatMessage(destName, extraSpellLink or extraSpellName)
            else
                self:SendChatMessage(destName, extraSpellName)
            end
        end
    end
end
