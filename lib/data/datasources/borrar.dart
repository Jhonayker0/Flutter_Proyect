import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> deleteDatabaseFile() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app.db'); // el nombre de tu DB
  await deleteDatabase(path);
  print('Base de datos eliminada');
}