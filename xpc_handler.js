#!/usr/bin/env osascript -l JavaScript

ObjC.import('dispatch');
ObjC.import('xpc');

var semaphore = $.dispatch_semaphore_create(0);
$.xpc_set_event_stream_handler('com.apple.notifyd.matching', $(), (event) => {
    var eventName = $.xpc_dictionary_get_string(event, 'XPCEventName');
    console.log(eventName);
    $.dispatch_semaphore_signal(semaphore);
});
$.dispatch_semaphore_wait(semaphore, -1);
