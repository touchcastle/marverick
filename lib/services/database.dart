import 'package:marverick/utils/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:marverick/models/form.dart';
import 'package:marverick/models/field.dart';
import 'package:marverick/services/forms/ccc_form.dart';
import 'package:marverick/services/forms/fcss_form.dart';
import 'package:marverick/services/forms/line_check5_form.dart';
import 'package:marverick/services/forms/line_check_form.dart';
import 'package:marverick/services/forms/line_train_form.dart';
import 'package:marverick/services/forms/ppc5_form.dart';
import 'package:marverick/services/forms/ppc6_form.dart';
import 'package:marverick/services/forms/ppc8_form.dart';
import 'package:marverick/services/forms/psc_form.dart';
import 'package:marverick/services/forms/rt1_form.dart';
import 'package:marverick/services/forms/rt22_form.dart';
import 'package:marverick/services/forms/rt2_form.dart';
import 'package:marverick/services/forms/rt3_form.dart';
import 'package:marverick/services/forms/rt4_form.dart';
import 'package:marverick/services/forms/stdloft_form.dart';

class DatabaseService {
  static Future<Database> openDB() async {
    // Must return/await the actual open — otherwise callers (main.dart)
    // proceed before the database file exists and before onCreate/onUpgrade
    // (schema migrations) have actually finished running.
    return openDatabase(join(await getDatabasesPath(), kDbName),
        onCreate: onCreateTable, onUpgrade: onUpdateTable, version: 16);
  }

