# xpc_handler

A demonstration of using launchd LaunchEvents to trigger LaunchDaemons on-demand (as opposed to cron-like triggering) by taking advantage of Apple's XPC framework. This allows, for example, commands to be run when the network configuration or power state of a Mac changes.

Feel free to use this example per the terms of the included license, although you'll probably want to remove the `smaddock` references from any production use. ;)

This is a port of [@snosrap](https://github.com/snosrap)'s [Objective-C XPC event handler](https://github.com/snosrap/xpc_set_event_stream_handler) to a [Javascript for Automation (JXA)](https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/Introduction.html) handler. Many thanks to [@PicoMitchell](https://github.com/PicoMitchell) for the JXA help!

## Notes

- This example launches on BSD notifications (`com.apple.notifyd.matching`) instead of IOKit events (`com.apple.iokit.matching`) but either or both are possible in the same LaunchDaemon.
- Why JXA: https://scriptingosx.com/2021/11/the-unexpected-return-of-javascript-for-automation/
- Why LaunchEvents must be consumed: https://stackoverflow.com/questions/13987671/launchd-plist-runs-every-10-seconds-instead-of-just-once
- Why the process must not exit after consuming: https://developer.apple.com/forums/thread/133915
- At WWDC 2022 Apple announced some [changes to how launchd services will be handled in macOS 13](https://developer.apple.com/documentation/servicemanagement/updating_helper_executables_from_earlier_versions_of_macos); it's unclear at the time of writing if this will impact the functionality demonstrated in this repository.

## Usage

To execute this example as-is:

1. Install the files
    - munkipkg method:
        1. Install [munkipkg](https://github.com/munki/munki-pkg)
        1. Clone this repository locally
        1. Run `munkipkg` on the repo local root directory
        1. Run the installer built by `munkipkg`
    - Manual method:
        1. Copy the files from the payload directory of this repo to their corresponding location in your filesystem
        1. Change the owner of all the copied files to `root`
        1. Run `sudo launchctl bootstrap system /Library/LaunchDaemons/com.github.smaddock.xpc_handler.plist`
1. Test the LaunchEvents
    - Turn your WiFi off and on a couple times
    - Sleep and wake your Mac a couple times
1. Inspect `/private/var/log/smaddock.log` to see the logged events
