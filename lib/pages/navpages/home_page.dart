import 'package:detection_mobile/models/student_model.dart';
import 'package:detection_mobile/pages/navpages/detail_page.dart';
import 'package:detection_mobile/pages/navpages/data_page.dart';
import 'package:detection_mobile/widgets/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import '../../../constants.dart';
import '../../api/api_service.dart';
import '../../config.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  bool isAsyncCallProcess = false;
  StudentModel? studentModel;
  String? studentId;
  String? enterdStudentId;

  void _processData() {
    globalKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kActiveColor,
          title: Text(
            "Check Data",
            style: GoogleFonts.prompt(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: kMainColor,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: kBgColor,
        body: ProgressHUD(
          child: Form(
            key: globalKey,
            child: _addHomeUI(context),
          ),
          inAsyncCall: isAsyncCallProcess,
          opacity: 0.3,
          key: UniqueKey(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    studentModel = StudentModel();

    Future.delayed(Duration.zero, () {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

        studentModel = arguments["model"];
        setState(() {});
      }
    });
  }

  Widget _addHomeUI(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "check student id",
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: kActiveColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  FormHelper.inputFieldWidget(
                    context,
                    "studentId",
                    "student id",
                    (onValidateVal) {
                      String pattern = r'^([0-9]{8})$';
                      if (onValidateVal.isEmpty) {
                        return "* จำเป็น";
                      }
                      if (!RegExp(pattern).hasMatch(onValidateVal)) {
                        return "รหัสนิสิต รูปแบบไม่ถูกต้อง";
                      }
                      return null;
                    },
                    (onSavedVal) {
                      studentId = onSavedVal.toString().trim();
                      enterdStudentId = onSavedVal.toString().trim();
                    },
                    showPrefixIcon: false,
                    borderRadius: 10,
                    contentPadding: 15,
                    fontSize: 14,
                    prefixIconPaddingLeft: 10,
                    borderColor: Colors.grey.shade400,
                    textColor: Colors.black,
                    prefixIconColor: Colors.black,
                    hintColor: Colors.black.withOpacity(.6),
                    backgroundColor: Colors.grey.shade100,
                    borderFocusColor: Colors.grey.shade400,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: FormHelper.submitButton(
                      "CHECK",
                      () {
                        if (validateAndSave()) {
                          setState(() {
                            isAsyncCallProcess = true;
                          });

                          APIService.checkData(studentId!).then(
                            (response) {
                              APIService.getCount(studentId!).then(
                                (value) {
                                  setState(() {
                                    isAsyncCallProcess = false;
                                  });

                                  if (response) {
                                    foundDialog(
                                      context,
                                      Config.appName,
                                      "พบข้อมูลนิสิต",
                                      "ดูข้อมูล",
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DetailPage(
                                              studentID:
                                                  enterdStudentId.toString(),
                                            ),
                                          ),
                                        ).then(
                                          (_) =>
                                              globalKey.currentState?.reset(),
                                        );
                                      },
                                      "เพิ่มข้อมูลใหม่",
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ScanPage(),
                                          ),
                                        ).then(
                                          (_) =>
                                              globalKey.currentState?.reset(),
                                        );
                                      },
                                      value,
                                    );
                                  } else {
                                    notFoundDialog(
                                      context,
                                      Config.appName,
                                      "ไม่พบเจอผู้ไม่สวมหมวกนิรภัย",
                                      "ยกเลิก",
                                      () {
                                        Navigator.of(context).pop();
                                        _processData();
                                      },
                                      "เพิ่มข้อมูลใหม่",
                                      () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ScanPage(),
                                          ),
                                        ).then(
                                          (_) =>
                                              globalKey.currentState?.reset(),
                                        );
                                      },
                                      value,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        }
                      },
                      btnColor: kActiveColor,
                      borderColor: Colors.white,
                      txtColor: Colors.white,
                      borderRadius: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;

    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
}
