# Setup script for 'Alt Tab' app.

osascript -e 'tell application "AltTab" to quit'

# Shortcuts and mouse
defaults write com.lwouis.alt-tab-macos holdShortcut -string "⌘"
defaults write com.lwouis.alt-tab-macos focusWindowShortcut -string "↩"
defaults write com.lwouis.alt-tab-macos mouseHoverEnabled -string true
defaults write com.lwouis.alt-tab-macos vimKeysEnabled -string true

# Appearance
defaults write com.lwouis.alt-tab-macos appearanceSize -string "1"
defaults write com.lwouis.alt-tab-macos appearanceStyle -string "2"
defaults write com.lwouis.alt-tab-macos appearanceTheme -string "2"
defaults write com.lwouis.alt-tab-macos appearanceVisibility -string "0"

defaults write com.lwouis.alt-tab-macos startAtLogin -string true

defaults write com.lwouis.alt-tab-macos menubarIcon -string 0
defaults write com.lwouis.alt-tab-macos menubarIconShown -string true

defaults write com.lwouis.alt-tab-macos cursorFollowFocusEnabled -string true
defaults write com.lwouis.alt-tab-macos cursorFollowFocus -string 1
# Leave this empty:
defaults write com.lwouis.alt-tab-macos hideShowAppShortcut -string ""
defaults write com.lwouis.alt-tab-macos previewFocusedWindow -string false
defaults write com.lwouis.alt-tab-macos hideAppBadges -string false
defaults write com.lwouis.alt-tab-macos showHiddenWindows -string 2
defaults write com.lwouis.alt-tab-macos showTabsAsWindows -string false
defaults write com.lwouis.alt-tab-macos showAppsOrWindows -string 1
defaults write com.lwouis.alt-tab-macos showTitles -string 2
defaults write com.lwouis.alt-tab-macos titleTruncation -string 1
defaults write com.lwouis.alt-tab-macos hideColoredCircles -string true
defaults write com.lwouis.alt-tab-macos hideSpaceNumberLabels -string true
defaults write com.lwouis.alt-tab-macos hideStatusIcons -string false
defaults write com.lwouis.alt-tab-macos hideThumbnails -string false
defaults write com.lwouis.alt-tab-macos hideWindowlessApps -string false

killall AltTab
