## **Version 3.0.3.2**

- Added "Hide windows" option (on by default) that hides the disenchant, ignored items and enchant windows during combat and shows them again afterwards (Thanks **rherzfeld**)
- Fixed an error when trying to move the enchant window during combat

## **Version 3.0.3.1**

- The enchanting window tooltip title now reads "Disenchant" instead of "Enchanting" (Thanks **flep82**)
- Removed unused embedded libraries (HereBeDragons-2.0, LibCandyBar-3.0, LibSharedMedia-3.0)
- Fixed disenchant tooltip predictions on Forever and TBC by using item level (Thanks **donlam**)
- Replaced the Auctionator toggle with an "Auction house price source" option: None, Auctionator or auxForever
- Added auxForever prices to the disenchant tooltip, with their age next to "Auction"

## **Version 3.0.3.0**

- Added distribution stats to tooltips: how often each quantity of a material was obtained (x1, x2, x3...), with a "Show distribution" toggle
- Renamed some tooltip options for clarity

## **Version 3.0.2.1**

- Added the missing localization of the "Mute sounds" option for all languages

## **Version 3.0.2.0**

- Added a "Mute sounds" toggle in General settings to silence the addon sound effects
- Addon sound effects now play on the SFX audio channel, so they follow the game's sound effects volume

## **Version 3.0.1.1**

- Fixed the `attempt to compare local 'spellID' (a secret number value...)` error on Forever when enchanting
- Fixed the "You don't have the enchanting skill" warning for non-English clients by also detecting Enchanting by its skill line ID

## **Version 3.0.1.0**

- Added welcome screens for the enchant and disenchant windows, with a "Hide welcome screen" toggle in General settings
- Fixed the disenchant tooltip showing up for poor and common items (Thanks **theAnton81**)
- The enchanting window status text now explains why the list is empty when the filters hide every enchant

## **Version 3.0.0.3**

- Fixed the "Enchant" button in the enchanting window not enchanting the selected item (Thanks **Subfocu5**)
- The "replace existing enchantment" confirmation is now accepted automatically
- Fixed the enchantment and item lists not scrolling when they are longer than the visible area
- Fixed duplicate frame names of the craft filter buttons and the craft type colors
- Fixed the enchanting window not reopening after closing it with Escape

## **Version 3.0.0.2**

- Restored TBC Classic support (interface 20505 and 20506) on the same branch, using `DisenchanterPlus_TBC.toc`
- TBC client detection by project ID (`WOW_PROJECT_BURNING_CRUSADE_CLASSIC`), so both interface numbers share the same code
- Restored the TBC disenchant table and the TBC branches in the database, tooltip, tradeskill and enchant window

## **Version 3.0.0.1**

- Fixed enchanting window showing another profession's recipes (e.g. Tailoring) when that profession was open
- Fixed `SetFont` error in the enchanting window (invalid `"NONE"` flag)

## **Version 3.0.0.0**

- Added support for Classic WoW Forever (Camelot) 1.60.x
- Fixed ElvUI_BenikUI error (`ElvUF_Player` was nil) by moving login initialization to `OnEnable`
- Removed TBC Classic support (interface 20505, disenchant table and client branches)

## **Version 2.0.1.6**

- Fixed disenchant table for rare and epic items (TBC)

## **Version 2.0.1.5**

- Minor UI and window overlap improvements

## **Version 2.0.1.4**

- Fixed UI rendering and window layering issues
- Fixed protected field access warnings
- Fixed tooltips displaying when disabled
- Made enchantment names clickable for selection
- Removed non-existent "Material Tracking" feature from documentation
- Updated documentation with bulk enchanting guide

## **Version 2.0.1.3**

- Removed unnecessary log

## **Version 2.0.1.2**

- Fixed disenchant window not reopening after closing with Escape key.
- Fixed state synchronization issue in DisenchantProcess.

## **Version 2.0.1.1**

- Removed unnecessary source files

## **Version 2.0.1.0**

- Fixed enchanting window errors.
- Cataclysm compatibility removed

## **Version 2.0.0.2**

