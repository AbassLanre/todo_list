import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/todoitem.dart';
import 'package:todo_list/utils/databaseclient.dart';
import 'package:todo_list/utils/dateformatter.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _textController = TextEditingController();
  var db = DatabaseHelper();
  final List<TodoItem> _itemList = <TodoItem>[];

  //////////////////////////////////////////////////////////////////////////////
  void _handleSubmit(String Text) async {
    _textController.clear();
    TodoItem todoItem = TodoItem(Text, dateFormatted());
    int savedItemId = await db.saveItem(todoItem);

    TodoItem addedItem = await db.getItem(savedItemId);
    setState(() {
      _itemList.insert(0, addedItem);
    });

    print("saved is $savedItemId");
  }

  ///////////////////////////////////////////////////////////////////////////////
  void _showFormDialog() {
    var alert = new AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
                labelText: "Item",
                hintText: "What do you want to do",
                icon: Icon(Icons.note_add)),
          ))
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _handleSubmit(_textController.text);
            _textController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  //////////////////////////////////////////////////////////////////////////////
  _showTodoList() async {
    List items = await db.getAllItems();

    //you can use a for loop here if you like. Check database_intro
    items.forEach((element) {
      TodoItem todoItem = TodoItem.map(element);
      setState(() {
        _itemList.add(TodoItem.map(element));
      });
      print(" do ${todoItem.itemName}");
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  _deleteTodo(int id, int index) async {
    debugPrint("deleted");
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  _updateItem(TodoItem todoItem, int index) {
    var alert = new AlertDialog(
      title: Text("Update"),
      content: Row(
        children: <Widget>[
          Expanded(
              child: TextField(
            controller: _textController,
            autofocus: true,
            decoration: InputDecoration(
                labelText: "Item",
                hintText: "Update",
                icon: Icon(Icons.update)),
          ))
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async {
            TodoItem newtodoitem = TodoItem.fromMap({
              "itemName": _textController.text,
              "dateCreated": dateFormatted(),
              "id": todoItem.id,
            });
            _handleSubmittedUpdate(index, todoItem);
            await db.updateItem(newtodoitem);
            setState(() {
              _showTodoList();
            });
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        FlatButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancel"))
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  //////////////////////////////////////////////////////////////////////////////
  void _handleSubmittedUpdate(int index, TodoItem todoItem) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName == todoItem.itemName;
      });
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    super.initState();
    _showTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index) {
                    return Card(
                      color: Colors.white12,
                      child: ListTile(
                        title: _itemList[index],
                        onLongPress: () => _updateItem(_itemList[index], index),
                        trailing: Listener(
                          key: Key(_itemList[index].itemName),
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.blueGrey,
                          ),
                          onPointerDown: (pointerEvent) =>
                              _deleteTodo(_itemList[index].id, index),
                        ),
                      ),
                    );
                  })),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: "Add Item",
          backgroundColor: Colors.blueGrey,
          child: ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }
}
