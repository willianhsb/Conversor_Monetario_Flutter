import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

const request = "https://api.hgbrasil.com/finance?key=16c65ee5";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white
      ),
  ));
}

Future<Map> getData() async {
  /*retorna dados no futuro*/
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body); /*transforma o arquivo json em um  Mapa*/
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  double dolar = 0;
  double euro = 0;
  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  void _realChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
      double real = double.parse(text);
      dolarController.text = (real/dolar).toStringAsFixed(2);
      euroController.text = (real/euro).toStringAsFixed(2);
  }
  void _dolarChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text("\$ Conversor \$"),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),

        body: FutureBuilder<Map>(
            /*Mapa retornado pelo Json da api HG Brasil*/
            future: getData(),
            builder: (context, snapshot) {
              /*O que sera mostrado na tela em cada um dos casos*/
              switch (snapshot.connectionState) {
                /*Verifica o estado da tela*/
                case ConnectionState.none: /*sem conexão*/
                case ConnectionState.waiting: /*aguardando conexão*/
                  return Center(
                      /*retorna Carragando Dados*/
                      child: Text(
                    "Carregando Dados....",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default: /*Caso não execute nenhum estado acima*/
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao carregar os Dados :(",
                      /*Caso retorne algum erro*/
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  } else {  /*Se foi carregado com sucesso*/
                    /*Captura de dados da api, estrutura do json*/
                    dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView( /*permite rolar a tela*/
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          Icon(Icons.monetization_on, size: 150.0, color: Colors.amber),
                          buildTextField("Reais", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField("Dolares", "US", dolarController, _dolarChanged),
                          Divider(),
                          buildTextField("Euros", "€", euroController, _euroChanged),
                        ],
                      ),
                    );
                  }
              }
            })
    );

  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function(String) f){
  return TextField(
    controller: c,

    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),

    onChanged: f, /*sempre que acontece uma mudança no campo, a Function f é chamada*/
    keyboardType: TextInputType.numberWithOptions(decimal: true), /*permite somente numeros nos campos textos*/
  );

}
