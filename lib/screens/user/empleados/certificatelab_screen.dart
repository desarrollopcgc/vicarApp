import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:flutter_html_to_pdf_plus/flutter_html_to_pdf_plus.dart';

class CertificateEmployee extends StatefulWidget {
  const CertificateEmployee({
    super.key,
    required this.nit,
    required this.token,
  });
  final String nit;
  final String token;

  @override
  State<CertificateEmployee> createState() => _CertificateStateEmployee();
}

class _CertificateStateEmployee extends State<CertificateEmployee> {
  int salario = 0;
  String name = '';
  String email = '';
  String cargo = '';
  String contrato = '';
  var responseAPI = '';
  String fecInicio = '';
  bool alreadyTaped = false;
  var ftp = dotenv.env['FTP'];
  var passw = dotenv.env['PASSW'];
  var user = dotenv.env['USER_FTP'];
  final now = DateTime.now().toLocal();
  final SizeConfig sizeConfig = SizeConfig();
  final TextEditingController _forController = TextEditingController();

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
      '$ftp',
      user: '$user',
      pass: '$passw',
      port: 21,
      timeout: 120, // Increase the timeout to 120 seconds
    );
    String certifiName = 'Certificado.p12';

    try {
      await ftpConnect.connect();
      await ftpConnect.changeDirectory('signs');

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

  Future<File?> signExistingPdf(String file) async {
    // Load the existing PDF document
    final inputBytes = File(file).readAsBytesSync();
    final document = PdfDocument(inputBytes: inputBytes);

    String pfxDir = await _getTempDirectoryPath();
    String signedFilePath = "$pfxDir/signed_certificate.pdf";

    // Try to find an existing signature field
    PdfSignatureField? signatureField;
    for (int i = 0; i < document.form.fields.count; i++) {
      var field = document.form.fields[i];
      if (field is PdfSignatureField) {
        signatureField = field;
        break;
      }
    }

    if (signatureField == null) {
      // No signature field found, create a new one
      final page = document.pages[0]; // Add signature to the first page
      signatureField = PdfSignatureField(page, 'SignatureField',
          bounds: const Rect.fromLTWH(
              150, 600, 200, 50)); // Adjust the position as needed
      document.form.fields.add(signatureField);
    }

    // Load the certificate
    File? certificateFile = await loadCertifateFromFTP();
    if (certificateFile == null) {
      debugPrint('Email: Failed to download the certificate.');
      return null;
    }

    // Create a digital signature
    final signature = PdfSignature(
      certificate: PdfCertificate(
          File(certificateFile.path).readAsBytesSync(), 'Efacemco23!'),
      contactInfo: 'comercial@emcocables.co',
      locationInfo: 'Km 5.5 vía a Cajicá – Zipaquirá, Colombia',
      reason: 'Certicación Laboral',
      digestAlgorithm: DigestAlgorithm.sha512,
      cryptographicStandard: CryptographicStandard.cades,
    );

    // Assign the signature to the field
    signatureField.signature = signature;

    // Save the signed PDF document
    final output = File(signedFilePath);
    await output.writeAsBytes(await document.save());
    document.dispose();

    return output; // Return the signed file
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
            cargo = data['Cargo'] ?? '';
            name = data['Empleado'] ?? '';
            email = data['email'] ?? '';
            salario = data['Basico'] ?? '';
            contrato = data['Tipcontra'] ?? '';
            fecInicio = data['Fingreso'] ?? '';
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
                "Error al conectarse con servidor, por favor intenta mas tarde."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTextColor),
        title: Text(
          'Certificado laboral',
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
                horizontal: sizeConfig.safeBlockVertical * 2,
                vertical: sizeConfig.safeBlockVertical * 2),
            child: Column(
              children: <Widget>[
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    '¡Genera tu certificado! Ingresa el nombre de a quien va dirigido en caso de que lo necesites y luego presiona el botón. ¡Nosotros haremos el resto!',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: kBackgroundColor, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 15),
                TextInputs(
                  labelText: 'Dirigido a:',
                  prefixIcon: const Icon(Icons.approval_rounded),
                  myController: _forController,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Recibiras en tu correo el certificado tal y como lo necesitas en unos minutos.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(color: kBackgroundColor, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),
                Visibility(
                    visible: alreadyTaped ? false : true,
                    child: Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                          width: sizeConfig.safeBlockVertical * 30,
                          onPressed: _handleCertificate,
                          buttonText: 'Enviarme certificado',
                          fontSize: sizeConfig.safeBlockVertical * 2.3),
                    ))
              ],
            ),
          )),
    );
  }

  Future<void> sendEmail() async {
    try {
      String htmlEmail = '';
      final time = DateFormat('HH:mm').format(now); //Format datetime to time
      const subject = '¡Tu certificado ya llego! 📨';
      final strfecIngreso = DateTime.parse(fecInicio); //Format string to date
      final date = DateFormat('dd/MM/yyyy').format(now); //Day now
      final fecIngreso = DateFormat('dd/MM/yyyy')
          .format(strfecIngreso); //Format datetime to date
      final amount = NumberFormat.currency(
        symbol: '\$',
        decimalDigits: 0,
      ); //Format int to currency
      final salary = amount.format(salario);
      final output = await getTemporaryDirectory();
      final smtpEmail = Address(dotenv.env['USER']!);
      final mailer = Mailer(dotenv.env['SENDGRID_API_KEY']!);
      final toEmail = Address(email);
      final ccEmail = [
        Address('diegocoronado@emcocables.co'),
      ];
      final personalization = Personalization([toEmail], cc: ccEmail);

      if (_forController.text.isEmpty) {
        String htmlBody =
            await rootBundle.loadString('assets/emails/workersfiles.html');
        htmlEmail =
            await rootBundle.loadString('assets/files/certificado.html');

        htmlEmail = htmlEmail.replaceAll('\$cargo', cargo);
        htmlEmail = htmlEmail.replaceAll('\$empleado', name);
        htmlEmail = htmlEmail.replaceAll('\$nit', widget.nit);
        htmlEmail = htmlEmail.replaceAll('\$salario', salary);
        htmlEmail = htmlEmail.replaceAll('\$contrato', contrato);
        htmlEmail = htmlEmail.replaceAll('\$fecInicio', fecIngreso);
        htmlEmail = htmlEmail.replaceAll('\$now', '$date a las $time');

        final certificatePDF = await FlutterHtmlToPdf.convertFromHtmlContent(
          content: htmlEmail,
          configuration: PrintPdfConfiguration(
              targetDirectory: output.path, targetName: 'Certificado'),
        );

        // Sign the PDF and get the signed file
        final signedFile = await signExistingPdf(certificatePDF.path);
        if (signedFile == null) {
          debugPrint('Failed to sign the PDF.');
          return;
        }

        final pdfBytes = await signedFile.readAsBytes();
        final base64PDF = base64Encode(pdfBytes);

        final attachment = Attachment(base64PDF, 'Certificado.pdf',
            type: 'application/pdf', disposition: 'attachment');

        final content = Content('text/html', htmlBody);

        // Prepare the email body
        final bodyEmail = Email(
          [personalization],
          smtpEmail,
          subject,
          content: [content],
          attachments: [attachment],
        );
        setState(() {
          alreadyTaped = true;
        });
        // Send the email
        await mailer.send(bodyEmail);
      } else {
        String htmlBody =
            await rootBundle.loadString('assets/emails/workersfiles.html');
        htmlEmail = await rootBundle
            .loadString('assets/files/certificadoDirigido.html');

        htmlEmail = htmlEmail.replaceAll('\$cargo', cargo);
        htmlEmail = htmlEmail.replaceAll('\$empleado', name);
        htmlEmail = htmlEmail.replaceAll('\$nit', widget.nit);
        htmlEmail = htmlEmail.replaceAll('\$salario', salary);
        htmlEmail = htmlEmail.replaceAll('\$contrato', contrato);
        htmlEmail = htmlEmail.replaceAll('\$fecInicio', fecIngreso);
        htmlEmail = htmlEmail.replaceAll('\$now', '$date a las $time');
        htmlEmail = htmlEmail.replaceAll('\$dirigido', _forController.text);

        final certificatePDF = await FlutterHtmlToPdf.convertFromHtmlContent(
          content: htmlEmail,
          configuration: PrintPdfConfiguration(
              targetDirectory: output.path, targetName: 'Certificado'),
        );

        // Sign the PDF and get the signed file
        final signedFile = await signExistingPdf(certificatePDF.path);
        if (signedFile == null) {
          debugPrint('Failed to sign the PDF.');
          return;
        }

        final pdfBytes = await signedFile.readAsBytes();
        final base64PDF = base64Encode(pdfBytes);

        final attachment = Attachment(base64PDF, 'Certificado.pdf',
            type: 'application/pdf', disposition: 'attachment');

        final content = Content('text/html', htmlBody);

        // Prepare the email body
        final bodyEmail = Email(
          [personalization],
          smtpEmail,
          subject,
          content: [content],
          attachments: [attachment],
        );
        setState(() {
          alreadyTaped = true;
        });
        // Send the email
        await mailer.send(bodyEmail);
      }
    } catch (e) {
      debugPrint('Email error: $e');
      setState(() {
        alreadyTaped = false;
      });
    }
  }
}
