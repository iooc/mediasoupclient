// import { EventEmitter } from 'events';
// import { Logger } from './Logger';

// const logger = new Logger('EnhancedEventEmitter');

import 'dart:async';
import 'dart:developer';

import 'package:events2/events2.dart';

// import 'event-emitter/event_emitter.dart';

class EnhancedEventEmitter extends EventEmitter {
  EnhancedEventEmitter() : super(); //{
  //   // super();
  //   setMaxListeners(null);
  // }

  void safeEmit(String event, [Map<String, dynamic>? args]) //: boolean
  {
    // var numListeners = listenerCount(event);

    try {
      return emit(event, args);
    } catch (error) {
      debugger(
          when: false,
          message:
              'safeEmit() | event listener threw an error [event:${event}s]:$error}o');

      // return numListeners > 0;
    }
  }

  Future safeEmitAsPromise(String event,
      [Map<String, dynamic>? args]) async //: Promise<any>
  {
    // return Promise((resolve, reject) =>
    // {
    try {
      // this.emit(event, args, resolve, reject);
      var completer = Completer<dynamic>();
      var _args = {
        'callback': completer.complete,
        'errback': completer.completeError,
        ...?args,
      };
      emit(event, _args);
      return completer.future;
    } catch (error) {
      debugger(
          when: false,
          message:
              'safeEmitAsPromise() | event listener threw an error [event:${event}s]:$error}o');

      // reject(error);
      throw Exception('保存事件委托失败！$error');
    }
    // });
  }
}
