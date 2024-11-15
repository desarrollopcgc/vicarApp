import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vicar_app/components/components.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:vicar_app/screens/user/empleados/detail_screen.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({
    super.key,
    required this.nit,
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
  final String token;
  final String email;
  final String lastName;
  final String firstName;

  final String ftp;
  final int ftpPort;
  final String ftpUsr;
  final String emailMain;
  final String ftpPassWord;
  final String emailPassWord;
  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  String dcto = '';
  String email = '';
  var responseAPI = '';
  List<dynamic> dataList = [];
  final SizeConfig sizeConfig = SizeConfig();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context); // Initialize SizeConfig here
  }

  @override
  void initState() {
    super.initState();
    _loadPays();
    initializeDateFormatting('Es', null);
  }

  String formatDate(String start, String end) {
    try {
      final DateTime startDate = DateFormat("yyyy-MM-dd").parse(start);
      final DateTime endDate = DateFormat("yyyy-MM-dd").parse(end);

      if (startDate == endDate) {
        return DateFormat('yyy MMMM dd', 'es').format(startDate);
      }
      return "${DateFormat('MMM dd', 'es').format(startDate)} a ${DateFormat('dd - yyyy').format(endDate)}";
    } catch (e) {
      return "Invalid Date";
    }
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

  Future<void> _loadPays() async {
    try {
      final token = widget.token; //Get the token from login_screen.dart
      final String nit = widget.nit;
      final urlEmail = '$historyPayment$nit';

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
            dataList = jsonDecode(response.body);
            dataList.sort((a, b) {
              DateTime dateA = DateTime.parse(a['FecIni']);
              DateTime dateB = DateTime.parse(b['FecIni']);
              return dateB.compareTo(dateA);
            });
          });
          responseAPI = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Historicos cargados "),
            ),
          );
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
                  "No pudimos cargar tus pagos, por favor intenta mas tarde."),
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
            'Historico de pagos',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontSize: sizeConfig.safeBlockVertical * 2.5,
                fontFamily: "Arial"),
          ),
        ),
        body: ListView(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pcbackground.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Container(
                      margin: EdgeInsetsDirectional.symmetric(
                          horizontal: sizeConfig.safeBlockVertical * 2.5,
                          vertical: sizeConfig.safeBlockVertical * 0.5),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Presiona en el pago que desees para ver su detalle.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: kBackgroundColor,
                            fontSize: sizeConfig.safeBlockVertical * 2,
                          ),
                        ),
                      )),
                  dataList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(
                                sizeConfig.safeBlockVertical * 1),
                            child: Table(
                              border: TableBorder.all(color: Colors.black),
                              columnWidths: <int, TableColumnWidth>{
                                0: FlexColumnWidth(
                                    sizeConfig.safeBlockVertical * .60),
                                1: FlexColumnWidth(
                                    sizeConfig.safeBlockVertical * .46),
                                2: FlexColumnWidth(
                                    sizeConfig.safeBlockVertical * .39),
                              },
                              children: _tableRows(),
                            ),
                          ),
                        ),
                ],
              ),
            )
          ],
        ));
  }

  void _onTableTap(Map<String, dynamic> item) {
    setState(() {
      dcto = item['Documento'];
    });

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => DetailPayScreen(
          dcto: dcto,
          nit: widget.nit,
          token: widget.token,
          email: widget.email,
          lastName: widget.firstName,
          firstName: widget.firstName,
          ftp: widget.ftp,
          ftpUsr: widget.ftpUsr,
          ftpPort: widget.ftpPort,
          emailMain: widget.emailMain,
          ftpPassWord: widget.ftpPassWord,
          emailPassWord: widget.emailPassWord),
    ));
  }

//Build table rows dynamically from dataList
  List<TableRow> _tableRows() {
    // Create table header row
    List<TableRow> rows = [
      TableRow(
        decoration: const BoxDecoration(color: kBackgroundColor),
        children: [
          Padding(
            padding: EdgeInsets.all(sizeConfig.safeBlockVertical * .38),
            child: Text('Periodo',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
          ),
          Padding(
              padding: EdgeInsets.all(sizeConfig.safeBlockVertical * .38),
              child: const Text('Desprendible',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kTextColor,
                  ))),
          Padding(
            padding: EdgeInsets.all(sizeConfig.safeBlockVertical * .38),
            child: Text('Total',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: kTextColor)),
          ),
        ],
      ),
    ];

    // Create table rows from the dataList
    for (var item in dataList) {
      rows.add(
        TableRow(
          children: [
            GestureDetector(
              onTap: () {
                _onTableTap(item);
              },
              child: Padding(
                padding: EdgeInsets.all(
                  sizeConfig.safeBlockVertical * 0.8,
                ),
                child: Text(formatDate(
                    item['FecIni'] ?? 'N/A', item['FecFin'] ?? 'N/A')),
              ),
            ),
            GestureDetector(
              onTap: () {
                _onTableTap(item);
              },
              child: Padding(
                padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.8),
                child: Text(item['Documento']),
              ),
            ),
            GestureDetector(
              onTap: () {
                _onTableTap(item);
              },
              child: Padding(
                padding: EdgeInsets.all(sizeConfig.safeBlockVertical * 0.8),
                child: Text(formatAmount(item['Valor'])),
              ),
            ),
          ],
        ),
      );
    }
    return rows;
  }
}
