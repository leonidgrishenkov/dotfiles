#!/usr/bin/env bash
# vim: set filetype=bash:
# vim: set ts=4 sw=4 et:
#
# This is a base setup script for MacOS with my favourite settings.
#
# Some commands have been taken from these repos:
#   - https://github.com/darrylabbate/dotfiles/blob/master/macos/defaults.sh
#   - https://github.com/sobolevn/dotfiles/blob/master/macos/settings.sh
#   - https://github.com/skwp/dotfiles/blob/master/bin/macos
#   - https://github.com/mathiasbynens/dotfiles/blob/master/.macos

set -e

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Now, you can move windows by holding ctrl + cmd and dragging any part of the window (not necessarily the window title)
defaults write -g NSWindowShouldDragOnGesture -bool true

# Scrollbars visible when scrolling
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"

defaults write NSGlobalDomain AppleLocale -string "en_RU"

# === Dock ===
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Change dock orientation
defaults write com.apple.dock orientation -string right

# Don't show recent apps in dock
defaults write com.apple.dock show-recents -bool false

# Change the Dock minimize animation.
defaults write com.apple.dock mineffect -string scale

# Only show opened apps in Dock. I like to keep Dock clean. :)
defaults write com.apple.dock static-only -bool true

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# === Finder ===
# Show hidden files inside the Finder
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

# Show file extensions in Finder:
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Set the default view style for folders without custom setting
defaults write com.apple.finder "FXPreferredViewStyle" -string "Nlsv" 

# Keep folders on top
defaults write com.apple.finder "_FXSortFoldersFirst" -bool "true"

# Set the default search scope when performing a search. Search the current folder
defaults write com.apple.finder "FXDefaultSearchScope" -string "SCcf"

# Always show folder icon before title in the title bar
defaults write com.apple.universalaccess "showWindowTitlebarIcons" -bool "true"

# Choose the size of Finder sidebar icons. 2 - medium
defaults write NSGlobalDomain "NSTableViewDefaultSizeMode" -int "2"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Show Library folder
chflags nohidden ~/Library

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show path bar
defaults write com.apple.finder "ShowPathbar" -bool "true"

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Do not show status bar in Finder:
defaults write com.apple.finder ShowStatusBar -bool false

# New Finder window opens in home directory
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Disable window animations and Get Info animations in Finder
defaults write com.apple.finder DisableAllAnimations -bool true

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

# === Trackpad ===
# Enable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# === Menu Bar ===
# Menu bar clock appearance
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 2
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false
defaults write com.apple.menuextra.clock ShowSeconds -bool false

# === App Store ===
# Disable in-app rating requests from apps downloaded from the App Store.
defaults write com.apple.appstore InAppReviewEnabled -int 0

# === Text editing ===
# Disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Play feedback when volume is changed ?
defaults write NSGlobalDomain "com.apple.sound.beep.feedback" -int 1

# Set FN key to act as standard function key modifier
defaults write NSGlobalDomain "com.apple.keyboard.fnState" -bool true

killall Finder
killall Dock

# In order to some settings take precedence you need either logout-login or run command below.
# Discusssed here: https://apple.stackexchange.com/questions/48112/how-to-change-tap-to-click-using-defaults-write-from-command-line/48126#48126
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
