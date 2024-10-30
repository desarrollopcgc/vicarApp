import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';
import 'package:vicar_app/components/components.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:vicar_app/screens/user/register_screen.dart';

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});
  static String id = 'home_screen';

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  final SizeConfig sizeConfig = SizeConfig();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context); // Initialize SizeConfig here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/pcbackground.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Stack(
          children: [
            Column(
              children: [
                SizedBox(
                    height: sizeConfig.safeBlockVertical *
                        12), // Space between columns
                Expanded(
                  child: ListView(
                    children: [
                      Center(
                        child: Column(children: <Widget>[
                          Align(
                              alignment: Alignment.center,
                              child: Text('Bienvenido a PCAPP',
                                  style: TextStyle(
                                      color: kColor4,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          sizeConfig.safeBlockVertical * 5),
                                  textAlign: TextAlign.center)),
                          SizedBox(
                              height: sizeConfig.safeBlockVertical *
                                  1), // Space between columns
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 60),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    'Estas a punto de acceder y gestionar tu mismo tus solicitudes.',
                                    style:
                                        TextStyle(color: kColor4, fontSize: 18),
                                    textAlign: TextAlign.center)),
                          ),
                          SizedBox(
                              height: sizeConfig.safeBlockVertical *
                                  2), // Space between columns
                          CustomButton(
                              //Check to `lib/components/components.dart` at lines 124-171
                              fontSize: sizeConfig.safeBlockVertical * 2,
                              width: sizeConfig.safeBlockVertical * 25,
                              buttonText: 'Iniciar Sesión',
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                              }),
                          const SizedBox(height: 2), // Space between columns
                          Align(
                              alignment: Alignment.center,
                              child: Text('O',
                                  style:
                                      TextStyle(color: kColor4, fontSize: 15),
                                  textAlign: TextAlign.center)),
                          const SizedBox(height: 2), // Space between columns
                          CustomButton(
                              //Check to `lib/components/components.dart` at lines 124-171
                              fontSize: sizeConfig.safeBlockVertical * 2,
                              width: sizeConfig.safeBlockVertical * 25,
                              buttonText: 'Registrarse',
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen()));
                              }),
                          const SizedBox(height: 5), // Space between columns
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    ));
  }
}
