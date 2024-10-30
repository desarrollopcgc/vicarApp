import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: kTextColor),
        title: const Text('Autorización tratamiento de \ndatos personales',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: kTextColor,
                fontSize: 18,
                fontFamily: 'Arial')),
        backgroundColor: kBackgroundColor,
      ),
      body: Stack(
        children: [
          // Background image layer
          /*Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/data_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),*/
          // Foreground content layer
          Column(
            children: [
              // Fixed header container at the top
              _buildHeaderContainer(
                'Dando cumplimiento a lo dispuesto en la Ley 1581 de 2012, "Por el cual se dictan disposiciones generales para la protección de datos personales" y de conformidad con lo señalado en el Decreto 1377 de 2013, con la firma de este documento manifiesto que he sido informado por EMCOCABLES SAS de lo siguiente:',
              ),
              // Scrollable content below the header
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTextContainer(
                          '1. EMCOCABLES SAS actuará como Responsable del Tratamiento de datos personales de los cuales soy titular y que, conjunta o separadamente podrá recolectar, usar y tratar mis datos personales conforme ',
                          'la Política de Tratamiento de Datos Personales disponible en su página WEB.'),
                      _buildTextContainer(
                          '2. Que conozco la finalizad de la recolección de los datos personales, la cual está señalada en su política de privacidad.',
                          ''),
                      _buildTextContainer(
                          '3. Mis derechos como titular de los datos son los previstos en la Constitución y la ley, especialmente el derecho a conocer, actualizar, rectificar y suprimir mi información personal, así como el derecho a revocar el consentimiento otorgado para el tratamiento de datos personales.',
                          ''),
                      _buildTextContainer(
                          '4. Los derechos pueden ser ejercidos a través de los canales dispuestos por EMCOCABLES SAS y observando su Política de Tratamiento de Datos Personales.',
                          ''),
                      _buildTextContainer(
                          '5. Mediante la informacion suministrada en la página web de EMCOCABLES SAS, podré radicar cualquier tipo de requerimiento relacionado con el tratamiento de mis datos personales.',
                          ''),
                      _buildTextContainer(
                          '6. EMCOCABLES SAS garantizará la confidencialidad, libertad, seguridad, veracidad, transparencia, acceso y circulación restringida de mis datos y se reservará el derecho de modificar su Política de Tratamiento de Datos Personales en cualquier momento. Cualquier cambio será informado y publicado oportunamente en la página web.',
                          ''),
                      _buildTextContainer(
                          '7. Teniendo en cuenta lo anterior, autorizo de manera voluntaria, previa, explícita, informada e inequívoca a EMCOCABLES SAS para tratar mis datos personales de acuerdo con su Política de Tratamiento de Datos Personales para los fines relacionados con su objeto y en su política de privacidad.',
                          ''),
                      _buildTextContainer(
                          '8. La información obtenida para el Tratamiento de mis datos personales la he suministrado de forma voluntaria y es verídica.',
                          ''),
                    ],
                  ),
                ),
              ),
              /*Container(
                margin: const EdgeInsets.all(0),
                child: Image.asset('assets/images/databackground.png'),
              )*/
            ],
          ),
        ],
      ),
    );
  }

  //Method to build the containers text
  Widget _buildTextContainer(String prefixText, String linkText) {
    return Container(
      decoration: BoxDecoration(
        color: kTextColor,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      padding: const EdgeInsets.all(10),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: kBackgroundColor,
              fontSize: 16,
              fontFamily: 'Arial'),
          children: [
            TextSpan(
              text: prefixText,
              style: const TextStyle(color: kBackgroundColor),
            ),
            TextSpan(
              text: linkText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Style for clickable text
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final url = Uri.parse(
                      'https://emcocables.co/politica-de-tratamiento-de-datos-personales/');
                  if (!await launchUrl(url)) {
                    throw Exception('No se pudo abrir $url');
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

//Method to build the fixed header container
  Widget _buildHeaderContainer(String text) {
    return Container(
      decoration: const BoxDecoration(
        color: kTextColor,
      ),
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: kBackgroundColor,
            fontSize: 16,
            fontFamily: 'Arial',
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
