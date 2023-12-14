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

  ///TODO: New form (9): Add new database version
  static Future onCreateTable(Database db, int version) async {
    print('Crate new table>> linecheck');
    await db
        .execute("CREATE TABLE $kLineCheckTable (id TEXT PRIMARY KEY NOT NULL, "
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

    print('Crate new table>> ppc');
    await db.execute("CREATE TABLE $kPPCTable(id TEXT PRIMARY KEY , "
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
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "examiner_type TEXT, "
        "examiner_id TEXT, "
        "examiner_pel_no TEXT, "
        "examiner_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "route TEXT, "
        "check_course TEXT, "
        // "check_type TEXT, "
        "check_type_0 TEXT, "
        "check_type_1 TEXT, "
        "check_type_2 TEXT, "
        "a_1 TEXT, "
        "a_2_detail TEXT, "
        "a_2 TEXT, "
        "a_3 TEXT, "
        "a_comment TEXT, "
        "b_4 TEXT, "
        "b_5 TEXT, "
        "b_6 TEXT, "
        "b_7 TEXT, "
        "b_8 TEXT, "
        "b_comment TEXT, "
        "c_9 TEXT, "
        "c_10 TEXT, "
        "c_11 TEXT, "
        "c_12 TEXT, "
        // "c_13_detail TEXT, "
        "c_13_check_0 TEXT, "
        "c_13_check_1 TEXT, "
        "c_13_check_2 TEXT, "
        "c_13 TEXT, "
        "c_14 TEXT, "
        "c_15 TEXT, "
        "c_16 TEXT, "
        "c_comment TEXT, "
        "d_17 TEXT, "
        // "d_18_detail TEXT, "
        "d_18_check_0 TEXT, "
        "d_18_check_1 TEXT, "
        "d_18 TEXT, "
        "d_19 TEXT, "
        "d_comment TEXT, "
        // "e_20_detail TEXT, "
        "e_20_check_0 TEXT, "
        "e_20_check_1 TEXT, "
        "e_20 TEXT, "
        "e_21 TEXT, "
        "e_22 TEXT, "
        "e_23 TEXT, "
        "e_24 TEXT, "
        "e_25 TEXT, "
        "e_comment TEXT, "
        "f_26 TEXT, "
        "f_27 TEXT, "
        "f_comment TEXT, "
        // "g_28_detail TEXT, "
        "g_28_check_0 TEXT, "
        "g_28_check_1 TEXT, "
        "g_28_check_2 TEXT, "
        "g_28_check_3 TEXT, "
        "g_28_check_4 TEXT, "
        "g_28 TEXT, "
        "g_29 TEXT, "
        "g_30 TEXT, "
        "g_31 TEXT, "
        "g_32 TEXT, "
        "g_comment TEXT, "
        "h_33 TEXT, "
        "h_34 TEXT, "
        "h_35 TEXT, "
        "h_36 TEXT, "
        "h_comment TEXT, "
        "i_37 TEXT, "
        "i_38 TEXT, "
        "i_39 TEXT, "
        "i_40 TEXT, "
        "i_41 TEXT, "
        "i_comment TEXT, "
        "j_42 TEXT, "
        "j_43 TEXT, "
        "j_44_detail TEXT, "
        "j_44 TEXT, "
        "j_45_detail TEXT, "
        "j_45 TEXT, "
        "j_46_detail TEXT, "
        "j_46 TEXT, "
        "j_47_detail TEXT, "
        "j_47 TEXT, "
        "j_48_detail TEXT, "
        "j_48 TEXT, "
        "j_comment TEXT, "
        "no_landing TEXT, "
        "no_goaround TEXT, "
        "comp_kno TEXT, "
        "comp_pro TEXT, "
        "comp_com TEXT, "
        "comp_fpa TEXT, "
        "comp_fpm TEXT, "
        "comp_ltw TEXT, "
        "comp_psd TEXT, "
        "comp_saw TEXT, "
        "comp_wlm TEXT, "
        "general_comment TEXT, "
        "result TEXT, "
        "pilot_sig_date TEXT,"
        "examiner_sig_date TEXT"
        ")");
    print('create ppc complete');
  }

  static Future onUpdateTable(
      Database db, int oldVersion, int newVersion) async {
    Future version2() async {
      // await db.execute("ALTER TABLE $kPPCTable ADD check_type_0 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD check_type_1 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD check_type_2 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD c_13_check_0 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD c_13_check_1 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD c_13_check_2 TEXT");
    }

    Future version3() async {
      // await db.execute("ALTER TABLE $kPPCTable ADD d_18_check_0 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD d_18_check_1 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD e_20_check_0 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD e_20_check_1 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD g_28_check_0 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD g_28_check_1 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD g_28_check_2 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD g_28_check_3 TEXT");
      // await db.execute("ALTER TABLE $kPPCTable ADD g_28_check_4 TEXT");
    }

    // if (oldVersion == 1) {
    //   await version2();
    //   await version3();
    // } else if (oldVersion == 2) {
    //   await version3();
    // }
  }
}

