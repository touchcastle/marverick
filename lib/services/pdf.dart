import 'package:flutter/material.dart';
import 'package:marverick/services/authen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:provider/provider.dart';

// import 'package:open_file/open_file.dart' as open_file;
// import 'package:open_file_safe/open_file_safe.dart' as open_file;
import 'package:open_file_plus/open_file_plus.dart' as open_file;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';
import 'package:marverick/utils/utils.dart';
import 'package:marverick/utils/constants.dart';

class Pdf {
  Future<List<int>> gen(
      f.Form form, void Function(String, ErrorType) callback) async {
    //Load the PDF document
    // final PdfDocument document =
    //     PdfDocument(inputBytes: await _readDocumentData('sample.pdf'));
    PdfDocument document = await getAssets('assets/${form.filePath}');
    final ByteData markBytes = await rootBundle.load('assets/icons/mark.png');
    final Uint8List markPng = markBytes.buffer.asUint8List();
    final PdfBitmap mark = PdfBitmap(markPng);
    //Get the pages count
    int pageCount = document.pages.count;
    //Create the PDF standard font
    // PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 11);
    //Create layout format
    // PdfLayoutFormat layoutFormat = PdfLayoutFormat(
    //     layoutType: PdfLayoutType.paginate,
    //     breakType: PdfLayoutBreakType.fitPage);
    // PdfStringFormat stringFormat = PdfStringFormat(
    //   lineSpacing: 0,
    // );
    // drawFormat.WordWrap = PdfWordWrapType.Word;
    // drawFormat.Alignment = PdfTextAlignment.Justify;
    // drawFormat.LineAlignment = PdfVerticalAlignment.Top;
    // drawFormat.LineSpacing = 20f;
    // drawFormat.WordSpacing = 10f;
    form.validate();

    for (int page = 1; page <= pageCount; page++) {
      final double width = document.pages[page - 1].getClientSize().width;
      final double height = document.pages[page - 1].getClientSize().height;
      final PdfGraphics graphics = document.pages[page - 1].graphics;

      final PdfPen grayPen =
          PdfPen(PdfColor(100, 100, 100), width: 0.5); // light gray lines
      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 6);
      final PdfBrush blackBrush = PdfSolidBrush(PdfColor(0, 0, 0));

      if (Authen.isTjo() && form.ruler) {
        // --- Vertical ruler ---
        for (double x = 0; x <= width; x += 10) {
          if (x > 0 && x % 10 == 0) {
            // Measure text width
            final String text = x.toInt().toString();
            final Size textSize = font.measureString(text);

            // Draw number centered at top
            graphics.drawString(
              text,
              font,
              brush: blackBrush,
              bounds: Rect.fromLTWH(
                  x - textSize.width / 2, 0, textSize.width, textSize.height),
            );

            // Line begins AFTER number (below text)
            graphics.drawLine(
              grayPen,
              Offset(x, textSize.height + 2), // start just below number
              Offset(x, height),
            );
          } else {
            // Just draw full line (no number)
            graphics.drawLine(grayPen, Offset(x, 0), Offset(x, height));
          }
        }

        // --- Horizontal ruler ---
        for (double y = 0; y <= height; y += 10) {
          if (y > 0 && y % 10 == 0) {
            final String text = y.toInt().toString();
            final Size textSize = font.measureString(text);

            // Draw number centered at left
            graphics.drawString(
              text,
              font,
              brush: blackBrush,
              bounds: Rect.fromLTWH(
                  0, y - textSize.height / 2, textSize.width, textSize.height),
            );

            // Line begins AFTER number (to the right of text)
            graphics.drawLine(
              grayPen,
              Offset(textSize.width + 2, y), // start just after number
              Offset(width, y),
            );
          } else {
            // Just draw full line (no number)
            graphics.drawLine(grayPen, Offset(0, y), Offset(width, y));
          }
        }
      }

      for (int i = 0; i < form.fields.length; i++) {
        Field _field = form.fields[i];

        ///Some fields is not for display
        if (_field.writePdf) {
          ///Some fields is to duplicate data from other field to display at
          ///other place
          if (_field.duplicateFrom != null) {
            final _ref = form.fields
                .firstWhere((element) => element.name == _field.duplicateFrom);
            _field.stringValue = _ref.stringValue;
            _field.intValue = _ref.intValue;
          }

          if (page == _field.page) {
            // if (_field.type == FieldType.signature && _field.signature != null) {

            ///Signature
            if (_field.type == FieldType.signature &&
                _field.signature != null) {
              // Use the already-confirmed bytes as-is — do not re-derive
              // from the live drawing controller here, since it may hold a
              // newer, unconfirmed re-signing the user never saved.
              final PdfBitmap image = PdfBitmap(_field.signature!);
              var _decodedImage = await decodeImageFromList(_field.signature!);
              var _width = _field.sigWidth;
              var _height = _field.sigWidth *
                  (_decodedImage.height / _decodedImage.width);
              if (_height > _field.sigMaxHeight) {
                _width = _field.sigWidth * (_field.sigMaxHeight / _height);
                _height = _field.sigMaxHeight;
              }
              document.pages[page - 1].graphics.drawImage(
                  image,
                  Rect.fromLTWH(
                    _field.posX,
                    _field.posY - _height,
                    _width,
                    _height,
                  ));
            }

            ///Radio / Dropdown: draw a 'check' mark
            else if ((_field.type == FieldType.radio ||
                    _field.type == FieldType.dropdown) &&
                _field.intValue >= 0) {
              document.pages[page - 1].graphics.drawImage(
                mark,
                Rect.fromLTWH(
                    _field.posX != 0
                        ? _field.posX - 2
                        : _field.posXList[_field.intValue] - 2,
                    _field.posY != 0
                        ? _field.posY + 3
                        : _field.posYList[_field.intValue] + 3,
                    8,
                    8),
              );
            }

            ///Checkbox: draw a multiple 'check' mark
            else if (_field.type == FieldType.checkbox) {
              for (int _i = 0; _i < _field.checkBoxValue.length; _i++) {
                if (_field.checkBoxValue[_i]) {
                  document.pages[page - 1].graphics.drawImage(
                    mark,
                    Rect.fromLTWH(
                        _field.posX != 0
                            ? _field.posX - 2
                            : _field.posXList[_i] - 2,
                        _field.posY != 0
                            ? _field.posY + 3
                            : _field.posYList[_i] + 3,
                        8,
                        8),
                  );
                }
              }
            }

            ///String: Write text
            else {
              // print('${_field.label} length: ${_field.stringValue.length}');
              try {
                PdfTextElement(
                  text: _field.stringValue,
                  font: PdfStandardFont(PdfFontFamily.helvetica,
                      _field.fontSize ?? form.fontSize),
                  format: PdfStringFormat(lineSpacing: 0),
                ).draw(
                  page: document.pages[page - 1],
                  bounds: Rect.fromLTWH(
                      _field.posX,
                      _field.posY,
                      _field.width ??
                          document.pages[page - 1].getClientSize().width / 1.3,
                      _field.height ??
                          document.pages[page - 1].getClientSize().height / 2),
                );
              } catch (e) {
                ///todo: error message
                callback(
                    'There is an error when writing filed: ${_field.label}',
                    ErrorType.other);
                print('error catch $e');
              }
            }
          }
        }
      }
      // if (form.hasSig && form.signature != null) {
      //   final PdfBitmap image = PdfBitmap(form.signature!);
      //   var _decodedImage = await decodeImageFromList(form.signature!);
      //   var _width = form.sigWidth;
      //   var _height =
      //       form.sigWidth * (_decodedImage.height / _decodedImage.width);
      //   if (_height > form.sigMaxHeight) {
      //     _width = form.sigWidth * (form.sigMaxHeight / _height);
      //     _height = form.sigMaxHeight;
      //   }
      //   document.pages[page - 1].graphics.drawImage(
      //       image,
      //       Rect.fromLTWH(
      //         form.sigPosX,
      //         form.sigPosY - _height,
      //         _width,
      //         _height,
      //       ));
      // }
    }

