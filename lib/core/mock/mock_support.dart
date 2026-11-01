import 'dart:async';

/// Pretend network delay, so loading spinners can be built and tested.
const Duration kMockLatency = Duration(milliseconds: 300);

Future<void> mockDelay() => Future<void>.delayed(kMockLatency);

int _idCounter = 0;

/// Makes a fake document id, like "mock-club-1".
String mockId(String prefix) => 'mock-$prefix-${++_idCounter}';

/// An in-memory list that streams its changes. It stands in for one
/// Firestore collection while the real database is not wired up yet.
class MockCollection<T> {
  MockCollection(Iterable<T> initial) : _items = List<T>.of(initial);

  final List<T> _items;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// A read-only copy of what is in the collection right now.
  List<T> get items => List<T>.unmodifiable(_items);

  /// Changes the list, then tells every listener.
  void mutate(void Function(List<T> items) change) {
    change(_items);
    _changes.add(null);
  }

  /// Emits the current value straight away, then again after every change.
  Stream<R> watch<R>(R Function(List<T> items) select) {
    late final StreamController<R> controller;
    StreamSubscription<void>? subscription;
    controller = StreamController<R>(
      onListen: () {
        controller.add(select(items));
        subscription =
            _changes.stream.listen((_) => controller.add(select(items)));
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }
}
