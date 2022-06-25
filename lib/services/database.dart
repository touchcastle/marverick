import 'package:marverick/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:marverick/models/form.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/models/field.dart';

class DatabaseService {
  static Future openDB() async {
    openDatabase(join(await getDatabasesPath(), kDbName),
        onCreate: onCreateTable, onUpgrade: onUpdateTable, version: 1);
  }

  static Future onCreateTable(Database db, int version) async {
    print('Crate new table>>');
    await db.execute("CREATE TABLE $kDbLineCheck(id TEXT PRIMARY KEY NOT NULL, "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "examiner_rank TEXT, "
        "examiner_id TEXT, "
        "examiner_license_no TEXT, "
        "examiner_name TEXT, "
        "type_of_check TEXT, "
        "other_type TEXT, "
        "date_1 TEXT, "
        "ac_type_1 TEXT, "
        "ac_reg_1 TEXT, "
        "flt_no_1 TEXT, "
        "from_1 TEXT, "
        "to_1 TEXT, "
        "duty_1 TEXT, "
        "date_2 TEXT, "
        "ac_type_2 TEXT, "
        "ac_reg_2 TEXT, "
        "flt_no_2 TEXT, "
        "from_2 TEXT, "
        "to_2 TEXT, "
        "duty_2 TEXT, "
        "a_1 TEXT, "
        "a_2 TEXT, "
        "a_3 TEXT, "
        "a_4 TEXT, "
        "a_5 TEXT, "
        "a_6 TEXT, "
        "a_7 TEXT, "
        "a_comment TEXT, "
        "b_8 TEXT, "
        "b_9 TEXT, "
        "b_10 TEXT, "
        "b_11 TEXT, "
        "b_12 TEXT, "
        "b_13 TEXT, "
        "b_comment TEXT, "
        "c_14 TEXT, "
        "c_15 TEXT, "
        "c_16 TEXT, "
        "c_17 TEXT, "
        "c_18 TEXT, "
        "c_comment TEXT, "
        "d_19 TEXT, "
        "d_20 TEXT, "
        "d_21 TEXT, "
        "d_22 TEXT, "
        "d_23 TEXT, "
        "d_24 TEXT, "
        "d_25 TEXT, "
        "d_26 TEXT, "
        "d_27 TEXT, "
        "d_28 TEXT, "
        "d_comment TEXT, "
        "e_29 TEXT, "
        "e_30 TEXT, "
        "e_31 TEXT, "
        "e_32 TEXT, "
        "e_33 TEXT, "
        "e_34 TEXT, "
        "e_comment TEXT, "
        "brief_1 TEXT, "
        "brief_2 TEXT, "
        "brief_3 TEXT, "
        "brief_4 TEXT, "
        "brief_5 TEXT, "
        "brief_comment TEXT, "
        "comp_pro TEXT, "
        "comp_com TEXT, "
        "comp_fpa TEXT, "
        "comp_fpm TEXT, "
        "comp_kno TEXT, "
        "comp_ltw TEXT, "
        "comp_psd TEXT, "
        "comp_saw TEXT, "
        "comp_wlm TEXT, "
        "general_comment TEXT, "
        "result TEXT, "
        "competent_level TEXT, "
        "result_comment TEXT,"
        "pilot_sig_date TEXT,"
        "examiner_sig_date TEXT"
        ")");
  }

  static Future onUpdateTable(
      Database db, int oldVersion, int newVersion) async {
    // if (oldVersion < newVersion && newVersion == 2) {
    //   await db.execute(
    //       "CREATE TABLE $kDbRecord(id TEXT PRIMARY KEY NOT NULL, record TEXT NOT NULL)");
    // }
  }
}

class LineCheckDatabase {
  // List<DatabaseDeviceName>? databaseDeviceName = [];

  static Future<Database> database() async => openDatabase(
        join(await getDatabasesPath(), kDbName),
      );

