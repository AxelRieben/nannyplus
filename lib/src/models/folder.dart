import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/database_utils.dart';

class Folder {
  Folder.create({
    this.firstName,
    this.lastName,
    this.birthDate,
    this.preSchool,
    this.kinderGarden,
    this.allergies,
    this.parentsName,
    this.address,
    this.phoneNumber,
    this.misc,
    this.archived,
  });
  Folder.empty();

  int? id;
  String? firstName;
  String? lastName;
  DateTime? birthDate;
  bool? preSchool;
  bool? kinderGarden;
  String? allergies;
  String? parentsName;
  String? address;
  String? phoneNumber;
  String? misc;
  bool? archived;

  Folder.fromDbMap(Map<String, Object?> row)
      : id = row['id'] as int,
        firstName = row['firstName'] as String?,
        lastName = row['lastName'] as String?,
        birthDate = row['birthDate'] == null ? null : DateTime.parse(row['birthDate'] as String),
        preSchool = row['preSchool'].toBool(),
        kinderGarden = row['kinderGarden'].toBool(),
        allergies = row['allergies'] as String?,
        parentsName = row['parentsName'] as String?,
        address = row['address'] as String?,
        phoneNumber = row['phoneNumber'] as String?,
        misc = row['misc'] as String?,
        archived = row['archived'].toBool();

  Map<String, Object?> toDbMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate == null ? null : DateFormat('yyyy-MM-dd').format(birthDate!),
      'preSchool': preSchool.toDbInt(),
      'kinderGarden': kinderGarden.toDbInt(),
      'allergies': allergies,
      'parentsName': parentsName,
      'address': address,
      'phoneNumber': phoneNumber,
      'misc': misc,
      'archived': archived.toDbInt(),
    };
  }
}

extension ListExt on List<Folder> {
  sortByFirstName() {
    sort((a, b) => a.firstName!.compareTo(b.firstName!));
  }
}

class Folders extends ChangeNotifier {
  Folders() {
    reload();
  }

  final _data = <Folder>[];

  List<Folder> get data => UnmodifiableListView(_data.where((element) => !element.archived!));

  Future<void> createFolder(Folder folder) async {
    var db = await DatabaseUtils.databaseUtils.database;
    await db.insert('folder', folder.toDbMap());
    reload();
  }

  Future<void> addFolders(List<Folder> folders) async {
    var db = await DatabaseUtils.databaseUtils.database;
    for (var folder in folders) {
      await db.insert('folder', folder.toDbMap());
    }
    await reload();
  }

  Future<void> reload() async {
    var db = await DatabaseUtils.databaseUtils.database;
    var rows = await db.query('folder');
    _data.clear();
    _data.addAll(rows.map((row) => Folder.fromDbMap(row)).toList());
    _data.sortByFirstName();
    notifyListeners();
  }
}
