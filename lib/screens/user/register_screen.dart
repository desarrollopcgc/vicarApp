import 'dart:math';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:encrypt/encrypt.dart' as decryp;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:vicar_app/screens/user/coderegister_screen.dart';
import 'package:vicar_app/screens/user/personaldata_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static String id = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  //Credencials from API
  var credencials = {
    'Ftp': '',
    'FtpUsr': '',
    'FtpPsw': '',
    'FtpPort': '',
    'EmailPsw': '',
    'EmailMain': ''
  };

  var responseAPI = '';
  String resultado = '';
  String numbConfirm = '';
  final now = DateTime.now();
  bool _passwordsMatch = false;
  bool _emailIscorrect = false;
  bool _keyBoardVisible = false;
  bool _passwordHasNumber = false;
  var passapi = dotenv.env['PASSAPI'];
  var emailapi = dotenv.env['EMAILAPI'];
  bool _passwordEightCharacters = false;
  final SizeConfig sizeConfig = SizeConfig();
  final TextEditingController _email = TextEditingController();
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

  void _onEmailChanged(String email) {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    setState(() {
      _emailIscorrect = emailRegex.hasMatch(email);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confirmPolicy(context);
    });
  }

  Future<String> getAuth() async {
    try {
      String passAPI = passapi.toString();
      String emailAPI = emailapi.toString();
      numbConfirm = Random().nextInt(10000).toString().padLeft(4, '0');
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
        List<String> encryptedCredencials = [
          responseBody['ftp'],
          responseBody['ftpUsr'],
          responseBody['ftpPassWord'],
          responseBody['ftpPort'],
          responseBody['email'],
          responseBody['emailPassWord']
        ];

        _decryptCredencials(encryptedCredencials);
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

  void _decryptCredencials(List<String> encryptedCredencials) {
    final key = decryp.Key.fromUtf8('eFac_PCgc_092009');
    final encrypter =
        decryp.Encrypter(decryp.AES(key, mode: decryp.AESMode.ecb));

    setState(() {
      credencials['Ftp'] = encrypter.decrypt64(encryptedCredencials[0]);
      credencials['FtpUsr'] = encrypter.decrypt64(encryptedCredencials[1]);
      credencials['FtpPsw'] = encrypter.decrypt64(encryptedCredencials[2]);
      credencials['FtpPort'] = encrypter.decrypt64(encryptedCredencials[3]);
      credencials['EmailMain'] = encrypter.decrypt64(encryptedCredencials[4]);
      credencials['EmailPsw'] = encrypter.decrypt64(encryptedCredencials[5]);
    });
  }

  Future<void> _handleRegister() async {
    if (_passwordsMatch &&
        _passwordHasNumber &&
        _passwordEightCharacters &&
        _emailIscorrect) {
      try {
        //Get the authentication token from getAuth
        final token = await getAuth();
        final String email = _email.text;
        final urlEmail = '$usrInfo$email';
        final String password = _password.text;
        final response = await http.get(
          Uri.parse(urlEmail),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        final List<dynamic> dataList = jsonDecode(response.body);
        final Map<String, dynamic> data = dataList[0];
        setState(() {
          resultado = data['resultado'] ?? '';
        });
        if (mounted) {
          if (resultado.contains('Usuario registrado activo')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '¡Ya se encuentra registrado el correo $email. Por favor inicie sesión.'),
              ),
            );
            await Future.delayed(const Duration(milliseconds: 300));
            if (mounted) {
              //Navigate to login screen
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          } else if (resultado.contains('Usuario se puede registrar')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('¡Enviamos un codigo a $email! Por favor valide.'),
              ),
            );
            await sendEmail(); //Send email whit code to register
            if (mounted) {
              //Navigate to register Code screen
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RegisterCode(
                      numbConfirm: numbConfirm,
                      email: email,
                      token: token,
                      password: password,
                      emailMain: credencials['EmailMain']!,
                      emailPassWord: credencials['EmailPsw']!)));
            }
          } else if (resultado.contains('No es un posible registrar usuario')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'El correo $email no se encuentra habilitado, por favor comuniquese con la empresa.'),
              ),
            );
          } else if (resultado.contains('Usuario registrado inactivo')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Su usuario se encuentra inactivo, por favor comuniquese con la empresa.'),
              ),
            );
          } else {
            // Registration failed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'No se pudo llevar a cabo el registro. Intente mas tarde.'),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No se pudo conectar con el servidor, intente mas tarde. '),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete los campos correctamente.'),
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
          image: AssetImage('assets/images/vicarback2.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: PopScope(
          canPop: false,
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: sizeConfig.safeBlockVertical * 0.5),
            child: Column(
              children: <Widget>[
                const TopScreenImage(
                    screenImageName:
                        'vicar_logo.png'), //Check to `lib/components/components.dart` at lines 14-33
                const SizedBox(height: 8), // Space between columns
                TextInputs(
                  //Check to `lib/components/components.dart` at lines 35-122
                  keyboardType: TextInputType.emailAddress,
                  myController: _email,
                  onChanged: _onEmailChanged,
                  labelText: 'Email',
                  errorText: _emailIscorrect ? null : 'El correo no es válido.',
                  prefixIcon: const Icon(Icons.email_rounded),
                ),
                const SizedBox(height: 6), // Space between columns
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
                const SizedBox(height: 5.5), // Space between columns
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
                const SizedBox(height: 8), // Space between columns
                Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 1),
                  child: Column(
                    children: [
                      AlerstPasss(
                        //Check to `lib/components/components.dart` at lines 173-208
                        alert:
                            'La contraseña debe tener al menos \n8 caracteres.',
                        color: _passwordEightCharacters
                            ? Colors.green
                            : Colors.transparent,
                        border: _passwordEightCharacters
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 12), // Space between columns
                      AlerstPasss(
                        //Check to `lib/components/components.dart` at lines 173-208
                        alert: 'La contraseña debe tener numeros y letras.',
                        color: _passwordHasNumber
                            ? Colors.green
                            : Colors.transparent,
                        border: _passwordHasNumber
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 12), // Space between columns
                      AlerstPasss(
                        //Check to `lib/components/components.dart` at lines 173-208
                        alert: 'Las contraseñas deben coincidir.',
                        color:
                            _passwordsMatch ? Colors.green : Colors.transparent,
                        border: _passwordsMatch
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // Space between columns
                CustomButton(
                  //Check to `lib/components/components.dart` at lines 124-171
                  fontSize: 20,
                  width: 280,
                  buttonText: 'Registrarme',
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 15), // Space between columns
                Visibility(
                  visible: !_keyBoardVisible,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        const Text(
                          '¿Ya tienes una cuenta?',
                          style: TextStyle(color: kColor4, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _toLoginScreen(context);
                          },
                          child: const Text(
                            '¡Inicia Sesión!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kBackgroundColor,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    ));
  }

  //Create email message
  Future<void> sendEmail() async {
    try {
      const subject = '¡Completa tu registro!';
      final smtpEmail = Address(credencials['EmailMain']!);
      final toEmail = Address(_email.text);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(credencials['EmailPsw']!);

      String htmlEmail = await rootBundle.loadString(
          'assets/emails/confirmregister.html'); //Get the html email file
      htmlEmail = htmlEmail.replaceAll('\$codigo',
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

//Create alert Policy
Future<void> _confirmPolicy(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
            canPop: false,
            child: AlertDialog(
              icon: Icon(
                Icons.info_outline_rounded,
                size: 150,
                color: Colors.yellow.shade600,
              ),
              title: const Text(
                'Antes de continuar',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontFamily: "Arial"),
                textAlign: TextAlign.center,
              ),
              content: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                        text: 'Al registrarte, estás aceptando nuestra ',
                        style: TextStyle(fontFamily: "Arial")),
                    TextSpan(
                        text: 'política de tratamiento de datos',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontFamily: "Arial"),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _openEmcoWeb),
                    const TextSpan(
                        text: ' y la ', style: TextStyle(fontFamily: "Arial")),
                    TextSpan(
                        text:
                            'autorización de protección y tratamiento de datos personales',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontFamily: "Arial"),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _toDataScreen(context);
                          }),
                    const TextSpan(
                      text: '.\n¿Deseas continuar?',
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context); // Closes the dialog
                        }
                      },
                      child: const Text(
                        'Si',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 25,
                            fontFamily: "Arial"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _toLoginScreen(context); // Navigates to home screen
                      },
                      child: const Text(
                        'No',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 25,
                            fontFamily: "Arial"),
                      ),
                    ),
                  ],
                ),
              ],
            ));
      });
}

//Navigate to login screen
void _toLoginScreen(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const LoginScreen(),
    ),
  );
}

//Navigate to home screen
_toHomeScreen(BuildContext context) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => const BottomMenu(),
    ),
  );
}

//Navigate to usaged data confirm screen
_toDataScreen(BuildContext context) async {
  Future.delayed(Duration.zero, () {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PersonalDataScreen(),
        ),
      );
    }
  });
}

//Navigate to policy web
_openEmcoWeb() async {
  final url = Uri.parse(
      'https://emcocables.co/politica-de-tratamiento-de-datos-personales/');
  if (!await launchUrl(url)) {
    throw Exception('No se pudo abrir $url');
  }
}
