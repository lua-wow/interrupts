local _, ns = ...
local Interrupt = ns.Interrupts

-- Blizzard
local GetTime = _G.GetTime
local UnitCanAttack = _G.UnitCanAttack
local issecretvalue = _G.issecretvalue
local GetSpellName = C_Spell.GetSpellName

-- Constants
local INTERRUPT = "Interrupted with %s!"

----------------------------------------------------------------
-- Interrupt Announce (Retail, Forever)
----------------------------------------------------------------
-- The combat log can't be read and the enemy's spell, name and interrupter are secret. The player's
-- (or pet's) interrupt cast is paired with an enemy cast stopping in the same frame (same GetTime()).

-- player and pet interrupt spells
local spells
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    -- Blizzard_CooldownBroadcaster/TrackedCooldowns.lua (InterruptSpellsBySpec)
    -- false: an interrupt the same-frame pairing can't credit, listed for completeness
    spells = {
        -- DEATHKNIGHT
        [47528] = true, -- Mind Freeze
        -- DEMONHUNTER
        [183752] = true, -- Disrupt
        -- DRUID
        [78675] = true, -- Solar Beam
        [106839] = true, -- Skull Bash
        -- EVOKER
        [351338] = true, -- Quell
        -- HUNTER
        [147362] = true, -- Counter Shot
        [187707] = true, -- Muzzle
        -- MAGE
        [2139] = true, -- Counterspell
        -- MONK
        [116705] = true, -- Spear Hand Strike
        -- PALADIN
        [96231] = true, -- Rebuke
        -- projectile: the interrupt lands after the cast (unverified IDs and timing)
        [31935] = false, -- Avenger's Shield
        [375576] = false, -- Divine Toll
        -- PRIEST
        [15487] = true, -- Silence
        -- ROGUE
        [1766] = true, -- Kick
        -- SHAMAN
        [57994] = true, -- Wind Shear
        -- WARLOCK
        [119910] = true, -- Spell Lock (Command Demon)
        [132409] = true, -- Spell Lock (Grimoire of Sacrifice)
        [119914] = true, -- Axe Toss (Command Demon)
        [19647] = true, -- Spell Lock (Felhunter), unverified
        [89766] = true, -- Axe Toss (Felguard), unverified
        -- WARRIOR
        [6552] = true, -- Pummel
        [386071] = true, -- Disrupting Shout
    }
else
    -- Forever: vanilla spell IDs, unverified
    spells = {
        -- DRUID
        [16979] = true, -- Feral Charge
        -- MAGE
        [2139] = true, -- Counterspell
        -- PRIEST
        [15487] = true, -- Silence
        -- ROGUE
        [1766] = true, -- Kick (Rank 1)
        [1767] = true, -- Kick (Rank 2)
        [1768] = true, -- Kick (Rank 3)
        [1769] = true, -- Kick (Rank 4)
        -- SHAMAN
        [8042] = true, -- Earth Shock (Rank 1)
        [8044] = true, -- Earth Shock (Rank 2)
        [8045] = true, -- Earth Shock (Rank 3)
        [8046] = true, -- Earth Shock (Rank 4)
        [10412] = true, -- Earth Shock (Rank 5)
        [10413] = true, -- Earth Shock (Rank 6)
        [10414] = true, -- Earth Shock (Rank 7)
        -- WARLOCK (Felhunter)
        [19244] = true, -- Spell Lock (Rank 1)
        [19647] = true, -- Spell Lock (Rank 2)
        -- WARRIOR
        [72] = true, -- Shield Bash (Rank 1)
        [1671] = true, -- Shield Bash (Rank 2)
        [1672] = true, -- Shield Bash (Rank 3)

        [6552] = true, -- Pummel (Rank 1)
        [6554] = true, -- Pummel (Rank 2)
    }
end

-- the player's last interrupt cast, cleared once announced
local pendingTime, pendingSpell = 0, nil

function Interrupt:Enable()
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
end

-- remember the player's (or pet's) interrupt cast
function Interrupt:OnCastSucceeded(spellID)
    if not issecretvalue(spellID) and spells[spellID] then
        pendingTime, pendingSpell = GetTime(), spellID
    end
end

-- only an enemy cast stopping in the same frame as the player's interrupt
function Interrupt:OnCastStopped(unit)
    if not pendingSpell or GetTime() ~= pendingTime then return end
    if issecretvalue(unit) then return end
    local canAttack = UnitCanAttack("player", unit)
    if issecretvalue(canAttack) or not canAttack then return end

    -- one message per interrupt: the target, nameplate and soft-target tokens fire the same stop
    local spellID = pendingSpell
    pendingSpell = nil
    -- plain name: Forever's spell link text carries the rank ("Kick (Rank 1)")
    self:Announce(INTERRUPT:format(GetSpellName(spellID)))
end

function Interrupt:UNIT_SPELLCAST_SUCCEEDED(_, _, spellID)
    self:OnCastSucceeded(spellID)
end

function Interrupt:UNIT_SPELLCAST_INTERRUPTED(unit)
    self:OnCastStopped(unit)
end

function Interrupt:UNIT_SPELLCAST_CHANNEL_STOP(unit)
    self:OnCastStopped(unit)
end
