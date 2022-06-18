# xpc_handler

Port of [@snosrap](https://github.com/snosrap)'s [Objective-C XPC event handler](https://github.com/snosrap/xpc_set_event_stream_handler) to a [Javascript for Automation (JXA)](https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/Introduction.html) handler. Many thanks to [@PicoMitchell](https://github.com/PicoMitchell) for the JXA help!

## Notes

- This example launches on BSD notifications (`com.apple.notifyd.matching`) instead of IOKit events (`com.apple.iokit.matching`) but either or both are possible in the same LaunchDaemon.
- Why JXA: https://scriptingosx.com/2021/11/the-unexpected-return-of-javascript-for-automation/
- Why LaunchEvents must be consumed: https://stackoverflow.com/questions/13987671/launchd-plist-runs-every-10-seconds-instead-of-just-once
- Why the process must not exit after consuming: https://developer.apple.com/forums/thread/133915
- At WWDC 2022 Apple announced some [changes to how launchd services will be handled in macOS 13](https://developer.apple.com/documentation/servicemanagement/updating_helper_executables_from_earlier_versions_of_macos); it's unclear at the time of writing if this will impact the functionality demonstrated in this repository.

## Usage

To execute this example as-is:

- Create a `/usr/local/share/smaddock/` directory owned by root
- Move `event_processor.sh` and `xpc_handler.js` to that directory
- Move `com.github.smaddock.xpc_handler.plist` to `/Library/LaunchDaemons/` and change the owner to `root`
- Run `sudo launchctl bootstrap system/com.github.smaddock.xpc_handler`
- Turn your WiFi off and on a couple times, and sleep and wake your Mac a couple times
- Inspect `/private/var/log/smaddock.log` to see the logged events

Feel free to use this example per the terms of the included license, although you'll probably want to remove the `smaddock` references from any production use. ;)
