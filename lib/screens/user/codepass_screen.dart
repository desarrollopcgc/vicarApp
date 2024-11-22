import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';
import 'package:vicar_app/components/components.dart';

class PassCode extends StatefulWidget {
  const PassCode({
    super.key,
    required this.email,
    required this.token,
    required this.numbConfirm,
    required this.emailMain,
    required this.emailPassWord,
  });
  final String email;
  final String token;
  final String numbConfirm;

  final String emailMain;
  final String emailPassWord;

  @override
  State<PassCode> createState() => _PassCodeState();
}

class _PassCodeState extends State<PassCode> {
  var responseAPI = '';
  late final FocusNode focusNode;
  final now = DateTime.now().toLocal();
  late final GlobalKey<FormState> formKey;
  late final TextEditingController pinController;
  late final time = DateFormat('HH:mm').format(now); //Format datetime to time
  final TextEditingController _code = TextEditingController();
  late final date =
      DateFormat('dd/MM/yyyy').format(now); //Format datetime to date
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
    focusNode.dispose();
    pinController.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/vicarback2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        //margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(children: <Widget>[
          const TopScreenImage(
              screenImageName:
                  'Register2.png'), //Check to `lib/components/components.dart` at lines 14-33
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Ingresa el codigo que enviamos al correo ${widget.email}',
                style: const TextStyle(
                    color: kColor4, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 15), // Space between columns
          ValidateCode(
              //Check to `lib/components/components.dart` at lines 467-608
              numCode: widget.numbConfirm,
              email: widget.email,
              token: widget.token,
              time: time,
              date: date,
              emailMain: widget.emailMain,
              emailPassWord: widget.emailPassWord),
        ]),
      ),
    );
  }
}
