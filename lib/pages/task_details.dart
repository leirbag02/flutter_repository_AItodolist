import 'package:flutter/material.dart';
import 'package:i/service/taskservice.dart';

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> task;

  TaskDetailPage({required this.task});

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late int _priority;
  late DateTime? _donedate;
  late bool _isCompleted;
  bool _isEditing = false;
  late TaskService _taskService;

  @override
  void initState() {
    widget.task.forEach((key, value) {
      print('$key: $value');
    });
    super.initState();
    _titleController = TextEditingController(text: widget.task['title'] ?? '');
    _descriptionController =
        TextEditingController(text: widget.task['description'] ?? '');
    _priority = widget.task['priority'] ?? 1;
    _donedate = widget.task['donedate'] != null
        ? DateTime.parse(widget.task['donedate'])
        : null;
    _isCompleted = widget.task['state'] == 2;
    _taskService = TaskService();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDoneDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _donedate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _donedate) {
      setState(() {
        _donedate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    final updatedTask = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'priority': _priority,
      'donedate': _donedate?.toIso8601String(),
      'state': _isCompleted ? 2 : 1,
    };

    int taskId = widget.task['id'];
    int userId = widget.task['userId'];

    try {
      await _taskService.updateTask(userId, taskId, updatedTask);
      Navigator.pop(context);
    } catch (e) {
      print('Erro ao salvar a tarefa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task['title'] ?? 'Detalhes da Tarefa'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isEditing
                ? TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Título'),
                  )
                : Text(
                    'Título: ${_titleController.text}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 10),
            _isEditing
                ? TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                  )
                : Text('Descrição: ${_descriptionController.text}'),
            SizedBox(height: 10),
            _isEditing
                ? DropdownButtonFormField<int>(
                    value: _priority,
                    decoration: InputDecoration(labelText: 'Prioridade'),
                    items: [
                      DropdownMenuItem(child: Text('1 (Baixa)'), value: 1),
                      DropdownMenuItem(child: Text('2 (Média)'), value: 2),
                      DropdownMenuItem(child: Text('3 (Alta)'), value: 3),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _priority = value!;
                      });
                    },
                  )
                : Text('Prioridade: $_priority'),
            SizedBox(height: 10),
            if (_isEditing)
              ElevatedButton(
                onPressed: () => _selectDoneDate(context),
                child: Text('Selecionar Data de Conclusão'),
              ),
            SizedBox(height: 10),
            Text(
                'Data de Conclusão: ${_donedate != null ? _donedate.toString() : 'N/A'}'),
            SizedBox(height: 10),
            Text('Data de Criação: ${widget.task['createddate'] ?? 'N/A'}'),
            SizedBox(height: 10),
            if (_isEditing)
              SwitchListTile(
                title: Text('Concluída'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),
            SizedBox(height: 20),
            if (_isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _saveTask,
                    child: Text('Salvar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Voltar'),
                  ),
                ],
              ),
            if (!_isEditing)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Voltar'),
              ),
          ],
        ),
      ),
    );
  }
}
