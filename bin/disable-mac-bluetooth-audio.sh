#!/bin/sh
# Disable Bluetooth audio output on Mac OS X, setting audio output to the
# default device.  This is used as a cron job on my media Mac to free up
# Bluetooth speakers for phone connections.

TMPFILE=$(mktemp /tmp/bluetoothaudio.XXXXXX)
export TMPFILE
cleantmp() {
  rm -f ${TMPFILE}
}
trap cleantmp 0

# Read the system audio preferences.
# The preference file was determined by experimentation, switching the
# interface on and off via the user-interface.  Since the data includes
# a constant and fixed strings, it's likely OS version-specific and could
# even be machine-specific.

defaults read /Library/Preferences/Audio/com.apple.audio.SystemSettings 501 > ${TMPFILE}

bluetoothdev=$(egrep 'current default output device' ${TMPFILE} | sed 's/.*= //;s/;$//')

# First, determine whether audio is bluetooth or not.

if echo ${bluetoothdev} | fgrep -i -q Bluetooth ; then
  echo "Bluetooth is on."
else
  echo "Bluetooth is already off."
  exit 0
fi

# Next, copy the default audio input to the default output.  We assume
# that the bluetooth device does not have an audio input (they're just
# speakers).

outputdev=$(egrep 'current default input device' ${TMPFILE} | sed 's/.*= //;s/;$//')

sudo defaults write /Library/Preferences/Audio/com.apple.audio.SystemSettings 501 -dict \
    "current default input device" -string ${outputdev} \
    "current default output device" -string ${outputdev} \
    "current default system output device" -string ${outputdev} \
    "primary default input device" -string ${outputdev} \
    "primary default output device" -string ${outputdev} \
    "primary default system output device" -string ${outputdev} \
    "secondary default output device" -string ${bluetoothdev} \
    "secondary default system output device" -string ${bluetoothdev}
