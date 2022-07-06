import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marverick/models/form.dart';
import 'package:marverick/models/form.dart' as f;
import 'package:marverick/services/pdf.dart';
import 'package:marverick/services/form_service.dart';
import 'package:marverick/services/authen.dart';
import 'package:marverick/ui/views/input.dart';
import 'package:marverick/ui/views/log_in.dart';
import 'package:marverick/ui/widgets/snackbar.dart';
import 'package:marverick/utils/constants.dart';

class FormList extends StatefulWidget {
  static const id = kFormListId; //for route.
  FormStatus status;

  FormList({required this.status});

  @override
  _FormListState createState() => _FormListState();
}

class _FormListState extends State<FormList> {
  Widget getLabel(f.Form form, String? fieldName) {
    if (fieldName != null) {
      int i = form.fields.indexWhere((e) => e.name == fieldName);
      if (i >= 0) {
        String text = form.fields[i].stringValue;
        return Text(
          text,
          style: label(),
        );
      } else {
        return SizedBox.shrink();
      }
    } else {
      return SizedBox.shrink();
    }
  }

  TextStyle header() =>
      TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 22);

  TextStyle label() =>
      TextStyle(color: Colors.black, fontWeight: FontWeight.w500);

  String displayStatus(FormStatus status) {
    if (status == FormStatus.completed) {
      return '[SUBMITTED]';
    } else if (status == FormStatus.working) {
      return '[DRAFT]';
    } else if (status == FormStatus.pending) {
      return '[WAITING FOR SUBMIT]';
    } else {
      return '[ERROR]';
    }
  }

  String delText() =>
      widget.status == FormStatus.completed ? 'DELETE LOCALLY' : 'DELETE';

  Widget dateDetail({required List<Widget> children}) {
    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      // if the screen width >= 480 i.e Wide Screen
      if (constraints.maxWidth >= 600) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }
    });
  }

  Widget boxHeader({required List<Widget> children}) {
    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      if (constraints.maxWidth >= 600) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        );
      }
    });
  }

  void onDismissed(DismissDirection direction, f.Form form) {
    setState(() {
      context.read<FormService>().delete(form, (String response) {
        Snackbar.show(context,
            text: response == kStatusSuccess
                ? 'Form deleted'
                : 'Error: $response',
            type: response == kStatusSuccess ? Type.info : Type.error,
            isFixed: true);
      });
    });
  }

  Future _submitForm(BuildContext c, f.Form form) async {
    String message = '';
    ErrorType errorType = ErrorType.success;

    if (Authen.user == null) {
      await Navigator.of(context).push(PageRouteBuilder(
          settings: const RouteSettings(name: kMainPageName),
          pageBuilder: (_, __, ___) => Login(fromInside: true)));
    }
    if (Authen.user != null) {
      await context.read<FormService>().submitForm(form,
          (String response, ErrorType type) {
        errorType = type;
        if (response == 'SUCCESS') {
          message = 'SUCCESS: form submitted';
        } else {
          message = response;
        }
      });
      Snackbar.show(c,
          text: message,
          type: errorType == ErrorType.noInternet
              ? Type.caution
              : errorType == ErrorType.success
                  ? Type.info
                  : Type.error,
          isFixed: true);
    }
  }

  bool sampleCheck(FormType type) {
    if (!Authen.isSample) {
      return true;
    } else {
      if (type == FormType.sample) {
        return true;
      } else {
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEmpty() => context
        .watch<FormService>()
        .forms
        .where((f) => f.status == widget.status)
        .toList()
        .isEmpty;
    return Scaffold(
      body: Center(
        child: isEmpty()
            ? SizedBox(
                width: 300,
                child: SvgPicture.asset('assets/images/aircraft.svg',
                    color: Colors.black12),
              )
            : ListView.builder(
                itemCount: context.watch<FormService>().forms.length,
                itemBuilder: (BuildContext context, int _index) {
                  f.Form _form = context.watch<FormService>().forms[_index];
                  if (_form.status == widget.status &&
                      sampleCheck(_form.type)) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 10),
                      child: Dismissible(
                        key: Key(_form.id),
                        onDismissed: (direction) =>
                            onDismissed(direction, _form),
                        background: dismissBackground(),
                        child: Container(
                          decoration: fileBoxDecor(_form.status),
                          child: Row(
                            children: [
                              Expanded(
                                child: fileBox(_form, context, _index),
                              ),
                              _form.status == FormStatus.pending
                                  ? Container(
                                      padding: EdgeInsets.only(right: 10),
                                      color: Colors.transparent,
                                      child: IconButton(
                                        onPressed: () async {
                                          _submitForm(context, _form);
                                        },
                                        icon: Icon(Icons.file_upload),
                                        iconSize: 40,
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
      ),
    );
  }

  Text formName(f.Form form) => Text(form.formLabel, style: header());
  Text formStatus(f.Form form) =>
      Text(displayStatus(form.status), style: label());

  Widget formPercentCompleted(f.Form form, int index) {
    if (form.status == FormStatus.working) {
      return Text(
        '${context.watch<FormService>().forms[index].percentFilled().round()}%',
        style: label(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget fileBox(f.Form form, BuildContext context, int index) {
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            boxHeader(
              children: [
                formName(form),
                Row(
                  children: [
                    formStatus(form),
                    // const SizedBox(width: 5),
                    // formPercentCompleted(form, index),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8, child: Divider(color: Colors.black)),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                formLabel(form),
                const SizedBox(height: 5),
                dateDetail(
                  children: [
                    Text(
                      'Created on: ${dateTimeText(form.createDateTime)}',
                      style: label(),
                    ),
                    form.submitDateTime != null
                        ? Text(
                            'Submitted on: ${dateTimeText(form.submitDateTime!)}',
                            style: label(),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      onTap: () async {
        if (form.status == FormStatus.working) {
          Navigator.of(context).push(
            PageRouteBuilder(
              settings: RouteSettings(name: kInputPageName),
              pageBuilder: (_, __, ___) => InputScreen(
                form: context.watch<FormService>().forms[index],
              ),
            ),
          );
        } else {
          await context.read<Pdf>().lunchPdf(form);
        }
      },
    );
  }

  String dateTimeText(DateTime value) =>
      DateFormat('dd/MM/yyyy HH:mm').format(value);

  Row formLabel(f.Form form) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            getLabel(form, form.formLabelInfoField1),
            const SizedBox(width: 2),
            getLabel(form, form.formLabelInfoField2),
          ],
        ),
      ],
    );
  }

  Container dismissBackground() {
    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            delText(),
            style: const TextStyle(
              // fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
