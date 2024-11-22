import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vicar_app/constants.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vicar_app/components/components.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:vicar_app/screens/user/login_screen.dart';
import 'package:vicar_app/screens/user/profile_screen.dart';

class ChangeProfileScreen extends StatefulWidget {
  const ChangeProfileScreen({
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
  State<ChangeProfileScreen> createState() => _ChangeProfileScreenState();
}

class _ChangeProfileScreenState extends State<ChangeProfileScreen> {
  Image? decodedImage;
  var responseAPI = '';
  File? _selectedImage;
  bool correct = false;
  bool _passwordsMatch = false;
  bool _passwordHasNumber = false;
  final now = DateTime.now().toLocal();
  bool _passwordEightCharacters = false;
  final SizeConfig sizeConfig = SizeConfig();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _oldPassword = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadImageFromFTP();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sizeConfig.init(context); // Initialize SizeConfig here
  }

  void _onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    final alphaRegex = RegExp(r'[a-zA-Z]');

    setState(() {
      _passwordEightCharacters = password.length >= 8;
      _passwordsMatch = password == _confirmPassword.text;
      _passwordHasNumber =
          numericRegex.hasMatch(password) && alphaRegex.hasMatch(password);
    });
  }

  Future<String> _getTempDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<String?> _convertImageToBase64(File imageFile) async {
    try {
      final bytes =
          await imageFile.readAsBytes(); // Read the image file as bytes
      final base64String = base64Encode(bytes); // Convert to Base64 string
      return base64String;
    } catch (e) {
      debugPrint('Error converting image to Base64: $e');
      return null;
    }
  }