- Added toggle minimap visibility (Thanks to https://github.com/rcouch00)

## **Version 2.0.0.1**

- Fixed a skill check error in Classic TBC.
- Fixed an error where failed disenchants would permanently add items to the ignored list.

## **Version 2.0.0.0**

- Fixed a bug with moving minimap icon.
- Fixed disenchant table for classic TBC.
- Fixed a bug with disenchant table in tooltip.

## **Version 2.0.0.0-RC1**

- Updated to Classic TBC (2.5.5)

## **Version 1.0.9.2**

- Toc version.

## **Version 1.0.9.1**

- Added Enchanting vellums [Cata].
- Minor interface changes.
- Fixed a bug when disabling all settings for enchants.
- Bug fixes.

## **Version 1.0.9.0**

- Added enchanting functionality. You can now select an enchantment, an item, and enchant it continuously without popups (not tested in cataclysm yet).
- Added strings for pending translations (de, fr and it)
- Minor interface changes.
- Corrections for Cata.
- Corrections for the German language.
- Fixed a bug with some events and sending items to the permanently ignore list (Road-block issue).
- Bug fixes.

## **Version 1.0.9.0-alpha3**

- Corrections for Cata.

## **Version 1.0.9.0-alpha2**

- Corrections for the German language.

## **Version 1.0.9.0-alpha1**

- Added enchanting functionality. You can now select an enchantment, an item, and enchant it continuously without popups (not tested in cataclysm yet).
- Added strings for pending translations (de, fr and it)
- Minor interface changes.
- Fixed a bug with some events and sending items to the permanently ignore list (Road-block issue).
- Bug fixes.

## **Version 1.0.8.4**

- Minor changes in main window.
- Fixed an error with items that have been disenchanted and reappear.
- Fixed an error with tooltips in main window.

## **Version 1.0.8.3**

- Fixed a bug with items that could not be disenchanted. They have now been added to the ignore list.
- Fixed a bug when manually disenchanting an item with disenchant option disabled in settings frame (Road-block issue).
- Fixed a bug when starting / stopping disenchanting process from main window.
- Fixed a bug with spell casting events. They would not start properly when they failed or were interrupted.

## **Version 1.0.8.2**

- Fixed a bug with combat lockdown and looting items.
- Fixed a bug when entering combat.

## **Version 1.0.8.1**

- Fixed a bug when an item did not have an auction price.

## **Version 1.0.8.0**

- Integration with Auctionator. Auction prices are displayed in the tooltip if installed. Configurable.

## **Version 1.0.7.2**

- Fixed disenchant table for Classic Era

## **Version 1.0.7.1**

- Fixed disenchant table for Cataclysm

## **Version 1.0.7**

- Settings panel redone.
- Fixed a bug in Cata with disenchanting tables (Road-block issue).
- Fixed a bug when entering combat if main frame has not been initialized.
- Code cleanup.
- Bug fixes.

## **Version 1.0.7-alpha1**

- Settings panel redone.
- Fixed an issue where the "Press Key to Show" option for tooltip disenchant information didn't seem to do anything. (Road-block issue)
- Code cleanup.

## **Version 1.0.6**

- Closing the main window now does not pause the automatic disenchant.
- Added an option to the settings to show/hide the qualities that are going to be disenchanted
- Fixed a bug with combat lockdown.
- Fixed a bug when displaying the item name in the disenchant window

## **Version 1.0.5**

- Bug fixes.

## **Version 1.0.4**

- Added qualities that can be disenchanted in disenchant window.
- Added keybind support to accept, cancel and ignore items.
- Added window with ignored items tabbed by permanent or session.
- Fixed a bug with Blizzard_SharedXML and GetItemInfoFromHyperlink.
- Fixed tooltips on generic items.
- Lib update.
- Bug fixes.

## **Version 1.0.4-alpha3**

- Added keybindings for cancel and ignore items.
- Added qualities that can be disenchanted in disenchant window.

## **Version 1.0.4-alpha2**

- Added keybind support to accept disenchant.
- Fixed a bug with Blizzard_SharedXML and GetItemInfoFromHyperlink.
- Lib update.

## **Version 1.0.4-alpha1**

- Added window with ignored items tabbed by permanent or session.
- Bug fixes.

## **Version 1.0.3**

- Corrections in project.

## **Version 1.0.2**

- Fixed the minimap icon not updating when auto disenchant status changes.

## **Version 1.0.1**

- Can now start/stop auto disenchant from minimap button.
- Can now open disenchant window when there are no items to disenchant (to clean ignored/session lists).
- Added button to start/stop auto disenchant in the main disenchant window.
- Bug fixes

## **Version 1.0.0**

- First release.

## **Version 0.0.1**

- Alpha release.
