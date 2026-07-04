#!/bin/bash
# macOS system defaults for a fresh install or dotfiles restore.

set -euo pipefail

echo "==> Applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true

# Finder
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"
defaults write com.apple.finder QuitMenuItem -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredGroupBy -string "Kind"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Global domain
defaults write NSGlobalDomain AppleICUForce24HourTime -bool false
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0.7788008

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 1                    # fastest repeat rate
defaults write NSGlobalDomain InitialKeyRepeat -int 10            # shortest delay until repeat
defaults write com.apple.BezelServices kDim -bool false           # don't adjust keyboard brightness in low light
defaults write NSGlobalDomain AppleKeyboardUIMode -int 0          # disable keyboard navigation (Tab → all controls)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# Screenshot location
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# Login window (optional — requires sudo; skip without aborting other defaults)
echo "==> Login window (optional, requires sudo)..."
if sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false 2>/dev/null; then
  echo "    Guest login disabled"
else
  echo "    Skipped — run manually if needed:"
  echo "    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false"
fi

# Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Restart affected services
echo "==> Restarting Finder, Dock, and SystemUIServer..."
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "==> macOS defaults applied. Some changes may require a logout/restart."
