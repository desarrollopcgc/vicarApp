import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';

class CertificaterteRTEScreen extends StatefulWidget {
  const CertificaterteRTEScreen({
    super.key,
    required this.token,
    required this.nit,
    required this.ftp,
    required this.ftpUsr,
    required this.ftpPort,
    required this.emailMain,
    required this.ftpPassWord,
    required this.emailPassWord,
  });
  final String nit;
  final String token;

  final String ftp;
  final int ftpPort;
  final String ftpUsr;
  final String emailMain;
  final String ftpPassWord;
  final String emailPassWord;
  @override
  State<CertificaterteRTEScreen> createState() =>
      _CertificaterteRTEScreenState();
}

class _CertificaterteRTEScreenState extends State<CertificaterteRTEScreen> {
  String hash = '';
  String email = '';
  var responseAPI = '';
  bool alreadyTaped = false;
  final SizeConfig sizeConfig = SizeConfig();
  int? _selectedYear = DateTime.now().year - 1; // Default year1 selected
  var year1 = DateTime.utc(DateTime.now().year - 1);
  var year2 = DateTime.utc(DateTime.now().year - 2);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context); // Initialize SizeConfig here
  }

  Future<String> _getTempDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File?> loadCertifateFromFTP() async {
    FTPConnect ftpConnect = FTPConnect(
      widget.ftp,
      user: widget.ftpUsr,
      pass: widget.ftpPassWord,
      port: widget.ftpPort,
      timeout: 120, // Increase the timeout to 120 seconds
    );

    var hashCerti = utf8.encode(hash);
    var urlCerti = sha384.convert(hashCerti);
    String certifiName = '$urlCerti.pdf';

    try {
      await ftpConnect.connect();
      await ftpConnect.changeDirectory('certificados');

      // Set the transfer mode to binary
      await ftpConnect.setTransferType(TransferType.binary);

      bool fileExist = await ftpConnect.existFile(certifiName);
      if (!fileExist) {
        return null;
      }

      String tempDir = await _getTempDirectoryPath();
      File tempFile = File("$tempDir/$certifiName");

      bool downloadResult =
          await ftpConnect.downloadFile(certifiName, tempFile);

      if (downloadResult) {
        return tempFile; // Return the downloaded file
      } else {
        debugPrint('Download failed');
        return null;
      }
    } catch (e) {
      debugPrint('FTP error: $e');
      return null;
    } finally {
      await ftpConnect.disconnect();
    }
  }

  Future<void> _handleCertificate() async {
    try {
      final token = widget.token; //Get the token from login_screen.dart
      final urlEmail = '$employeesInfo${widget.nit}';

      final response = await http.get(
        Uri.parse(urlEmail),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          // Password changed
          responseAPI = response.body;
          final List<dynamic> dataList = jsonDecode(response.body);
          final Map<String, dynamic> data = dataList[0];
          setState(() {
            email = data['email'] ?? '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("¡Certificado enviado correctamente!"),
            ),
          );
          await sendEmail(); //Send email whit change notification
        } else if (response.body.contains("jwt expired")) {
          // Token expired
          responseAPI = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Se ha vencido la sesión, vuelve a ingresar."),
            ),
          );
          if (mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ));
          }
        } else {
          // Change failed
          responseAPI = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "No se puedo enviar el certificado, por favor intenta mas tarde."),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Error al conectarse con servidor, por favor intenta mas tarde. "),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTextColor),
        title: Text(
          'Certificados tributarios',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextColor,
              fontSize: sizeConfig.safeBlockVertical * 2.5,
              fontFamily: "Arial"),
        ),
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/pcbackground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: sizeConfig.safeBlockVertical * 2.5,
                vertical: sizeConfig.safeBlockVertical * 2.5),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBackgroundColor, width: 2.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Selecciona el año a consultar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: kBackgroundColor,
                              fontSize: sizeConfig.safeBlockVertical * 2.5,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Custom toggle buttons without the circle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _customToggleButton(
                              DateFormat('yyyy').format(year2), year2.year),
                          _customToggleButton(
                              DateFormat('yyyy').format(year1), year1.year),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Para obtener documentos de más de 2 años de antiguedad, acércate al área de compensación.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: sizeConfig.safeBlockVertical * 5),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Visibility(
                            visible: !alreadyTaped,
                            child: CustomButton(
                              width: sizeConfig.safeBlockVertical * 30,
                              onPressed: () async {
                                setState(() {
                                  alreadyTaped = true;
                                });
                                if (_selectedYear == 2023) {
                                  setState(() {
                                    hash =
                                        '${widget.nit}RCERDIAN220$_selectedYear';
                                  });
                                  await _handleCertificate();
                                } else if (_selectedYear == 2022) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'El documento no ha sido generado, por favor comuniquese con compensación.'),
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Seleccione un año para continuar'),
                                  ));
                                }
                              },
                              buttonText: 'Enviarme certificado',
                              fontSize: sizeConfig.safeBlockVertical * 2.3,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  // Custom toggle button to simulate radio buttons without a circle
  Widget _customToggleButton(String text, int year) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedYear = year;
        });
      },
      child: Container(
        margin:
            EdgeInsets.symmetric(horizontal: sizeConfig.safeBlockVertical * 2),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: _selectedYear == year ? kBackgroundColor : kTextColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: kBackgroundColor,
            width: 2,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            color: _selectedYear == year ? Colors.white : kBackgroundColor,
          ),
        ),
      ),
    );
  }

  Future<void> sendEmail() async {
    try {
      const subject = '¡Tu certificado ya llego! 📨';
      final smtpEmail = Address(widget.emailMain);
      final toEmail = Address(email);
      //const ccEmail = Address('johannajimenez@emcocables.co');
      final personalization = Personalization([toEmail] /*cc: [ccEmail]*/
          );
      final mailer = Mailer(widget.emailPassWord);

      String htmlBody =
          await rootBundle.loadString('assets/emails/workersfiles.html');

      File? certificateFile = await loadCertifateFromFTP();
      if (certificateFile == null) {
        debugPrint('Email: Failed to download the certificate.');
        return;
      }
      final pdfFile = File(certificateFile.path);
      final pdfBytes = await pdfFile.readAsBytes();
      final base64PDF = base64Encode(pdfBytes);

      final attachment = Attachment(base64PDF, 'Certificado.pdf',
          type: 'application/pdf', disposition: 'attachment');

      final content = Content('text/html', htmlBody);

      //Get the values to send the email
      final bodyEmail = Email(
        [personalization],
        smtpEmail,
        subject,
        content: [content],
        attachments: [attachment],
      );

      //Sent the email
      await mailer.send(bodyEmail);
      debugPrint('Email: Send.');
    } catch (e) {
      debugPrint('Email $e');
      setState(() {
        alreadyTaped = false;
      });
    }
  }
}
