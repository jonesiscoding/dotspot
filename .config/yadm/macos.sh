# shellcheck shell=bash

source functions.sh

configure_macos() {

  ### region ############################################ Prep

  # Close any open System Preferences panes, to prevent them from overriding
  # settings we’re about to change
  osascript -e 'tell application "System Preferences" to quit'

  if _isMacSudo; then
    # Keep-alive: update existing `sudo` time stamp until `configure_macos` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  fi

  ### endregion ######################################### Prep

  ### region ############################################ General UI/UX

  # Increase window resize speed for Cocoa applications
  defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

  # Expand save panel by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Expand print panel by default
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Remove duplicates in the “Open With” menu (also see `lscleanup` alias)
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

  # Disable automatic capitalization as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable automatic period substitution as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  ### endregion ######################################### General UI/UX

  ### region ############################################ Input Devices

  # Trackpad: enable tap to click for this user and for the login screen
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Enable Three Finger Drag
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

  ### endregion ######################################### Input Devices

  ### region ############################################ Energy Saver

  if $isSudoer; then
    # Enable lid wakeup
    sudo pmset -a lidwake 1

    # Restart automatically on power loss
    sudo pmset -a autorestart 1

    # Restart automatically if the computer freezes
    sudo systemsetup -setrestartfreeze on
  fi

  ### endregion ######################################### Energy Saver

  ### region ############################################ Display

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Save screenshots to the desktop
  defaults write com.apple.screencapture location -string "${HOME}/Desktop"

  # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
  defaults write com.apple.screencapture type -string "png"

  # Disable shadow in screenshots
  defaults write com.apple.screencapture disable-shadow -bool true

  # Enable subpixel font rendering on non-Apple LCDs
  # Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
  defaults write NSGlobalDomain AppleFontSmoothing -int 1

  # Enable HiDPI display modes (requires restart)
  if $isSudoer; then
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true
  fi

  ### endregion ######################################### Display

  ### region ############################################ Finder & Time Machine

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  # Set Desktop as the default location for new Finder windows
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfDe"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

  # Show icons for hard drives, servers, and removable media on the desktop
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

  # Finder: show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true

  # Finder: show path bar
  defaults write com.apple.finder ShowPathbar -bool true

  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Enable spring loading for directories
  defaults write NSGlobalDomain com.apple.springing.enabled -bool true

  # Remove the spring loading delay for directories
  defaults write NSGlobalDomain com.apple.springing.delay -float 0

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Automatically open a new Finder window when a volume is mounted
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Expand the following File Info panes:
  # “General”, “Open with”
  defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true

  # Show the Library Folder
  chflags nohidden ~/Library

  # Show the /Volumes folder
  if $isSudoer; then
    sudo chflags nohidden /Volumes
  fi

  ### endregion ######################################### Finder & Time Machine

  ### region ############################################ Dock, Dashboard, Hot Corners

  # Enable highlight hover effect for the grid view of a stack (Dock)
  defaults write com.apple.dock mouse-over-hilite-stack -bool true

  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36

  # Enable spring loading for all Dock items
  defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Speed up Mission Control animations
  defaults write com.apple.dock expose-animation-duration -float 0.1

  # Disable Dashboard
  defaults write com.apple.dashboard mcx-disabled -bool true

  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true

  # Don’t automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  # Make Dock icons of hidden applications translucent
  defaults write com.apple.dock showhidden -bool true

  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  # Add iOS & Watch Simulator to Launchpad
  if $isSudoer && [ -f "/Applications/Xcode.app" ]; then
    sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
    sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"
  fi

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # 13: Lock Screen
  # Bottom left screen corner → Start screen saver
  defaults write com.apple.dock wvous-bl-corner -int 5
  defaults write com.apple.dock wvous-bl-modifier -int 0

  ### endregion ######################################### Dock, Dashboard, Hot Corners

  ### region ############################################ Safari Tweaks

  # Privacy: don’t send search queries to Apple
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true

  # Allow hitting the Backspace key to go to the previous page in history
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool false

  # Enable Safari’s debug menu
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

  # Make Safari’s search banners default to Contains instead of Starts With
  defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Warn about fraudulent websites
  defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

  # Disable auto-playing video
  defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
  defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
  defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

  # Enable “Do Not Track”
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  # Update extensions automatically
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

  ### endregion ######################################### Safari Tweaks

  ### region ############################################ Spotlight

  # Disable Spotlight indexing for any volume that gets mounted and has not yet
  # been indexed before.
  if $isSudoer; then
    sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
  fi

  # Change indexing order and disable some search results
  defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 1;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 1;"name" = "IMAGES";}' \
    '{"enabled" = 1;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 1;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 0;"name" = "SOURCE";}' \
    '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
  # Load new settings before rebuilding the index
  killall mds >/dev/null 2>&1

  if $isSudoer; then
    # Make sure indexing is enabled for the main volume
    sudo mdutil -i on / >/dev/null
    # Rebuild the index from scratch
    sudo mdutil -E / >/dev/null
  fi

  ### endregion ######################################### Spotlight

  ### region ############################################ Application Behavior

  # Only use UTF-8 in Terminal.app
  defaults write com.apple.terminal StringEncodings -array 4

  # Don’t display the annoying prompt when quitting iTerm
  defaults write com.googlecode.iterm2 PromptOnQuit -bool false

  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

  ### endregion ######################################### Application Behavior

  ### region ############################################ Cleanup

  for app in "Activity Monitor" \
    "Address Book" \
    "Calendar" \
    "cfprefsd" \
    "Contacts" \
    "Dock" \
    "Finder" \
    "Google Chrome Canary" \
    "Google Chrome" \
    "Photos" \
    "Safari" \
    "SystemUIServer" \
    "Terminal"; do
    killall "${app}" &>/dev/null
  done

  ### endregion ######################################### End Cleanup
}
