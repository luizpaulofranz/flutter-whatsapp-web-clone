import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whatsapp_web_clone/models/user_model.dart';
import 'package:whatsapp_web_clone/resources/local_colors.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  final _controllerName = TextEditingController();
  final _controllerEmail = TextEditingController();
  final _controllerPass = TextEditingController();
  bool _registerNewUser = false;
  bool _loading = false;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  Uint8List? _selectedProfileImage;

  bool _emailError = false;
  bool _nameError = false;
  bool _passwordError = false;
  bool _pictureError = false;

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedin();
  }

  void _checkIfUserIsLoggedin() {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  Future<void> _selectProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    setState(() {
      _selectedProfileImage = result?.files.single.bytes;
    });
  }

  /// Uploads profile picture and saves user data on firestore.
  void _uploadImage(UserModel user) {
    if (_selectedProfileImage != null) {
      Reference profileImageRef =
          _storage.ref("images/profile/${user.userId}.jpg");
      UploadTask uploadTask = profileImageRef.putData(_selectedProfileImage!);

      uploadTask.whenComplete(() async {
        String linkImage = await uploadTask.snapshot.ref.getDownloadURL();
        user.profileImageUrl = linkImage;

        // updates firebaseauth user's data, like name and profile picture
        await _auth.currentUser?.updateDisplayName(user.name);
        await _auth.currentUser?.updatePhotoURL(linkImage);

        final usersRef = _firestore.collection("users");
        usersRef.doc(user.userId).set(user.toMap()).then((value) {
          setState(() {
            _loading = false;
          });
          //main screen
          Navigator.pushReplacementNamed(context, "/home");
        });
      });
    }
  }

  /// Handles Login and Register form submit
  Future<void> _formSubmit() async {
    setState(() {
      _loading = true;
      _emailError = false;
      _nameError = false;
      _passwordError = false;
      _pictureError = false;
    });
    String name = _controllerName.text;
    String email = _controllerEmail.text;
    String pass = _controllerPass.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (pass.isNotEmpty && pass.length > 6) {
        if (_registerNewUser) {
          if (_selectedProfileImage != null) {
            //Registration
            if (name.isNotEmpty && name.length >= 3) {
              final user = await _auth.createUserWithEmailAndPassword(
                email: email,
                password: pass,
              );

              //Upload
              String? userId = user.user?.uid;
              print(userId);
              if (userId != null) {
                final user = UserModel(userId, name, email);
                _uploadImage(user);
              }
              print("Successfull registered user id: $userId");
            } else {
              setState(() {
                _nameError = true;
              });
              print("Invalid name, at least 3 characters");
            }
          } else {
            setState(() {
              _pictureError = true;
            });
            print('Select a profile image');
          }
        } else {
          //Login
          _auth
              .signInWithEmailAndPassword(
            email: email,
            password: pass,
          )
              .then(
            (_) {
              setState(() {
                _loading = false;
              });
              Navigator.pushReplacementNamed(context, "/home");
            },
          );
        }
      } else {
        print("Invalid password");
        setState(() {
          _passwordError = true;
        });
      }
    } else {
      print("Invalid Email");
      setState(() {
        _emailError = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: LocalColors.background,
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            Positioned(
                child: Container(
              width: screenWidth,
              height: screenHeight * 0.5,
              color: LocalColors.primary,
            )),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      width: 500,
                      child: Column(
                        children: [
                          //Profile image with button
                          Visibility(
                            visible: _registerNewUser,
                            child: ClipOval(
                              child: _selectedProfileImage != null
                                  ? Image.memory(
                                      _selectedProfileImage!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "assets/profile.png",
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Visibility(
                            visible: _registerNewUser,
                            child: OutlinedButton(
                              onPressed: _selectProfileImage,
                              style: _pictureError
                                  ? OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 2, color: Colors.red),
                                    )
                                  : null,
                              child: const Text("Select photo"),
                            ),
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          //name field
                          Visibility(
                            visible: _registerNewUser,
                            child: TextField(
                              keyboardType: TextInputType.text,
                              controller: _controllerName,
                              decoration: InputDecoration(
                                hintText: "Type a valid name",
                                labelText: "Name",
                                suffixIcon: const Icon(Icons.person_outline),
                                enabledBorder: _nameError
                                    ? const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: Colors.red,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: InputDecoration(
                              hintText: _registerNewUser
                                  ? "Type a valid e-mail"
                                  : "Type your login e-mail",
                              labelText: "Email",
                              suffixIcon: const Icon(Icons.mail_outline),
                              enabledBorder: _emailError
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.red,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.text,
                            controller: _controllerPass,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: _registerNewUser
                                  ? "Must have more than 7 characters"
                                  : "Type your password",
                              labelText: "Password",
                              suffixIcon: const Icon(Icons.lock_outline),
                              enabledBorder: _passwordError
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2,
                                        color: Colors.red,
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          //Botão
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _formSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: LocalColors.primary,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _registerNewUser ? "Register" : "Login",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              const Text("Login"),
                              Switch(
                                  value: _registerNewUser,
                                  onChanged: (bool valor) {
                                    setState(() {
                                      _registerNewUser = valor;
                                    });
                                  }),
                              const Text("Register"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
