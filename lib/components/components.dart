import 'dart:io';
import 'dart:ui';
import 'package:pinput/pinput.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:vicar_app/constants.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/home/us_screen.dart';
import 'package:vicar_app/screens/home/home_screen.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:vicar_app/screens/user/changepass_screen.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';

//IMAGES//
class TopScreenImage extends StatelessWidget {
  const TopScreenImage({super.key, required this.screenImageName});
  final String screenImageName;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.contain,
            image: AssetImage('assets/images/$screenImageName'),
          ),
        ),
      ),
    );
  }
}
//IMAGES//

//INPUTS//
class TextInputs extends StatefulWidget {
  const TextInputs({
    super.key,
    required this.labelText,
    this.onChanged,
    required this.prefixIcon,
    required this.myController,
    required this.keyboardType,
    this.showSuffixIcon = false,
    this.initialObscureText = false,
    this.errorText,
    this.errorBorderColor = Colors.black,
  });
  final Icon prefixIcon;
  final void Function(String)? onChanged;
  final String labelText;
  final bool showSuffixIcon;
  final bool initialObscureText;
  final TextInputType keyboardType;
  final TextEditingController? myController;
  final String? errorText;
  final Color errorBorderColor;

  @override
  State<TextInputs> createState() => _TextInputsState();
}

class _TextInputsState extends State<TextInputs> {
  late bool _obscureText;
  late IconData _suffixIcon;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
    _suffixIcon = _obscureText ? Icons.visibility_off : Icons.visibility;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _suffixIcon = _obscureText ? Icons.visibility_off : Icons.visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      controller: widget.myController,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      style: const TextStyle(color: kColor4, fontFamily: "Arial", fontSize: 18),
      decoration: InputDecoration(
          prefixIconColor: kColor1,
          suffixIconColor: kColor1,
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kColor2, width: 3.0),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kColor1, width: 3.0),
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: kColor1, width: 2.0),
            borderRadius: BorderRadius.circular(15),
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.showSuffixIcon
              ? IconButton(
                  onPressed: _toggleObscureText, icon: Icon(_suffixIcon))
              : null,
          labelStyle: const TextStyle(
              color: kColor4,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: "Arial"),
          labelText: widget.labelText,
          errorText: widget.errorText,
          errorStyle: const TextStyle(
              color: kColor2, fontSize: 12.3, fontFamily: "Arial"),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: kColor2, width: 3.0),
            borderRadius: BorderRadius.circular(15),
          )),
    );
  }
}
//INPUTS//

//BUTTONS//
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.width,
    this.enabled = true,
    required this.fontSize,
    required this.onPressed,
    required this.buttonText,
  });

  final double fontSize;
  final double width;
  final bool enabled;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Material(
        borderRadius: BorderRadius.circular(30),
        elevation: 4,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: kColor1,
            border: Border.all(color: const Color(0xFFFFFFFF), width: 2.5),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              buttonText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: kTextColor,
                  fontFamily: "Arial"),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
//BUTTONS//

//ALERTS//
class AlerstPasss extends StatelessWidget {
  const AlerstPasss({
    super.key,
    required this.alert,
    required this.border,
    required this.color,
  });

  final String alert;
  final Border border;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 18,
          height: 18,
          decoration: BoxDecoration(
              color: color,
              border: border,
              borderRadius: BorderRadius.circular(50)),
          child: const Center(
            child: Icon(
              Icons.check,
              color: kColor4,
              size: 10,
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Text(
          alert,
          style: const TextStyle(color: kColor4, fontFamily: "Arial"),
        )
      ],
    );
  }
}
//ALERTS//

