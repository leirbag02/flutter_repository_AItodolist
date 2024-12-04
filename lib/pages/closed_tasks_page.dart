import 'package:flutter/material.dart';
import 'package:i/service/taskservice.dart';
import 'package:i/pages/task_details.dart';

class ClosedTasksPage extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;

  ClosedTasksPage(
      {required this.userId, required this.userName, required this.userEmail});

  @override
  _ClosedTasksPageState createState() => _ClosedTasksPageState();
}

class _ClosedTasksPageState extends State<ClosedTasksPage> {
  final TaskService taskService = TaskService();
  List<Map<String, dynamic>> closedTasks = [];
  bool isLoading = true;
  int currentPage = 0;
  int totalPages = 0;
  final int itemsPerPage = 9;

  @override
  void initState() {
    super.initState();
    _loadClosedTasks();
  }

  void _loadClosedTasks() async {
    try {
      final response =
          await taskService.getAllTasksClosed(currentPage, itemsPerPage);
      final totalTasks = response['totalTasks'];
      final tasksList = response['tasks'];

      if (tasksList != null && tasksList.isNotEmpty) {
        setState(() {
          closedTasks = List<Map<String, dynamic>>.from(tasksList);
          totalPages = (totalTasks / itemsPerPage).ceil();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          closedTasks = [];
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        closedTasks = [];
      });
    }
  }

  void _loadNextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
        _loadClosedTasks();
      });
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _loadClosedTasks();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarefas Fechadas'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : closedTasks.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma tarefa fechada encontrada.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: closedTasks.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: ListTile(
                            title: Text(
                                closedTasks[index]['title'] ?? 'Sem título'),
                            subtitle: Text(closedTasks[index]['description'] ??
                                'Sem descrição'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskDetailPage(task: closedTasks[index]),
                                ),
                              );
                            },
                          ));
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: _loadPreviousPage,
                          ),
                        ),
                        SizedBox(width: 20),
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20,
                          child: IconButton(
                            icon:
                                Icon(Icons.arrow_forward, color: Colors.white),
                            onPressed: _loadNextPage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
