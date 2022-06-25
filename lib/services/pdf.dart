import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/models/field.dart';
import 'package:marverick/utils/utils.dart';

class Pdf {
  Future<List<int>> gen(f.Form form) async {
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
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 11);
    //Create layout format
    PdfLayoutFormat layoutFormat = PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
        breakType: PdfLayoutBreakType.fitPage);
    PdfStringFormat stringFormat = PdfStringFormat(
      lineSpacing: 4,
    );
    // drawFormat.WordWrap = PdfWordWrapType.Word;
    // drawFormat.Alignment = PdfTextAlignment.Justify;
    // drawFormat.LineAlignment = PdfVerticalAlignment.Top;
    // drawFormat.LineSpacing = 20f;
    // drawFormat.WordSpacing = 10f;
    form.validate();
    for (int page = 1; page <= pageCount; page++) {
      for (int i = 0; i < form.fields.length; i++) {
        Field _field = form.fields[i];
        if (_field.duplicateFrom != null) {
          final _ref = form.fields
              .firstWhere((element) => element.name == _field.duplicateFrom);
          _field.stringValue = _ref.stringValue;
          _field.intValue = _ref.intValue;
        }
        if (page == _field.page) {
          // if (_field.type == FieldType.signature && _field.signature != null) {
          if (_field.type == FieldType.signature && _field.signature != null) {
            await _field.convertSignature((String response) {});
            final PdfBitmap image = PdfBitmap(_field.signature!);
            var _decodedImage = await decodeImageFromList(_field.signature!);
            var _width = _field.sigWidth;
            var _height =
                _field.sigWidth * (_decodedImage.height / _decodedImage.width);
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
          } else if ((_field.type == FieldType.radio ||
                  _field.type == FieldType.dropdown) &&
              _field.intValue >= 0) {
            /// as png
            // final PdfBitmap image = PdfBitmap(markPng);
            document.pages[page - 1].graphics.drawImage(
                mark,
                Rect.fromLTWH(
                    _field.posXList[_field.intValue] - 2,
                    _field.posYList[_field.intValue] + 3,
                    // _field.width ??
                    //     document.pages[page - 1].getClientSize().width / 1.3,
                    // _field.height ??
                    //     document.pages[page - 1].getClientSize().height / 2));
                    8,
                    8));

            /// as '/'
            // PdfTextElement(
            //         text: '/',
            //         font:
            //             PdfStandardFont(PdfFontFamily.helvetica, form.fontSize),
            //         format: stringFormat)
            //     .draw(
            //         page: document.pages[page - 1],
            //         bounds: Rect.fromLTWH(
            //             _field.posXList[_field.intValue],
            //             _field.posYList[_field.intValue],
            //             _field.width ??
            //                 document.pages[page - 1].getClientSize().width /
            //                     1.3,
            //             _field.height ??
            //                 document.pages[page - 1].getClientSize().height /
            //                     2));
          } else {
            // if (form.fields[i].name == 'NARRATIVE') {
            //Create a text element with the text and font
            //Draw the text in the first column
            PdfTextElement(
                    text: _field.stringValue,
                    font: PdfStandardFont(PdfFontFamily.helvetica,
                        _field.fontSize ?? form.fontSize),
                    format: stringFormat)
                .draw(
                    page: document.pages[page - 1],
                    bounds: Rect.fromLTWH(
                        _field.posX,
                        _field.posY,
                        _field.width ??
                            document.pages[page - 1].getClientSize().width /
                                1.3,
                        // 100,
                        _field.height ??
                            document.pages[page - 1].getClientSize().height /
                                2));
            // 100));
            // } else {
            //   document.pages[page - 1].graphics.drawString(
            //       '${form.fields[i].stringValue}', font,
            //       bounds:
            //           Rect.fromLTWH(form.fields[i].posX, form.fields[i].posY, 0, 0),
            //       brush: PdfBrushes.black);
            // }
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
    List<int> bytes = document.save();
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
  Future<void> lunchPdf(f.Form form) async {
    String name = '${form.id}.pdf';

    Utils.showInProgress(true);
    List<int> bytes = await gen(form);

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
      //Launch the file (used open_file package)
      print('$path/$name');
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