  static Future createLineCheck(Database db) async {
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
            "updated_at TEXT, "
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

  static Future createLineCheck5(Database db) async {
    await db
        .execute("CREATE TABLE $kLineCheck5Table (id TEXT PRIMARY KEY NOT NULL, "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        // "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        // "examiner_rank TEXT, "
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
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "a_comment TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "b_comment TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "c_comment TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "d_comment TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "e_comment TEXT, "
        "brief_1 TEXT, "
        "brief_2 TEXT, "
        "brief_3 TEXT, "
        "brief_4 TEXT, "
        "brief_5 TEXT, "
        "brief_6 TEXT, "
        "brief_comment TEXT, "
        "oral_1_text TEXT, "
        "oral_1 TEXT, "
        "oral_2_text TEXT, "
        "oral_2 TEXT, "
        "oral_3_text TEXT, "
        "oral_3 TEXT, "
        "oral_comment TEXT, "
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

  static Future createPpc(Database db) async {
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
            "updated_at TEXT, "
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

  static Future createPpc5(Database db) async {
    await db.execute("CREATE TABLE $kPPC5Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
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
        "check_type_0 TEXT, "
        "check_type_1 TEXT, "
        "check_type_2 TEXT, "
        "check_type_3 TEXT, "
        "q1 TEXT, "
        "q2_detail TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "qa_comment TEXT, "
        "q4 TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "qb_comment TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11_check_0 TEXT, "
        "q11_check_1 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13_check_0 TEXT, "
        "q13_check_1 TEXT, "
        "q13_check_2 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16_check_0 TEXT, "
        "q16_check_1 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "qc_comment TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "qd_comment TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "qe_comment TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "qf_comment TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "qg_comment TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "qh_comment TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "q53 TEXT, "
        "qi_comment TEXT, "
        "q54_detail TEXT, "
        "q54 TEXT, "
        "q55_detail TEXT, "
        "q55 TEXT, "
        "q56_detail TEXT, "
        "q56 TEXT, "
        "q57_detail TEXT, "
        "q57 TEXT, "
        "q58_detail TEXT, "
        "q58 TEXT, "
        "qj_comment TEXT, "
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
    print('create ppc5 complete');
  }

  static Future createPpc6(Database db) async {
    await db.execute("CREATE TABLE $kPPC6Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
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
        "ac_type TEXT, "
        "check_type_0 TEXT, "
        "check_type_1 TEXT, "
        "check_type_2 TEXT, "
        "check_type_3 TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3_detail TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "qb_comment TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12_check_0 TEXT, "
        "q12_check_1 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14_check_0 TEXT, "
        "q14_check_1 TEXT, "
        "q14_check_2 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17_check_0 TEXT, "
        "q17_check_1 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "qc_comment TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "qd_comment TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "qe_comment TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "qf_comment TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "qg_comment TEXT, "
        "q50 TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "qh_comment TEXT, "
        "q53 TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "qi_comment TEXT, "
        "q56_detail TEXT, "
        "q56 TEXT, "
        "q57_detail TEXT, "
        "q57 TEXT, "
        "q58_detail TEXT, "
        "q58 TEXT, "
        "qj_comment TEXT, "
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
    print('create ppc6 complete');
  }

  static Future createPpc8(Database db) async {
    await db.execute("CREATE TABLE $kPPC8Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
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
        "ac_type TEXT, "
        "check_type_0 TEXT, "
        "check_type_1 TEXT, "
        "check_type_2 TEXT, "
        "check_type_3 TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3_detail TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "qb_comment TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13_check_0 TEXT, "
        "q13_check_1 TEXT, "
        "q13_check_2 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16_check_0 TEXT, "
        "q16_check_1 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "qc_comment TEXT, "
        "q20_check_0 TEXT, "
        "q20_check_1 TEXT, "
        "q20 TEXT, "
        "q21_check_0 TEXT, "
        "q21_check_1 TEXT, "
        "q21 TEXT, "
        "qd_comment TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "qe_comment TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "qf_comment TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "qg_comment TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "qh_comment TEXT, "
        "q53 TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "qi_comment TEXT, "
        "q56 TEXT, "
        "q57 TEXT, "
        "q58 TEXT, "
        "qj_comment TEXT, "
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
    print('create ppc8 complete');
  }

  static Future createRt1(Database db) async {
    await db.execute("CREATE TABLE $kRt1Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "q5 TEXT, "
        "q6_detail TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "qb_comment TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "qc_comment TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20_check_0 TEXT, "
        "q20_check_1 TEXT, "
        "q20_check_2 TEXT, "
        "q20 TEXT, "
        "q21_check_0 TEXT, "
        "q21_check_1 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "qd_comment TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "qe_comment TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "qf_comment TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "qg_comment TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "qh_comment TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "qi_comment TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "qj_comment TEXT, "
        "q51 TEXT, "
        "q52_detail TEXT, "
        "q52 TEXT, "
        "q53_detail TEXT, "
        "q53 TEXT, "
        "q54_detail TEXT, "
        "q54 TEXT, "
        "q55_detail TEXT, "
        "q55 TEXT, "
        "qk_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt1 complete');
  }

  static Future createRt2(Database db) async {
    await db.execute("CREATE TABLE $kRt2Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "ac_type TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "q5 TEXT, "
        "q6_detail TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "qb_comment TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "qc_comment TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14_check_0 TEXT, "
        "q14_check_1 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16_check_0 TEXT, "
        "q16_check_1 TEXT, "
        "q16_check_2 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19_check_0 TEXT, "
        "q19_check_1 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "qd_comment TEXT, "
        "q27_check_0 TEXT, "
        "q27_check_1 TEXT, "
        "q27_check_2 TEXT, "
        "q27 TEXT, "
        "q28_check_0 TEXT, "
        "q28_check_1 TEXT, "
        "q28_check_2 TEXT, "
        "q28 TEXT, "
        "q29_check_0 TEXT, "
        "q29_check_1 TEXT, "
        "q29_check_2 TEXT, "
        "q29 TEXT, "
        "qe_comment TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "qf_comment TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "qg_comment TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "qh_comment TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "qi_comment TEXT, "
        "q50 TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "qj_comment TEXT, "
        "q53 TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "q56 TEXT, "
        "q57 TEXT, "
        "qk_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt2 complete');
  }

  static Future createRt22(Database db) async {
    await db.execute("CREATE TABLE $kRt22Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "ac_type TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "qa_comment TEXT, "
        "q4 TEXT, "
        "q5_detail TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "qb_comment TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "qc_comment TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14_check_0 TEXT, "
        "q14_check_1 TEXT, "
        "q14_check_2 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17_check_0 TEXT, "
        "q17_check_1 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "qd_comment TEXT, "
        "q25_check_0 TEXT, "
        "q25_check_1 TEXT, "
        "q25_check_2 TEXT, "
        "q25 TEXT, "
        "q26_check_0 TEXT, "
        "q26_check_1 TEXT, "
        "q26_check_2 TEXT, "
        "q26 TEXT, "
        "q27_check_0 TEXT, "
        "q27_check_1 TEXT, "
        "q27_check_2 TEXT, "
        "q27 TEXT, "
        "qe_comment TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35_check_0 TEXT, "
        "q35_check_1 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "qf_comment TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "qg_comment TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "qh_comment TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "qi_comment TEXT, "
        "q50 TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "qj_comment TEXT, "
        "q53 TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "q56 TEXT, "
        "q57 TEXT, "
        "qk_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt22 complete');
  }

  static Future createRt3(Database db) async {
    await db.execute("CREATE TABLE $kRt3Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "ac_type TEXT, "
        "route TEXT, "
        "rhs TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "qa_comment TEXT, "
        "q4 TEXT, "
        "q5_detail TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "qb_comment TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "qc_comment TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14_check_0 TEXT, "
        "q14_check_1 TEXT, "
        "q14_check_2 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17_check_0 TEXT, "
        "q17_check_1 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "qd_comment TEXT, "
        "q25_check_0 TEXT, "
        "q25_check_1 TEXT, "
        "q25_check_2 TEXT, "
        "q25_check_3 TEXT, "
        "q25 TEXT, "
        "q26_check_0 TEXT, "
        "q26_check_1 TEXT, "
        "q26 TEXT, "
        "q27_check_0 TEXT, "
        "q27_check_1 TEXT, "
        "q27_check_2 TEXT, "
        "q27_check_3 TEXT, "
        "q27 TEXT, "
        "qe_comment TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34_check_0 TEXT, "
        "q34_check_1 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "qf_comment TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "qg_comment TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "qh_comment TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "qi_comment TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "q53 TEXT, "
        "qj_comment TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "q56 TEXT, "
        "qk_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt3 complete');
  }

  static Future createRt4(Database db) async {
    await db.execute("CREATE TABLE $kRt4Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "ac_type TEXT, "
        "route TEXT, "
        "rhs TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "qa_comment TEXT, "
        "q4 TEXT, "
        "q5_detail TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "qb_comment TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "qc_comment TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14_check_0 TEXT, "
        "q14_check_1 TEXT, "
        "q14_check_2 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17_check_0 TEXT, "
        "q17_check_1 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "qd_comment TEXT, "
        "q25_check_0 TEXT, "
        "q25_check_1 TEXT, "
        "q25 TEXT, "
        "q26_check_0 TEXT, "
        "q26_check_1 TEXT, "
        "q26 TEXT, "
        "q27_check_0 TEXT, "
        "q27 TEXT, "
        "qe_comment TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34_check_0 TEXT, "
        "q34_check_1 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "qf_comment TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "qg_comment TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "qh_comment TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "qi_comment TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "q53 TEXT, "
        "qj_comment TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "q56 TEXT, "
        "q57_detail TEXT, "
        "q57 TEXT, "
        "q58_detail TEXT, "
        "q58 TEXT, "
        "qk_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt4 complete');
  }

  static Future createStdloft(Database db) async {
    await db.execute("CREATE TABLE $kStdloftTable(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "ac_type TEXT, "
        "route TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3_detail TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "qb_comment TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12_check_0 TEXT, "
        "q12_check_1 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14_check_0 TEXT, "
        "q14_check_1 TEXT, "
        "q14_check_2 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17_check_0 TEXT, "
        "q17_check_1 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "qc_comment TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "qd_comment TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "qe_comment TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "qf_comment TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "qg_comment TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "q51 TEXT, "
        "qh_comment TEXT, "
        "q52 TEXT, "
        "q53 TEXT, "
        "q54 TEXT, "
        "qi_comment TEXT, "
        "q55 TEXT, "
        "q56 TEXT, "
        "q57 TEXT, "
        "q58 TEXT, "
        "qj_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    // print('create stdloft complete');
  }

  static Future createRt5(Database db) async {
    print('Crate new table>> rt5');
    await db.execute("CREATE TABLE $kRt5Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "qb TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13_check_0 TEXT, "
        "q13_check_1 TEXT, "
        "q13_check_2 TEXT, "
        "q13_check_3 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16_check_0 TEXT, "
        "q16_check_1 TEXT, "
        "q16 TEXT, "
        "q17_check_0 TEXT, "
        "q17_check_1 TEXT, "
        "q17 TEXT, "
        "q18_check_0 TEXT, "
        "q18_check_1 TEXT, "
        "q18_check_2 TEXT, "
        "q18 TEXT, "
        "q19_check_0 TEXT, "
        "q19_check_1 TEXT, "
        "q19 TEXT, "
        "qb_comment TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "qc_comment TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25_check_0 TEXT, "
        "q25_check_1 TEXT, "
        "q25_check_2 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "qd_comment TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "qe_comment TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "qf_comment TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "qg_comment TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44_detail TEXT, "
        "q44 TEXT, "
        "q45_detail TEXT, "
        "q45 TEXT, "
        "q46_detail TEXT, "
        "q46 TEXT, "
        "q47_detail TEXT, "
        "q47 TEXT, "
        "q48_detail TEXT, "
        "q48 TEXT, "
        "q49_detail TEXT, "
        "q49 TEXT, "
        "q50_detail TEXT, "
        "q50 TEXT, "
        "qh_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt5 complete');
  }

  static Future createRt6(Database db) async {
    print('Crate new table>> rt5');
    await db.execute("CREATE TABLE $kRt6Table(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "instructor_rank TEXT, "
        "instructor_id TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "loft_duty TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qa_comment TEXT, "
        "q5 TEXT, "
        "q6_detail TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "qb_comment TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "qc_comment TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20_check_0 TEXT, "
        "q20_check_1 TEXT, "
        "q20_check_2 TEXT, "
        "q20 TEXT, "
        "q21_check_0 TEXT, "
        "q21_check_1 TEXT, "
        "q21 TEXT, "
        "qd_comment TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "qe_comment TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34_check_0 TEXT, "
        "q34_check_1 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "qf_comment TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "qg_comment TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "qh_comment TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "q46 TEXT, "
        "qi_comment TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "qj_comment TEXT, "
        "q50 TEXT, "
        "q51_detail TEXT, "
        "q51 TEXT, "
        "q52_detail TEXT, "
        "q52 TEXT, "
        "q53_detail TEXT, "
        "q53 TEXT, "
        "q54_detail TEXT, "
        "q54 TEXT, "
        "qk_comment TEXT, "
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
        "instructor_sig_date TEXT"
        ")");
    print('create rt6 complete');
  }

  static Future createLineTrain(Database db) async {
    print('Crate new table>> lineTrain');
    await db.execute("CREATE TABLE $kLineTrainTable(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_name TEXT, "
        "pilot_license_no TEXT, "
        "pilot_id TEXT, "
        "instructor_name TEXT, "
        "instructor_cert_no TEXT, "
        "instructor_id TEXT, "
        "examiner_name TEXT, "
        "examiner_license_no TEXT, "
        "examiner_id TEXT, "
        "course TEXT, "
        "other_course TEXT, "
        // "check_type TEXT, "
        "check_type_0 TEXT, "
        "check_type_1 TEXT, "
        "check_type_2 TEXT, "
        "check_type_3 TEXT, "
        "check_type_4 TEXT, "
        "check_type_5 TEXT, "
        "check_type_6 TEXT, "
        "check_type_7 TEXT, "
        "other_type TEXT, "
        "date_1 TEXT, "
        "ac_type_1 TEXT, "
        "ac_reg_1 TEXT, "
        "flt_no_1 TEXT, "
        "route_1 TEXT, "
        "duty_1 TEXT, "
        "date_2 TEXT, "
        "ac_type_2 TEXT, "
        "ac_reg_2 TEXT, "
        "flt_no_2 TEXT, "
        "route_2 TEXT, "
        "duty_2 TEXT, "
        "accum_pf TEXT, "
        "accum_pm TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qb TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "qa_comment TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "qb_comment TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "qc_comment TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "qd_comment TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "qe_comment TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "qf_comment TEXT, "
        "q36 TEXT, "
        "q37_detail TEXT, "
        "q37 TEXT, "
        "q38_detail TEXT, "
        "q38 TEXT, "
        "q39_detail TEXT, "
        "q39 TEXT, "
        "q40_detail TEXT, "
        "q40 TEXT, "
        "qg_comment TEXT, "
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
        "additional_note TEXT, "
        "result TEXT, "
        "examiner_result TEXT, "
        "pilot_sig_date TEXT,"
        "instructor_sig_date TEXT,"
        "examiner_sig_date TEXT"
        ")");
    print('create rt5 complete');
  }

  static Future createCcc(Database db) async {
    print('Crate new table>> ccc');
    await db.execute("CREATE TABLE $kCccTable(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "trainee_name TEXT, "
        "trainee_id TEXT, "
        "purser_name TEXT, "
        "purser_id TEXT, "
        "evaluator_name TEXT, "
        "evaluator_id TEXT, "
        "check_date TEXT, "
        "check_course TEXT, "
        "other_course TEXT, "
        "check_type TEXT, "
        "position TEXT, "
        "ac_type TEXT, "
        "ac_reg TEXT, "
        "flight TEXT, "
        "route TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qb TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "qa_comment TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "qb_comment TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "qc_comment TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "qd_comment TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "qe_comment TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "qf_comment TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "qg_comment TEXT, "
        "additional_comment TEXT, "
        "result TEXT, "
        "evaluator_result TEXT, "
        "trainee_sig_date TEXT,"
        "purser_sig_date TEXT,"
        "evaluator_sig_date TEXT"
        ")");
  }

  static Future createPsc(Database db) async {
    print('Crate new table>> psc');
    await db.execute("CREATE TABLE $kPscTable(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "trainee_name TEXT, "
        "trainee_id TEXT, "
        "purser_name TEXT, "
        "purser_id TEXT, "
        "evaluator_name TEXT, "
        "evaluator_id TEXT, "
        "check_date TEXT, "
        "check_course TEXT, "
        "other_course TEXT, "
        "check_type TEXT, "
        "position TEXT, "
        "ac_type TEXT, "
        "ac_reg TEXT, "
        "flight TEXT, "
        "route TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4 TEXT, "
        "qb TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10 TEXT, "
        "q11 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15 TEXT, "
        "qa_comment TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "q21 TEXT, "
        "q22 TEXT, "
        "q23 TEXT, "
        "q24 TEXT, "
        "q25 TEXT, "
        "q26 TEXT, "
        "q27 TEXT, "
        "q28 TEXT, "
        "q29 TEXT, "
        "q30 TEXT, "
        "q31 TEXT, "
        "q32 TEXT, "
        "q33 TEXT, "
        "q34 TEXT, "
        "q35 TEXT, "
        "q36 TEXT, "
        "q37 TEXT, "
        "q38 TEXT, "
        "qb_comment TEXT, "
        "q39 TEXT, "
        "q40 TEXT, "
        "q41 TEXT, "
        "q42 TEXT, "
        "q43 TEXT, "
        "q44 TEXT, "
        "q45 TEXT, "
        "qc_comment TEXT, "
        "q46 TEXT, "
        "q47 TEXT, "
        "q48 TEXT, "
        "q49 TEXT, "
        "q50 TEXT, "
        "q51 TEXT, "
        "q52 TEXT, "
        "q53 TEXT, "
        "q54 TEXT, "
        "q55 TEXT, "
        "qd_comment TEXT, "
        "q56 TEXT, "
        "q57 TEXT, "
        "q58 TEXT, "
        "qe_comment TEXT, "
        "q59 TEXT, "
        "q60 TEXT, "
        "q61 TEXT, "
        "q62 TEXT, "
        "q63 TEXT, "
        "q64 TEXT, "
        "q65 TEXT, "
        "q66 TEXT, "
        "q67 TEXT, "
        "q68 TEXT, "
        "q69 TEXT, "
        "q70 TEXT, "
        "qf_comment TEXT, "
        "q71 TEXT, "
        "q72 TEXT, "
        "q73 TEXT, "
        "q74 TEXT, "
        "qg_comment TEXT, "
        "q75 TEXT, "
        "q76 TEXT, "
        "q77 TEXT, "
        "q78 TEXT, "
        "qh_comment TEXT, "
        "q79 TEXT, "
        "q80 TEXT, "
        "q81 TEXT, "
        "q82 TEXT, "
        "q83 TEXT, "
        "q84 TEXT, "
        "q85 TEXT, "
        "q86 TEXT, "
        "qi_comment TEXT, "
        "q87 TEXT, "
        "q88 TEXT, "
        "q89 TEXT, "
        "q90 TEXT, "
        "q91 TEXT, "
        "q92 TEXT, "
        "q93 TEXT, "
        "qj_comment TEXT, "
        "additional_comment TEXT, "
        "result TEXT, "
        "evaluator_result TEXT, "
        "trainee_sig_date TEXT,"
        "purser_sig_date TEXT,"
        "evaluator_sig_date TEXT"
        ")");
  }

  static Future createFcss(Database db) async {
    await db.execute("CREATE TABLE $kFcssTable(id TEXT PRIMARY KEY , "
        "status TEXT NOT NULL, "
        "type TEXT NOT NULL, "
        "form_name TEXT NOT NULL, "
        "create_at TEXT NOT NULL, "
        "submit_at TEXT NOT NULL, "
        "create_by TEXT NOT NULL, "
        "file_path TEXT NOT NULL, "
        "font_size TEXT, "
        "pdf_url TEXT, "
            "updated_at TEXT, "
        "pilot_rank TEXT, "
        "pilot_id TEXT, "
        "pilot_license_no TEXT, "
        "pilot_name TEXT, "
        "evaluator_rank TEXT, "
        "evaluator_id TEXT, "
        "evaluator_license_no TEXT, "
        "evaluator_name TEXT, "
        "check_date TEXT, "
        "block_time TEXT, "
        "fstd_no TEXT, "
        "ac_type TEXT, "
        "check_type TEXT, "
        "check_type_other TEXT, "
        "q1 TEXT, "
        "q2 TEXT, "
        "q3 TEXT, "
        "q4_check_0 TEXT, "
        "q4_check_1 TEXT, "
        "q4_check_2 TEXT, "
        "q4_detail TEXT, "
        "q4 TEXT, "
        "q5 TEXT, "
        "q6 TEXT, "
        "q7 TEXT, "
        "q8_check_0 TEXT, "
        "q8_check_1 TEXT, "
        "q8 TEXT, "
        "q9 TEXT, "
        "q10_check_0 TEXT, "
        "q10_check_1 TEXT, "
        "q10 TEXT, "
        "q11_check_0 TEXT, "
        "q11_check_1 TEXT, "
        "q11_check_2 TEXT, "
        "q11_check_3 TEXT, "
        "q11_detail TEXT, "
        "q11 TEXT, "
        "q12_check_0 TEXT, "
        "q12_check_1 TEXT, "
        "q12 TEXT, "
        "q13 TEXT, "
        "q14 TEXT, "
        "q15_check_0 TEXT, "
        "q15_check_1 TEXT, "
        "q15_check_2 TEXT, "
        "q15 TEXT, "
        "q16 TEXT, "
        "q17 TEXT, "
        "q18 TEXT, "
        "q19 TEXT, "
        "q20 TEXT, "
        "qa_comment TEXT, "
        "qb_comment TEXT, "
        "qc_comment TEXT, "
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
        "result TEXT "
        // "pilot_sig_date TEXT,"
        // "instructor_sig_date TEXT"
        ")");
    print('create fcss complete');
  }

  ///TODO: New form (11): Add new database version
  static Future onCreateTable(Database db, int version) async {
    await createLineCheck(db);
    await createLineCheck5(db);
    await createPpc(db);
    await createPpc5(db);
    await createPpc6(db);
    await createPpc8(db);
    await createRt1(db);
    await createRt2(db);
    await createRt22(db);
    await createRt3(db);
    await createRt4(db);
    await createRt5(db);
    await createRt6(db);
    await createStdloft(db);
    await createLineTrain(db);
    await createCcc(db);
    await createPsc(db);
    await createFcss(db);
  }

  ///TODO: New form (12): Add new database version update
  static Future onUpdateTable(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await createPsc(db);
      await createCcc(db);
      await createRt1(db);
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createRt5(db);
      await createRt6(db);
      await createLineTrain(db);
      await createPpc5(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 2) {
      await createPsc(db);
      await createCcc(db);
      await createRt1(db);
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createLineTrain(db);
      await createRt6(db);
      await createPpc5(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 3) {
      await createPsc(db);
      await createCcc(db);
      await createRt1(db);
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createRt6(db);
      await createPpc5(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 4) {
      await createPsc(db);
      await createCcc(db);
      await createRt1(db);
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createPpc5(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 5) {
      await createPsc(db);
      await createCcc(db);
      await createRt1(db);
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 6) {
      await createPsc(db);
      await createCcc(db);
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 7) {
      await createRt2(db);
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createPpc6(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 8) {
      await createRt22(db);
      await createRt3(db);
      await createStdloft(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 9) {
      await db.execute('ALTER TABLE $kRt22Table ADD COLUMN q19 TEXT');
      await createStdloft(db);
      await createRt3(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 10) {
      await db.execute('ALTER TABLE $kStdloftTable ADD COLUMN route TEXT');
      await createRt3(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 11) {
      await createRt3(db);
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 12) {
      await createFcss(db);
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 13) {
      await createLineCheck5(db);
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 14) {
      await createRt4(db);
      await createPpc8(db);
    } else if (oldVersion == 15) {
      for (final table in kDbTableList) {
        await db.execute('ALTER TABLE $table ADD COLUMN updated_at TEXT');
      }
    }
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

  /// Reads just the `updated_at` column for [id] in [dbTable], used by the
  /// Firestore sync layer to decide which side of a conflict is newer
  /// without reconstructing a full `Form` object.
  static Future<String?> getUpdatedAt(String dbTable, String id) async {
    final Database db = await database();
    final rows = await db.query(
      dbTable,
      columns: ['updated_at'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return rows.first['updated_at'] as String?;
  }

  static Future<void> dbDelete(Form form, String dbName) async {
    final Database db = await database();
    await db.delete(
      dbName, //Table name
      where: "id = ?",
      whereArgs: [form.id],
    );
  }

  static String normalizeMonth(String input) {
    final parts = input.split(' ');
    if (parts.length == 3) {
      // Only fix middle part (month)
      final month = parts[1].toLowerCase();
      final fixedMonth = month[0].toUpperCase() + month.substring(1);
      return "${parts[0]} $fixedMonth ${parts[2]}";
    }
    return input;
  }

  ///Query from sql database into app's list.
  ///[createBy] scopes the query to a single account's forms (matches the
  ///`create_by` column) so a shared device never shows/syncs another
  ///account's forms. Pass null to get everything (not used in normal flow).
  static Future<List<Form>> dbQuery({String? createBy}) async {
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
        } else if (_result.type == FieldType.date){
          String pattern = "dd MMM yyyy";
          String dateText = map[i][_name];
          if (dateText != '') {
            if (dateText.contains('/')) {
              pattern = "dd/MM/yyyy"; // e.g. 21/08/2025
            } else if (dateText.contains(' ')) {
              dateText = normalizeMonth(dateText); // fix JUL → Jul
              pattern = "dd MMM yyyy"; // e.g. 21 Aug 2025
            } else {}

            try {
              _result.dateTimeValue = DateFormat(pattern).parseStrict(dateText);
              print(_result.dateTimeValue);
            } catch (e) {
              print('error');
            }
          }
        }
      }
      return _result;
    }

    bool isInitiated = false;
    for (int dbIndex = 0; dbIndex < kDbTableList.length; dbIndex++) {
      // Also include rows with no/blank create_by: forms saved while
      // Authen.user wasn't populated yet (e.g. before this account-scoping
      // filter existed, or a login race) would otherwise become permanently
      // invisible to everyone once a real account queries this table —
      // the row is still safely there, just unattributed.
      final List<Map<String, dynamic>> maps = await db.query(
        kDbTableList[dbIndex],
        where: createBy != null
            ? "(create_by = ? OR create_by IS NULL OR create_by = '')"
            : null,
        whereArgs: createBy != null ? [createBy] : null,
      );
      List.generate(maps.length, (i) {
        // late Form append;
        Form? append;
        isInitiated = false;

        ///TODO: New form (8): Add new form query db
        print('initiate db: ${kDbTableList[dbIndex]}');
        if (kDbTableList[dbIndex] == kLineCheckTable) {
          append = LineCheckForm.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kLineCheck5Table) {
          append = LineCheck5Form.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kPPC5Table) {
          append = Ppc5Form.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kPPC6Table) {
          append = Ppc6Form.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kPPC8Table) {
          append = Ppc8Form.init();
          isInitiated = true;
        }  else if (kDbTableList[dbIndex] == kRt1Table) {
          append = Rt1Form.init();
          isInitiated = true;
          // } else if (kDbTableList[dbIndex] == kRt5Table) {
          //   append = FormService.initRt5();
          // } else if (kDbTableList[dbIndex] == kRt6Table) {
          //   append = FormService.initRt6();
        } else if (kDbTableList[dbIndex] == kRt2Table) {
          append = Rt2Form.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kRt22Table) {
          append = Rt22Form.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kRt3Table) {
          append = Rt3Form.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kRt4Table) {
          append = Rt4Form.init();
          isInitiated = true;
        }  else if (kDbTableList[dbIndex] == kStdloftTable) {
          append = StdloftForm.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kLineTrainTable) {
          append = LineTrainForm.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kCccTable) {
          append = CccForm.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kPscTable) {
          append = PscForm.init();
          isInitiated = true;
        } else if (kDbTableList[dbIndex] == kFcssTable) {
          append = FcssForm.init();
          isInitiated = true;
        }

        if (isInitiated) {
          ///Move data from database mapping into app's list
          append!.status = FormStatus.values
              .firstWhere((e) => e.toString() == maps[i]['status']);
          // append.type = FormType.lineCheck;
          append.formName = maps[i]['form_name'];
          append.createDateTime = DateTime.parse(maps[i]['create_at']);
          if (maps[i]['submit_at'] != null && maps[i]['submit_at'] != '') {
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
              for (int _c = 0;
                  _c < append.fields[_i].checkBoxValue.length;
                  _c++) {
                String name = '${append.fields[_i].name}_$_c';
                if (maps[i][name] == 'true' ||
                    maps[i][name] == 'TRUE' ||
                    maps[i][name] == 'false' ||
                    maps[i][name] == 'FALSE') {
                  append.fields[_i].checkBoxValue[_c] =
                      bool.parse(maps[i][name].toLowerCase());
                }
              }
            }
          }

          _dbList.add(append);
          isInitiated = false;
        }
      });
    }

    _dbList.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    ///LINE CHECK
    // final List<Map<String, dynamic>> lineCheckMaps =
    //     await db.query(kLineCheckTable);
    // List.generate(lineCheckMaps.length, (i) {
    //   Form _new = LineCheckForm.init();
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