//CAROUSEL PRODUCTS//
/*
class Carousel extends StatelessWidget {
  const Carousel({
    super.key,
    required this.width,
    required this.widthCard,
  });
  final double width;
  final double widthCard;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
        itemCount: imagesCarousel.length,
        itemBuilder: (context, index, realIndex) {
          // ignore: unused_local_variable
          final imageCarousel = imagesCarousel[index];
          return CardImages(
            widthCard: widthCard,
            imagesCarousel: imagesCarousel[index],
          );
        },
        options: CarouselOptions(
          height: width,
          autoPlay: true,
          autoPlayCurve: Curves.easeInOut,
          enlargeCenterPage: true,
          autoPlayAnimationDuration: const Duration(seconds: 5),
          scrollDirection: Axis.horizontal,
        ));
  }
}

class CardImages extends StatelessWidget {
  final Products imagesCarousel;
  const CardImages({
    super.key,
    required this.imagesCarousel,
    required this.widthCard,
  });
  final double widthCard;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthCard,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            imagesCarousel.copy();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Description(
                          imagesCarousel: imagesCarousel,
                        )));
          },
          child: FadeInImage(
              placeholder: const AssetImage("assets/images/loading1.gif"),
              image: NetworkImage(
                imagesCarousel.image,
              ),
              fit: BoxFit.cover),
        ),
      ),
    );
  }
}
//CAROUSEL PRODUCTS//

//INFO PRODUCTS//
class Description extends StatelessWidget {
  final Products imagesCarousel;
  const Description({super.key, required this.imagesCarousel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kTextColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kTextColor,
        iconTheme: const IconThemeData(color: kBackgroundColor),
        title: Text(
          imagesCarousel.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
            color: kBackgroundColor,
            letterSpacing: 1.0,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 15, right: 15, top: 20),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FadeInImage(
                      placeholder:
                          const AssetImage("assets/images/loading1.gif"),
                      image: NetworkImage(
                        imagesCarousel.image,
                      ),
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    imagesCarousel.description,
                    style: const TextStyle(
                        color: kBackgroundColor,
                        fontSize: 20,
                        fontFamily: "Arial"),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15), // Space between sections
            const Align(
              alignment: Alignment.center,
              child: Text(
                'Presentes en:',
                style: TextStyle(
                    color: kBackgroundColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Arial"),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  // Display the uses list here
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: imagesCarousel.uses.map((use) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          use,
                          style: const TextStyle(
                              color: kBackgroundColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Arial"),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.center,
              child: CustomButton(
                  width: 250,
                  onPressed: _openWeb,
                  buttonText: 'Quiero saber más',
                  fontSize: 19),
            )
          ],
        ),
      ),
    );
  }

  _openWeb() async {
    final Uri url = Uri.parse(imagesCarousel.link);
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }
}
*/
//INFO PRODUCTS//

//INFO SERVICES//
/*
class ServiceCard extends StatelessWidget {
  final Services service;

  const ServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFECECEC),
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            widthFactor: 1.5,
            heightFactor: 1.1,
            child: GestureDetector(
              onTap: _openServices,
              child: Image.network(
                service.image,
                height: 150,
                width: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              service.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "Arial"),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 155, maxWidth: 300),
              child: SingleChildScrollView(
                child: Text(
                  service.description,
                  style: const TextStyle(fontSize: 15, fontFamily: "Arial"),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  maxLines: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _openServices() async {
    final Uri url = Uri.parse("https://emcocables.co/mrt/");
    if (!await launchUrl(url)) {
      throw Exception('No se pudo abrir $url');
    }
  }
}*/
//INFO SERVICES//

//BOTTOM NAVIGATION BAR//
/*
class Navigation extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const Navigation({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: kTextColor,
      color: kBackgroundColor,
      height: 55,
      index: widget.currentIndex,
      onTap: widget.onTap,
      items: const [
        Icon(Icons.home_rounded, size: 30, color: kTextColor),
        //label: 'Inicio',
        Icon(Icons.recycling_rounded, size: 30, color: kTextColor),
        //label: 'Ambiental',
        Icon(Icons.handshake_rounded, size: 30, color: kTextColor),
        //label: 'Etica',
        Icon(Icons.engineering_rounded, size: 30, color: kTextColor),
        //label: 'Integral',
        Icon(Icons.groups_2_rounded, size: 30, color: kTextColor),
        //label: 'Nosotros',
      ],
    );
  }
}*/
//BOTTOM NAVIGATION BAR//

