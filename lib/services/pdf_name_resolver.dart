// lib/services/pdf_name_resolver.dart
//
// Resolves the PDF filename for a given form + submission date.
// Extracted from form_service.dart to keep naming logic in one place.

import 'package:intl/intl.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/services/form_type_config.dart';
import 'package:marverick/utils/constants.dart';

class PdfNameResolver {
  /// Returns the PDF filename for [form] submitted at [date].
  static String resolve(f.Form form, DateTime date) {
    switch (form.type) {
      case f.FormType.ppc:
      case f.FormType.ppc5:
      case f.FormType.ppc6:
      case f.FormType.ppc8:
      case f.FormType.rt1:
      case f.FormType.rt2:
      case f.FormType.rt22:
      case f.FormType.rt3:
      case f.FormType.rt4:
      case f.FormType.rt5:
      case f.FormType.rt6:
      case f.FormType.stdloft:
        final id = form.getStrVal('pilot_id');
        final rank = form.getStrVal('pilot_rank').toUpperCase();
        final name = form.getStrVal('pilot_name').toUpperCase();
        final type = form.type.formName.toUpperCase();
        if (DateTime.now().isBefore(kFirstJune25)) {
          final dateText = form.getStrVal('check_date').replaceAll(' ', '-');
          return '$id $rank $name - $type $dateText.pdf';
        } else {
          final dateText = form.getDateStrVal('check_date', 'yyyyMMdd');
          return '$id $rank $name - $dateText $type.pdf';
        }

      case f.FormType.lineTrain:
        final dateText = form.getStrVal('date_1').replaceAll(' ', '-');
        final id = form.getStrVal('pilot_id');
        final name = form.getStrVal('pilot_name').toUpperCase();
        final type = form.type.formName.toUpperCase();
        final time = DateFormat('kk:mm:ss').format(DateTime.now());
        return '$id $name - $type $dateText $time.pdf';

      case f.FormType.lineCheck:
      case f.FormType.lineCheck5:
      case f.FormType.fcss:
        final dateText = DateFormat('yyyyMMdd').format(date);
        final time = DateFormat('kk:mm:ss').format(DateTime.now());
        final pilotName = form.getStrVal('pilot_name').toUpperCase();
        return '${form.type.formName}_${pilotName}_$dateText $time.pdf';

      case f.FormType.ccc:
      case f.FormType.psc:
        final dateText = DateFormat('yyyyMMdd').format(date);
        final time = DateFormat('kk:mm:ss').format(DateTime.now());
        final id = _idFormatted(form.getStrVal('trainee_id'));
        final name = form.getStrVal('trainee_name');
        return '${id}_${name}_$dateText $time.pdf';

      default:
        return '${form.id}.pdf';
    }
  }

  /// Pads or trims a staff ID to exactly 4 digits.
  static String _idFormatted(String raw) {
    if (raw.length < 4) return raw.padLeft(4, '0');
    if (raw.length > 4) return raw.substring(raw.length - 4);
    return raw;
  }
}
