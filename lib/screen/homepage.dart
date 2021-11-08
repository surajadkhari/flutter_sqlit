import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sqlit_todo/services/sql_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  bool _loading = true;

  //loadDatafunction
  void _loadTodos() async {
    var data = await SqlService().getTodo();
    setState(() {
      _todos = data;
      _loading = false;
    });
  }

//addTOdo
  Future<void> _addTodo() async {
    await SqlService()
        .insertTodo(_titleController.text, _descriptionController.text);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green.shade100,
        content: Text("Successfully Added")));

    _loadTodos();
  }

  //Update Todo
  Future<void> _updateTodo(int id) async {
    await SqlService()
        .updateTodo(id, _titleController.text, _descriptionController.text);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue.shade100,
        content: Text("Successfully Updated")));
    _loadTodos();
  }

  //Delete Todo
  Future<void> _deleteTodo(int id) async {
    await SqlService().deleteTodo(id);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red.shade100,
        content: Text("Successfully Deleted")));
    _loadTodos();
  }

//Display
  void _showFrom(int? id) async {
    if (id != null) {
      final _oldTodo = _todos.firstWhere((element) => element['id'] == id);
      _titleController.text = _oldTodo['title'];
      _descriptionController.text = _oldTodo['description'];
    }
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            height: 500,
      
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(hintText: 'title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(hintText: 'description'),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addTodo();
                      }
                      if (id != null) {
                        await _updateTodo(id);
                      }
                      Navigator.pop(context);
                    },
                    child: id == null ? Text("Add Todo") : Text('Update Todo'))
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    _loadTodos(); //first check
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do app'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFrom(null);
        },
        child: Icon(Icons.add),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: _todos[index]['title'],
                  subtitle: _todos[index]['description'],
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _showFrom(_todos[index]['id']);
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _deleteTodo(_todos[index]['id']);
                          },
                          icon: Icon(Icons.delete),
                        )
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
