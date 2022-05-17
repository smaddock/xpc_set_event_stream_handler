# xpc_set_event_stream_handler

Attempt to port the upstream [ObjC handler](xpc_set_event_stream_handler/main.m) to a [JXA handler](xpc_handler.js). Only concerned with the actual event consumption. Thanks to @PicoMitchell for getting this far!

### Issues

- [test.plist](test.plist) LaunchDaemon used for both ObjC and JXA, just change the `ProgramArguments`
	- designed to fire whenever network config changes (easy to test with turning WiFi on or off)
	- just using `/Users/Shared` for ease of testing
- ObjC compiles and works as intended. Changes from upstream:
	- changed the launch event from `com.apple.iokit.matching` to `com.apple.notifyd.matching`
	- updated the Xcode recommendations for 13.3
- `xpc_handler.js` and `xpc_handler2.js` hangs forever
	- using a while loop does work, but have to account for https://developer.apple.com/forums/thread/133915

### Documentation:

- `man xpc_events`
- [xpc_set_event_stream_handler](https://developer.apple.com/documentation/xpc/1505578-xpc_set_event_stream_handler?language=objc)
- [dispatch_semaphore](https://developer.apple.com/documentation/dispatch/dispatch_semaphore?language=objc)

# Upstream README

Consume a `com.apple.iokit.matching` event, then run the executable specified in the first parameter.

This is useful when creating `launchd` LaunchAgents that are triggered by IO events (e.g., run a script when keyboard/mouse attached). Failing to consume the `com.apple.iokit.matching` event will result in the executable being called [repeatedly](https://stackoverflow.com/questions/13987671/launchd-plist-runs-every-10-seconds-instead-of-just-once).

This isn't really documented anywhere other than the `man` page for `xpc_set_event_stream_handler`.

## Example Property List

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.example.KeyboardAttach</string>
		<key>ProgramArguments</key>
		<array>
			<string>/usr/local/bin/xpc_set_event_stream_handler</string>
			<string>/usr/local/bin/KeyboardAttachScript.sh</string>
		</array>
		<key>LaunchEvents</key>
		<dict>
			<key>com.apple.iokit.matching</key>
			<dict>
				<key>com.example.KeyboardAttach.Event</key>
				<dict>
					<key>idVendor</key>
					<integer>1234</integer>
					<key>idProduct</key>
					<integer>56789</integer>
					<key>IOProviderClass</key>
					<string>IOUSBDevice</string>
					<key>IOMatchLaunchStream</key>
					<true/>
				</dict>
			</dict>
		</dict>
	</dict>
	</plist>
