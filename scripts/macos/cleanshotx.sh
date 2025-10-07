# Setup script for 'CleanShot X'

osascript -e 'tell application "CleanShot X" to quit'

defaults write pl.maketheweb.cleanshotx mediaNameTemplate -array "%y" "%m" "%d" "%H" "%M" "%S"
defaults write pl.maketheweb.cleanshotx add2xRetinaSuffix -string 0
defaults write pl.maketheweb.cleanshotx addFrameToScreenshots -string 0
defaults write pl.maketheweb.cleanshotx afterScreenshotActions -array "3"
defaults write pl.maketheweb.cleanshotx analyticsAllowed -string 0
defaults write pl.maketheweb.cleanshotx autoClosePopup -string 0
defaults write pl.maketheweb.cleanshotx automaticallyCheckForUpdates -string 0
defaults write pl.maketheweb.cleanshotx deletePopupAfterDragging -string 1
defaults write pl.maketheweb.cleanshotx deletePopupAfterUploading -string 0
defaults write pl.maketheweb.cleanshotx dimScreenWhileRecording -string 1
defaults write pl.maketheweb.cleanshotx exportPath -string "$HOME/Documents/Screenshots"
defaults write pl.maketheweb.cleanshotx highlightClicks -string 1
defaults write pl.maketheweb.cleanshotx popupAskForDestinationWhenSaving -string 0
defaults write pl.maketheweb.cleanshotx popupAutoCloseMode -string 1
defaults write pl.maketheweb.cleanshotx popupSize -string 2
defaults write pl.maketheweb.cleanshotx recordComputerAudio -string 1
defaults write pl.maketheweb.cleanshotx screenshotFormat -string png
defaults write pl.maketheweb.cleanshotx screenshotSound -string 4
defaults write pl.maketheweb.cleanshotx showCursorOnRecordings -string 1
defaults write pl.maketheweb.cleanshotx showKeystrokes -string 1
defaults write pl.maketheweb.cleanshotx showMenubarIcon -string 1
defaults write pl.maketheweb.cleanshotx useUTCTimezoneInFilename -string 0
defaults write pl.maketheweb.cleanshotx windowBackgroundPadding -string 2
defaults write pl.maketheweb.cleanshotx transparentWindowBackground -string 0

killall "CleanShot X"
