import 'events/new_listener_event.dart';
import 'events/remove_listener_event.dart';
import 'interface/event_handler_interface.dart';
import 'interface/event_interface.dart';

/// Basic implementation of EventEmitter in Dart - a port of Node.js' [EventEmitter](https://nodejs.org/api/events.html#events_class_events_eventemitter) enhanced with Dart goodness.
///
/// ## Installation
///
/// To install package in your system, declare it as a dependency in `pubspec.yaml`:
///
///     dependencies:
///         dart_event_emitter: ">=1.0.0 <2.0.0"
///
/// Then import `dart_event_emitter` in your project
///
///     import 'package:dart_event_emitter/dart_event_emitter.dart';
///
/// ## Usage
///
/// ### As an instance
///
/// You can treat `EventEmitter` class as a object holding data about your events:
///
///     class MyAwesomeClass {
///         EventEmitter _emitter = new EventEmitter();
///
///         MyAwesomeClass() {
///             _emitter.on('action', () {
///                 print 'Action recorded!';
///             });
///         }
///
///         void doAwesomeThings() {
///             _emitter.emit('action');
///         }
///     }
///
/// ### As a parent class
/// You can also decide that your class be responsible for own events:
///
///     class MyAwesomeClass extends EventEmitter {
///         MyAwesomeClass() {
///             on('action', () {
///                 print 'Action recorded!';
///             });
///         }
///
///         void doAwesomeThings() {
///             emit('action');
///         }
///     }
///
// library dart_event_emitter;

// part 'src/interface/event_interface.dart';
// part 'src/interface/event_handler_interface.dart';
// part 'src/events/new_listener_event.dart';
// part 'src/events/remove_listener_event.dart';

/// The look of handler function that can be executed when adding an [EventInterface] event
typedef void EventHandlerFunction(EventInterface event);

/// The heart of event handling mechanism - collects data about event handlers and allows to emit events
class EventEmitter {
  /// Method [setMaxListeners] sets the maximum on a per-instance basis.
  /// This class property lets you set it for all [EventEmitter] instances, current and future, effective immediately. Use with care.
  /// Note that [setMaxListeners] still has precedence over [defaultMaxListeners].
  static int defaultMaxListeners = 10;

  Map<dynamic, List> _listeners = {};
  Map<dynamic, List> _oneTimeListeners = {};
  int? _maxListeners;

  /// Adds a listener to the end of the listeners array for the specified event.
  /// No checks are made to see if the listener has already been added.
  /// Multiple calls passing the same combination of event and listener will result in the listener being added multiple times.
  ///
  /// You can pass [String] or [EventInterface] object **Type** as event.
  ///
  /// Listener can be either simple function or [EventHandlerInterface] object
  ///
  ///     EventEmitter emitter = new EventEmitter();
  ///
  ///     emitter.addListener('event', () {
  ///         print('Simple listener executed');
  ///     });
  ///
  ///     emitter.addListener(MyEvent, () {
  ///         print('This listeners listen will be fired with MyEvent event class');
  ///     });
  ///
  ///     emitter.addListener(MyEvent, MyListener);
  EventEmitter addListener(event, listener) {
    if (!_listeners.containsKey(event)) {
      _listeners[event] = [];
    }

    _verifyListenersLimit(event);
    _listeners[event]!.add(listener);

    emit(NewListenerEvent.NAME, [event, listener]);
    emit(NewListenerEvent, [event, listener]);

    return this;
  }

  /// Alias for [addListener]
  EventEmitter on(event, listener) {
    return addListener(event, listener);
  }

  /// Adds a **one time** listener for the event.
  /// This listener is invoked only the next time the event is fired, after which it is removed.
  EventEmitter once(event, listener) {
    if (!_oneTimeListeners.containsKey(event)) {
      _oneTimeListeners[event] = [];
    }

    _verifyListenersLimit(event);
    _oneTimeListeners[event]!.add(listener);

    emit(NewListenerEvent.NAME, [event, listener]);
    emit(NewListenerEvent, [event, listener]);

    return this;
  }

  int _getMaxListeners() {
    if (_maxListeners == null) {
      return defaultMaxListeners;
    }

    return _maxListeners!;
  }

  void _verifyListenersLimit(event) {
    int nextCount = ++listeners(event).length;
    int maxListeners = _getMaxListeners();

    if (nextCount >= maxListeners) {
      throw new Exception(
          "Max listeners count for event '$event' exceeded. Current limit is set to $maxListeners");
    }
  }

