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
  ///todo: New form step 9 — only add a case here if the form needs a custom PDF
  ///filename; otherwise it falls through to the default `<id>.pdf`.
  static String resolve(f.Form form, DateTime date) {
    switch (form.type) {
      case f.FormType.ppc6:
      case f.FormType.ppc8:
      case f.FormType.rt3:
      case f.FormType.rt4:
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

      case f.FormType.lineCheck5:
      case f.FormType.fcss:
        final dateText = DateFormat('yyyyMMdd').format(date);
        final time = DateFormat('kk:mm:ss').format(DateTime.now());
        final pilotName = form.getStrVal('pilot_name').toUpperCase();
        return '${form.type.formName}_${pilotName}_$dateText $time.pdf';

      default:
        return '${form.id}.pdf';
    }
  }
}
