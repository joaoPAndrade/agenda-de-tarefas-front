import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/task.dart';
import '../../../models/taskResponse.dart';

import '../../../models/category.dart';
import '../../../models/groups.dart';

class TaskService {
  final String baseUrl = 'http://localhost:3333';
  Future<List<TaskResponse>> getTasksByDay(
      DateTime dateTime, String email) async {
  print("Dia buscado: $dateTime");
    final response = await http.put(
      Uri.parse('$baseUrl/task/day'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'date': dateTime.toUtc().toIso8601String(), 'email': email}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      // Acessando a lista correta dentro do JSON retornado
      List<dynamic> tasks = jsonData['tasksWithDetails'] ?? [];

      return tasks.map((e) => TaskResponse.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar tarefas do dia');
    }
  }

  Future<void> createTask(Task task) async {
    print(task.toJsonUpdate());
    final response = await http.post(
      Uri.parse('$baseUrl/task/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJsonUpdate()),
    );
    if (response.statusCode != 201) {
      throw Exception('Erro ao criar tarefa');
    }
  }

  Future<void> updateTask(Task task) async {
    print("Update Task");
    print(task.dateTask);

    final response = await http.put(
      Uri.parse('$baseUrl/task/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJsonUpdate()),
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar tarefa');
    }
  }

  Future<void> deleteTask(int taskId) async {
    final response = await http.delete(Uri.parse('$baseUrl/task/$taskId'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar tarefa');
    }
  }

  Future<void> concludeTask(int taskId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/task/conclude/$taskId'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao concluir tarefa');
    }
  }

  Future<void> unconcludeTask(int taskId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/task/unconclude/$taskId'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao reabrir tarefa');
    }
  }
}

class CategoryService {
  final String baseUrl = 'http://localhost:3333';

  Future<List<Category>> getCategories(String ownerEmail) async {
    final response = await http
        .get(Uri.parse('$baseUrl/category/email?ownerEmail=$ownerEmail'));
    if (response.statusCode == 200) {
      // Supondo que a resposta tenha a chave 'category' contendo a lista de categorias
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (jsonData['category'] != null) {
        List<dynamic> categories = jsonData['category'];
        return categories.map((e) => Category.fromJson(e)).toList();
      } else {
        throw Exception('Categoria não encontrada');
      }
    } else {
      throw Exception('Erro ao buscar categorias');
    }
  }
}

class GroupService {
  final String baseUrl = 'http://localhost:3333';

  Future<List<Group>> getGroupsOwnedByUser(String email) async {
    print(email);
    final response = await http.get(Uri.parse('$baseUrl/group/owned/$email'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Group.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar grupos do usuário');
    }
  }
}
