// Verifies DatabaseService.formTableColumns() — the generic table-creation
// helper — derives the right column set from a form's field definitions,
// using PPC8 as a stand-in for "a new form's init()".
import 'package:flutter_test/flutter_test.dart';
import 'package:marverick/services/database.dart';
import 'package:marverick/services/forms/ppc8_form.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('formTableColumns includes header + named fields, skips checkbox/signature',
      () {
    final form = Ppc8Form.init();
    final columns = DatabaseService.formTableColumns(form);

    // Fixed header present.
    expect(columns, contains('id TEXT PRIMARY KEY NOT NULL'));
    expect(columns, contains('updated_at TEXT'));

    // Ordinary named field included.
    expect(columns, contains('pilot_name TEXT'));

    // Checkbox mirror fields (plain named string fields) included...
    expect(columns, contains('q13_check_0 TEXT'));
    expect(columns, contains('q13_check_1 TEXT'));
    expect(columns, contains('q13_check_2 TEXT'));

    // ...but the checkbox field itself ("check_type") is not, since its
    // data lives entirely in the check_type_N mirror columns.
    expect(columns.where((c) => c.startsWith('check_type ')), isEmpty);

    // Signature fields are stored via SignatureStorage, not as a column.
    expect(columns.where((c) => c.startsWith('pilot_sig ')), isEmpty);
    expect(columns.where((c) => c.startsWith('examiner_sig ')), isEmpty);

    // No duplicate columns even though duplicateFrom fields exist unnamed.
    expect(columns.toSet().length, columns.length);
  });
}
