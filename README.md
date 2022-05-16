# xpc_set_event_stream_handler

Attempt to port the upstream [ObjC handler](xpc/xpc_set_event_stream_handler/main.m) to a [JXA handler](xpc_handler.js). Only concerned with the actual event consumption.

### Issues

- [test.plist](test.plist) LaunchDaemon used for both ObjC and JXA, just change the `ProgramArguments`
	- designed to fire whenever network config changes (easy to test with turning WiFi on or off)
	- just using `/Users/Shared` for ease of testing
- ObjC compiles and works as intended. Changes from upstream:
	- changed the launch event from `com.apple.iokit.matching` to `com.apple.notifyd.matching`
	- updated the Xcode recommendations for 13.3
- `xpc_handler.js` always crashes either osascript or applet:
	```
	Crashed Thread:        1  Dispatch queue: com.apple.libdispatch-manager

	Exception Type:        EXC_BAD_ACCESS (SIGBUS)
	Exception Codes:       KERN_PROTECTION_FAILURE at 0x00007ff852f38cd8
	Exception Codes:       0x0000000000000002, 0x00007ff852f38cd8
	Exception Note:        EXC_CORPSE_NOTIFY

	Termination Reason:    Namespace SIGNAL, Code 10 Bus error: 10
	Terminating Process:   exc handler [9389]
	```
	- sometimes also logs error 49 (File «script» is already open)
	- no difference if called as-is or compiled into an applet
	- no difference if code-signed with the `xpc_handler.plist` entitlements
	- `DISPATCH_TIME_FOREVER` constant appears undefined in JXA
	- tried switching from `dispatch_semaphore` to `dispatch_main` inside a `main` function, but does not execute as intended.

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
