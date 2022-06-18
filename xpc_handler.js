#!/usr/bin/env osascript -l JavaScript

// This JXA script is called by the com.github.smaddock.xpchandler LaunchDaemon
// when the specified LaunchEvents occur, as explained below. The JXA acts as
// middleware to consume the LaunchEvents and then call the specified command.
//
// The com.github.smaddock.xpchandler LaunchDaemon launches on-demand for
// select BSD Notifications (XPC events in the com.apple.notifyd.matching
// stream). This example uses the following events, but others can be found in
// Apple's own LaunchDaemons at /System/Library/LaunchDaemons
// - System Power State change (com.apple.powermanagement.systempowerstate)
// - Network Configuration change (com.apple.system.config.network_change)
//
// Launchd delivers the event to this script, which in-turn consumes the events
// with `xpc_set_event_stream_handler` so launchd does not continue delivering
// the same event every 10 seconds. It runs continuously so launchd does not
// respawn the process. (Launchd will terminate the process if needed.)

ObjC.import('xpc')

while (true) {
	let xpcEventConsumed = false
	let xpcEventName = ''

	$.xpc_set_event_stream_handler('com.apple.notifyd.matching', $(), (xpcEvent) => {
		xpcEventName = $.xpc_dictionary_get_string(xpcEvent, 'XPCEventName')
		if (!xpcEventConsumed) {
			xpcEventConsumed = true
		}
	})

	while (!xpcEventConsumed) {
		delay(1)
	}

	const fileManager = $.NSFileManager.defaultManager
	const commandPath = $.NSProcessInfo.processInfo.environment.objectForKey('COMMAND_PATH')
	if (!commandPath.isNil() && fileManager.fileExistsAtPath(commandPath) && fileManager.isExecutableFileAtPath(commandPath)) {
		$.NSTask.launchedTaskWithExecutableURLArgumentsErrorTerminationHandler(
			$.NSURL.fileURLWithPath(commandPath),
			[xpcEventName],
			$(),
			(thisTask) => { }
		)
	}
}
