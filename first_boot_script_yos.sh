#!/bin/bash

# Initial setup script for Mac OS X 10.10.x
# Rich Trouton, created August 20, 2014
# Last modified 9-3-2014
#
# Adapted from Initial setup script for Mac OS X 10.9.x
# Rich Trouton, created August 15, 2013
# Last modified 10-25-2013
#
# Adapted for use at My Company
# Emily Kausalik, 10-28-2014
# Last modified 1-06-2015

# Sleeping for 30 seconds to allow the new default User Template folder to be moved into place

# sleep 30

# Get the system's UUID to set ByHost prefs

if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` == "00000000-0000-1000-8000-" ]]; then
MAC_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c51-62 | awk {'print tolower()'}`
elif [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
MAC_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
fi

# Disable Time Machine's pop-up message whenever an external drive is plugged in

/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Turn on Automatic Time Zone adjustment

defaults write /Library/Preferences/com.apple.timezone.auto "Active" -bool true

# Enable screensaver password requirement - can be disabled later.
#
defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "askForPassword" -int 1

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "askForPasswordDelay" -int 0.0

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "moduleName" -string "Flurry"

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "modulePath" -string "/System/Library/Screen Savers/Flurry.saver"

# Turn off DS_Store file creation on network volumes

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores true

# Configure Finder to use Column View

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder "AlwaysOpenWindowsInColumnView" -bool true

# Configure Finder to hide Hard Drive on Desktop

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder "ShowHardDrivesOnDesktop" -bool false

# Disable root login by setting root's shell to /usr/bin/false
# Note: Setting this value has been known to cause issues seen
# by others when they used Casper's FileVault 2 management.
# If you are running Casper and see problems encrypting, the
# original UserShell value is as follows:
#
# /bin/sh
#
# To revert it back to /bin/sh, run the following command:
# /usr/bin/dscl . -change /Users/root UserShell /usr/bin/false /bin/sh

/usr/bin/dscl . -create /Users/root UserShell /usr/bin/false


# Make a symbolic link from /System/Library/CoreServices/Applications/Directory Utility.app
# to /Applications/Utilities so that Directory Utility.app is easier to access.

if [[ ! -e "/Applications/Utilities/Directory Utility.app" ]]; then
ln -s "/System/Library/CoreServices/Applications/Directory Utility.app" "/Applications/Utilities/Directory Utility.app"
fi

if [[ -L "/Applications/Utilities/Directory Utility.app" ]]; then
rm "/Applications/Utilities/Directory Utility.app"
ln -s "/System/Library/CoreServices/Applications/Directory Utility.app" "/Applications/Utilities/Directory Utility.app"
fi

# Make a symbolic link from /System/Library/CoreServices/Applications/Network Utility.app
# to /Applications/Utilities so that Network Utility.app is easier to access.

if [[ ! -e "/Applications/Utilities/Network Utility.app" ]]; then
ln -s "/System/Library/CoreServices/Applications/Network Utility.app" "/Applications/Utilities/Network Utility.app"
fi

if [[ -L "/Applications/Utilities/Network Utility.app" ]]; then
rm "/Applications/Utilities/Network Utility.app"
ln -s "/System/Library/CoreServices/Applications/Network Utility.app" "/Applications/Utilities/Network Utility.app"
fi

# Make a symbolic link from /System/Library/CoreServices/Screen Sharing.app
# to /Applications/Utilities so that Screen Sharing.app is easier to access.

if [[ ! -e "/Applications/Utilities/Screen Sharing.app" ]]; then
ln -s "/System/Library/CoreServices/Applications/Screen Sharing.app" "/Applications/Utilities/Screen Sharing.app"
fi

if [[ -L "/Applications/Utilities/Screen Sharing.app" ]]; then
rm "/Applications/Utilities/Screen Sharing.app"
ln -s "/System/Library/CoreServices/Applications/Screen Sharing.app" "/Applications/Utilities/Screen Sharing.app"
fi

# Set separate power management settings for desktops and laptops
# If it's a laptop, the power management settings for "Battery" are set to have the computer sleep in 15 minutes, disk will spin down
# in 10 minutes, the display will sleep in 5 minutes and the display itslef will dim to half-brightness before sleeping. While plugged
# into the AC adapter, the power management settings for "Charger" are set to have the computer never sleep, the disk doesn't spin down,
# the display sleeps after 30 minutes and the display dims before sleeping.
#
# If it's not a laptop (i.e. a desktop), the power management settings are set to have the computer never sleep, the disk doesn't spin down, the display
# sleeps after 30 minutes and the display dims before sleeping.
#

# Detects if this Mac is a laptop or not by checking the model ID for the word "Book" in the name.
IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`

if [ "$IS_LAPTOP" != "" ]; then
pmset -b sleep 15 disksleep 10 displaysleep 5 halfdim 1
pmset -c sleep 0 disksleep 0 displaysleep 30 halfdim 1
else
pmset sleep 0 disksleep 0 displaysleep 30 halfdim 1
fi

# Set the login window to name and password

/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Disable external accounts (i.e. accounts stored on drives other than the boot drive.)

/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false

# Set timezone

/usr/sbin/systemsetup -settimezone "America/Chicago"

# Primary Time server for Company Macs
TimeServer1=ntp.yourcompany.com
# Secondary Time server for Company Macs
TimeServer2=time.apple.com

# Set the primary network server with systemsetup -setnetworktimeserver
# Using this command will clear /etc/ntp.conf of existing entries and
# add the primary time server as the first line.
/usr/sbin/systemsetup -setnetworktimeserver $TimeServer1

# Add the secondary time server as the second line in /etc/ntp.conf
echo "server $TimeServer2" >> /etc/ntp.conf

# Set the ability to  view additional system info at the Login window
# The following will be reported when you click on the time display
# (click on the time again to proceed to the next item):
#
# Computer name
# Version of OS X installed
# IP address
# This will remain visible for 60 seconds.

/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Sets the "Show scroll bars" setting (in System Preferences: General)
# to "Always" in your Mac's default user template and for all existing users.
# Code adapted from DeployStudio's rc130 ds_finalize script, where it's
# disabling the iCloud and gestures demos

# Checks the system default user template for the presence of
# the Library/Preferences directory. If the directory is not found,
# it is created and then the "Show scroll bars" setting (in System
# Preferences: General) is set to "Always".

for USER_TEMPLATE in "/System/Library/User Template"/*
do
if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
then
mkdir -p "${USER_TEMPLATE}"/Library/Preferences
fi
if [ ! -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
then
mkdir -p "${USER_TEMPLATE}"/Library/Preferences/ByHost
fi
if [ -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
then
/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
fi
done

# Checks the existing user folders in /Users for the presence of
# the Library/Preferences directory. If the directory is not found,
# it is created and then the "Show scroll bars" setting (in System
# Preferences: General) is set to "Always".

for USER_HOME in /Users/*
do
USER_UID=`basename "${USER_HOME}"`
if [ ! "${USER_UID}" = "Shared" ]
then
if [ ! -d "${USER_HOME}"/Library/Preferences ]
then
mkdir -p "${USER_HOME}"/Library/Preferences
chown "${USER_UID}" "${USER_HOME}"/Library
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
fi
if [ ! -d "${USER_HOME}"/Library/Preferences/ByHost ]
then
mkdir -p "${USER_HOME}"/Library/Preferences/ByHost
chown "${USER_UID}" "${USER_HOME}"/Library
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost
fi
if [ -d "${USER_HOME}"/Library/Preferences/ByHost ]
then
/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/.GlobalPreferences.*
fi
fi
done


# Determine OS version and build version
# as part of the following actions to disable
# the iCloud and Diagnostic pop-up windows

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)
sw_build=$(sw_vers -buildVersion)


# Checks first to see if the Mac is running 10.7.0 or higher.
# If so, the script checks the system default user template
# for the presence of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# iCloud and Diagnostic pop-up settings are set to be disabled.

if [[ ${osvers} -ge 7 ]]; then

for USER_TEMPLATE in "/System/Library/User Template"/*
do
/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
done

# Checks first to see if the Mac is running 10.7.0 or higher.
# If so, the script checks the existing user folders in /Users
# for the presence of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# iCloud and Diagnostic pop-up settings are set to be disabled.

for USER_HOME in /Users/*
do
USER_UID=`basename "${USER_HOME}"`
if [ ! "${USER_UID}" = "Shared" ]
then
if [ ! -d "${USER_HOME}"/Library/Preferences ]
then
mkdir -p "${USER_HOME}"/Library/Preferences
chown "${USER_UID}" "${USER_HOME}"/Library
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
fi
if [ -d "${USER_HOME}"/Library/Preferences ]
then
/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
fi
fi
done
fi

# enable tap-click on trackpad
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# disable "natural" scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Turn SSH on

systemsetup -setremotelogin on

# Turn off Gatekeeper

# spctl --master-disable

# Remove setup LaunchDaemon item

# srm /Library/LaunchDaemons/com.company.initialsetup.plist

# Make script self-destruct

srm $0
