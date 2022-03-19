// import { EventEmitter } from 'events';
// import { Logger } from './Logger';

// const logger = new Logger('EnhancedEventEmitter');

import 'dart:developer';

import 'event-emitter/event_emitter.dart';

class EnhancedEventEmitter extends EventEmitter {
  EnhancedEventEmitter() : super() {
    // super();
    setMaxListeners(null);
  }

  bool safeEmit(String event, [List args = const []]) //: boolean
  {
    var numListeners = listenerCount(event);

    try {
      return emit(event, args);
    } catch (error) {
      debugger(
          when: false,
          message:
              'safeEmit() | event listener threw an error [event:${event}s]:$error}o');

      return numListeners > 0;
    }
  }

  Future safeEmitAsPromise(String event,
      [List? args = const []]) async //: Promise<any>
  {
    // return Promise((resolve, reject) =>
    // {
    try {
      // this.emit(event, args, resolve, reject);
      emit(event, args);
    } catch (error) {
      debugger(
          when: false,
          message:
              'safeEmitAsPromise() | event listener threw an error [event:${event}s]:$error}o');

      // reject(error);
      throw Exception('保存事件委托失败！');
    }
    // });
  }
}