  static Future<void> dbLineCheckInsert(Form form) async {
    final Database db = await database();
    await db.insert(
      kDbLineCheck, //Table name
      form.lineCheckToMap(), //Data's Row
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> dbLineCheckDelete(Form form) async {
    final Database db = await database();
    await db.delete(
      kDbLineCheck, //Table name
      where: "id = ?",
      whereArgs: [form.id],
    );
  }

  //Query Device Database
  static Future<List<Form>> dbLineCheckQuery() async {
    final Database db = await database();
    List<Form> _dbList = [];
    final List<Map<String, dynamic>> maps = await db.query(kDbLineCheck);
    List.generate(maps.length, (i) {
      Form _new = FormService.initLineCheck();

      //To get item value from database.
      Field _replaceItemValue(Field field) {
        Field _result = field;
        String _name = field.name;
        if (maps[i][_name] != null && maps[i][_name] != '') {
          _result.stringValue = maps[i][_name];
          if (_result.type == FieldType.radio) {
            _result.intValue =
                _result.listValue.indexWhere((e) => e == maps[i][_name]);
          }
        }
        return _result;
      }

      // _new.status = maps[i]['status'] == 'working'
      //     ? FormStatus.working
      //     : maps[i]['status'] == 'completed'
      //         ? FormStatus.completed
      //         : FormStatus.pending;
      _new.status = FormStatus.values
          .firstWhere((e) => e.toString() == maps[i]['status']);
      _new.type = FormType.lineCheck;
      _new.formName = maps[i]['form_name'];
      _new.createDateTime = DateTime.parse(maps[i]['create_at']);
      if (maps[i]['submit_at'] != null && maps[i]['submit_at'] != '') {
        _new.submitDateTime = DateTime.parse(maps[i]['submit_at']);
      }
      _new.createBy = maps[i]['create_by'];
      _new.filePath = maps[i]['file_path'];
      _new.id = maps[i]['id'];
      _new.fontSize = double.parse(maps[i]['font_size']);

      for (int _i = 0; _i < _new.fields.length; _i++) {
        _new.fields[_i] = _replaceItemValue(_new.fields[_i]);
      }

      _dbList.add(_new);
    });
    return _dbList;
  }

  //
  // //Update Device
  // Future<void> dbLineCheckUpdate(
  //     {required String id, required String name}) async {
  //   DatabaseDeviceName _updateData =
  //   DatabaseDeviceName(id: id, deviceName: name);
  //   final db = await _database();
  //   await db.update(
  //     kDbDeviceName,
  //     _updateData.toMap(),
  //     where: "id = ?",
  //     whereArgs: [_updateData.id],
  //   );
  // }
  //
  // //Delete Device
  // Future<void> dbLineCheckDelete({required String id}) async {
  //   final Future<Database> database = openDatabase(
  //     join(await getDatabasesPath(), kDbName),
  //   );
  //   final db = await database;
  //
  //   await db.delete(
  //     kDbDeviceName,
  //     where: "id = ?",
  //     whereArgs: [id],
  //   );
  // }

  // /// Get displayName from [databaseDeviceName] and return.
  // ///
  // /// If not found, return old same [name].
  // String getStoredName({required String id, required String name}) {
  //   String _deviceName = name;
  //   if (databaseDeviceName != null) {
  //     int _i =
  //     databaseDeviceName!.indexWhere((d) => d.id == id);
  //     if (_i >= 0) {
  //       _deviceName = databaseDeviceName![_i].deviceName;
  //     }
  //   }
  //   return _deviceName;
  // }

// Future updateName({required String id, required String name}) async {
//   if (databaseDeviceName!.indexWhere((d) => d.id == id) < 0) {
//     dbInsertDevice(id: id, name: name);
//     databaseDeviceName?.add(DatabaseDeviceName(id: id, deviceName: name));
//   } else {
//     dbUpdateDevice(id: id, name: name);
//     int _i = databaseDeviceName!.indexWhere((d) => d.id == id);
//     databaseDeviceName![_i].deviceName = name;
//   }
// }
}
