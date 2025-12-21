# 🕐 cronwhisper.nvim
<img width="1260" height="200" alt="image" src="https://github.com/user-attachments/assets/ab6ead37-77c8-4c6b-9d27-e43d77a7ee40" />
<img width="1260" height="200" alt="image" src="https://github.com/user-attachments/assets/c862333b-e7b9-407f-a72e-61b7ddda0824" />
<img width="1786" height="352" alt="image" src="https://github.com/user-attachments/assets/1478c2f3-e73a-410f-9956-c1d2cc280f49" />

**Cron expression parser and human-readable describer for Neovim**

## ✨ Features

- 🔍 **Real-time descriptions** - Ghost text updates as you type
- ✅ **Syntax validation** - Instant feedback on invalid expressions
- 📖 **Natural language** - Descriptions match [crontab.guru](https://crontab.guru/) format
- 🎯 **Zero configuration** - Works out of the box with sensible defaults
- ⚡ **Performance optimized** - Dual-cache system prevents redundant parsing
- 🔧 **Flexible** - Auto-describe can be toggled, customizable highlight groups
- 📦 **Comprehensive** - Supports special commands (`@daily`, `@hourly`, etc.)
  
## 📋 Supported Formats

### Standard Cron Expressions
```cron
0 12 * * * command.sh         # At 12:00
*/5 * * * * backup.sh         # At every 5 minutes
0 0 * * 1-5 workday.sh        # At 00:00 on every day-of-week from Monday through Friday
```

### Special Commands
```cron
@reboot    # Run at startup
@yearly    # Run once a year (0 0 1 1 *)
@annually  # Same as @yearly
@monthly   # Run once a month (0 0 1 * *)
@weekly    # Run once a week (0 0 * * 0)
@daily     # Run once a day (0 0 * * *)
@hourly    # Run once an hour (0 * * * *)
```

## ⚡ Requirements

- Neovim >= 0.8.0
- Optional: [busted](https://lunarmodules.github.io/busted/) for running tests

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "FromWau/cronwhisper.nvim",
  ft = "cron",  -- Lazy load on cron filetype
  opts = {
    -- your configuration comes here
    -- or leave empty to use defaults
  },
}
```

### [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "FromWau/cronwhisper.nvim",
  ft = "cron",
  config = function()
    require("cronwhisper").setup({
      -- your configuration
    })
  end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'FromWau/cronwhisper.nvim'
```

Then in your `init.lua`:
```lua
require("cronwhisper").setup()
```

## ⚙️ Configuration

cronwhisper.nvim works great out of the box, but you can customize it to your liking.

### Default Options

<details>
<summary>Click to see default configuration</summary>

```lua
require("cronwhisper").setup({
  -- Floating window options (used by :CronDescribe)
  float_opts = {
    border = "rounded",  -- Border style: "none", "single", "double", "rounded", "solid", "shadow"
    relative = "cursor", -- Position relative to cursor
    row = 1,             -- Row offset
    col = 0,             -- Column offset
  },

  -- Highlight group for virtual text
  virtual_text_hl = "Comment",  -- Use any highlight group

  -- Automatically show descriptions as virtual text
  auto_describe = true,  -- Set to false to disable auto-describe
})
```

</details>

### Configuration Examples

#### Disable Auto-Describe
```lua
require("cronwhisper").setup({
  auto_describe = false,  -- Only show descriptions when using :CronDescribe
})
```

#### Customize Virtual Text Appearance
```lua
require("cronwhisper").setup({
  virtual_text_hl = "DiagnosticHint",  -- Use a different highlight group
})
```

#### Customize Floating Window
```lua
require("cronwhisper").setup({
  float_opts = {
    border = "double",
    relative = "cursor",
    row = 2,
    col = 1,
  },
})
```

## 🚀 Usage

cronwhisper.nvim automatically detects cron files based on patterns:
- `*.cron`
- `crontab`
- `crontab.*`
- Files in `*/cron.d/*`, `*/cron.daily/*`, `*/cron.hourly/*`, etc.

### Automatic Descriptions

When `auto_describe` is enabled (default), descriptions appear as ghost text while you edit:

```cron
0 */2 * * * command.sh
# → "At minute 0 past every 2nd hour" (shown as virtual text)
```

The ghost text updates in real-time as you type, even in insert mode!

### Manual Commands

| Command | Description |
|---------|-------------|
| `:CronDescribe` | Show description in floating window |
| `:CronParse` | Display parsed cron structure (debug view) |
| `:CronValidate` | Validate current line and show result |

### Keybindings

In `cron` filetype buffers:

| Key | Action |
|-----|--------|
| `K` | Show cron description in floating window (overrides default man page lookup) |

### Programmatic Usage

You can also use cronwhisper programmatically in your Lua scripts:

```lua
local cronwhisper = require("cronwhisper")

-- Parse and describe a cron expression
local description, err = cronwhisper.describe("0 12 * * *")
if description then
  print(description)  -- "At 12:00"
else
  print("Error:", err)
end

-- Parse a cron expression
local parsed, err = cronwhisper.parse("*/5 * * * *")
if parsed then
  vim.print(parsed)  -- Shows parsed structure
end
```

## 🎨 Customization

### Highlight Groups

cronwhisper uses the following highlight group for virtual text:
- `virtual_text_hl` (default: `Comment`)

You can link it to any existing highlight group:

```lua
require("cronwhisper").setup({
  virtual_text_hl = "DiagnosticHint",
})
```

Or create your own:

```vim
highlight CronDescription guifg=#6c7086 gui=italic
```

```lua
require("cronwhisper").setup({
  virtual_text_hl = "CronDescription",
})
```