  Future<void> loadImageFromFTP() async {
    FTPConnect ftpConnect = FTPConnect(
      widget.ftp,
      user: widget.ftpUsr,
      pass: widget.ftpPassWord,
      port: int.parse(widget.ftpPort),
      timeout: 120,
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

  Future<void> uploadBase64ImageToFTP(
      String base64Image, String fileName) async {
    FTPConnect ftpConnect = FTPConnect(
      widget.ftp,
      user: widget.ftpUsr,
      pass: widget.ftpPassWord,
      port: int.parse(widget.ftpPort),
      timeout: 120,
    );

    try {
      await ftpConnect.connect();
      await ftpConnect.changeDirectory('usersimg');

      // Get the temporary directory path
      String tempDir = await _getTempDirectoryPath();

      // Create the full path for the temporary file
      String tempFilePath = "$tempDir/$fileName.txt";

      // Write the Base64 image string to a file locally
      File base64File = File(tempFilePath);
      await base64File.writeAsString(base64Image);

      // Upload the Base64 file to FTP
      bool uploadResult = await ftpConnect.uploadFile(base64File);
      if (uploadResult) {
        debugPrint('Base64 image uploaded successfully as $fileName.txt');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Foto actualizada"),
            ),
          );
        }
      } else {
        debugPrint('Failed to upload Base64 image');
      }

      await ftpConnect.disconnect();
    } catch (e) {
      debugPrint('FTP error: $e');
    }
  }

  //Navigate to Profile screen
  void _toProfileScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
            role: widget.role,
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
      ),
    );
  }

  Future<String?> _logIn() async {
    final String email = widget.email;
    final String password = _oldPassword.text;
    final response = await http.post(
      Uri.parse(logInUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        correct = true;
      });
      await _handleChange();
      return 'Success';
    } else {
      setState(() {
        correct = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("La antigua contraseña no es correcta, valide."),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _handleChange() async {
    if (_passwordsMatch && _passwordHasNumber && _passwordEightCharacters) {
      try {
        final token = widget.token; //Get the token from login_screen.dart
        final String email = widget.email;
        final String password = _password.text;
        final urlEmail = '$usrInfo$email';

        final response = await http.put(
          Uri.parse(urlEmail),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, String>{
            'password': password,
            "email": widget.email,
          }),
        );

        if (mounted) {
          if (response.statusCode == 200) {
            // Password changed
            responseAPI = response.body;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("¡Cambio de contraseña exitoso!"),
              ),
            );
            await sendEmail(); //Send email whit change notification
            if (mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProfileScreen(
                    nit: widget.nit,
                    role: widget.role,
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
                    "No se pudo llevar a cabo tu cambio de contraseña, por favor intenta mas tarde."),
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
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Complete los campos correctamente."),
          ),
        );
      }
    }
  }

  void _onConfirmPasswordChanged(String confirmPassword) {
    setState(() {
      _passwordsMatch = _password.text == confirmPassword;
    });
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColor6,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              _toProfileScreen();
            },
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: kTextColor,
            )),
        title: const Text(
          'Editar',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kTextColor,
              fontSize: 20,
              fontFamily: "Arial"),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/vicarback2.jnpg'),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!)
                          : decodedImage ??
                              const Image(
                                image: AssetImage(
                                    'assets/images/userDefault.png'), // Default image when no photo
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: kTextColor,
                        ),
                        child: IconButton(
                            onPressed: () {
                              _pickGalleryImage();
                            },
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                            ))),
                  )
                ],
              ),
              SizedBox(
                  height: sizeConfig.safeBlockVertical *
                      1), // Space between columns
              Divider(color: kBackgroundColor),
              SizedBox(
                  height: sizeConfig.safeBlockVertical *
                      1), // Space between columns
              TextInputs(
                //Check to `lib/components/components.dart` at lines 35-122
                keyboardType: TextInputType.text,
                myController: _oldPassword,
                labelText: 'Anterior Contraseña',
                prefixIcon: const Icon(Icons.password_rounded),
                initialObscureText: true,
                showSuffixIcon: true,
              ),
              const SizedBox(height: 12), // Space between columns
              TextInputs(
                //Check to `lib/components/components.dart` at lines 35-122
                keyboardType: TextInputType.text,
                myController: _password,
                onChanged: _onPasswordChanged,
                labelText: 'Nueva Contraseña',
                prefixIcon: const Icon(Icons.password_rounded),
                initialObscureText: true,
                showSuffixIcon: true,
              ),

              const SizedBox(height: 12), // Space between columns
              TextInputs(
                //Check to `lib/components/components.dart` at lines 35-122
                keyboardType: TextInputType.text,
                myController: _confirmPassword,
                onChanged: _onConfirmPasswordChanged,
                labelText: 'Confirmar Contraseña',
                prefixIcon: const Icon(Icons.password_rounded),
                initialObscureText: true,
                showSuffixIcon: true,
              ),
              const SizedBox(height: 20), // Space between columns
              Container(
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 1),
                child: Column(
                  children: [
                    AlerstPasss(
                      //Check to `lib/components/components.dart` at lines 173-208
                      alert:
                          'La contraseña debe tener al menos \n8 caracteres.',
                      color: _passwordEightCharacters
                          ? Colors.green
                          : Colors.transparent,
                      border: _passwordEightCharacters
                          ? Border.all(color: Colors.transparent)
                          : Border.all(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 12), // Space between columns
                    AlerstPasss(
                      //Check to `lib/components/components.dart` at lines 173-208
                      alert: 'La contraseña debe tener numeros y letras.',
                      color: _passwordHasNumber
                          ? Colors.green
                          : Colors.transparent,
                      border: _passwordHasNumber
                          ? Border.all(color: Colors.transparent)
                          : Border.all(color: Colors.grey.shade400),
                    ),
                    const SizedBox(height: 12), // Space between columns
                    AlerstPasss(
                      //Check to `lib/components/components.dart` at lines 173-208
                      alert: 'Las contraseñas deben coincidir.',
                      color:
                          _passwordsMatch ? Colors.green : Colors.transparent,
                      border: _passwordsMatch
                          ? Border.all(color: Colors.transparent)
                          : Border.all(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10), // Space between columns
              CustomButton(
                //Check to `lib/components/components.dart` at lines 124-171
                fontSize: sizeConfig.safeBlockVertical * 2,
                width: sizeConfig.safeBlockVertical * 30,
                buttonText: 'Actualizar contraseña',
                onPressed: _logIn,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/footer2.png',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Get the image from gallery
  Future<void> _pickGalleryImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);

      // Convert the image to Base64
      String? base64Image = await _convertImageToBase64(imageFile);
      if (base64Image != null) {
        // Remove special characters from email to create a valid file name
        String emailWithoutDots =
            widget.email.replaceAll(".", "").replaceAll("@", "");

        // Proceed with uploading the Base64 image
        await uploadBase64ImageToFTP(base64Image, emailWithoutDots);
      }

      setState(() {
        _selectedImage = imageFile;
      });
    }
  }

  //Create email message
  Future<void> sendEmail() async {
    try {
      final time = DateFormat('HH:mm').format(now); //Format datetime to time
      final smtpEmail = Address(widget.emailMain);
      final toEmail = Address(widget.email);
      final personalization = Personalization([toEmail]);
      final mailer = Mailer(widget.emailPassWord);
      final date =
          DateFormat('dd/MM/yyyy').format(now); //Format datetime to date
      String htmlEmail = await rootBundle.loadString(
          'assets/emails/restartpassword.html'); //Get the html email file
      htmlEmail = htmlEmail.replaceAll('\$now',
          '$date a las $time'); //Replace dinamically the vars to the vars data
      const subject = 'Tu contraseña se reestablecio correctamente';

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
