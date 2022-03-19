// part of dart_event_emitter;

import 'event_interface.dart';

/// Interface for building listeners as complex classes
///
/// Each class implementing [EventHandlerInterface] must declare [execute] method that is called when event is emitted.
///
///     class MyHandler implements EventHandlerInterface {
///         void execute(EventInterface event) {
///             print("This is execute method called in MyHandler instance");
///         }
///     }
abstract class EventHandlerInterface {
  /// Method called each time event has been emitted
  void execute(EventInterface event);
}
