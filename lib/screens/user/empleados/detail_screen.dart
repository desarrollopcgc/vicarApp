import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';

class DetailPayScreen extends StatefulWidget {
  const DetailPayScreen({
    super.key,
    required this.nit,
    required this.dcto,
    required this.token,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
  final String nit;
  final String dcto;
  final String token;
  final String email;
  final String firstName;
  final String lastName;
  @override
  State<DetailPayScreen> createState() => _DetailPayScreenState();
}

class _DetailPayScreenState extends State<DetailPayScreen> {
  String hash = '';
  var responseAPI = '';
  bool alreadyTaped = false;
  var ftp = dotenv.env['FTP'];
  List<dynamic> detailList = [];
  var passw = dotenv.env['PASSW'];
  var user = dotenv.env['USER_FTP'];
  final now = DateTime.now().toLocal();
  final SizeConfig sizeConfig = SizeConfig();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context); // Initialize SizeConfig here
  }

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  String formatAmount(dynamic number) {
    try {
      if (number == null) return 'N/A'; // Handle null cases
      final double amount = double.parse(number.toString());
      return NumberFormat("#,##0").format(amount);
    } catch (e) {
      return number.toString(); // Return original if parsing fails
    }
  }

  Future<String> _getTempDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<File?> loadPayment() async {
    FTPConnect ftpConnect = FTPConnect(
      '$ftp',
      user: '$user',
      pass: '$passw',
      port: 21,
      timeout: 120, // Increase the timeout to 120 seconds
    );

    var hashPay = utf8.encode(hash);
    var urlPay = sha384.convert(hashPay);
    String payName = '$urlPay.pdf';

    try {
      await ftpConnect.connect();
      await ftpConnect.changeDirectory('desprendibles');

      // Set the transfer mode to binary
      await ftpConnect.setTransferType(TransferType.binary);

      bool fileExist = await ftpConnect.existFile(payName);
      if (!fileExist) {
        return null;
      }

      String tempDir = await _getTempDirectoryPath();
      File tempFile = File("$tempDir/$payName");

      bool downloadResult = await ftpConnect.downloadFile(payName, tempFile);

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

  Future<void> _loadDetail() async {
    try {
      final token = widget.token; //Get the token from login_screen.dart
      final urlEmail = '$detailPayment${widget.dcto}';
      final response = await http.get(
        Uri.parse(urlEmail),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            detailList = jsonDecode(response.body);
            detailList.sort((a, b) {
              double numA = double.tryParse(a['Valor'].toString()) ?? 0.0;
              double numB = double.tryParse(b['Valor'].toString()) ?? 0.0;
              return numB.compareTo(numA);
            });
          });
          responseAPI = response.body;
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
                  "No pudimos cargar el pago, por favor intenta mas tarde."),
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
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          centerTitle: true,
          iconTheme: const IconThemeData(color: kTextColor),
          title: Text(
            'Desprendible ${widget.dcto}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontSize: sizeConfig.safeBlockVertical * 2.5,
                fontFamily: "Arial"),
          ),
        ),
        body: Column(
          children: [
            detailList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Table(
                        border: TableBorder.all(color: Colors.black),
                        columnWidths: <int, TableColumnWidth>{
                          0: FlexColumnWidth(
                              sizeConfig.safeBlockVertical * 0.3),
                          1: FlexColumnWidth(
                              sizeConfig.safeBlockVertical * 0.1),
                          2: FlexColumnWidth(
                              sizeConfig.safeBlockVertical * 0.14),
                        },
                        children: _tableRows(),
                      ),
                    ),
                  ),
            Visibility(
                visible: !alreadyTaped,
                child: CustomButton(
                    width: 250,
                    onPressed: () {
                      setState(() {
                        alreadyTaped = true;
                        hash = '${widget.nit}${widget.dcto}';
                      });
                      sendEmail;
                    },
                    buttonText: 'Enviar PDF desprendible via email',
                    fontSize: sizeConfig.safeBlockVertical * 1.8))
          ],
        ));
  }

//Build table rows dynamically from dataList
  List<TableRow> _tableRows() {
    // Create table header row
    List<TableRow> rows = [
      TableRow(
        decoration: BoxDecoration(color: kBackgroundColor),
        children: [
          Padding(
            padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.8),
            child: Text('Concepto',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
          ),
          Padding(
            padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.8),
            child: Text('Horas',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
          ),
          Padding(
            padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.8),
            child: Text('Valor',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
          ),
        ],
      ),
    ];

    // Create table rows from the dataList
    for (var item in detailList) {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.9),
              child: Text((item['Concepto'] ?? 'N/A')),
            ),
            Padding(
              padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.9),
              child: Text(item['Horas'].toString()),
            ),
            Padding(
              padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.9),
              child: Text(formatAmount(item['Valor'])),
            ),
          ],
        ),
      );
    }
    return rows;
  }

  //Create email message
  Future<void> sendEmail() async {
    try {
      String htmlBody =
          await rootBundle.loadString('assets/emails/workersfiles.html');
      const subject = '¡Tu desprendible esta aca! 📨';
      final smtpEmail = Address(dotenv.env['USER']!);
      final toEmail = Address(widget.email);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(dotenv.env['SENDGRID_API_KEY']!);

      File? certificateFile = await loadPayment();
      if (certificateFile == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "No pudimos encontrar el desprendible, por favor comunicate con compensación."),
            ),
          );
        }
        return;
      }

      final pdfFile = File(certificateFile.path);
      final pdfBytes = await pdfFile.readAsBytes();
      final base64PDF = base64Encode(pdfBytes);

      final attachment = Attachment(
          base64PDF, 'Desprendible ${widget.dcto}.pdf',
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Desprendible enviado correctamente!"),
          ),
        );
      }
    } catch (e) {
      debugPrint('Email $e');
    }
  }
}
