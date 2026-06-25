import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/task_model.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';
import 'widgets/task_card.dart';
import 'widgets/task_stats.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database service (Firestore or local mock fallback)
  final databaseService = await DatabaseServiceFactory.initialize();
  
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatefulWidget {
  final DatabaseService databaseService;

  const MyApp({super.key, required this.databaseService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SyncTask Workspace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: TaskHomeScreen(
        databaseService: widget.databaseService,
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  final DatabaseService databaseService;
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const TaskHomeScreen({
    super.key,
    required this.databaseService,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  
  // State for adding task
  String _selectedCategory = 'Work';
  String _selectedPriority = 'Medium';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  
  // UI preferences
  bool _isGridView = false;
  String _filterCategory = 'All';
  String _searchQuery = '';
  
  // Categories and Priorities definitions
  final List<String> _categories = ['Work', 'Design', 'Meeting', 'Personal', 'Urgent', 'Other'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Pick Due Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Handle Add Task Submission
  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: '', // Will be set by Firestore / Mock DB
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        dueDate: _selectedDate,
        priority: _selectedPriority,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      widget.databaseService.addTask(task).then((_) {
        if (!mounted) return;
        // Show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text("Task '${task.title}' added successfully!")),
              ],
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Reset Inputs
        _titleController.clear();
        _descController.clear();
        setState(() {
          _selectedCategory = 'Work';
          _selectedPriority = 'Medium';
          _selectedDate = DateTime.now().add(const Duration(days: 1));
        });
      }).catchError((error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add task: $error"),
            backgroundColor: Colors.redAccent,
          ),
        );
      });

    }
  }

  // Toggle Task Completion State
  void _toggleTaskCompletion(Task task, bool? value) {
    final newValue = value ?? false;
    widget.databaseService.toggleTaskCompletion(task.id, newValue).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue ? "Task '${task.title}' completed!" : "Task '${task.title}' marked pending."),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    });
  }

  // Delete Task with Confirmation
  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text("Are you sure you want to delete '${task.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.databaseService.deleteTask(task.id).then((_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Task deleted successfully!"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }


  void _openEditDialog(Task task) {
    final editFormKey = GlobalKey<FormState>();
    final editTitleController = TextEditingController(text: task.title);
    final editDescController = TextEditingController(text: task.description);
    String editCategory = task.category;
    String editPriority = task.priority;
    DateTime editDate = task.dueDate;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Task Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input
                      TextFormField(
                        controller: editTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Title cannot be empty';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Description Input
                      TextFormField(
                        controller: editDescController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: editCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.getCategoryColor(cat),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cat),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => editCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Priority Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: editPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                        ),
                        items: _priorities.map((pri) {
                          return DropdownMenuItem(
                            value: pri,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.getPriorityColor(pri),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(pri),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => editPriority = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Due Date Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Due Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, yyyy').format(editDate),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: editDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                              );
                              if (picked != null) {
                                setDialogState(() => editDate = picked);
                              }
                            },
                            icon: const Icon(Icons.date_range, size: 16),
                            label: const Text('Change'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editFormKey.currentState!.validate()) {
                      final updatedTask = task.copyWith(
                        title: editTitleController.text.trim(),
                        description: editDescController.text.trim(),
                        category: editCategory,
                        dueDate: editDate,
                        priority: editPriority,
                      );

                      widget.databaseService.updateTask(updatedTask).then((_) {
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Task '${updatedTask.title}' updated successfully!"),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      });
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.playlist_add_check_circle_outlined, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            const Text('SyncTask'),
          ],
        ),
        actions: [
          // Database Status Badge
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.databaseService.isMock
                  ? Colors.orange.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.databaseService.isMock ? Colors.orange : Colors.green,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.databaseService.isMock ? Colors.orange : Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.databaseService.isMock ? 'Offline Simulator' : 'Firestore Live',
                  style: TextStyle(
                    color: widget.databaseService.isMock ? Colors.orange[800] : Colors.green[800],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Dark/Light Mode',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Widget
              StreamBuilder<List<Task>>(
                stream: widget.databaseService.getTasksStream(),
                builder: (context, snapshot) {
                  final tasks = snapshot.data ?? [];
                  return TaskStats(tasks: tasks);
                },
              ),
              const SizedBox(height: 20),

              // Form for adding tasks
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_task, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Create New Task',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Title Textfield
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Task Title *',
                            hintText: 'Enter title (e.g. Design review)',
                            prefixIcon: Icon(Icons.title, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Task title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Description Textfield
                        TextFormField(
                          controller: _descController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            hintText: 'Provide details about the task...',
                            prefixIcon: Icon(Icons.description_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category Chips Selector
                        Text('Category', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              final isSelected = _selectedCategory == cat;
                              final catColor = AppColors.getCategoryColor(cat);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  selectedColor: catColor.withOpacity(0.2),
                                  checkmarkColor: catColor,
                                  labelStyle: TextStyle(
                                    color: isSelected ? catColor : (isDark ? Colors.white60 : Colors.black54),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? catColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Priority Chips Selector
                        Text('Priority Level', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: _priorities.map((priority) {
                            final isSelected = _selectedPriority == priority;
                            final priorityColor = AppColors.getPriorityColor(priority);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(priority),
                                selected: isSelected,
                                selectedColor: priorityColor.withOpacity(0.2),
                                labelStyle: TextStyle(
                                  color: isSelected ? priorityColor : (isDark ? Colors.white60 : Colors.black54),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                side: BorderSide(
                                  color: isSelected ? priorityColor : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedPriority = priority;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Due Date Picker & Add Task Button
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Due Date',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark ? Colors.white60 : Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              DateFormat('MMM d, yyyy').format(_selectedDate),
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _submitTask,
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add Task'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Filter Controls & Title Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Workspace Tasks',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Row(
                    children: [
                      // List / Grid Toggle
                      IconButton(
                        icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
                        onPressed: () {
                          setState(() {
                            _isGridView = !_isGridView;
                          });
                        },
                        tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search Bar & Filter options
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tasks by title...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Category Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: _filterCategory,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.filter_list, size: 18),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      items: ['All', ..._categories].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _filterCategory = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main List of Tasks (Real-Time stream)
              StreamBuilder<List<Task>>(
                stream: widget.databaseService.getTasksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Error loading tasks: ${snapshot.error}',
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    );
                  }

                  final allTasks = snapshot.data ?? [];

                  // Apply filters locally on the stream data
                  final filteredTasks = allTasks.where((task) {
                    final matchesSearch = task.title.toLowerCase().contains(_searchQuery);
                    final matchesCategory = _filterCategory == 'All' || task.category == _filterCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 64,
                              color: isDark ? Colors.white24 : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching tasks found',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white30 : Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (allTasks.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Try clearing your search query or filters',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white12 : Colors.grey[400],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isGridView
                        ? GridView.builder(
                            key: const ValueKey('grid_view'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return TaskCard(
                                key: ValueKey(task.id),
                                task: task,
                                isGridView: true,
                                onToggleComplete: (val) => _toggleTaskCompletion(task, val),
                                onEdit: () => _openEditDialog(task),
                                onDelete: () => _deleteTask(task),
                              );
                            },
                          )
                        : ListView.builder(
                            key: const ValueKey('list_view'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TaskCard(
                                  key: ValueKey(task.id),
                                  task: task,
                                  isGridView: false,
                                  onToggleComplete: (val) => _toggleTaskCompletion(task, val),
                                  onEdit: () => _openEditDialog(task),
                                  onDelete: () => _deleteTask(task),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
