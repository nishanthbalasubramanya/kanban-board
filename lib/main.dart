import 'package:flutter/material.dart';

void main() {
  runApp(const KanbanBoardApp());
}

class KanbanBoardApp extends StatelessWidget {
  const KanbanBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanban Board',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true, // Center the title
        ),
      ),
      home: const KanbanBoardScreen(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final Color color;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.color = Colors.blue,
  });
}

class KanbanColumn {
  String id;
  String title;
  Color color;
  List<Task> tasks;

  KanbanColumn({
    required this.id,
    required this.title,
    required this.color,
    required this.tasks,
  });
}

class KanbanBoardScreen extends StatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  // Initial columns and tasks
  List<KanbanColumn> _columns = [];
  
  // Controllers for adding new tasks and columns
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  final TextEditingController _columnTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with default columns
    _columns = [
      KanbanColumn(
        id: '1',
        title: 'To Do',
        color: Colors.red.shade100,
        tasks: [
          Task(
            id: '1',
            title: 'Research UI design',
            description: 'Look for inspiration for the new project',
            color: Colors.blue,
          ),
          Task(
            id: '2',
            title: 'Create wireframes',
            description: 'Design initial wireframes for client approval',
            color: Colors.green,
          ),
        ],
      ),
      KanbanColumn(
        id: '2',
        title: 'In Progress',
        color: Colors.yellow.shade100,
        tasks: [
          Task(
            id: '3',
            title: 'Implement login screen',
            description: 'Create the UI and logic for the login screen',
            color: Colors.orange,
          ),
        ],
      ),
      KanbanColumn(
        id: '3',
        title: 'Done',
        color: Colors.green.shade100,
        tasks: [
          Task(
            id: '4',
            title: 'Project setup',
            description: 'Initialize the project and configure dependencies',
            color: Colors.purple,
          ),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _columnTitleController.dispose();
    super.dispose();
  }

  // Move task between columns
  void _moveTask(Task task, KanbanColumn sourceColumn, KanbanColumn destinationColumn) {
    setState(() {
      sourceColumn.tasks.remove(task);
      destinationColumn.tasks.add(task);
    });
  }

  // Delete a task
  void _deleteTask(Task task, KanbanColumn column) {
    setState(() {
      column.tasks.remove(task);
    });
  }

  // Add a new column
  void _addColumn() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Column'),
          content: TextField(
            controller: _columnTitleController,
            decoration: const InputDecoration(
              labelText: 'Column Title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_columnTitleController.text.isNotEmpty) {
                  setState(() {
                    _columns.add(
                      KanbanColumn(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _columnTitleController.text,
                        color: Colors.blue.shade100,
                        tasks: [],
                      ),
                    );
                  });
                  _columnTitleController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Delete a column
  void _deleteColumn(KanbanColumn column) {
    setState(() {
      _columns.remove(column);
    });
  }

  void _showAddTaskDialog(KanbanColumn column) {
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Task to ${column.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskTitleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: _taskDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_taskTitleController.text.isNotEmpty) {
                  setState(() {
                    column.tasks.add(
                      Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _taskTitleController.text,
                        description: _taskDescriptionController.text,
                        color: Colors.blue,
                      ),
                    );
                  });
                  _taskTitleController.clear();
                  _taskDescriptionController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kanban Board',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Column',
            onPressed: _addColumn,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _columns.isEmpty
            ? const Center(
                child: Text('No columns yet. Add a column to get started!'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _columns.map((column) {
                    return _buildColumn(column);
                  }).toList(),
                ),
              ),
      ),
    );
  }

  Widget _buildColumn(KanbanColumn column) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: column.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    column.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add Task',
                  onPressed: () => _showAddTaskDialog(column),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  tooltip: 'Delete Column',
                  onPressed: () => _deleteColumn(column),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onAccept: (data) {
                final task = data['task'] as Task;
                final sourceColumn = data['sourceColumn'] as KanbanColumn;
                if (sourceColumn.id != column.id) {
                  _moveTask(task, sourceColumn, column);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  itemCount: column.tasks.length,
                  itemBuilder: (context, index) {
                    final task = column.tasks[index];
                    return _buildDraggableTaskCard(task, column);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTaskCard(Task task, KanbanColumn sourceColumn) {
    return Draggable<Map<String, dynamic>>(
      data: {
        'task': task,
        'sourceColumn': sourceColumn,
      },
      feedback: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: task.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 20),
                  child: Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCard(task, sourceColumn),
      ),
      child: _buildTaskCard(task, sourceColumn),
    );
  }

  Widget _buildTaskCard(Task task, KanbanColumn column) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: task.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Delete Task',
                  onPressed: () => _deleteTask(task, column),
                ),
              ],
            ),
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 20),
                child: Text(task.description),
              ),
          ],
        ),
      ),
    );
  }
}