//BOTTOM NAVIGATION BAR CONTROLLER//
class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  List sgiImages = [];
  List ambImages = [];
  List eticImages = [];
  int _currentIndex = 0;
  bool isMenuOpen = false;
  var ftp = dotenv.env['FTP'];
  var passw = dotenv.env['PASSW'];
  var user = dotenv.env['USER_FTP'];
  final GlobalKey<FabCircularMenuPlusState> _fabKey = GlobalKey();

  Future<String> _getTempDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  @override
  void initState() {
    super.initState();
    fetchImagesFromFTP();
  }

  Future<void> fetchImagesFromFTP() async {
    FTPConnect ftpConnect = FTPConnect(
      '$ftp',
      user: '$user',
      pass: '$passw',
      port: 21,
      timeout: 60,
    );

    try {
      await ftpConnect.connect(); // Connect to FTP server
      await ftpConnect
          .changeDirectory('imagenes'); // Change to the desired directory

      List<FTPEntry> fileList = await ftpConnect.listDirectoryContent();
      String tempDir =
          await _getTempDirectoryPath(); // Get temporary directory path

      // Fetch and save 'SGI' files for `sgiImages` (corrected filter for SGI images)
      List<FTPEntry> filesSgi = fileList
          .where((file) => file.name.startsWith('SGI-'))
          .toList(); // <-- Changed filter to 'SGI-'
      filesSgi.sort((a, b) => a.name.compareTo(b.name));
      final List<String> imagesSgi = [];

      for (var file in filesSgi) {
        String sgiFilesPath = '$tempDir/${file.name}';
        File sgiLocalFile = File(sgiFilesPath);
        bool sgiFiles = await ftpConnect.downloadFile(file.name, sgiLocalFile);
        if (sgiFiles) {
          imagesSgi.add(sgiFilesPath);
        }
      }
      setState(() {
        sgiImages = imagesSgi;
      });

      await ftpConnect.disconnect(); // Disconnect from the FTP server
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const LoginScreen(),
    const UsScreen(),
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fabKey.currentState?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PopScope(
      canPop: false,
      child: Stack(
        children: [
          _screens[_currentIndex],
          if (isMenuOpen)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          FabCircularMenuPlus(
            key: _fabKey,
            alignment: Alignment.bottomLeft,
            onDisplayChange: (isOpen) {
              setState(() {
                isMenuOpen = isOpen;
              });
            },
            ringColor: kColor2,
            fabColor: kColor2,
            fabCloseIcon: Icon(
              size: 30,
              Icons.close,
              color: kTextColor,
            ),
            fabOpenIcon: Icon(
              size: 30,
              Icons.menu_outlined,
              color: kTextColor,
            ),
            children: <Widget>[
              IconButton(
                iconSize: 30,
                color: kTextColor,
                icon: Icon(Icons.home),
                onPressed: () => _onNavItemTapped(0),
              ),
              IconButton(
                iconSize: 30,
                color: kTextColor,
                onPressed: () => _onNavItemTapped(1),
                icon: Icon(Icons.account_circle_rounded),
              ),
              IconButton(
                iconSize: 30,
                color: kTextColor,
                icon: Icon(Icons.groups_2_rounded),
                onPressed: () => _onNavItemTapped(2),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
//BOTTOM NAVIGATION BAR CONTROLLER//

//INPUT VALIDATION CODE//
class ValidateCode extends StatefulWidget {
  const ValidateCode({
    super.key,
    required this.email, //Get the email from forgotpass_screen.dart
    required this.time, //Get the email from forgotpass_screen.dart
    required this.date, //Get the email from forgotpass_screen.dart
    required this.token, //Get the token from forgotpass_screen.dart
    required this.numCode, //Get the numCode from forgotpass_screen.dart
    required this.emailMain,
    required this.emailPassWord,
  });

  final String time;
  final String date;
  final String token;
  final String email;
  final String numCode;
  final String emailMain;
  final String emailPassWord;

  @override
  State<ValidateCode> createState() => _ValidateCodeState();
}

class _ValidateCodeState extends State<ValidateCode> {
  String? errorMessage;
  late final String numCode;
  late final FocusNode focusNode;
  final now = DateTime.now().toLocal();
  late final GlobalKey<FormState> formKey;
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
    numCode = widget.numCode;
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 22, color: Colors.black87, fontFamily: "Arial"),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: kBackgroundColor),
      ),
    );

    return Form(
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
                if (value != numCode) {
                  setState(() {
                    errorMessage = 'Pin incorrecto';
                  });
                } else {
                  setState(() {
                    errorMessage = null;
                  });
                  // Navigate to codepass_screen.dart and pass it the email and token info
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChangepassScreen(
                          email: widget.email,
                          token: widget.token,
                          emailMain: widget.emailMain,
                          emailPassWord: widget.emailPassWord)));
                  sendEmail();
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
                    color: kBackgroundColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBackgroundColor),
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
              style: const TextStyle(
                  color: kColor2, fontSize: 18, fontFamily: "Arial"),
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
    );
  }

  Future<void> sendEmail() async {
    try {
      const subject = 'Tu contraseña se reestablecio correctamente';
      final smtpEmail = Address(widget.emailMain);
      final toEmail = Address(widget.email);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(widget.emailPassWord);

      String htmlEmail = await rootBundle.loadString(
          'assets/emails/restartpassword.html'); //Get the html email file
      htmlEmail = htmlEmail.replaceAll('\$now',
          '${widget.date} a las ${widget.time}'); //Replace dinamically the vars to the vars data

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
//INPUT VALIDATION CODE//

//USERS OPTIONS//
class ProfileActionsList extends StatelessWidget {
  const ProfileActionsList({
    super.key,
    required this.icon,
    required this.tittle,
    this.endIcon = true,
    required this.onPress,
    required this.textColor,
  });

  final bool endIcon;
  final String tittle;
  final IconData icon;
  final Color? textColor;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: kTextColor,
          ),
          child: Icon(
            icon,
            color: kBackgroundColor,
          )),
      title: Text(tittle,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kColor5,
              fontSize: 15,
              fontFamily: "Arial")),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: kBackgroundColor,
              ),
              child: const Icon(Icons.chevron_right_rounded,
                  size: 20, color: kTextColor))
          : null,
    );
  }
}
//USERS OPTIONS//

//RESPONSIVE//
class SizeConfig {
  late double screenWidth;
  late double screenHeight;
  late double blockSizeVertical;
  late double _safeAreaVertical;
  late double safeBlockVertical;
  late double blockSizeHorizontal;
  late double _safeAreaHorizontal;
  late double safeBlockHorizontal;
  late MediaQueryData _mediaQueryData;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }
}
//RESPONSIVE//
