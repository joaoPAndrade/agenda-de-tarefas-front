import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../components/navBar.dart';
import '../../components/sideBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../report/reportScreen.dart';
import '../../models/category.dart';
class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class CreateCategoryDialog extends StatefulWidget {
  final Function(String, String) onCreate;

  CreateCategoryDialog({required this.onCreate});

  @override
  _CreateCategoryDialogState createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final categoryName = TextEditingController();
  String? emailLocal;

  Future<void> loadLocalEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        emailLocal = prefs.getString('email');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadLocalEmail();
  }

  @override
  void dispose() {
    categoryName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF8DDCE),
      title: const Text("Criar Nova Categoria"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: categoryName,
            decoration: const InputDecoration(labelText: "Nome da Categoria"),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (categoryName.text.isNotEmpty && emailLocal != null) {
              widget.onCreate(categoryName.text, emailLocal!);
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC03A2B)),
          child: const Text("Criar", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> categories = [];
  late String? emailLocal;
  bool isLoading = false;

  Future<void> loadLocalEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        emailLocal = prefs.getString('email');
      });
    }
    if (emailLocal != null) {
      fetchCategories(emailLocal);
    }
  }

  @override
  void initState() {
    super.initState();
    loadLocalEmail();
  }

  Future<void> fetchCategories(String? email) async {
    print(email);
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3333/category/group?ownerEmail=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final List<dynamic> categoryList = responseBody['categories'];
        setState(() {
          categories =
              categoryList.map((data) => Category.fromJson(data)).toList();
        });
      } else {
        throw Exception('Erro ao carregar categorias.');
      }
    } catch (e) {
      print("Erro: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> createCategory(String name, String ownerEmail) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3333/category'),
        body: json.encode({
          'name': name,
          'ownerEmail': ownerEmail,
        }),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        fetchCategories(ownerEmail); // Recarregar as categorias
      } else {
        throw Exception('Erro ao criar categoria.');
      }
    } catch (e) {
      print("Erro ao criar categoria: $e");
    }
  }

  void editCategory(BuildContext context, int categoryId, String ownerEmail,
      String currentName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController =
            TextEditingController(text: currentName);
        final _formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Editar Categoria"),
              backgroundColor: const Color(0xFFF8DDCE),
              contentPadding: const EdgeInsets.all(16.0),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Insira o novo nome da categoria',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "O nome da categoria não pode estar vazio";
                    }
                    return null;
                  },
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFC03A2B),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Color(0xFFF8DDCE)),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFC03A2B),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool isUpdated = await updateCategory(
                              categoryId, ownerEmail, nameController.text);
                          if (isUpdated) {
                            fetchCategories(ownerEmail);
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text(
                        'Salvar',
                        style: TextStyle(color: Color(0xFFF8DDCE)),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> updateCategory(
      int categoryId, String ownerEmail, String name) async {
    final url = Uri.parse('http://localhost:3333/category/$categoryId');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ownerEmail': ownerEmail,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint("Erro ao atualizar categoria: ${response.body}");
      return false;
    }
  }

  Future<bool> deleteCategory(Category category) async {
    bool? shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8DDCE),
          title: const Text(
            'Confirmar atualização',
            style: TextStyle(color: Colors.black),
          ),
          content: const Text(
            'Você tem certeza que deseja excluir a categoria?',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFF8DDCE)),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFC03A2B),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Color(0xFFF8DDCE)),
              ),
            ),
          ],
        );
      },
    );
    if (shouldUpdate == true) {
      final url = Uri.parse('http://localhost:3333/category/${category.id}');

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ownerEmail': category.ownerEmail}),
      );

      if (response.statusCode == 204) {
        fetchCategories(category.ownerEmail);

        return true;
      } else {
        debugPrint("Erro ao excluir categoria: ${response.body}");
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const navBar(),
      drawer: const Sidebar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final Category category = categories[index];
                return Card(
                  child: ListTile(
                    title: Text(category.name),
                    subtitle: Text(
                        "Proprietário: ${category.ownerEmail == emailLocal ? "Dono" : "Participante"}"),
                    leading:
                        const Icon(Icons.category, color: Color(0xFFC03A2B)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Permite que os botões ocupem o mínimo de espaço necessário
                      children: [
                        // Botão de Deletar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC03A2B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {
                              deleteCategory(category);
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        const SizedBox(width: 8), // Espaço entre os botões
                        // Novo botão
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFF577A59), // Cor para o novo botão (verde, por exemplo)
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Ação do novo botão
                              editCategory(context, category.id,
                                  category.ownerEmail, category.name);
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Reportscreen(category: category))),
                      
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC03A2B),
        onPressed: () {
          if (emailLocal != null) {
            showDialog(
              context: context,
              builder: (context) =>
                  CreateCategoryDialog(onCreate: createCategory),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      "Erro: Email não encontrado. Por favor, tente novamente.")),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}


/*
class Category {
  int id;
  String name;
  String ownerEmail;

  Category({
    required this.id,
    required this.name,
    required this.ownerEmail,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      ownerEmail: json['ownerEmail'],
    );
  }
}
*/