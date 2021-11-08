import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlService {
//Open Database
  Future<sql.Database> Db() async {
    return sql.openDatabase('todo.db', version: 1,
        //create database
        onCreate: (sql.Database database, int verssion) async {
      await createTables(database);

      //Direct create table ko execution code use garna milcha but hamile different fuction bata call agreko
      //   await database.execute("""CREATE TABLE Todo(
      //   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      //   title TEXT,
      //   description TEXT,
      //   createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      // )""");
    });
  }

  //Create Table
  Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE Todo(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

//Inset To Do
  Future<int> insertTodo(String title, String description) async {
    //Databse open garera table ma pass garne, Sqlservice() use garera Db lai call gareko
    final _db = await SqlService().Db(); //_db =instace to open data
    final todoData = {
      'title': title,
      'description': description,
    };
    final id = await _db.insert('Todo', todoData,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

//Read todo
  Future<List<Map<String, dynamic>>> getTodo() async {
    final _db = await SqlService().Db(); //open database
    return _db.query('Todo', orderBy: 'id');
  }

//Update new Todo
  Future<int> updateTodo(int id, String title, String description) async {
    final _db = await SqlService().Db(); //open database
    final newTodo = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString()
    };
    final result =
        await _db.update('Todo', newTodo, where: 'id =?', whereArgs: [id]);
    return result;
  }

  //Delete
  Future deleteTodo(int id) async {
    final _db = await SqlService().Db(); //open database
    try {
      await _db.delete('Todo', where: 'id=?', whereArgs: [id]);
    } catch (error) {
      debugPrint(error.toString());
    }
  }
}
