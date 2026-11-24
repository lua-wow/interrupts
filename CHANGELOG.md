# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

-   Interface for Retail and Forever (`120105, 16001`)
-   Retail and Forever announcer (`mainline.lua`): the combat log can't be read and the enemy's name,
    spell and interrupter are secret, so the player's or pet's interrupt cast is paired with an enemy
    cast stopping in the same frame. Announces `Interrupted with <spell>!`, one message per interrupt
-   Interrupt spell tables per client, grouped by class; Avenger's Shield and Divine Toll listed as
    `false` (the shield lands after the cast)

### Changed

-   Solo outdoors the message is printed to the chat frame instead of being dropped (all clients)
-   Combat log announcer moved to `classic.lua`; `Interrupts.lua` keeps the shared frame, chat
    channel and `Announce`
-   TOC loads files per client with `[AllowLoadGameType]`; `init.xml` removed

## [1.5.0] - 2026-10-14

### Changed

-   Interface for Classic Era, TBC, WotLK and MoP only (the combat log can't be read on Retail)
-   `C_ChatInfo.SendChatMessage` instead of the deprecated global
-   Announce channel is updated when the group changes (`GROUP_ROSTER_UPDATE`)
-   Removed dead code; added `.luacheckrc` and `make check`

## [1.3.0] - 2024-07-27

### Changed

-   Fixed taint. We can not use SAY chat cannel to announce interrupts on the outdoor world.

## [1.2.0] - 2024-07-25

### Changed

-   Update .toc file - Patch 11.0.0
-   `_G.GetSpellLink` do not exists anymore, replacing with `C_Spell.GetSpellLink`

## [1.1.0] - 2024-07-22

### Changed

-   Update `.toc` file.

## [1.0.0] - 2024-01-02

### Added

-   `CHANGELOG.md' initialized.
