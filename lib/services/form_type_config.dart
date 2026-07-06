// lib/services/form_type_config.dart
//
// Replaces all repeated if/else chains for formName(), folderName(), formUrl().
// To add a new form type:
//   1. Add the type to FormType enum in models/form.dart
//   2. Add ONE entry to _formConfig below
//   3. Create a new init file in form_definitions/
//   Done — no other files need touching.

import 'package:marverick/models/form.dart';
import 'package:marverick/utils/constants.dart';

class _FormConfig {
  final String name;
  final String folder;
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
    folder: 'line_check',
    url: kLineChekSheetUrl,
    dbTable: kLineCheckTable,
  ),
  FormType.ppc: _FormConfig(
    name: 'ppc',
    folder: 'ppc',
    url: kPPCSheetUrl,
    dbTable: kPPCTable,
  ),
  FormType.ppc5: _FormConfig(
    name: 'ppc5',
    folder: 'ppc5',
    url: kPPC5SheetUrl,
    dbTable: kPPC5Table,
  ),
  FormType.rt1: _FormConfig(
    name: 'rt1',
    folder: 'rt1',
    url: kRt1SheetUrl,
    dbTable: kRt1Table,
  ),
  FormType.rt5: _FormConfig(
    name: 'rt5',
    folder: 'rt5',
    url: kRt5SheetUrl,
    dbTable: kRt5Table,
  ),
  FormType.rt6: _FormConfig(
    name: 'rt6',
    folder: 'rt6',
    url: kRt6SheetUrl,
    dbTable: kRt6Table,
  ),
  FormType.lineTrain: _FormConfig(
    name: 'LINE TRN',
    folder: 'line_train',
    url: kLineTrainSheetUrl,
    dbTable: kLineTrainTable,
  ),
  FormType.ccc: _FormConfig(
    name: 'ccc',
    folder: 'ccc',
    url: kCccSheetUrl,
    dbTable: kCccTable,
  ),
  FormType.psc: _FormConfig(
    name: 'psc',
    folder: 'psc',
    url: kPscSheetUrl,
    dbTable: kPscTable,
  ),
  FormType.sample: _FormConfig(
    name: 'sample',
    folder: 'sample',
    url: '',
    dbTable: '',
  ),
  FormType.loe: _FormConfig(
    name: 'loe',
    folder: 'loe',
    url: '',
    dbTable: '',
  ),
};

extension FormTypeConfig on FormType {
  /// Short name used in PDF filenames, e.g. 'line_check', 'ppc5'
  String get formName => _formConfig[this]?.name ?? 'untitled';

  /// Firebase Storage folder name
  String get folderName => _formConfig[this]?.folder ?? 'untitled';

  /// Google Apps Script Web URL for sheet submission
  String get sheetUrl => _formConfig[this]?.url ?? '';

  /// SQLite table name
  String get dbTable => _formConfig[this]?.dbTable ?? '';
}
