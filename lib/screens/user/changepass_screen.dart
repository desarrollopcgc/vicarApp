import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';

class ChangepassScreen extends StatefulWidget {
  const ChangepassScreen(
      {super.key,
      required this.email,
      required this.token,
      required this.emailMain,
      required this.emailPassWord});
  final String email;
  final String token;

  final String emailMain;
  final String emailPassWord;

  @override
  State<ChangepassScreen> createState() => _ChangepassScreenState();
}

class _ChangepassScreenState extends State<ChangepassScreen> {
  var responseAPI = '';
  bool _passwordsMatch = false;
  bool _keyBoardVisible = false;
  bool _passwordHasNumber = false;
  final now = DateTime.now().toLocal();
  bool _passwordEightCharacters = false;

  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  void _onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    final alphaRegex = RegExp(r'[a-zA-Z]');

    setState(() {
      _passwordEightCharacters = password.length >= 8;
      _passwordsMatch = password == _confirmPassword.text;
      _passwordHasNumber =
          numericRegex.hasMatch(password) && alphaRegex.hasMatch(password);
    });
  }

  void _onConfirmPasswordChanged(String confirmPassword) {
    setState(() {
      _passwordsMatch = _password.text == confirmPassword;
    });
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _handleChange() async {
    if (_passwordsMatch && _passwordHasNumber && _passwordEightCharacters) {
      try {
        final token = widget.token; //Get the token from forgotpass_screen.dart
        final String email = widget.email;
        final String password = _password.text;
        final urlEmail = '$usrInfo$email';

        final response = await http.put(
          Uri.parse(urlEmail),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, String>{
            'password': password,
            "email": widget.email,
          }),
        );

        if (mounted) {
          if (response.statusCode == 200) {
            //Registration successful
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Cambio de contraseña exitoso!"),
              ),
            );
            await sendEmail(); //Send email whit change notification
            if (mounted) {
              //Navigate to login screen
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          } else if (response.body.contains("jwt expired")) {
            //Token expired
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Se ha vencido la sesión, vuelve a intentarlo."),
              ),
            );
            if (mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
            }
          } else {
            //Registration failed
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "No se pudo llevar a cabo tu cambio de contraseña, por favor intenta mas tarde."),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Error al conectarse con servidor, por favor intenta mas tarde."),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Complete los campos correctamente."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisibility = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisibility != _keyBoardVisible) {
      setState(() {
        _keyBoardVisible = keyboardVisibility;
      });
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _keyBoardVisible
          ? AppBar(
              centerTitle: true,
              title: Image.asset(
                "assets/images/logo_emco.png",
                fit: BoxFit.cover,
                height: 75,
              ),
              backgroundColor: kBackgroundColor,
            )
          : null,
      body: Container(
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Column(
          children: <Widget>[
            _keyBoardVisible
                ? const Text(
                    'Crea tu nueva contraseña',
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const TopScreenImage(
                    screenImageName:
                        'Register2.png'), //Check to `lib/components/components.dart` at lines 14-33
            //const SizedBox(height: 1), // Space between columns
            TextInputs(
              //Check to `lib/components/components.dart` at lines 35-122
              keyboardType: TextInputType.text,
              myController: _password,
              onChanged: _onPasswordChanged,
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.password_rounded),
              initialObscureText: true,
              showSuffixIcon: true,
            ),
            const SizedBox(height: 15), // Space between columns
            TextInputs(
              //Check to `lib/components/components.dart` at lines 35-122
              keyboardType: TextInputType.text,
              myController: _confirmPassword,
              onChanged: _onConfirmPasswordChanged,
              labelText: 'Confirmar Contraseña',
              prefixIcon: const Icon(Icons.password_rounded),
              initialObscureText: true,
              showSuffixIcon: true,
            ),
            const SizedBox(height: 15), // Space between columns
            AlerstPasss(
              //Check to `lib/components/components.dart` at lines 173-208
              alert: 'La contraseña debe tener al menos 8 caracteres.',
              color:
                  _passwordEightCharacters ? Colors.green : Colors.transparent,
              border: _passwordEightCharacters
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 10), // Space between columns
            AlerstPasss(
              //Check to `lib/components/components.dart` at lines 173-208
              alert: 'La contraseña debe tener numeros y letras.',
              color: _passwordHasNumber ? Colors.green : Colors.transparent,
              border: _passwordHasNumber
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 10), // Space between columns
            AlerstPasss(
              //Check to `lib/components/components.dart` at lines 173-208
              alert: 'Las contraseñas deben coincidir.',
              color: _passwordsMatch ? Colors.green : Colors.transparent,
              border: _passwordsMatch
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20), // Space between columns
            CustomButton(
              //Check to `lib/components/components.dart` at lines 124-171
              fontSize: 20,
              width: 280,
              buttonText: 'Cambiar',
              onPressed: _handleChange,
            ),
            const SizedBox(height: 60), // Space between columns
          ],
        ),
      ),
    );
  }

  Future<void> sendEmail() async {
    try {
      const subject = 'Tu contraseña se restableció correctamente';
      final date =
          DateFormat('dd/MM/yyyy').format(now); //Format datetime to date
      final time = DateFormat('HH:mm').format(now); //Format datetime to time
      final smtpEmail = Address(widget.emailMain);
      final toEmail = Address(widget.email);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(widget.emailPassWord);

      String htmlEmail = await rootBundle.loadString(
          'assets/emails/restartpassword.html'); //Get the html email file
      htmlEmail = htmlEmail.replaceAll('\$now',
          '$date a las $time'); //Replace dinamically the vars to the vars data

      final content = Content('text/html', htmlEmail);

      //Get the values to send the email
      final bodyEmail = Email(
        [personalization],
        smtpEmail,
        subject,
        content: [content],
      );

      //Sent the email
      await mailer.send(bodyEmail);
    } catch (e) {
      debugPrint('Email $e');
    }
  }
}
