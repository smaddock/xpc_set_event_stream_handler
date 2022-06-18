#!/bin/bash

# This script is called by xpc_handler.js after consuming XPC LaunchEvents.
# It processes the events further to only take action on specific triggers.
#
# For com.apple.powermanagement.systempowerstate LaunchEvents, further
# processing must occur to what the state change is. For example, to determine
# if the system is coming out of sleep:
# `pmset -g systemstate | grep waking`
# which under the hood, is executing:
# `ioreg -rc IOPMrootDomain -d 1 | grep IOPowerManagement`
# and looking for a DesiredPowerState value of 3

# For com.apple.system.config.network_change LaunchEvents, further processing
# must occur to what the network change is. For example, to determine
# if a network interface came online: `dmesg | grep "Link Up" | tail -n 1`
# combined with: `sysctl -n kern.boottime` and compare to: `date +%s`

if [[ -z $1 ]]; then
  echo "Missing required LaunchEvent, exiting"
  exit 1
else
  LAUNCH_EVENT="$1"
fi

if [[ $LAUNCH_EVENT = "com.apple.powermanagement.systempowerstate" ]] && pmset -g systemstate | grep waking; then
  # System is waking from sleep
  echo "System just woke up." > /private/var/log/smaddock.log
elif [[ $LAUNCH_EVENT = "com.apple.system.config.network_change" ]]; then
  LATEST_LINK_UP=$(dmesg | awk '/Link Up/ { a=$0 } END { print a }')

  NOW_TIME=$(date +%s)
  BOOT_TIME=$(sysctl -n kern.boottime | awk '{ print substr($4, 1, length($4)-1) }')
  LINK_UP_TIME=$(awk 'match($0, /[0-9]+/) { print substr($0, RSTART, RLENGTH) }' <<< "$LATEST_LINK_UP")

  if (( NOW_TIME - BOOT_TIME - LINK_UP_TIME < 5 )); then
    # Network interface came online in the last 5 seconds
    echo "$(awk '{ print $NF }' <<< "$LATEST_LINK_UP") just came online." > /private/var/log/smaddock.log
  fi
fi