    // //Get the pages count
    // int count = document.pages.count;
    //   //Draw text to the page
    //   document.pages[i - 1].graphics.drawString('Page $i of $count', font,
    //       bounds: Rect.fromLTWH(20, 20, 0, 0), brush: PdfBrushes.red);
    //
    //   document.pages[i - 1].graphics.drawString(
    //       '${form.fields[0].stringValue}', font,
    //       bounds: Rect.fromLTWH(390, 107, 0, 0), brush: PdfBrushes.black);
    // }
    //Save the document
    print("before read sig1");
    List<int> bytes = await document.save();
    callback(kStatusSuccess, ErrorType.success);
    //Dispose the document
    document.dispose();
    return bytes;
    // await saveAndLaunchFile(bytes, '${form.formName}.pdf');
  }

  Future<PdfDocument> getAssets(String name) async {
    final PdfDocument _document =
        PdfDocument(inputBytes: await _assetsLoad(name));
    return _document;
  }

  Future<List<int>> _assetsLoad(String name) async {
    final ByteData data = await rootBundle.load(name);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  ///To save the pdf file in the device
  Future<void> lunchPdf(
      f.Form form, void Function(String, ErrorType) callback) async {
    String name = '${form.id}.pdf';

    Utils.showInProgress(true);
    List<int> bytes = await gen(form, (String response, ErrorType type) {
      callback(response, type);
    });

    //Get the storage folder location using path_provider package.
    String? path;
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isLinux ||
        Platform.isWindows) {
      final Directory directory =
          await path_provider.getApplicationSupportDirectory();
      path = directory.path;
    }
    final File file = File(Platform.isWindows ? '$path\\$name' : '$path/$name');
    await file.writeAsBytes(bytes, flush: true);
    Utils.showInProgress(false);
    if (Platform.isAndroid || Platform.isIOS) {
      await open_file.OpenFile.open('$path/$name');
    } else if (Platform.isWindows) {
      await Process.run('start', <String>['$path\\$name'], runInShell: true);
    } else if (Platform.isMacOS) {
      await Process.run('open', <String>['$path/$name'], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', <String>['$path/$name'], runInShell: true);
    }
  }
}
