// part of dart_event_emitter;

/// Interface representing event class
///
/// [EventInterface] classes can be helpful with creating events holding more information than classic event.
///
///     class MyEvent implements EventInterface {
///         int _i;
///
///         MyEvent(int this._i);
///
///         getNumber() {
///             return _i;
///         }
///     }
///
///     emitter.emit(new MyEvent(2), (EventInterface event) {
///         print("Event has been called with i=${event.getNumber()}");
///     });
abstract class EventInterface {}
