import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vicar_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:vicar_app/screens/user/codepass_screen.dart';

class ForgotpassScreen extends StatefulWidget {
  const ForgotpassScreen({
    super.key,
  });
  static String id = 'forgotpass_screen';
  @override
  State<ForgotpassScreen> createState() => _ForgotpassState();
}

class _ForgotpassState extends State<ForgotpassScreen> {
  var responseAPI = '';
  String numbConfirm = '';
  bool _emailIscorrect = false;
  bool _keyBoardVisible = false;
  var passapi = dotenv.env['PASSAPI'];
  final now = DateTime.now().toLocal();
  var emailapi = dotenv.env['EMAILAPI'];
  final SizeConfig sizeConfig = SizeConfig();
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
  }

  void _onEmailChanged(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    setState(() {
      _emailIscorrect = emailRegex.hasMatch(email);
    });
  }

  Future<String> getAuth() async {
    try {
      String passAPI = passapi.toString();
      String emailAPI = emailapi.toString();
      final response = await http.post(
        Uri.parse(logInUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailAPI,
          'password': passAPI,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'] as String;
        return token;
      } else {
        final errorMessage = response.body.isNotEmpty
            ? jsonDecode(response.body)['error'] ?? 'Failed to authenticate'
            : 'Failed to authenticate';
        throw Exception('Authentication failed: $errorMessage');
      }
    } catch (e) {
      throw Exception('Error during authentication: $e');
    }
  }

  void _handleCode() async {
    if (_emailIscorrect) {
      try {
        final email = _email.text;
        final token =
            await getAuth(); //Get the authentication token from getAuth
        final urlEmail = '$usrInfo$email';
        numbConfirm = Random().nextInt(10000).toString().padLeft(4, '0');

        final response = await http.get(
          Uri.parse(urlEmail),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (mounted) {
          if (response.statusCode == 200) {
            // Registration successful
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("¡Hemos enviado un mensaje al correo $email!"),
              ),
            );
            await sendEmail(); //Send email whit restart code.
            if (mounted) {
              //Navigate to codepass screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PassCode(
                      numbConfirm: numbConfirm, email: email, token: token)));
            }
          } else if (responseAPI.contains("res.json is not a function")) {
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "El email proporcionado no esta registrado, ¡Registrate!."),
              ),
            );
          } else {
            //  failed
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    "El email proporcionado no esta registrado, ¡Registrate!."),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text("El servidor no responde, por favor intente mas tarde."),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ingrese un correo electronico válido."),
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context);
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
        body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pcbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: sizeConfig.safeBlockVertical * 0.5),
                child: Column(children: <Widget>[
                  const TopScreenImage(
                    screenImageName: 'vicar_logo.png',
                  ), //Check to `lib/components/components.dart` at lines 14-33
                  const Align(
                      alignment: Alignment.center,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kBackgroundColor,
                                  fontSize: 25),
                            ),
                            Text(
                              'Ingresa el correo asociado a tu cuenta',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kBackgroundColor,
                                  fontSize: 16),
                            ),
                          ])),
                  const SizedBox(height: 15), // Space between columns
                  TextInputs(
                    //Check to `lib/components/components.dart` at lines 35-122
                    keyboardType: TextInputType.emailAddress,
                    myController: _email,
                    onChanged: _onEmailChanged,
                    labelText: 'Email',
                    errorText:
                        _emailIscorrect ? null : 'El correo no es válido.',
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                  const SizedBox(height: 20), // Space between columns
                  CustomButton(
                      //Check to `lib/components/components.dart` at lines 124-171
                      fontSize: 20,
                      width: 280,
                      buttonText: 'Enviar Codigo',
                      onPressed: _handleCode),
                  const SizedBox(height: 30), // Space between columns
                  const Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '¿Recordaste tu contraseña?',
                        style: TextStyle(color: kBackgroundColor, fontSize: 16),
                      )),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _toLoginScreen(context);
                        },
                        child: const Text(
                          '¡Inicia Sesión!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kBackgroundColor,
                              fontSize: 17),
                        )),
                  )
                ]))));
  }

  //Create email message
  Future<void> sendEmail() async {
    try {
      const subject = '¿Olvidaste tu contraseña?';
      final smtpEmail = Address(dotenv.env['USER']!);
      final toEmail = Address(_email.text);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(dotenv.env['SENDGRID_API_KEY']!);

      String htmlEmail = await rootBundle.loadString(
          'assets/emails/coderestart.html'); //Get the html email file
      htmlEmail = htmlEmail.replaceAll('\$numbConfirm',
          numbConfirm); //Replace dinamically the vars to the vars data

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

//Navigate to login screen
void _toLoginScreen(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
}
