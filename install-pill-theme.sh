#!/bin/bash
#
# Waybar Pill Theme Installer for Omarchy
# 
# This script applies a pill-style waybar theme to any Omarchy system.
# It creates backups before making changes and can be safely run multiple times.
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
BACKUP_DIR="$HOME/.config/waybar/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo -e "${GREEN}=== Waybar Pill Theme Installer for Omarchy ===${NC}"
echo ""

# Check if this is an Omarchy system
if [ -z "$OMARCHY_PATH" ] && [ ! -d "$HOME/.local/share/omarchy" ]; then
    echo -e "${RED}Error: This doesn't appear to be an Omarchy system.${NC}"
    echo "OMARCHY_PATH is not set and ~/.local/share/omarchy doesn't exist."
    exit 1
fi

echo -e "${GREEN}✓${NC} Omarchy system detected"

# Check if waybar config directory exists
if [ ! -d "$WAYBAR_CONFIG_DIR" ]; then
    echo -e "${YELLOW}Creating waybar config directory...${NC}"
    mkdir -p "$WAYBAR_CONFIG_DIR"
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup existing config if it exists
if [ -f "$WAYBAR_CONFIG_DIR/config.jsonc" ]; then
    echo -e "${YELLOW}Backing up existing config.jsonc...${NC}"
    cp "$WAYBAR_CONFIG_DIR/config.jsonc" "$BACKUP_DIR/config.jsonc.$TIMESTAMP"
fi

if [ -f "$WAYBAR_CONFIG_DIR/style.css" ]; then
    echo -e "${YELLOW}Backing up existing style.css...${NC}"
    cp "$WAYBAR_CONFIG_DIR/style.css" "$BACKUP_DIR/style.css.$TIMESTAMP"
fi

echo -e "${GREEN}✓${NC} Backups created in $BACKUP_DIR"

# Write the pill-style config.jsonc
echo -e "${YELLOW}Writing pill-style config.jsonc...${NC}"
cat > "$WAYBAR_CONFIG_DIR/config.jsonc" << 'CONFIGEOF'
{
  "reload_style_on_change": true,
  "layer": "bottom",
  "margin-top": 5,
  "margin-bottom": 0,
  "margin-left": 5,
  "margin-right": 5,
  "position": "top",
  "spacing": 0,
  "width": 1000,
  "height": 28,
  "modules-left": ["custom/omarchy", "hyprland/workspaces", "mpris"],
  "modules-center": ["clock", "custom/update", "custom/voxtype", "custom/screenrecording-indicator"],
  "modules-right": [
    "group/tray-expander",
    "bluetooth",
    "network",
    "pulseaudio",
    "cpu",
    "battery"
  ],
  "hyprland/workspaces": {
    "on-click": "activate",
    "format": "{icon}",
    "format-icons": {
      "default": "",
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5",
      "6": "6",
      "7": "7",
      "8": "8",
      "9": "9",
      "10": "0",
      "active": "󱓻"
    },
    "persistent-workspaces": {
      "1": [],
      "2": [],
      "3": [],
      "4": [],
      "5": []
    }
  },
  "custom/omarchy": {
    "format": "<span font='omarchy'>\ue900</span>",
    "on-click": "omarchy-menu",
    "on-click-right": "xdg-terminal-exec",
    "tooltip-format": "Omarchy Menu\n\nSuper + Alt + Space"
  },
  "mpris": {
    "format": "<span size='x-large'>󰎆</span> <span rise='2000'>│ {title}</span>",
    "format-paused": "<span size='x-large'>󰎄</span> <span rise='2000'>│ {title}</span>",
    "max-length": 30,
    "on-click": "playerctl play-pause",
    "on-click-right": "playerctl next",
    "on-scroll-up": "playerctl volume 0.05+",
    "on-scroll-down": "playerctl volume 0.05-",
    "tooltip-format": "{player}: {title} - {artist}\n{album}"
  },
  "custom/update": {
    "format": "",
    "exec": "omarchy-update-available",
    "on-click": "omarchy-launch-floating-terminal-with-presentation omarchy-update",
    "tooltip-format": "Omarchy update available",
    "signal": 7,
    "interval": 21600
  },
  "cpu": {
    "interval": 5,
    "format": "󰍛",
    "on-click": "omarchy-launch-or-focus-tui btop",
    "on-click-right": "alacritty"
  },
  "clock": {
    "format": "{:%A %H:%M}",
    "tooltip": false,
    "on-click": "gnome-calendar"
  },
  "network": {
    "format-icons": ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"],
    "format": "{icon}",
    "format-wifi": "{icon}",
    "format-ethernet": "󰀂",
    "format-disconnected": "󰤮",
    "tooltip-format-wifi": "{essid} ({frequency} GHz)\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}",
    "tooltip-format-ethernet": "⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}",
    "tooltip-format-disconnected": "Disconnected",
    "interval": 3,
    "spacing": 1,
    "on-click": "omarchy-launch-wifi"
  },
  "battery": {
    "format": "{capacity}% {icon}",
    "format-discharging": "{icon}",
    "format-charging": "{icon}",
    "format-plugged": "",
    "format-icons": {
      "charging": ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"],
      "default": ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    },
    "format-full": "󰂅",
    "tooltip-format-discharging": "{power:>1.0f}W↓ {capacity}%",
    "tooltip-format-charging": "{power:>1.0f}W↑ {capacity}%",
    "interval": 5,
    "on-click": "omarchy-menu power",
    "states": {
      "warning": 20,
      "critical": 10
    }
  },
  "bluetooth": {
    "format": "",
    "format-off": "󰂲",
    "format-disabled": "󰂲",
    "format-connected": "󰂱",
    "format-no-controller": "",
    "tooltip-format": "Devices connected: {num_connections}",
    "on-click": "omarchy-launch-bluetooth"
  },
  "pulseaudio": {
    "format": "{icon}",
    "on-click": "omarchy-launch-audio",
    "on-click-right": "pamixer -t",
    "tooltip-format": "Playing at {volume}%",
    "scroll-step": 5,
    "format-muted": "",
    "format-icons": {
      "headphone": "",
      "default": ["", "", ""]
    }
  },
  "group/tray-expander": {
    "orientation": "inherit",
    "drawer": {
      "transition-duration": 600,
      "children-class": "tray-group-item"
    },
    "modules": ["custom/expand-icon", "tray"]
  },
  "custom/expand-icon": {
    "format": "",
    "tooltip": false,
    "on-scroll-up": "",
    "on-scroll-down": "",
    "on-scroll-left": "",
    "on-scroll-right": ""
  },
  "custom/screenrecording-indicator": {
    "on-click": "omarchy-cmd-screenrecord",
    "exec": "$OMARCHY_PATH/default/waybar/indicators/screen-recording.sh",
    "signal": 8,
    "return-type": "json"
  },
  "custom/voxtype": {
    "exec": "omarchy-voxtype-status",
    "return-type": "json",
    "format": "{icon}",
    "format-icons": {
      "idle": "",
      "recording": "󰍬",
      "transcribing": "󰔟"
    },
    "tooltip": true,
    "on-click-right": "omarchy-voxtype-config",
    "on-click": "omarchy-voxtype-model"
  },
  "tray": {
    "icon-size": 12,
    "spacing": 17
  }
}
CONFIGEOF

