// class AwaitQueueOptions
// {
// 	/**
// 	 * Custom Error derived class that will be used to reject pending tasks after
// 	 * close() method has been called. If not set, Error class is used.
// 	 */
// 	var closedErrorClass;
// 	/**
// 	 * Custom Error derived class that will be used to reject pending tasks after
// 	 * stop() method has been called. If not set, Error class is used.
// 	 */
// 	var stoppedErrorClass;

//   AwaitQueueOptions({this.closedErrorClass,this.stoppedErrorClass});
// }

// export type AwaitQueueTask<T> = () => (Promise<T> | T);
import 'dart:async';

typedef AwaitQueueTask<T> = Future<T> Function();

class AwaitQueueDumpItem<T> {
  AwaitQueueTask<T> task;
  String? name; //: string;
  int enqueuedTime; //: number;
  int executingTime; //: number;

  AwaitQueueDumpItem(this.task, this.enqueuedTime, this.executingTime,
      {this.name});
}

class PendingTask<T> {
  AwaitQueueTask<T> task; //: AwaitQueueTask<unknown>;
  String? name; //?: string;
  // void Function([dynamic args]) resolve; //: (...args: any[]) => any;
  // void Function(dynamic error) reject; //: (error: Error) => void;
  Completer finished;
  DateTime enqueuedAt; //: Date;
  DateTime? executedAt; //?: Date;
  bool stopped; //: boolean;

  PendingTask(this.task, /* this.resolve, this.reject,*/ this.finished,
      this.enqueuedAt, this.stopped,
      {this.name, this.executedAt});
}

class AwaitQueue {
  // Closed flag.
  bool closed = false;

  // Queue of pending tasks.
  final List<PendingTask> pendingTasks = [];

  // // Error class used when rejecting a task due to AwaitQueue being closed.
  // dynamic closedErrorClass = Error;

  // // Error class used when rejecting a task due to AwaitQueue being stopped.
  // dynamic stoppedErrorClass = Error;

  AwaitQueue();

  /**
	 * The number of ongoing enqueued tasks.
	 */
  int get size //(): number
  {
    return pendingTasks.length;
  }

  /**
	 * Closes the AwaitQueue. Pending tasks will be rejected with ClosedErrorClass
	 * error.
	 */
  void close() //: void
  {
    if (closed) return;

    closed = true;

    for (var pendingTask in pendingTasks) {
      pendingTask.stopped = true;
      // pendingTask.reject('AwaitQueue closed');
      pendingTask.finished.completeError('AwaitQueue closed');
    }

    // Enpty the pending tasks array.
    pendingTasks.length = 0;
  }

  /**
	 * Accepts a task as argument (and an optional task name) and enqueues it after
	 * pending tasks. Once processed, the push() method resolves (or rejects) with
	 * the result returned by the given task.
	 *
	 * The given task must return a Promise or directly a value.
	 */
  Future<T> push<T>(AwaitQueueTask<T> task, String? name) async //: Promise<T>
  {
    if (closed) throw Exception('AwaitQueue closed');

    // if (typeof task !== 'function')
    // 	throw new TypeError('given task is not a function');

    // if (!task.name && name)
    // {
    // 	try
    // 	{
    // 		Object.defineProperty(task, 'name', { value: name });
    // 	}
    // 	catch (error)
    // 	{}
    // }
    var completer = Completer<T>();

    var pendingTask = PendingTask(
      task,
      // name,
      // resolve,
      // reject,
      completer,
      DateTime.now(),
      false, name: name,
    );

    // Append task to the queue.
    pendingTasks.add(pendingTask);

    // And run it if this is the only task in the queue.
    if (pendingTasks.length == 1) next();

    return completer.future;
  }

  /**
	 * Make ongoing pending tasks reject with the given StoppedErrorClass error.
	 * The AwaitQueue instance is still usable for future tasks added via push()
	 * method.
	 */
  void stop() //: void
  {
    if (closed) return;

    for (var pendingTask in pendingTasks) {
      pendingTask.stopped = true;
      // pendingTask.reject('AwaitQueue stopped');
    }

    // Enpty the pending tasks array.
    pendingTasks.length = 0;
  }

  List<AwaitQueueDumpItem> dump() {
    var now = DateTime.now();

    return pendingTasks.map((pendingTask) {
      return AwaitQueueDumpItem(
          pendingTask.task,
          // name         : pendingTask.name,
          pendingTask.executedAt != null
              ? pendingTask.executedAt!
                  .difference(pendingTask.enqueuedAt)
                  .inMilliseconds
              : now.difference(pendingTask.enqueuedAt).inMilliseconds,
          pendingTask.executedAt != null
              ? now.difference(pendingTask.executedAt!).inMilliseconds
              : 0);
    }).toList();
  }

  Future next() async //: Promise<any>
  {
    // Take the first pending task.
    var pendingTask = pendingTasks[0];

    // if (!pendingTask)
    // 	return;

    // Execute it.
    await executeTask(pendingTask);

    // Remove the first pending task (the completed one) from the queue.
    pendingTasks.removeAt(0);

    // And continue.
    next();
  }

  Future executeTask(PendingTask pendingTask) async //: Promise<any>
  {
    // If the task is stopped, ignore it.
    if (pendingTask.stopped) return;

    pendingTask.executedAt = DateTime.now();

    try {
      var result = await pendingTask.task();

      // If the task is stopped, ignore it.
      if (pendingTask.stopped) return;

      // Resolve the task with the returned result (if any).
      pendingTask.finished.complete(result);
    } catch (error) {
      // If the task is stopped, ignore it.
      if (pendingTask.stopped) return;

      // Reject the task with its own error.
      pendingTask.finished.completeError(error);
    }
  }
}
