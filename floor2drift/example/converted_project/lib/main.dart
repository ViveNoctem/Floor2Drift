import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:initial_project/floor/database.dart';
import 'package:initial_project/floor/user.dart';
import 'package:initial_project/task_board.dart';

void main() async {
  final database = await initDatabase();

  runApp(MyApp(database: database));
}

// create migration
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE person ADD COLUMN nickname TEXT');
});

// create migration
final migration2to3 = Migration(2, 3, (database) async {
  await database.execute('ALTER TABLE person ADD COLUMN nickname TEXT');
});

Future<ExampleDatabase> initDatabase() async {
  final database = await $FloorExampleDatabase
      .databaseBuilder('app_database.db')
      .addMigrations([migration1to2, migration2to3])
      .build();

  return database;
}

class MyApp extends StatelessWidget {
  final ExampleDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', database: database),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ExampleDatabase database;

  const MyHomePage({super.key, required this.title, required this.database});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController userNameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userNameController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> create() async {
    final userName = userNameController.text;
    final password = passwordController.text;

    final user = await widget.database.userDao.getByUsername(userName);

    if (user != null) {
      if (mounted == false) {
        return;
      }

      const snackBar = SnackBar(content: Text('User already exists'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final newUser = ExampleUser(
      userName: userName,
      password: password,
      id: null,
    );
    await widget.database.userDao.insertUser(newUser);

    if (mounted == false) {
      return;
    }

    final snackBar = SnackBar(content: Text("User added successfully"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> submit() async {
    final userName = userNameController.text;
    final password = passwordController.text;

    final user = await widget.database.userDao.getByUsername(userName);

    if (user == null) {
      if (mounted == false) {
        return;
      }

      const snackBar = SnackBar(content: Text('User does not exist'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (user.password != password) {
      if (mounted == false) {
        return;
      }

      const snackBar = SnackBar(content: Text('Password wrong'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (mounted == false) {
      return;
    }

    const snackBar = SnackBar(content: Text('Login successful'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskBoard(database: widget.database, user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[
              TextField(
                controller: userNameController,
                decoration: InputDecoration.collapsed(hintText: "Username"),
              ),
              const SizedBox(height: 30),
              TextField(
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration.collapsed(hintText: "Password"),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  OutlinedButton(onPressed: create, child: Text("Create")),
                  const SizedBox(width: 30),
                  OutlinedButton(onPressed: submit, child: Text("Submit")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