echo -e "${GREEN}✓${NC} config.jsonc written"

# Write the pill-style style.css
echo -e "${YELLOW}Writing pill-style style.css...${NC}"
cat > "$WAYBAR_CONFIG_DIR/style.css" << 'STYLEEOF'
@import "../omarchy/current/theme/waybar.css";

* {
  background: transparent;
  color: @foreground;
  border: none;
  min-height: 0;
  font-family: 'JetBrainsMono Nerd Font';
  font-size: 12px;
}

window#waybar {
  background-color: @background;
  border-radius: 10px;
}

.modules-left {
  margin-left: 8px;
}

.modules-right {
  margin-right: 8px;
}

#workspaces button {
  all: initial;
  color: @foreground;
  font-family: 'JetBrainsMono Nerd Font';
  padding: 0 6px;
  margin: 0 1.5px;
  min-width: 9px;
}

#workspaces button.empty {
  opacity: 0.5;
}

#mpris {
  margin-left: 10px;
  padding: 0 8px;
  font-size: 12px;
}

#mpris.paused {
  opacity: 0.7;
}

#cpu,
#battery,
#pulseaudio,
#custom-omarchy,
#custom-screenrecording-indicator,
#custom-update {
  min-width: 12px;
  margin: 0 7.5px;
}

#tray {
  margin-right: 16px;
}

#tray menu {
  background-color: @background;
  color: @foreground;
  border: 1px solid alpha(@foreground, 0.2);
  padding: 6px;
}

#tray menu menuitem {
  background-color: transparent;
  color: @foreground;
  border: none;
  padding: 6px 10px;
  font-family: 'JetBrainsMono Nerd Font';
  font-size: 11px;
  outline: none;
  box-shadow: none;
}

#tray menu menuitem:hover {
  background-color: alpha(@foreground, 0.1);
}

#tray menu separator {
  background-color: alpha(@foreground, 0.15);
  margin: 4px 8px;
}

#bluetooth {
  margin-right: 17px;
}

#network {
  margin-right: 13px;
}

#custom-expand-icon {
  margin-right: 18px;
}

tooltip {
  background-color: @background;
  color: @foreground;
  border: 1px solid alpha(@foreground, 0.15);
  border-radius: 12px;
  padding: 8px 12px;
  font-family: 'JetBrainsMono Nerd Font';
  font-size: 11px;
}

tooltip label {
  color: @foreground;
  font-family: 'JetBrainsMono Nerd Font';
}

#custom-update {
  font-size: 10px;
}

#clock {
  margin-left: 8.75px;
}

.hidden {
  opacity: 0;
}

#custom-screenrecording-indicator {
  min-width: 12px;
  margin-left: 5px;
  font-size: 10px;
  padding-bottom: 1px;
}

#custom-screenrecording-indicator.active {
  color: #D14D41;
}

#custom-voxtype {
  min-width: 12px;
  margin: 0 0 0 7.5px;
}

#custom-voxtype.recording {
  color: #D14D41;
}
STYLEEOF

echo -e "${GREEN}✓${NC} style.css written"

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "The pill-style waybar theme has been applied!"
echo ""
echo "Features:"
echo "  • Rounded bar with 10px border-radius"
echo "  • Centered floating bar (1000px width)"
echo "  • 5px margins on all sides"
echo "  • Theme-adaptive colors (follows omarchy theme)"
echo "  • Styled tooltips with rounded corners"
echo "  • Clock shows day + time, left-click opens gnome-calendar"
echo "  • Media controls (mpris) with play/pause, next track"
echo ""
echo "Requirements:"
echo "  • playerctl (for media controls): sudo pacman -S playerctl"
echo ""
echo "Backups saved to: $BACKUP_DIR"
echo ""
echo "To restore the original config, run:"
echo "  cp $BACKUP_DIR/config.jsonc.$TIMESTAMP $WAYBAR_CONFIG_DIR/config.jsonc"
echo "  cp $BACKUP_DIR/style.css.$TIMESTAMP $WAYBAR_CONFIG_DIR/style.css"
echo ""
echo "Waybar should auto-reload. If not, restart it with:"
echo "  killall waybar && waybar &"
