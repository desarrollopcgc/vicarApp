import 'dart:convert';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';

class RegisterCode extends StatefulWidget {
  const RegisterCode({
    super.key,
    required this.email,
    required this.token,
    required this.password,
    required this.numbConfirm,
  });
  final String email;
  final String token;
  final String password;
  final String numbConfirm;
  static String id = 'codepas_screen';

  @override
  State<RegisterCode> createState() => _RegisterCodeState();
}

class _RegisterCodeState extends State<RegisterCode> {
  var responseAPI = '';
  String? errorMessage;
  late final FocusNode focusNode;
  var passapi = dotenv.env['PASSAPI'];
  final now = DateTime.now().toLocal();
  var emailapi = dotenv.env['EMAILAPI'];
  late final GlobalKey<FormState> formKey;
  final SizeConfig sizeConfig = SizeConfig();
  late final TextEditingController pinController;
  final TextEditingController _code = TextEditingController();

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

  Future<void> _handleRegister() async {
    try {
      //Get the authentication token from getAuth
      final token = await getAuth();
      final String email = widget.email;
      final String password = widget.password;
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          // Registration successful
          responseAPI = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Registro exitoso!"),
            ),
          );
          await sendEmail(); //Send email whit login notification
          if (mounted) {
            //Navigate to login screen
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()));
          }
        } else if (responseAPI.contains(" ya se encuentra registrado")) {
          responseAPI = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("El email esta vinculado a una cuenta existente."),
            ),
          );
        } else {
          // Registration failed
          responseAPI = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "No se pudó llevar a cabo el registro. Por favor intente mas tarde "),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "No se pudo conectar con el servidor. Por favor intente mas tarde"),
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
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black87,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: kTextColor),
      ),
    );
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pcbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        margin: EdgeInsets.symmetric(
            horizontal: sizeConfig.safeBlockVertical * 0.5),
        child: Column(children: <Widget>[
          const TopScreenImage(
              screenImageName:
                  'vicar_logo.png'), //Check to `lib/components/components.dart` at lines 14-33
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Ingresa el codigo que enviamos al correo ${widget.email}',
                style: const TextStyle(
                    color: kTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 15), // Space between columns
          Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: pinController,
                    focusNode: focusNode,
                    defaultPinTheme: defaultPinTheme,
                    separatorBuilder: (index) => const SizedBox(width: 8),
                    validator: (value) {
                      if (value != widget.numbConfirm) {
                        setState(() {
                          errorMessage = 'Código incorrecto';
                        });
                      } else {
                        setState(() {
                          errorMessage = null;
                        });
                        _handleRegister();
                        return null;
                      }
                      return null;
                    },
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {
                      debugPrint('onCompleted: $pin');
                    },
                    onChanged: (value) {
                      debugPrint('onChanged: $value');
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: kTextColor,
                        ),
                      ],
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kTextColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: kTextColor,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: kTextColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: const Color(0xFFFF4C4C)),
                    ),
                  ),
                ),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: kTextColor, fontSize: 18),
                  ),
                const SizedBox(height: 40), // Space between columns
                /*CustomButton(
            fontSize: 18,
            width:130,
            buttonText: 'Validar',
            onPressed: () {
              focusNode.unfocus();
              formKey.currentState!.validate();
            },
          ),*/
              ],
            ),
          )
        ]),
      ),
    );
  }

  //Create email message
  Future<void> sendEmail() async {
    try {
      const subject = '¡Registro exitoso!';
      final toEmail = Address(widget.email);
      final ccEmail = [
        Address('habeasdata@emcocables.com'),
      ];
      final smtpEmail = Address(dotenv.env['USER']!);
      final mailer = Mailer(dotenv.env['SENDGRID_API_KEY']!);
      final personalization = Personalization([toEmail], cc: ccEmail);

      String htmlEmail = await rootBundle
          .loadString('assets/emails/register.html'); //Get the html email file
      htmlEmail = htmlEmail.replaceAll('\$CORREO',
          widget.email); //Replace dinamically the vars to the vars data

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
