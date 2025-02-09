import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
// ignore: implementation_imports
import 'package:gettext_i18n/src/gettext_localizations.dart';
import 'package:intl/intl.dart';
import 'package:nannyplus/utils/font_utils.dart';
import 'package:nannyplus/utils/i18n_utils.dart';
import 'package:nannyplus/utils/prefs_util.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqlite;

class DatabaseUtil {
  DatabaseUtil._();
  static sqlite.Database? _database;

  static Future<String> get _databasePath async =>
      join(await sqlite.getDatabasesPath(), 'childcare.db');

  static Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }

  static Future<void> deleteDatabase() async {
    await closeDatabase();
    await sqlite.deleteDatabase(await _databasePath);
  }

  static Future<void> clear() async {
    await _database?.delete('children');
    await _database?.delete('prices');
    await _database?.delete('services');
    await _database?.delete('invoices');
  }

  static Future<String> get databasePath async => await _databasePath;

  static Future<sqlite.Database> get instance async {
    if (_database != null) return _database!;

    _database = await sqlite.openDatabase(
      await _databasePath,
      version: 13,
      onCreate: (db, version) async {
        await _create(db);
        for (var i = 2; i <= version; i++) {
          await _upgradeTo(i, db);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (var i = oldVersion + 1; i <= newVersion; i++) {
          await _upgradeTo(i, db);
        }
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        throw Exception('Downgrade not supported');
      },
    );

    return _database!;
  }

  static Future<void> _create(sqlite.Database db) async {
    final gettext = await GettextLocalizationsDelegate().load(I18nUtils.locale);

    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT,
        birthdate TEXT,
        phoneNumber TEXT,
        allergies TEXT,
        parentsName TEXT,
        address TEXT,
        archived INTEGER NOT NULL DEFAULT 0,
        preschool INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        label TEXT,
        amount DOUBLE,
        fixedPrice INTEGER
      )
      ''');

    await db.execute('''
      CREATE TABLE services(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        childId INTEGER NOT NULL,
        date TEXT,
        priceId INTEGER NOT NULL,
        priceLabel TEXT,
        priceAmount DOUBLE,
        isFixedPrice INTEGER,
        hours INTEGER,
        minutes INTEGER,
        total DOUBLE,
        invoiced INTEGER,
        invoiceId INTEGER
      )
      ''');

    await db.execute('''
      CREATE TABLE invoices(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        number INTEGER NOT NULL,
        childId INTEGER NOT NULL,
        date TEXT,
        total DOUBLE NOT NULL,
        parentsName TEXT NOT NULL,
        address TEXT NOT NULL
      )
      ''');

    await insertSampleData(db, gettext);
  }

  static Future<void> insertSampleData(
    sqlite.Database db,
    GettextLocalizations gettext,
  ) async {
    // Sample data for the first time user

    await insertSamplePrices(db, gettext);

    await insertSampleChildren(db, gettext);

    await insertSampleServices(db, gettext);

    await insertSampleInvoice(db, gettext);

    final prefsUtil = await PrefsUtil.getInstance();
    await prefsUtil.clear();
    prefsUtil
      ..line1 = 'Nanny+'
      ..line1FontFamily = FontUtils.defaultFontItem.family
      ..line1FontAsset = FontUtils.defaultFontItem.asset
      ..line2 = gettext.t('Your name', null)
      ..line2FontFamily = FontUtils.defaultFontItem.family
      ..line2FontAsset = FontUtils.defaultFontItem.asset
      ..conditions = gettext.t('Payment within 10 day via bank transfert', null)
      ..bankDetails = "${gettext.t("Bank : {0}", [
            "Monopoly",
          ])}\n${gettext.t("IBAN : {0}", ["XY7900123456789"])}"
      ..address = 'Boldistrasse 97\n2560 Nidau';

    final image = await rootBundle.load('assets/img/logo.png');
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final appDocumentsPath = appDocumentsDirectory.path;
    final filePath = '$appDocumentsPath/logo';
    File(filePath).writeAsBytesSync(
      image.buffer.asUint8List(),
      flush: true,
    );
  }

  static Future<void> insertSampleInvoice(
    sqlite.Database db,
    GettextLocalizations gettext,
  ) async {
    await db.insert('invoices', {
      'number': 1,
      'childId': 1,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'total': 43,
      'parentsName': 'Manon et Robet Simon',
      'address': 'Höhenweg 136\n8888 Heiligkreuz',
    });
  }

  // ignore: long-method
  static Future<void> insertSampleServices(
    sqlite.Database db,
    GettextLocalizations gettext,
  ) async {
    await db.insert('services', {
      'childId': 1,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'priceId': 1,
      'priceLabel': gettext.t('Example {0}', [1]),
      'priceAmount': 5.0,
      'isFixedPrice': 1,
      'hours': 0,
      'minutes': 0,
      'total': 5.0,
      'invoiced': 0,
      'invoiceId': null,
    });

    await db.insert('services', {
      'childId': 1,
      'date': DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 7))),
      'priceId': 1,
      'priceLabel': gettext.t('Example {0}', [2]),
      'priceAmount': 7.0,
      'isFixedPrice': 1,
      'hours': 0,
      'minutes': 0,
      'total': 7.0,
      'invoiced': 1,
      'invoiceId': 1,
    });

    await db.insert('services', {
      'childId': 1,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'priceId': 1,
      'priceLabel': gettext.t('Example {0}', [3]),
      'priceAmount': 7.0,
      'isFixedPrice': 0,
      'hours': 3,
      'minutes': 15,
      'total': 22.75,
      'invoiced': 0,
      'invoiceId': 0,
    });

    await db.insert('services', {
      'childId': 1,
      'date': DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 6))),
      'priceId': 1,
      'priceLabel': gettext.t('Example {0}', [4]),
      'priceAmount': 8.0,
      'isFixedPrice': 0,
      'hours': 4,
      'minutes': 30,
      'total': 36.00,
      'invoiced': 1,
      'invoiceId': 1,
    });
  }

  static Future<void> insertSampleChildren(
    sqlite.Database db,
    GettextLocalizations gettext,
  ) async {
    await db.insert('children', {
      'firstName': 'Fabienne',
      'lastName': 'Simon',
      'birthdate': '2014-08-01',
      'phoneNumber': '+41329866242',
      'allergies': gettext.t('Peanuts', null),
      'parentsName': 'Manon et Robert Simon',
      'address': 'Höhenweg 136\n8888 Heiligkreuz',
      'archived': 0,
      'preschool': 0,
    });
  }

  static Future<void> insertSamplePrices(
    sqlite.Database db,
    GettextLocalizations gettext,
  ) async {
    await db.insert('prices', {
      'label': gettext.t('Example {0}', [1]),
      'amount': 5.0,
      'fixedPrice': 1,
    });

    await db.insert('prices', {
      'label': gettext.t('Example {0}', [2]),
      'amount': 7.0,
      'fixedPrice': 1,
    });

    await db.insert('prices', {
      'label': gettext.t('Example {0}', [3]),
      'amount': 7.0,
      'fixedPrice': 0,
    });

    await db.insert('prices', {
      'label': gettext.t('Example {0}', [4]),
      'amount': 8.0,
      'fixedPrice': 0,
    });
  }

  static Future<void> _upgradeTo(int version, sqlite.Database db) async {
    if (version == 2) {
      await db.execute('''
      ALTER TABLE children
      ADD labelForPhoneNumber2 TEXT
      ''');
      await db.execute('''
      ALTER TABLE children
      ADD phoneNumber2 TEXT
      ''');
      await db.execute('''
      ALTER TABLE children
      ADD labelForPhoneNumber3 TEXT
      ''');
      await db.execute('''
      ALTER TABLE children
      ADD phoneNumber3 TEXT
      ''');
      await db.execute('''
      ALTER TABLE children
      ADD freeText TEXT
      ''');
    }

    if (version == 3) {
      await db.execute('''
    ALTER TABLE prices
    ADD sortOrder INTEGER NOT NULL DEFAULT 0
    ''');

      final rows = await db.query('prices', orderBy: 'label ASC');
      var sortOrder = 1;
      for (final row in rows) {
        await db.update(
          'prices',
          {
            'sortOrder': sortOrder,
          },
          where: 'id = ?',
          whereArgs: [
            row['id'],
          ],
        );
        sortOrder += 1;
      }
    }

    if (version == 4) {
      await db.execute('''
    ALTER TABLE invoices
    ADD paid INTEGER NOT NULL DEFAULT 0
    ''');
    }

    if (version == 5) {
      await db.execute('''
    ALTER TABLE prices 
    ADD COLUMN deleted INTEGER NOT NULL DEFAULT 0
    ''');
    }

    if (version == 6) {
      await db.execute('''
    CREATE TABLE documents (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      childId INTEGER NOT NULL,
      label TEXT NOT NULL,
      path TEXT NOT NULL,
      FOREIGN KEY(childId) REFERENCES children(id)
    )
    ''');
    }

    if (version == 7) {
      await db.execute('''
    ALTER TABLE children
    ADD COLUMN pic BLOB
    ''');
    }

    if (version == 8) {
      await db.execute('''
    ALTER TABLE documents
    ADD COLUMN bytes BLOB
    ''');
    }

    if (version == 9) {
      await db.execute('''
    ALTER TABLE invoices
    ADD COLUMN childFirstName TEXT NOT NULL DEFAULT ''
    ''');
      await db.execute('''
    ALTER TABLE invoices
    ADD COLUMN childLastName TEXT NOT NULL DEFAULT ''
    ''');
      await db.execute('''
    UPDATE invoices 
    SET 
      childFirstName = (SELECT firstName FROM children WHERE children.id = invoices.childId), 
      childLastName = (SELECT lastName FROM children WHERE children.id = invoices.childId)
    ''');
    }

    if (version == 10) {
      await db.execute('''
    CREATE TABLE deductions (
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      sortOrder INTEGER NOT NULL DEFAULT 0,
      label TEXT,
      value REAL NOT NULL DEFAULT 0,
      type TEXT,
      periodicity TEXT
    )
    ''');
    }

    if (version == 11) {
      await db.execute('''
    CREATE TABLE periods(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      childId INTEGER NOT NULL,
      day TEXT,
      hourFrom INTEGER,
      minuteFrom INTEGER,
      hourTo INTEGER,
      minuteTo INTEGER,
      sortOrder INTEGER NOT NULL DEFAULT 0
    )
      ''');

      await db.execute('''
    CREATE TABLE schedule_colors(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      childId INTEGER NOT NULL,
      color INTEGER NOT NULL
    )
      ''');

      await db.execute('''
    CREATE TABLE vacation_period(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      start TEXT,
      end TEXT,
      sortOrder INTEGER NOT NULL DEFAULT 0
    )
      ''');
    }

    if (version == 12) {
      await db.execute('''
        CREATE TABLE plannings(
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          start TEXT NOT NULL,
          end TEXT NOT NULL
        )
      ''');

      await db.execute('''
        ALTER TABLE periods
        ADD COLUMN planningId INTEGER
      ''');

      final rows = await db.query('periods', columns: ['COUNT(1) AS pcount']);
      final count = rows.first['pcount'] as int;
      if (count > 0) {
        final planningId = await db.insert('plannings', {
          'start': '2023-08-01',
          'end': '2024-07-31',
        });
        await db.update('periods', {
          'planningId': planningId,
        });
      }
    }

    if (version == 13) {
      await db.execute('''
        ALTER TABLE children
        ADD COLUMN hourCredits INTEGER NOT NULL DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE invoices
        ADD COLUMN hourCredits TEXT NOT NULL DEFAULT ''
      ''');
    }
  }
}
