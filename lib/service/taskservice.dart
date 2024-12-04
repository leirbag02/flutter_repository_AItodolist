import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  final String baseUrl = 'https://microservices-to-do-list.onrender.com/api';

  Future<Map<String, dynamic>> getAllTasks(int page, int size) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);
        final response = await http.get(
          Uri.parse('$baseUrl/${user['id']}/task/active?page=$page&size=$size'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          return Map<String, dynamic>.from(jsonDecode(response.body));
        } else {
          throw Exception('Erro ao buscar tarefas: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<Map<String, dynamic>> getAllTasksClosed(int page, int size) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);
        final response = await http.get(
          Uri.parse('$baseUrl/${user['id']}/task/closed?page=$page&size=$size'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          return Map<String, dynamic>.from(jsonDecode(response.body));
        } else {
          throw Exception('Erro ao buscar tarefas: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<void> updateTask(
      int userId, int taskId, Map<String, dynamic> updatedTask) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$userId/task/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedTask),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar a tarefa');
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);

        final response = await http.delete(
          Uri.parse('$baseUrl/${user['id']}/task/$taskId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 204) {
          // No content
          return true;
        } else {
          throw Exception('Erro ao excluir tarefa: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      Map<String, dynamic> user = jsonDecode(userData);
      return user['id'];
    }
    return null;
  }

  Future<bool> completeTask(int taskId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);

        final response = await http.put(
          Uri.parse('$baseUrl/${user['id']}/task/done/$taskId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception('Erro ao concluir tarefa: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Função para criar uma nova tarefa
  Future<Map<String, dynamic>?> createTask(
      Map<String, dynamic> taskData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userData = prefs.getString('user');

      if (userData != null) {
        Map<String, dynamic> user = jsonDecode(userData);
        taskData['userID'] = user['id'];

        final response = await http.post(
          Uri.parse('$baseUrl/${user['id']}/task'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(taskData),
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Erro ao criar tarefa: ${response.statusCode}');
        }
      } else {
        throw Exception('Usuário não logado');
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
