#!/usr/bin/env osascript -l JavaScript

ObjC.import('Foundation');
ObjC.import('dispatch');
ObjC.import('xpc');

var semaphore = $.dispatch_semaphore_create(0);
$.xpc_set_event_stream_handler('com.apple.notifyd.matching', null, function(event) {
    var eventName = $.xpc_dictionary_get_string(event, XPC_EVENT_KEY_NAME);
    $.NSLog('%s', eventName);
    console.log(eventName);
    $.dispatch_semaphore_signal(semaphore);
});
$.dispatch_semaphore_wait(semaphore, 300);
