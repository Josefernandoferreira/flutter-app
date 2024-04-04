import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/user.dart';

class Users with ChangeNotifier {
  final Map<String, User> _items = {};

  List<User> get all {
    return [..._items.values];
  }

  int get count {
    return _items.length;
  }

  User byIndex(int i) {
    return _items.values.elementAt(i);
  }

  Future<void> fetchUsersFromAPI() async {
    try {
      final response = await http.get(Uri.parse(endpoint()));

      if (response.statusCode == 200) {
        final List<dynamic> userData = json.decode(response.body);

        clear();    

        for (var userData in userData) {
          final user = User(
            id: userData['_id'],
            name: userData['name'],
            email: userData['email'],
            avatarUrl: userData['avatarUrl'],
          );
          _items[user.id] = user;
        }
        
        notifyListeners();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {}
  }

Future<void> remove(BuildContext context, User user) async {
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Removendo usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Por favor, aguarde...'),
        ],
      ),
    ),
  );

  try {
    final response = await http.delete(Uri.parse(endpoint() + '/${user.id}'));
    if (response.statusCode == 200) {
      _items.remove(user.id);      
      Navigator.of(context).pop();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usuário removido com sucesso'),
      ));
    } else {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  } catch (error) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Erro ao remover usuário: $error'),
      backgroundColor: Colors.red,
    ));
  }
}

Future<void> saveUser(BuildContext context, User user) async {
  try {
    if (user.id != '') {

      final response = await http.patch(
        Uri.parse(endpoint()+ '/${user.id}'),
        body: json.encode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newUserId = responseData['_id'];
        final newUser = User(
          id: newUserId,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        );

        _items[newUserId] = newUser;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Usuário atualizado com sucesso'),
        ));
      } else {
        throw Exception('Falha ao atualizar o usuário: ${response.statusCode}');
      }
    } else {
      final response = await http.post(
        Uri.parse(endpoint()),
        body: json.encode(user.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final newUserId = responseData['_id'];
        final newUser = User(
          id: newUserId,
          name: user.name,
          email: user.email,
          avatarUrl: user.avatarUrl,
        );

        _items[newUserId] = newUser;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Usuário criado com sucesso'),
        ));
      } else {
        throw Exception('Falha ao criar o usuário: ${response.statusCode}');
      }
    }
    } catch (error) {
      print('Erro ao salvar usuário: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao salvar usuário: $error'),
        backgroundColor: Colors.red,
      ));
    }
  }

  void clear() {
    _items.clear();
  }

  String endpoint() {
    return 'http://localhost:3000/todos';
  }

}