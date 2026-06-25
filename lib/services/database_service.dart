import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/task_model.dart';

abstract class DatabaseService {
  Stream<List<Task>> getTasksStream();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id, bool isCompleted);
  bool get isMock;
}

class FirestoreDatabaseService implements DatabaseService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  @override
  Stream<List<Task>> getTasksStream() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<void> addTask(Task task) async {
    await _tasksCollection.add(task.toFirestore());
  }

  @override
  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toFirestore());
  }

  @override
  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }

  @override
  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    await _tasksCollection.doc(id).update({'isCompleted': isCompleted});
  }

  @override
  bool get isMock => false;
}

class MockDatabaseService implements DatabaseService {
  final List<Task> _tasks = [];
  final StreamController<List<Task>> _controller = StreamController<List<Task>>.broadcast();

  MockDatabaseService() {
    // Add sample tasks to showcase the premium GUI out of the box.
    _tasks.addAll([
      Task(
        id: '1',
        title: 'Design Dashboard UI',
        description: 'Create high fidelity wireframes and user flow diagrams for the team project.',
        category: 'Design',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: 'High',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Task(
        id: '2',
        title: 'Setup Firebase Firestore',
        description: 'Create the database instance, configure collections and indexes for tasks.',
        category: 'Work',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: 'Medium',
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Task(
        id: '3',
        title: 'Sprint Retrospective Meeting',
        description: 'Discuss what went well, what could be improved, and actions for next sprint.',
        category: 'Meeting',
        dueDate: DateTime.now().add(const Duration(hours: 4)),
        priority: 'Low',
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ]);
    _controller.add(List.from(_tasks));
  }

  @override
  Stream<List<Task>> getTasksStream() {
    Timer.run(() => _controller.add(List.from(_tasks)));
    return _controller.stream;
  }

  @override
  Future<void> addTask(Task task) async {
    final newTask = task.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    _tasks.insert(0, newTask); // Add to the top
    _controller.add(List.from(_tasks));
  }

  @override
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      _controller.add(List.from(_tasks));
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    _controller.add(List.from(_tasks));
  }

  @override
  Future<void> toggleTaskCompletion(String id, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: isCompleted);
      _controller.add(List.from(_tasks));
    }
  }

  @override
  bool get isMock => true;
}

class DatabaseServiceFactory {
  static DatabaseService? _instance;

  static Future<DatabaseService> initialize() async {
    if (_instance != null) return _instance!;

    try {
      // Initialize Firebase with the generated options from flutterfire configure.
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _instance = FirestoreDatabaseService();
    } catch (e) {
      // Fallback to in-memory mock if Firebase fails (e.g. missing config).
      _instance = MockDatabaseService();
    }
    return _instance!;
  }
}
