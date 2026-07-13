// lib/services/form_type_config.dart
//
// Single source of truth for what used to be repeated if/else chains for
// formName(), folderName(), formUrl() and dbTable lookups.
// To add a new form type:
//   1. Add the type to FormType enum in models/form.dart
//   2. Add ONE entry to _formConfig below
//   3. Create a new init file in services/forms/
//   Done — no other files need touching.

import 'package:marverick/models/form.dart';
import 'package:marverick/utils/constants.dart';

class _FormConfig {
  final String name;

  /// A function rather than a plain string because some form types (ppc6)
  /// change their storage folder on a fixed date.
  final String Function() folder;
  final String url;
  final String dbTable;

  const _FormConfig({
    required this.name,
    required this.folder,
    required this.url,
    required this.dbTable,
  });
}

const Map<FormType, _FormConfig> _formConfig = {
  FormType.lineCheck: _FormConfig(
    name: 'line_check',
    folder: _lineCheckFolder,
    url: kLineChekSheetUrl,
    dbTable: kLineCheckTable,
  ),
  FormType.lineCheck5: _FormConfig(
    name: 'line_check5',
    folder: _lineCheck5Folder,
    url: kLineChek5SheetUrl,
    dbTable: kLineCheck5Table,
  ),
  FormType.ppc: _FormConfig(
    name: 'ppc',
    folder: _ppcFolder,
    url: kPPCSheetUrl,
    dbTable: kPPCTable,
  ),
  FormType.ppc5: _FormConfig(
    name: 'ppc',
    folder: _ppc5Folder,
    url: kPPC5SheetUrl,
    dbTable: kPPC5Table,
  ),
  FormType.ppc6: _FormConfig(
    name: 'ppc',
    folder: _ppc6Folder,
    url: kPPC6SheetUrl,
    dbTable: kPPC6Table,
  ),
  FormType.ppc8: _FormConfig(
    name: 'ppc',
    folder: _ppc8Folder,
    url: kPPC8SheetUrl,
    dbTable: kPPC8Table,
  ),
  FormType.stdloft: _FormConfig(
    name: 'stdloft',
    folder: _stdloftFolder,
    url: kStdloftSheetUrl,
    dbTable: kStdloftTable,
  ),
  FormType.rt1: _FormConfig(
    name: 'rt1',
    folder: _rt1Folder,
    url: kRt1SheetUrl,
    dbTable: kRt1Table,
  ),
  FormType.rt2: _FormConfig(
    name: 'rt2',
    folder: _rt2Folder,
    url: kRt2SheetUrl,
    dbTable: kRt2Table,
  ),
  FormType.rt22: _FormConfig(
    name: 'rt2',
    folder: _rt2Folder,
    url: kRt22SheetUrl,
    dbTable: kRt22Table,
  ),
  FormType.rt3: _FormConfig(
    name: 'rt3',
    folder: _rt3Folder,
    url: kRt3SheetUrl,
    dbTable: kRt3Table,
  ),
  FormType.rt4: _FormConfig(
    name: 'rt4',
    folder: _rt4Folder,
    url: kRt4SheetUrl,
    dbTable: kRt4Table,
  ),
  FormType.rt5: _FormConfig(
    name: 'rt5',
    folder: _rt5Folder,
    url: kRt5SheetUrl,
    dbTable: kRt5Table,
  ),
  FormType.rt6: _FormConfig(
    name: 'rt6',
    folder: _rt6Folder,
    url: kRt6SheetUrl,
    dbTable: kRt6Table,
  ),
  FormType.lineTrain: _FormConfig(
    name: 'LINE TRN',
    folder: _lineTrainFolder,
    url: kLineTrainSheetUrl,
    dbTable: kLineTrainTable,
  ),
  FormType.ccc: _FormConfig(
    name: 'ccc',
    folder: _cccFolder,
    url: kCccSheetUrl,
    dbTable: kCccTable,
  ),
  FormType.psc: _FormConfig(
    name: 'psc',
    folder: _pscFolder,
    url: kPscSheetUrl,
    dbTable: kPscTable,
  ),
  FormType.fcss: _FormConfig(
    name: 'fcss',
    folder: _fcssFolder,
    url: kFcssSheetUrl,
    dbTable: kFcssTable,
  ),
  FormType.sample: _FormConfig(
    name: 'sample',
    folder: _sampleFolder,
    url: '',
    dbTable: '',
  ),
  FormType.loe: _FormConfig(
    name: 'loe',
    folder: _loeFolder,
    url: '',
    dbTable: '',
  ),
};

String _lineCheckFolder() => 'line_check';
String _lineCheck5Folder() => 'line_check5';
String _ppcFolder() => 'ppc';
String _ppc5Folder() => 'ppc5';

/// PPC rev.6 moves from the 'ppc6' folder to 'ppc7' starting 1 Jan 2026.
String _ppc6Folder() => DateTime.now().isBefore(k1Jan26) ? 'ppc6' : 'ppc7';
String _ppc8Folder() => 'ppc8';
String _stdloftFolder() => 'stdloft';
String _rt1Folder() => 'rt1';
String _rt2Folder() => 'rt2';
String _rt3Folder() => 'rt3';
String _rt4Folder() => 'rt4';
String _rt5Folder() => 'rt5';
String _rt6Folder() => 'rt6';
String _lineTrainFolder() => 'line_train';
String _cccFolder() => 'ccc';
String _pscFolder() => 'psc';
String _fcssFolder() => 'fcss';
String _sampleFolder() => 'sample';
String _loeFolder() => 'loe';

extension FormTypeConfig on FormType {
  /// Short name used in PDF filenames, e.g. 'line_check', 'ppc'
  String get formName => _formConfig[this]?.name ?? 'untitled';

  /// Firebase Storage folder name
  String get folderName => _formConfig[this]?.folder() ?? 'untitled';

  /// Google Apps Script Web URL for sheet submission
  String get sheetUrl => _formConfig[this]?.url ?? '';

  /// SQLite table name
  String get dbTable => _formConfig[this]?.dbTable ?? '';
}
