import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/supabase_service.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Task> _tasks = [
    // Mock tasks for initial display as requested
    Task(
      id: "1",
      title: "Morning Workout",
      time: "8 A.M",
      category: "Healthy",
      isCompleted: false,
      date: DateTime.now(),
    ),
    Task(
      id: "2",
      title: "Reading Book",
      time: "10 A.M",
      category: "Education",
      isCompleted: false,
      date: DateTime.now(),
    ),
    Task(
      id: "3",
      title: "Job Tasks",
      time: "11 A.M",
      category: "Job",
      isCompleted: false,
      date: DateTime.now(),
    ),
    Task(
      id: "4",
      title: "Eating Breakfast",
      time: "6 A.M",
      category: "Healthy",
      isCompleted: true,
      date: DateTime.now(),
    ),
  ];
  bool _isLoading = false; // Initially false to show mock tasks

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasksFromSupabase = await _supabaseService.getTasks();
      if (tasksFromSupabase.isNotEmpty) {
        setState(() {
          _tasks = tasksFromSupabase;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Supabase connection failed, using local tasks: $e');
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    // Update local state first for immediate UI response
    setState(() {
      final index = _tasks.indexWhere(
        (t) => t.id == task.id || t.title == task.title,
      );
      if (index != -1) {
        _tasks[index] = Task(
          id: _tasks[index].id,
          title: _tasks[index].title,
          description: _tasks[index].description,
          date: _tasks[index].date,
          category: _tasks[index].category,
          time: _tasks[index].time,
          isCompleted: !_tasks[index].isCompleted,
        );
      }
    });

    // Attempt to update Supabase in background
    if (task.id != null) {
      try {
        await _supabaseService.updateTaskStatus(task.id!, !task.isCompleted);
      } catch (e) {
        debugPrint('Supabase update failed: $e');
      }
    }
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;
  double get _progress => _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

  int get _pendingCount => _tasks.where((t) => !t.isCompleted).length;

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2DC78A)),
            )
          : _buildBody(),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const Center(
          child: Text("Tareas Guardadas", style: TextStyle(fontSize: 18)),
        );
      case 2:
        return const Center(
          child: Text(
            "Cronómetro / Temporizador",
            style: TextStyle(fontSize: 18),
          ),
        );
      case 3:
        return const Center(
          child: Text("Perfil de Usuario", style: TextStyle(fontSize: 18)),
        );
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Tasks Card
          _buildWeeklyCard(),
          const SizedBox(height: 32),
          // Today Tasks Header
          _buildHeader(),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 24),
          // Task List or Empty Message
          if (_tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No hay tareas para hoy',
                  style: TextStyle(color: Color(0xFF1A1A2E), fontSize: 16),
                ),
              ),
            )
          else
            _buildTaskList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 10,
      height: 70,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_rounded, 0),
          _buildNavItem(Icons.list_alt_rounded, 1),
          _buildNavItem(Icons.timer_rounded, 2),
          _buildNavItem(Icons.person_outline, 3),
          const SizedBox(width: 10), // Gap before FAB
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTaskScreen()),
              );
              if (result != null && result is Task) {
                setState(() {
                  _tasks.insert(0, result);
                });
              }
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2DC78A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? const Color(0xFF2DC78A) : const Color(0xFF9E9E9E),
        size: 28,
      ),
      onPressed: () => setState(() => _currentIndex = index),
    );
  }

  Widget _buildWeeklyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE8F5E9),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2DC78A),
                  ),
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Tasks →",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildWeeklyChip(
                      "$_completedCount",
                      const Color(0xFFE8F5E9),
                      const Color(0xFF2DC78A),
                    ),
                    const SizedBox(width: 8),
                    _buildWeeklyChip(
                      "$_pendingCount",
                      const Color(0xFFFFEBEE),
                      const Color(0xFFE53935),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Today Tasks",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Text(
          "$_completedCount of ${_tasks.length}",
          style: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: _progress,
        backgroundColor: const Color(0xFFE0E0E0),
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DC78A)),
        minHeight: 8,
      ),
    );
  }

  Future<void> _deleteTask(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar tarea"),
        content: const Text(
          "¿Estás seguro de que quieres eliminar esta tarea?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _supabaseService.deleteTask(id);
      _loadTasks();
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTaskScreen(taskToEdit: task)),
    );
    if (result != null && result is Task) {
      setState(() {
        final index = _tasks.indexWhere(
          (t) => t.id == task.id || t.title == task.title,
        );
        if (index != -1) {
          _tasks[index] = result;
        }
      });
    }
  }

  Widget _buildTaskList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return TaskCard(
          task: task,
          onToggle: () => _toggleTaskStatus(task),
          onLongPress: task.id != null ? () => _deleteTask(task.id!) : null,
          onTap: () => _editTask(task),
        );
      },
    );
  }

  Widget _buildWeeklyChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
