import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web_clone/resources/local_colors.dart';

class LoginRegister extends StatefulWidget {
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  final _controllerName = TextEditingController(text: "Jamilton Damasceno");
  final _controllerEmail = TextEditingController(text: "jamilton@gmail.com");
  final _controllerPass = TextEditingController(text: "1234567");
  bool _registerNewUser = false;
  final _auth = FirebaseAuth.instance;

  Future<void> _formSubmit() async {
    String nome = _controllerName.text;
    String email = _controllerEmail.text;
    String senha = _controllerPass.text;

    if (email.isNotEmpty && email.contains("@")) {
      if (senha.isNotEmpty && senha.length > 6) {
        if (_registerNewUser) {
          //Registration
          if (nome.isNotEmpty && nome.length >= 3) {
            final user = await _auth.createUserWithEmailAndPassword(
                email: email, password: senha);

            //Upload
            String? idUsuario = user.user?.uid;
            print("Successfull registered user id: $idUsuario");
          } else {
            print("Invalid name, at least 3 characters");
          }
        } else {
          //Login
          final user = await _auth.signInWithEmailAndPassword(
            email: email,
            password: senha,
          );
          String? userEmail = user.user?.email;
          print("Registered user email: $userEmail");
        }
      } else {
        print("Invalid password");
      }
    } else {
      print("Invalid FEmail");
    }
  }

  @override
  Widget build(BuildContext context) {
    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: LocalColors.background,
        width: larguraTela,
        height: alturaTela,
        child: Stack(
          children: [
            Positioned(
                child: Container(
              width: larguraTela,
              height: alturaTela * 0.5,
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
                              child: Image.asset(
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
                              onPressed: () {},
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
                              decoration: const InputDecoration(
                                hintText: "Name",
                                labelText: "Name",
                                suffixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),

                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: const InputDecoration(
                              hintText: "Email",
                              labelText: "Email",
                              suffixIcon: Icon(Icons.mail_outline),
                            ),
                          ),

                          TextField(
                            keyboardType: TextInputType.text,
                            controller: _controllerPass,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Password",
                              labelText: "Password",
                              suffixIcon: Icon(Icons.lock_outline),
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
                                child: Text(
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
