import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vicar_app/constants.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/components/components.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/profile_screen.dart';
import 'package:vicar_app/screens/user/register_screen.dart';
import 'package:vicar_app/screens/user/forgotpass_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String nit = '';
  String role = '';
  String email = '';
  String _lastName = '';
  String _firstName = '';
  bool _emailIscorrect = false;
  bool _isKeyboardVisible = false;
  final now = DateTime.now().toLocal();
  final SizeConfig sizeConfig = SizeConfig();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    setState(() {
      _emailIscorrect = emailRegex.hasMatch(email);
    });
  }

  Future<String> _logIn() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final response = await http.post(
      Uri.parse(logInUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
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
  }

  Future<void> _handleLogin() async {
    final String password = _passwordController.text;
    if (_emailIscorrect && password.isNotEmpty) {
      try {
        final token = await _logIn();
        final urlEmail = '$usrInfo${_emailController.text}';
        final response = await http.get(
          Uri.parse(urlEmail),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (mounted) {
          if (response.statusCode == 200) {
            final List<dynamic> dataList = jsonDecode(response.body);
            final Map<String, dynamic> data = dataList[0];
            setState(() {
              nit = data['NIT'] ?? '';
              role = data['role'] ?? '';
              email = data['email'] ?? '';
              _lastName = data['lastName'] ?? '';
              _firstName = data['firstName'] ?? '';
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sesión Iniciada Correctamente. ¡Bienvenido!"),
              ),
            );

            await sendEmail(); //Send email whit login notification
            if (mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  nit: nit,
                  role: role,
                  token: token,
                  email: email,
                  firstName: _firstName,
                  lastName: _lastName,
                ),
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Usuario o contraseña incorrectos."),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          // Check if the widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Usuario o contraseña incorrectos."),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Complete los campos correctamente."),
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
    if (keyboardVisibility != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = keyboardVisibility;
      });
    }

    return Scaffold(
      appBar: _isKeyboardVisible
          ? AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Image.asset(
                "assets/images/logo_pc.png",
                fit: BoxFit.cover,
                height: 60,
              ),
              backgroundColor: kBackgroundColor,
            )
          : null,
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
            child: Column(
              children: <Widget>[
                _isKeyboardVisible
                    ? const Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '¡Bienvenido!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kBackgroundColor,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              'Inicia Sesión con tus datos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kBackgroundColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const TopScreenImage(screenImageName: 'vicar_logo.png'),
                TextInputs(
                  keyboardType: TextInputType.emailAddress,
                  myController: _emailController,
                  onChanged: _onEmailChanged,
                  labelText: 'Email',
                  errorText: _emailIscorrect ? null : 'El correo no es válido.',
                  prefixIcon: const Icon(Icons.email_rounded),
                ),
                const SizedBox(height: 9),
                TextInputs(
                  keyboardType: TextInputType.text,
                  myController: _passwordController,
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.password_rounded),
                  initialObscureText: true,
                  showSuffixIcon: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toForgetScreen(context);
                    },
                    child: const Text(
                      'Olvidé mi contraseña',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kBackgroundColor,
                          fontSize: 16,
                          fontFamily: "Arial"),
                    ),
                  ),
                ),
                CustomButton(
                  fontSize: 20,
                  width: 280,
                  buttonText: 'Ingresar',
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 5),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '¿Aun no tienes una cuenta?',
                    style: TextStyle(color: kBackgroundColor, fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toRegisScreen(context);
                    },
                    child: const Text(
                      '¡Registrate!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kBackgroundColor,
                          fontSize: 17,
                          fontFamily: "Arial"),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  //Create email message
  Future<void> sendEmail() async {
    try {
      const subject = 'Ingreso a EMCOAPP';
      final date =
          DateFormat('dd/MM/yyyy').format(now); //Format datetime to date
      final time = DateFormat('HH:mm').format(now); //Format datetime to time
      final smtpEmail = Address(dotenv.env['USER']!);
      final toEmail = Address(email);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(dotenv.env['SENDGRID_API_KEY']!);

      String htmlEmail = await rootBundle
          .loadString('assets/emails/login.html'); //Get the html email file
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

  void _toForgetScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const ForgotpassScreen(),
    ));
  }

  void _toRegisScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const RegisterScreen(),
    ));
  }
}
