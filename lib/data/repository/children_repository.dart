import 'package:nannyplus/data/model/child.dart';
import 'package:nannyplus/utils/database_util.dart';
import 'package:nannyplus/utils/prefs_util.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'children_repository.g.dart';

class ChildrenRepository {
  const ChildrenRepository();

  Future<List<Child>> getChildList(bool showArchived) async {
    final db = await DatabaseUtil.instance;
    final prefs = await PrefsUtil.getInstance();

    final rows = await db.query(
      'children',
      where: 'archived <= ?',
      whereArgs: [if (showArchived) 1 else 0],
      orderBy: prefs.sortListByLastName
          ? 'lastName, firstName'
          : 'firstName, lastname',
    );

    return rows.map(Child.fromMap).toList();
  }

  Future<Child> create(Child child) async {
    final db = await DatabaseUtil.instance;
    final id = await db.insert('children', child.toMap());

    return read(id);
  }

  Future<Child> read(int id) async {
    final db = await DatabaseUtil.instance;
    final child = await db.query('children', where: 'id = ?', whereArgs: [id]);

    return Child.fromMap(child.first);
  }

  Future<Child> update(Child child) async {
    final db = await DatabaseUtil.instance;
    await db.update(
      'children',
      child.toMap(),
      where: 'id = ?',
      whereArgs: [child.id],
    );

    return await read(child.id!);
  }

  Future<void> delete(Child child) async {
    final db = await DatabaseUtil.instance;
    await db.delete('invoices', where: 'childId = ?', whereArgs: [child.id]);
    await db.delete('services', where: 'childId = ?', whereArgs: [child.id]);
    await db.delete('children', where: 'id = ?', whereArgs: [child.id]);
  }

  Future<Map<int, String>> readChildrenNGrams() async {
    final db = await DatabaseUtil.instance;
    final rows = await db.query('children');
    final children = rows.map(Child.fromMap).toList();

    final childNames = <int, String>{};
    for (final child in children) {
      childNames[child.id as int] = child.nGram;
    }

    return childNames;
  }
}

@riverpod
ChildrenRepository childrenRepository(ChildrenRepositoryRef ref) {
  return const ChildrenRepository();
}
