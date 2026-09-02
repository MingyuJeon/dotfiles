#!/bin/bash
# cmux preferences (macOS defaults, domain com.cmuxterm.app)
# Terminal font/appearance is NOT here: cmux reads ../ghostty/config (~/.config/ghostty/config).
# To refresh after changing settings in the app:  defaults export com.cmuxterm.app -

set -e
D=com.cmuxterm.app

# General
defaults write $D appearanceMode -string "system"
defaults write $D browserThemeMode -string "system"
defaults write $D browserOpenTerminalLinksInCmuxBrowser -bool false
defaults write $D notificationSound -string "Blow"
defaults write $D cmuxWelcomeShown -bool true

# Sidebar
defaults write $D sidebarPreset -string "nativeSidebar"
defaults write $D sidebarState -string "followWindow"
defaults write $D sidebarMaterial -string "sidebar"
defaults write $D sidebarBlendMode -string "withinWindow"
defaults write $D sidebarBlurOpacity -float 1
defaults write $D sidebarCornerRadius -float 0
defaults write $D sidebarHideAllDetails -bool true
defaults write $D sidebarTintHex -string "#000000"
defaults write $D sidebarTintOpacity -float 0.18

echo "  Applied cmux defaults ($D) - restart cmux to take effect"
