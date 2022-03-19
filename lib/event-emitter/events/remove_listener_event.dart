// part of dart_event_emitter;

import '../interface/event_interface.dart';

/// Built-in event fired when event listener is removed from [EventEmitter]
class RemoveListenerEvent implements EventInterface {
  static const NAME = 'removeListener';
}
