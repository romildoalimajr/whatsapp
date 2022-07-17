import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();

  final _picker = ImagePicker();

  String _idUsuarioLogado = "";
  PickedFile? _imagem;
  bool _subindoImagem = false;
  String _urlImagemRecuperada = "";

  Future _recuperarImagem(String origemImagem) async {
    PickedFile? imagemSelecionada;

    switch (origemImagem) {
      case "camera":
        imagemSelecionada =
            (await _picker.getImage(source: ImageSource.camera));
        break;
      case "galeria":
        imagemSelecionada =
            (await _picker.getImage(source: ImageSource.gallery));
        break;
      default:
    }

    setState(() {
      _imagem = imagemSelecionada!;
      if (_imagem != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    var file = File(_imagem!.path);

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado + ".jpg");

    //upload das imagem
    UploadTask task = arquivo.putFile(file);

    //controlar progresso do upload

    task.snapshotEvents.listen((TaskSnapshot storageEvent) {
      if (storageEvent.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.state == TaskState.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    //recuperar URL da imagem

    task.then((TaskSnapshot taskSnapshot) {
      _recuperarUrlImagem(taskSnapshot);
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

/*  _atualizarNomeFirestore(String nome){
* String nome = _controllerNome.text;
* */
  _atualizarNomeFirestore() {
    String nome = _controllerNome.text;

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"nome": nome};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarUrlImagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"urlImagem": url};

    db.collection("usuarios").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = await auth.currentUser;
    _idUsuarioLogado = usuarioLogado!.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc(_idUsuarioLogado).get();

    Map<String, dynamic> dados = snapshot.data as Map<String, dynamic>;
    _controllerNome.text = dados["nome"];

    if (dados["urlImagem"] != null) {
      setState(() {
        _urlImagemRecuperada = dados["urlImagem"];
        print("imagem :" + _urlImagemRecuperada.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: _subindoImagem
                      ? CircularProgressIndicator()
                      : Container(),
                ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada)
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      child: Text("Câmera"),
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                    ),
                    FlatButton(
                      child: Text("Galeria"),
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    /*onChanged: (texto){
                      _atualizarNomeFirestore(texto);
                    },*/
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
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                    child: Text(
                      "Salvar",
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
                      _atualizarNomeFirestore();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
