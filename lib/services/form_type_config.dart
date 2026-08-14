// lib/services/form_type_config.dart
//
// Single source of truth for formName(), folderName(), sheetUrl() and dbTable
// lookups per form type.
//
// todo: New form step 5 — add ONE `_formConfig` entry (name, folder fn, url,
// dbTable) below. This is one step of several; see the full "HOW TO ADD A NEW
// FORM" checklist at the top of models/form.dart.

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
  FormType.lineCheck5: _FormConfig(
    name: 'line_check5',
    folder: _lineCheck5Folder,
    url: kLineChek5SheetUrl,
    dbTable: kLineCheck5Table,
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
  FormType.lineTrain: _FormConfig(
    name: 'LINE TRN',
    folder: _lineTrainFolder,
    url: kLineTrainSheetUrl,
    dbTable: kLineTrainTable,
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
};

String _lineCheck5Folder() => 'line_check5';

/// PPC rev.6 moves from the 'ppc6' folder to 'ppc7' starting 1 Jan 2026.
String _ppc6Folder() => DateTime.now().isBefore(k1Jan26) ? 'ppc6' : 'ppc7';
String _ppc8Folder() => 'ppc8';
String _stdloftFolder() => 'stdloft';
String _rt3Folder() => 'rt3';
String _rt4Folder() => 'rt4';
String _lineTrainFolder() => 'line_train';
String _fcssFolder() => 'fcss';
String _sampleFolder() => 'sample';

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
