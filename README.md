# Disenchanter Plus

A powerful World of Warcraft addon for managing enchantment materials and automating the disenchanting process. Track essences obtained from disenchanting, get expected material yields, auto-disenchant items, and integrate with Auctionator for price data.

## ✨ Features

- ** Expected Materials Display:** View what materials you'll get before disenchanting an item.
- **⚙️ Auto-Disenchant:** Automatically disenchant items in your inventory based on quality and custom filters.
- **🎨 Bulk Enchanting:** Apply enchantments to multiple items efficiently with a streamlined mass enchanting interface.
- **💰 Auctionator Integration:** See last auction house prices in tooltips for enchanting materials.
- **🎯 Advanced Filtering:** Filter disenchant items by quality (Uncommon, Rare, Epic) and custom exclusion lists.
- **📊 Database Management:** Automatic tracking and archiving of disenchanting history.
- **🔧 Extensive Configuration:** Fine-tune every aspect of the addon via the settings window.

## 🚀 Quick Start

1. **Install the addon** (see [Installation](#installation) below)
2. **Open the addon:** `/dplus` to see available commands
3. **Configure settings:** `/dplus config` to customize behavior
4. **Enable enchanting:** Toggle the enchanting module in settings if needed
5. **Start disenchanting:** Open your disenchant window or use auto-disenchant feature

## 📋 Slash Commands

The addon provides the following slash commands:

| Command          | Description                                     |
| ---------------- | ----------------------------------------------- |
| `/dplus`         | Display help information and available commands |
| `/dplus config`  | Open the configuration/settings window          |
| `/dplus minimap` | Toggle minimap icon visibility                  |

## 🎮 Compatibility

### Supported Versions

- **Classic WoW** (Season of Discovery, Classic Hardcore, Classic Anniversary)

### Requirements

- World of Warcraft (supported versions listed above)
- Ace3 library (included)

## 📦 Installation

### Step 1: Download

Get the addon from one of these sources:

- **[CurseForge](https://www.curseforge.com/wow/addons/disenchater-plus)** (Recommended)
- **[GitHub Releases](https://github.com/osilvay/DisenchanterPlus/releases)**

### Step 2: Extract

Extract the downloaded file to your WoW AddOns folder:

**For Classic WoW (Season of Discovery, Classic Hardcore):**

```
World of Warcraft/_classic_era_/Interface/AddOns/
```

**For Classic WoW Anniversary:**

```
World of Warcraft/_anniversary_/Interface/AddOns/
```

### Step 3: Restart

- **Restart World of Warcraft**, or
- **Run `/reload`** at your game console to reload without restarting

The addon should now appear in your AddOns list and be ready to use!

## ⚙️ Configuration

Access the settings window with `/dplus config` to customize:

- **Quality Filters:** Choose which item quality to auto-disenchant (Uncommon, Rare, Epic)
- **Material Filtering:** Filter by material availability
- **Custom Exclusions:** Add specific items to ignore
- **UI Preferences:** Minimap icon position, frame location, etc.

## 🏗️ Architecture

The addon is modular with the following key components:

- **EnchantWindow.lua** - Main enchanting UI
- **DisenchantWindow.lua** - Item selection and disenchanting interface
- **TradeskillCheck.lua** - Profession detection and validation
- **Database.lua** - Material history and statistics
- **EnchantProcess.lua** - Spell casting and enchanting logic
- **DisenchantProcess.lua** - Item processing and automation

## 🐛 Troubleshooting

### "You don't have Enchanting profession"

- Make sure your character has the Enchanting profession learned
- Open your Enchanting tradeskill window to verify

### "You need to open the enchanting tradeskill book"

- Open your Enchanting tradeskill window from your spellbook
- The addon will then display available enchantments

### Items not auto-disenchanting

- Check your quality filters in `/dplus config`
- Verify the item isn't in your custom exclusion list
- Ensure items meet the material availability filter

### Minimap button not showing

- Run `/dplus minimap` to toggle it back on
- Check that the minimap icon setting is enabled in config

## ❓ Frequently Asked Questions

### How do I use the Bulk Enchanting feature?

The Bulk Enchanting window works differently from Auto-Disenchant. Here's the proper workflow:

1. **Open your Enchanting Tradeskill** from your spellbook
2. **Make sure the tradeskill window stays open** - the addon detects it
3. **Click the enchant window button** (wand icon) in the disenchant window OR access it via minimap icon
4. **Click "Refresh"** in the enchant window to load available enchantments
5. **Select an enchantment** from the LEFT list (e.g., "Enchant Bracer - +5 Health")
6. **Select an item** from the RIGHT list (items in your bags that can be enchanted with that spell appear here)
7. **Click the green checkmark** to enchant the item

**Important Notes:**

- Items only appear on the right when you select an enchantment on the left
- **The addon only shows items in your bags/inventory - NOT items you currently have equipped**
- If you want to enchant an equipped item, you must first unequip it and put it in your bags
- The addon automatically filters items based on enchantment type (bracers with bracer enchants, weapons with weapon enchants, etc.)
- You must have the materials/reagents required for the enchantment
- Keep your Enchanting tradeskill window open while enchanting

## 📝 Localization

The addon includes translations for:

- English (en)
- Spanish (es)
- German (de)
- French (fr)
- Italian (it)

## 🤝 Contributing & Feedback

Your feedback helps make Disenchanter Plus better!

### Report Issues

Found a bug? Report it on **[GitHub Issues](https://github.com/osilvay/DisenchanterPlus/issues)**

Please include:

- Your WoW version (Classic Era, SoD, Cataclysm, etc.)
- Steps to reproduce the issue
- Any error messages from the game console

### Suggestions

Have ideas for new features? Open a **[GitHub Discussion](https://github.com/osilvay/DisenchanterPlus/discussions)** or **[GitHub Issue](https://github.com/osilvay/DisenchanterPlus/issues)**

## 📄 License

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

This addon is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

**Copyright © 2024 [osilvay]**

### WoW Terms of Service

- This addon must be used in compliance with [Blizzard's Terms of Service](https://www.blizzard.com/en-us/legal/)
- Addon provided "as-is" without warranty
- This is a community addon and is not affiliated with or endorsed by Blizzard Entertainment

## 🙏 Acknowledgments

- Built with **[Ace3](https://www.wowace.com/projects/ace3)** framework
- Thanks to all the testers and contributors
- Special thanks to the Classic WoW community
