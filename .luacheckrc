std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

unused_secondaries = false -- e.g. local name, _, itemLevel = GetItemInfo(...)

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
ignore = {
    '212', -- unused argument (callback signatures)
    '213', -- unused loop variable
    '431', -- shadowing an upvalue
    '432/self', -- shadowing upvalue argument self (nested methods)
    '611', -- line contains only whitespace
    '612', -- line contains trailing whitespace
    '614', -- trailing whitespace in comment
    '631', -- line is too long
}

-- WoW API and FrameXML; add entries as the addon uses them
read_globals = {
    -- namespaces
    'C_ChatInfo',
    'C_CombatLog',
    'C_Spell',

    -- constants
    'COMBATLOG_FILTER_ME',
    'COMBATLOG_FILTER_MINE',
    'COMBATLOG_FILTER_MY_PET',
    'LE_PARTY_CATEGORY_HOME',
    'LE_PARTY_CATEGORY_INSTANCE',

    -- API
    'CreateFrame',
    'IsInGroup',
    'IsInInstance',
    'IsInRaid',
    'UnitGUID',
}
