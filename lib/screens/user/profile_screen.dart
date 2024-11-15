import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:vicar_app/components/components.dart';
import 'package:vicar_app/screens/user/about_screen.dart';
import 'package:vicar_app/screens/user/changeprofile_screen.dart';
import 'package:vicar_app/screens/user/empleados/history_screen.dart';
import 'package:vicar_app/screens/user/empleados/certificaterte_screen.dart';
import 'package:vicar_app/screens/user/empleados/certificatelab_screen.dart';
import 'package:vicar_app/screens/user/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.nit,
    required this.role,
    required this.token,
    required this.email,
    required this.lastName,
    required this.firstName,
    required this.ftp,
    required this.ftpUsr,
    required this.ftpPort,
    required this.emailMain,
    required this.ftpPassWord,
    required this.emailPassWord,
  });
  final String nit;
  final String role;
  final String token;
  final String email;
  final String lastName;
  final String firstName;
  final String ftp;
  final String ftpUsr;
  final String ftpPort;
  final String emailMain;
  final String ftpPassWord;
  final String emailPassWord;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Image? decodedImage;
  String photoUsr = '';
  final SizeConfig sizeConfig = SizeConfig();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context); // Initialize SizeConfig here
  }

  @override
  void initState() {
    super.initState();
    loadImageFromFTP();
  }

  Future<String> _getTempDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<void> loadImageFromFTP() async {
    FTPConnect ftpConnect = FTPConnect(
      widget.ftp,
      user: widget.ftpUsr,
      pass: widget.ftpPassWord,
      port: int.parse(widget.ftpPort),
      timeout: 60,
    );

    // Remove dots and special characters from the email
    String emailWithoutDots = widget.email.replaceAll(".", "");
    String emailWithoutSpecials = emailWithoutDots.replaceAll("@", "");
    String base64File =
        '$emailWithoutSpecials.txt'; // The Base64 file stored on FTP

    try {
      await ftpConnect.connect();
      await ftpConnect.changeDirectory('usersimg');
      bool base64FileExists = await ftpConnect.existFile(base64File);

      if (base64FileExists) {
        // Download the Base64 file from FTP to a temporary location
        String tempDir = await _getTempDirectoryPath();
        File tempFile = File("$tempDir/$base64File");
        bool downloadResult =
            await ftpConnect.downloadFile(base64File, tempFile);

        if (downloadResult) {
          // Read the Base64 string from the file
          String base64String = await tempFile.readAsString();

          // Decode the Base64 string into bytes and create an image
          Uint8List imageBytes = base64Decode(base64String);
          setState(() {
            decodedImage = Image.memory(imageBytes, fit: BoxFit.cover);
          });
        } else {
          debugPrint('Failed to download Base64 file');
        }
      } else {
        debugPrint('Base64 image file does not exist on FTP');
      }

      await ftpConnect.disconnect();
    } catch (e) {
      debugPrint('FTP error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kTextColor,
        /*Color(0xFF2E2E2E),*/
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                _confirmLogOut(context);
              },
              icon: const Icon(
                Icons.exit_to_app_rounded,
                color: kTextColor,
              )),
          title: Text(
            'Bienvenido',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontSize: sizeConfig.safeBlockVertical * 2.8,
                fontFamily: "Arial"),
          ),
        ),
        body: Container(
          margin:
              EdgeInsets.symmetric(vertical: sizeConfig.safeBlockVertical * 0),
          child: SingleChildScrollView(
              child: PopScope(
            canPop: false,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: decodedImage ??
                              const Image(
                                image: AssetImage(
                                    'assets/images/userDefault.png'), // Default image when no photo
                                fit: BoxFit.cover,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Space between columns
                  Text(
                    '${widget.firstName} ${widget.lastName}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kColor5,
                        fontSize: sizeConfig.safeBlockVertical * 2.5),
                  ),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kColor5,
                        fontSize: sizeConfig.safeBlockVertical * 2),
                  ),
                  const SizedBox(height: 20), // Space between columns
                  SizedBox(
                      width: sizeConfig.safeBlockVertical * 25,
                      child: CustomButton(
                          //Check to `lib/components/components.dart` at lines 124-171
                          width: sizeConfig.safeBlockVertical * 1,
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChangeProfileScreen(
                                    nit: widget.nit,
                                    role: widget.role,
                                    token: widget.token,
                                    email: widget.email,
                                    lastName: widget.lastName,
                                    firstName: widget.firstName,
                                    ftp: widget.ftp,
                                    ftpUsr: widget.ftpUsr,
                                    ftpPort: widget.ftpPort,
                                    emailMain: widget.emailMain,
                                    ftpPassWord: widget.ftpPassWord,
                                    emailPassWord: widget.emailPassWord)));
                          },
                          buttonText: 'Editar cuenta',
                          fontSize: sizeConfig.safeBlockVertical * 2)),
                  const SizedBox(height: 30), // Space between columns
                  Divider(color: Colors.blueGrey.shade500),
                  const SizedBox(height: 10), // Space between columns
                  Visibility(
                    visible:
                        widget.role == 'Empleado' || widget.role == 'Vendedor'
                            ? true
                            : false,
                    child: Column(children: [
                      ProfileActionsList(
                          //Check to `lib/components/components.dart` at lines 611-642
                          icon: Icons.money_rounded,
                          tittle: 'Historico de Pagos',
                          onPress: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PaymentHistory(
                                    nit: widget.nit,
                                    token: widget.token,
                                    email: widget.email,
                                    lastName: widget.lastName,
                                    firstName: widget.firstName,
                                    ftp: widget.ftp,
                                    ftpUsr: widget.ftpUsr,
                                    emailMain: widget.emailMain,
                                    ftpPassWord: widget.ftpPassWord,
                                    ftpPort: int.parse(widget.ftpPort),
                                    emailPassWord: widget.emailPassWord)));
                          },
                          textColor: null),
                      ProfileActionsList(
                          //Check to `lib/components/components.dart` at lines 611-642
                          icon: Icons.file_copy_rounded,
                          tittle: 'Certificado Laboral',
                          onPress: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CertificateEmployee(
                                    nit: widget.nit,
                                    token: widget.token,
                                    ftp: widget.ftp,
                                    ftpUsr: widget.ftpUsr,
                                    emailMain: widget.emailMain,
                                    ftpPassWord: widget.ftpPassWord,
                                    ftpPort: int.parse(widget.ftpPort),
                                    emailPassWord: widget.emailPassWord)));
                          },
                          textColor: null),
                      ProfileActionsList(
                          //Check to `lib/components/components.dart` at lines 611-642
                          icon: Icons.file_open_rounded,
                          tittle: 'Certificado de Ingresos y Retenciones',
                          onPress: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CertificaterteRTEScreen(
                                    nit: widget.nit,
                                    token: widget.token,
                                    ftp: widget.ftp,
                                    ftpUsr: widget.ftpUsr,
                                    emailMain: widget.emailMain,
                                    ftpPassWord: widget.ftpPassWord,
                                    ftpPort: int.parse(widget.ftpPort),
                                    emailPassWord: widget.emailPassWord)));
                          },
                          textColor: null),
                    ]),
                  ),
                  Visibility(
                      visible: widget.role == 'Vendedor' ? true : false,
                      child: Column(
                        children: [
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.rocket_launch_rounded,
                              tittle: 'Lanzamientos nuevos',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.app_registration_rounded,
                              tittle: 'Visitas',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.alarm_rounded,
                              tittle: 'Pedidos pendientes',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.wallet_rounded,
                              tittle: 'Cartera x cobrar',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.inventory_2_rounded,
                              tittle: 'Inventario disponible',
                              onPress: () {},
                              textColor: null),
                        ],
                      )),
                  Visibility(
                      visible: widget.role == 'Cliente' ? true : false,
                      child: Column(
                        children: [
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.wallet_rounded,
                              tittle: 'Cartera',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.alarm_rounded,
                              tittle: 'APs pendientes',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.inventory_2_rounded,
                              tittle: 'Inventario disponible',
                              onPress: () {},
                              textColor: null),
                          ProfileActionsList(
                              //Check to `lib/components/components.dart` at lines 611-642
                              icon: Icons.waving_hand_rounded,
                              tittle: 'Solicitar cotización',
                              onPress: () {},
                              textColor: null),
                        ],
                      )),
                  const SizedBox(height: 12), // Space between columns
                  Divider(color: Colors.blueGrey.shade500),
                  const SizedBox(height: 5), // Space between columns
                  ProfileActionsList(
                    icon: Icons.info_rounded,
                    tittle: 'Acerca de',
                    onPress: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AboutAppScreen()));
                    },
                    textColor: kTextColor,
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}

//Create email message
_confirmLogOut(context) async {
  await Alert(
    context: context,
    type: AlertType.warning,
    title: "Estas a punto de cerrar sesión",
    desc: "¿Estas seguro?",
    buttons: [
      DialogButton(
        onPressed: () {
          _toHomeScreen(context);
        },
        color: Colors.greenAccent.shade700,
        child: const Text(
          "Si",
          style:
              TextStyle(color: kTextColor, fontSize: 18, fontFamily: "Arial"),
        ),
      ),
      DialogButton(
        onPressed: () => Navigator.pop(context),
        color: Colors.redAccent.shade700,
        child: const Text(
          "No",
          style:
              TextStyle(color: Colors.white, fontSize: 18, fontFamily: "Arial"),
        ),
      )
    ],
  ).show();
}

//Navigate to home screen
void _toHomeScreen(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const LoginScreen()));
}