class databaseService {
  // List<DatabaseDeviceName>? databaseDeviceName = [];

  static Future<Database> database() async => openDatabase(
        join(await getDatabasesPath(), kDbName),
      );

  static Future<void> dbInsert(Map<String, Object?> form, String dbName) async {
    final Database db = await database();
    await db.insert(
      // kDbLineCheck, //Table name
      dbName, //Table name
      form, //Data's Row
      // form.lineCheckToMap(), //Data's Row
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> dbDelete(Form form, String dbName) async {
    final Database db = await database();
    await db.delete(
      dbName, //Table name
      where: "id = ?",
      whereArgs: [form.id],
    );
  }

  ///Query from sql database into app's list
  static Future<List<Form>> dbQuery() async {
    final Database db = await database();
    List<Form> _dbList = [];

    Field _replaceItemValue(
        Field field, List<Map<String, dynamic>> map, int i) {
      Field _result = field;
      String _name = field.name;
      if (map[i][_name] != null && map[i][_name] != '') {
        _result.stringValue = map[i][_name];
        if (_result.type == FieldType.radio) {
          _result.intValue =
              _result.listValue.indexWhere((e) => e == map[i][_name]);
        }
      }
      return _result;
    }

    for (int dbIndex = 0; dbIndex < kDbTableList.length; dbIndex++){
      final List<Map<String, dynamic>> maps =
      await db.query(kDbTableList[dbIndex]);
      List.generate(maps.length, (i) {
        late Form append;
        ///TODO: New form (6): Add new form query db
        if(kDbTableList[dbIndex] == kLineCheckTable){
          append = FormService.initLineCheck();
        } else if(kDbTableList[dbIndex] == kPPCTable){
          append = FormService.initPpcCheck();
        }

        ///Move data from database mapping into app's list
        append.status = FormStatus.values
            .firstWhere((e) => e.toString() == maps[i]['status']);
        append.type = FormType.lineCheck;
        append.formName = maps[i]['form_name'];
        append.createDateTime = DateTime.parse(maps[i]['create_at']);
        if (maps[i]['submit_at'] != null &&
            maps[i]['submit_at'] != '') {
          append.submitDateTime = DateTime.parse(maps[i]['submit_at']);
        }
        append.createBy = maps[i]['create_by'];
        append.filePath = maps[i]['file_path'];
        append.id = maps[i]['id'];
        append.fontSize = double.parse(maps[i]['font_size']);

        ///Fields as []
        for (int _i = 0; _i < append.fields.length; _i++) {
          ///Move data into corresponding field. (normal case)
          append.fields[_i] = _replaceItemValue(append.fields[_i], maps, i);


          ///in case of checkbox type, boolean data is stored in another field
          ///with named as [field's name + '_' + array number]
          if (append.fields[_i].type == FieldType.checkbox) {
            for (int _c = 0; _c < append.fields[_i].checkBoxValue.length; _c++) {
              String name = '${append.fields[_i].name}_$_c';
              append.fields[_i].checkBoxValue[_c] =
                  bool.parse(maps[i][name].toLowerCase());
            }
          }
        }

        _dbList.add(append);
      });
    }

    ///LINE CHECK
    // final List<Map<String, dynamic>> lineCheckMaps =
    //     await db.query(kLineCheckTable);
    // List.generate(lineCheckMaps.length, (i) {
    //   Form _new = FormService.initLineCheck();
    //
    //   //To get item value from database.
    //   // Field _replaceItemValue(Field field) {
    //   //   Field _result = field;
    //   //   String _name = field.name;
    //   //   if (lineCheckMaps[i][_name] != null && lineCheckMaps[i][_name] != '') {
    //   //     _result.stringValue = lineCheckMaps[i][_name];
    //   //     if (_result.type == FieldType.radio) {
    //   //       _result.intValue = _result.listValue
    //   //           .indexWhere((e) => e == lineCheckMaps[i][_name]);
    //   //     }
    //   //   }
    //   //   return _result;
    //   // }
    //
    //   ///Move data from database mapping into list
    //   _new.status = FormStatus.values
    //       .firstWhere((e) => e.toString() == lineCheckMaps[i]['status']);
    //   _new.type = FormType.lineCheck;
    //   _new.formName = lineCheckMaps[i]['form_name'];
    //   _new.createDateTime = DateTime.parse(lineCheckMaps[i]['create_at']);
    //   if (lineCheckMaps[i]['submit_at'] != null &&
    //       lineCheckMaps[i]['submit_at'] != '') {
    //     _new.submitDateTime = DateTime.parse(lineCheckMaps[i]['submit_at']);
    //   }
    //   _new.createBy = lineCheckMaps[i]['create_by'];
    //   _new.filePath = lineCheckMaps[i]['file_path'];
    //   _new.id = lineCheckMaps[i]['id'];
    //   _new.fontSize = double.parse(lineCheckMaps[i]['font_size']);
    //
    //   for (int _i = 0; _i < _new.fields.length; _i++) {
    //     _new.fields[_i] = _replaceItemValue(_new.fields[_i], lineCheckMaps, i);
    //   }
    //
    //   _dbList.add(_new);
    // });

    ///PPC
    // final List<Map<String, dynamic>> ppcMaps = await db.query(kPPCTable);
    // List.generate(ppcMaps.length, (i) {
    //   Form _new = FormService.initPpcCheck();
    //
    //   //To get item value from database.
    //   // Field _replaceItemValue(Field field) {
    //   //   Field _result = field;
    //   //   String _name = field.name;
    //   //   if (ppcMaps[i][_name] != null && ppcMaps[i][_name] != '') {
    //   //     _result.stringValue = ppcMaps[i][_name];
    //   //     if (_result.type == FieldType.radio) {
    //   //       _result.intValue =
    //   //           _result.listValue.indexWhere((e) => e == ppcMaps[i][_name]);
    //   //     }
    //   //   }
    //   //   return _result;
    //   // }
    //
    //   ///Move data from database mapping into list
    //   _new.status = FormStatus.values
    //       .firstWhere((e) => e.toString() == ppcMaps[i]['status']);
    //   _new.type = FormType.ppc;
    //   _new.formName = ppcMaps[i]['form_name'];
    //   _new.createDateTime = DateTime.parse(ppcMaps[i]['create_at']);
    //   if (ppcMaps[i]['submit_at'] != null && ppcMaps[i]['submit_at'] != '') {
    //     _new.submitDateTime = DateTime.parse(ppcMaps[i]['submit_at']);
    //   }
    //   _new.createBy = ppcMaps[i]['create_by'];
    //   _new.filePath = ppcMaps[i]['file_path'];
    //   _new.id = ppcMaps[i]['id'];
    //   _new.fontSize = double.parse(ppcMaps[i]['font_size']);
    //
    //   for (int _i = 0; _i < _new.fields.length; _i++) {
    //     _new.fields[_i] = _replaceItemValue(_new.fields[_i], ppcMaps, i);
    //
    //     ///Add case for transfer checkbox data
    //     if (_new.fields[_i].type == FieldType.checkbox) {
    //       for (int _c = 0; _c < _new.fields[_i].checkBoxValue.length; _c++) {
    //         String _name = _new.fields[_i].name + '_' + _c.toString();
    //         _new.fields[_i].checkBoxValue[_c] =
    //             bool.parse(ppcMaps[i][_name].toLowerCase());
    //       }
    //     }
    //   }
    //
    //   _dbList.add(_new);
    // });
    return _dbList;
  }
}