  /// Remove a listener from the listener array for the specified event.
  ///
  /// **Caution**: changes array indices in the listener array behind the listener.
  /// [removeListener] will remove, at most, one instance of a listener from the listener array.
  /// If any single listener has been added multiple times to the listener array for the specified event,
  /// then [removeListener] must be called multiple times to remove each instance.
  ///
  /// Returns [EventEmitter], so calls can be chained.
  EventEmitter removeListener(event, listener) {
    if (_listeners.containsKey(event) &&
        _listeners[event]!.contains(listener)) {
      _listeners[event]!.remove(listener);
      emit(RemoveListenerEvent.NAME, [event, listener]);
      emit(RemoveListenerEvent, [event, listener]);
    }

    if (_oneTimeListeners.containsKey(event) &&
        _oneTimeListeners[event]!.contains(listener)) {
      _oneTimeListeners[event]!.remove(listener);
      emit(RemoveListenerEvent.NAME, [event, listener]);
      emit(RemoveListenerEvent, [event, listener]);
    }

    return this;
  }

  /// Removes all listeners, or those of the specified event.
  ///
  /// It's not a good idea to remove listeners that were added elsewhere in the code, especially when it's on an emitter that you didn't create
  ///
  /// Returns [EventEmitter], so calls can be chained.
  EventEmitter removeAllListeners([event]) {
    if (event == null) {
      _listeners.forEach((eventName, List handlers) {
        if (eventName != RemoveListenerEvent.NAME &&
            eventName != RemoveListenerEvent) {
          for (int i = 0; i < handlers.length; i++) {
            emit(RemoveListenerEvent.NAME, [eventName, handlers[i]]);
            emit(RemoveListenerEvent, [eventName, handlers[i]]);
            handlers.removeAt(i);
          }
        }
      });

      _listeners.clear();
    } else {
      if (_listeners.containsKey(event) &&
          event != RemoveListenerEvent.NAME &&
          event != RemoveListenerEvent) {
        for (int i = 0; i < _listeners[event]!.length; i++) {
          emit(RemoveListenerEvent.NAME, [event, _listeners[event]![i]]);
          emit(RemoveListenerEvent, [event, _listeners[event]![i]]);
          _listeners[event]!.removeAt(i);
        }

        _listeners[event]!.clear();
      }

      if (_oneTimeListeners.containsKey(event) &&
          event != RemoveListenerEvent.NAME &&
          event != RemoveListenerEvent) {
        for (int i = 0; i < _oneTimeListeners[event]!.length; i++) {
          emit(RemoveListenerEvent.NAME, [event, _oneTimeListeners[event]![i]]);
          _oneTimeListeners[event]!.removeAt(i);
        }

        _oneTimeListeners[event]!.clear();
      }
    }

    return this;
  }

  /// By default EventEmitters will print a warning if more than 10 listeners are added for a particular event.
  /// This is a useful default which helps finding memory leaks.
  ///
  /// Obviously not all Emitters should be limited to 10. This function allows that to be increased. Set to zero for unlimited.
  ///
  /// Returns [EventEmitter], so calls can be chained.
  EventEmitter setMaxListeners(int? listenersCount) {
    _maxListeners = listenersCount;

    return this;
  }

  /// Returns a list of listeners for the specified event.
  List listeners(event) {
    List result = [];
    if (_listeners.containsKey(event)) {
      result.addAll(_listeners[event]!);
    }

    if (_oneTimeListeners.containsKey(event)) {
      result.addAll(_oneTimeListeners[event]!);
    }

    return result;
  }

  /// Execute each of the listeners in order with the supplied arguments.
  ///
  /// Returns **true** if event had listeners, **false** otherwise.
  ///
  ///     EventEmitter emitter = new EventEmitter();
  ///
  ///     emitter.addListener('event', () {
  ///         print('Simple listener executed');
  ///     });
  ///
  ///     emitter.addListener(MyEvent, (Event event) {
  ///         print("Event with i=${event.i} executed")
  ///     });
  ///
  ///     emitter.emit('event');
  ///     // Will show "Simple listener executed"
  ///
  ///     MyEvent event = new MyEvent({i: 2});
  ///     emitter.emit(event);
  ///     // Will show "Event with i=2 executed"
  bool emit(event, [List? params = const []]) {
    var eventType = event is EventInterface ? event.runtimeType : event;
    bool handlersFound = false;

    if (_listeners.containsKey(eventType)) {
      handlersFound = true;
      for (var handler in _listeners[eventType]!) {
        _callHandler(handler, event, params);
      }
    }

    if (_oneTimeListeners.containsKey(eventType)) {
      handlersFound = true;
      for (int i = 0; i < _oneTimeListeners[eventType]!.length; i++) {
        var handler = _oneTimeListeners[eventType]![i];
        _callHandler(handler, event, params);
        _oneTimeListeners[eventType]!.removeAt(i);
      }
    }

    return handlersFound;
  }

  void _callHandler(handler, [event, List? params = const []]) {
    if (handler is EventHandlerFunction) {
      handler(event);
    } else if (handler is EventHandlerInterface) {
      (handler).execute(event);
    } else {
      Function.apply(handler, params);
    }
  }

  /// Return the number of listeners for a given event.
  // static int listenerCount(EventEmitter emitter, event) {
  //   return emitter.listeners(event).length;
  // }

  int listenerCount(event) {
    return listeners(event).length;
  }
}
