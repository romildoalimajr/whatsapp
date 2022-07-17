import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/Home.dart';

import 'RouteGenerator.dart';
import 'model/Usuario.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = "";

  _validarCampos() {
    String nome = _controllerNome.text;
    String email =
        _controllerEmail.text.replaceAll(new RegExp(r"\s+\b|\b\s"), "");
    String senha = _controllerSenha.text;

    if (nome.isNotEmpty) {
      print("clicado validado aqui nome");
      if (email.isNotEmpty && email.contains("@")) {
        print("clicado validado aqui email");
        if (senha.isNotEmpty && senha.length > 6) {
          print("clicado validado aqui senha");
          setState(() {
            _mensagemErro = "";
          });

          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;

          _cadastrarUsuario(usuario);
        } else {
          setState(() {
            _mensagemErro = "Preencha uma senha com mais de 6 caracteres";
          });
        }
      } else {
        setState(() {
          _mensagemErro = "Preencha o email corretamente";
        });
      }
    } else {
      setState(() {
        _mensagemErro = "Preencha o nome";
      });
    }
  }

  _cadastrarUsuario(Usuario usuario) {
    print("clicado validado aqui cadastrado");

    //WidgetsFlutterBinding.ensureInitialized();

    FirebaseAuth auth = FirebaseAuth.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((User) {
      //Salvar dados do usuário

      FirebaseFirestore db = FirebaseFirestore.instance;

      db.collection("usuarios").doc(User.user?.uid).set(usuario.toMap());

      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
      //Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
    }).catchError((error) {
      print("erro app: " + error.toString());
      setState(() {
        _mensagemErro =
            "Erro ao cadastrar usuario, verifique os campos e tente novamente!";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "assets/images/usuario.png",
                      width: 200,
                      height: 150,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerNome,
                      autofocus: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllerEmail,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _controllerSenha,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: RaisedButton(
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      color: Colors.green,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      onPressed: () {
                        print("clicado");
                        _validarCampos();
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
