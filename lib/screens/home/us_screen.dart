import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';

class UsScreen extends StatefulWidget {
  const UsScreen({super.key});

  @override
  State<UsScreen> createState() => _UsScreenState();
}

class _UsScreenState extends State<UsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTextColor,
      /*appBar: PreferredSize(
        preferredSize: const Size.fromHeight(350),
        child: Image.asset(
          "assets/images/us.png",
          fit: BoxFit.cover,
        ),
      ),*/
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: ListView(
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: kTextColor,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(75))),
                child: Column(
                  children: <Widget>[
                    const Align(
                      child: Text(
                        '¿Quiénes somos?',
                        style: TextStyle(
                          fontFamily: 'Arial',
                          fontWeight: FontWeight.bold,
                          color: kBackgroundColor,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: const Column(
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Text(
                                    'Somos EMCOCABLES, fundados en 1960 con la colaboración de industriales colombianos y Paulsen Wire Corporation. Combinamos experiencia y tecnología para fabricar cables, torones y alambres de alta calidad.',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontWeight: FontWeight.w500,
                                      color: kBackgroundColor,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.justify)),
                            SizedBox(height: 6), // Space between columns
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                  'Desde los años 70, diversificamos nuestros productos con alambres de alta tecnología para varias industrias. Mantenemos altos estándares de calidad y usamos equipos avanzados para servir tanto al mercado nacional como al de exportación.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: kBackgroundColor,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.justify),
                            )
                          ],
                        )),
                    Container(
                      decoration: const BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50))),
                      margin: const EdgeInsets.only(right: 10, bottom: 5),
                      child: Stack(
                        children: [
                          const Align(
                              alignment: Alignment.center,
                              child: Text('MISIÓN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                    fontSize: 25,
                                  ),
                                  textAlign: TextAlign.justify)),
                          Container(
                              margin: const EdgeInsets.only(
                                  right: 15, left: 5, bottom: 10, top: 15),
                              child: const Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.gps_fixed_rounded,
                                  color: kTextColor,
                                  size: 50,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(
                                  right: 70, left: 15, bottom: 10, top: 35),
                              alignment: Alignment.centerRight,
                              child: const Text(
                                'Nos dedicamos a la producción y venta de cables, torones y alambres.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kTextColor,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6), // Space between columns
                    Container(
                      decoration: const BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              bottomLeft: Radius.circular(50))),
                      margin: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Stack(
                        children: [
                          const Align(
                              alignment: Alignment.center,
                              child: Text('VISIÓN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: kTextColor,
                                    fontSize: 25,
                                  ),
                                  textAlign: TextAlign.justify)),
                          Container(
                              margin: const EdgeInsets.only(
                                  right: 5, left: 15, bottom: 10, top: 50),
                              child: const Align(
                                alignment: Alignment.topLeft,
                                child: Icon(
                                  Icons.auto_graph_rounded,
                                  color: kTextColor,
                                  size: 50,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(
                                  right: 15, left: 70, bottom: 10, top: 35),
                              alignment: Alignment.centerRight,
                              child: const Text(
                                'En el año 2025 ser el número uno en la producción y comercialización de cables, torones  y alambres, obteniendo una participación preponderante  en el desarrollo del país.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kTextColor,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6), // Space between columns
                    Container(
                      decoration: const BoxDecoration(
                          color: kBackgroundColor,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50))),
                      margin: const EdgeInsets.only(right: 10, bottom: 5),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                                right: 15, left: 10, bottom: 10, top: 10),
                            child: const Align(
                                alignment: Alignment.topLeft,
                                child: Text('PROPÓSITO TRANSFORMACIÓN MASIVA',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: kTextColor,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(
                                  right: 15, left: 10, bottom: 10, top: 40),
                              child: const Align(
                                alignment: Alignment.topRight,
                                child: Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: kTextColor,
                                  size: 50,
                                ),
                              )),
                          Container(
                              margin: const EdgeInsets.only(
                                  right: 120, left: 13, bottom: 0, top: 70),
                              alignment: Alignment.center,
                              child: const Text(
                                'Ayudamos  a construir un mundo mejor.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: kTextColor,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
