#!/bin/bash

# This script is called by xpc_handler.js after consuming XPC LaunchEvents.
# It processes the events further to log specific triggers.
#
# Note that the below is not directly looking up the cause of the BSD
# notifications, only inferring, so this is not 100% accurate. For example,
# when a network interface comes online, a lot of changes occur in the network
# configuration, so multiple events fire simultaneously. Your code should have
# logic to only run once within a short time frame.
#
# If accurate event triggers are needed, that should be handled in the JXA,
# but that is beyond the scope of this demo.

if [[ -z $1 ]]; then
  echo "Missing required LaunchEvent, exiting"
  exit 1
else
  LAUNCH_EVENT="$1"
fi

if [[ $LAUNCH_EVENT = "com.apple.powermanagement.systempowerstate" ]]; then
  CURRENT_STATE=$(pmset -g systemstate)
  if { grep -q "Current Power State: 4" <<< "$CURRENT_STATE"; } &&
    { grep -qv "Desired" <<< "$CURRENT_STATE"; }; then
    # System has come online
    # Alternative conditional: `ioreg -rc IOPMrootDomain -d 1`
    # grep IOPowerManagement and look for a DesiredPowerState value of 3
    echo "$(date) System just came online." >> /private/var/log/smaddock.log
  else
    echo "$(date) other power state event" >> /private/var/log/smaddock.log
  fi

elif [[ $LAUNCH_EVENT = "com.apple.system.config.network_change" ]]; then
  LATEST_LINK_UP=$(dmesg | awk '/Link Up/ { a=$0 } END { print a }')

  NOW_TIME=$(date +%s)
  BOOT_TIME=$(sysctl -n kern.boottime | awk '{ print substr($4, 1, length($4)-1) }')
  LINK_UP_TIME=$(awk 'match($0, /[0-9]+/) { print substr($0, RSTART, RLENGTH) }' <<< "$LATEST_LINK_UP")

  if ((NOW_TIME - BOOT_TIME - LINK_UP_TIME < 5)); then
    # Network interface came online in the last 5 seconds
    echo "$(date) $(awk '{ print $NF }' <<< "$LATEST_LINK_UP") just came online." >> /private/var/log/smaddock.log
  else
    echo "$(date) other network config event" >> /private/var/log/smaddock.log
  fi
fi
