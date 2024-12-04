import 'package:flutter/material.dart';
import 'package:i/pages/closed_tasks_page.dart';
import 'package:i/pages/speak_page.dart';
import 'package:i/pages/task_details.dart';
import 'package:i/service/taskservice.dart';
import 'package:i/service/userservice.dart';
import 'login_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;

  HomePage({
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskService taskService = TaskService();
  final UserService userService = UserService();
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;
  int currentPage = 0;
  int totalPages = 0;
  final int itemsPerPage = 9;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final response = await taskService.getAllTasks(currentPage, itemsPerPage);
      final totalTasks = response['totalTasks'];
      final tasksList = response['tasks'];

      setState(() {
        tasks = tasksList != null && tasksList.isNotEmpty
            ? List<Map<String, dynamic>>.from(tasksList)
            : [];
        totalPages = (totalTasks / itemsPerPage).ceil();
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        tasks = [];
      });
    }
  }

  Future<void> _updateTaskState(int taskId, bool isCompleted) async {
    try {
      Map<String, dynamic> updatedTask = {
        'state': isCompleted ? 2 : 1, // 2 = CLOSED, 1 = OPEN
      };
      await taskService.updateTask(widget.userId, taskId, updatedTask);
      _loadTasks();
    } catch (e) {
      print('Error updating task state: $e');
    }
  }

  void _logout() async {
    await userService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _showCreateTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: _CreateTaskForm(
            onTaskCreated: (newTask) async {
              Map<String, dynamic>? createdTask = await taskService.createTask(newTask);
              if (createdTask != null) {
                _loadTasks();
              }
            },
          ),
        );
      },
    );
  }

  void _loadNextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
        _loadTasks();
      });
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _loadTasks();
      });
    }
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        String dueDate = tasks[index]['donedate'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(tasks[index]['donedate']))
            : 'Sem data';

        IconData stateIcon;
        Color stateColor;

        switch (tasks[index]['state']) {
          case 2:
            stateIcon = Icons.check_circle;
            stateColor = Colors.green;
            break;
          case 3:
            stateIcon = Icons.error;
            stateColor = Colors.red;
            break;
          default:
            stateIcon = Icons.radio_button_unchecked;
            stateColor = Colors.grey;
        }

        return Card(
          child: ListTile(
            leading: Icon(stateIcon, color: stateColor),
            title: Text(
              '${tasks[index]['title'] ?? 'Sem título'} ${tasks[index]['priority'] ?? 'Sem prioridade'}',
            ),
            subtitle: Text('Data de validade: $dueDate'),
            trailing: Checkbox(
              value: tasks[index]['state'] == 2, // If task is CLOSED
              onChanged: (value) async {
                setState(() {
                  tasks[index]['state'] = value! ? 2 : 1;
                });
                await _updateTaskState(tasks[index]['id'], value!);
              },
            ),
            onTap: () => _navigateToTaskDetailsPage(tasks[index]),
          ),
        );
      },
    );
  }

  void _navigateToTaskDetailsPage(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: currentPage > 0 ? _loadPreviousPage : null,
            child: Icon(Icons.arrow_back),
          ),
          ElevatedButton(
            onPressed: _loadNextPage,
            child: Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
        _navigateToPage(index);
      },
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.check_box), label: 'Fechadas'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendário'),
        BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Gravador'),
      ],
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClosedTasksPage(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userId: widget.userId,
              userName: widget.userName,
              userEmail: widget.userEmail,
            ),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioRecorderScreen(
              userId: widget.userId,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(child: Text('Nenhuma tarefa encontrada'))
          : Column(
        children: [
          Expanded(child: _buildTaskList()),
          _buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskModal(context),
        backgroundColor: Colors.blue,
        tooltip: 'Adicionar Tarefa',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.userName),
              accountEmail: Text(widget.userEmail),
              currentAccountPicture: CircleAvatar(
                child: Text(widget.userName[0].toUpperCase()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTaskForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onTaskCreated;

  _CreateTaskForm({required this.onTaskCreated});

  @override
  __CreateTaskFormState createState() => __CreateTaskFormState();
}

class __CreateTaskFormState extends State<_CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  int _priority = 1;
  DateTime? _doneDate;
  int _category = 1;
  bool _done = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _doneDate) {
      setState(() {
        _doneDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Título'),
              onSaved: (value) => _title = value,
              validator: (value) => value!.isEmpty ? 'Digite um título' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Descrição'),
              onSaved: (value) => _description = value,
            ),
            DropdownButtonFormField<int>(
              value: _priority,
              decoration: InputDecoration(labelText: 'Prioridade'),
              items: [
                DropdownMenuItem(value: 1, child: Text('Baixa')),
                DropdownMenuItem(value: 2, child: Text('Média')),
                DropdownMenuItem(value: 3, child: Text('Alta')),
              ],
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(_doneDate == null ? 'Escolher Data' : 'Data: ${DateFormat('dd/MM/yyyy').format(_doneDate!)}'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onTaskCreated({
                    'title': _title,
                    'description': _description,
                    'priority': _priority,
                    'donedate': _doneDate?.toIso8601String(),
                    'category': _category,
                    'done': _done,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Criar Tarefa'),
            ),
          ],
        ),
      ),
    );
  }
}
