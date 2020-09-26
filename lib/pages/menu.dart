import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Declaracion de las push notifications
  final FirebaseMessaging fcm = FirebaseMessaging();
  Future initialize() async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: ListTile(
                    title: Text(message['notification']['title']),
                    subtitle: Text(message['notification']['body'] +
                        ' peso: ' +
                        this.weight),
                  ),
                  backgroundColor: Colors.blue[100],
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
  }

  // Declaracion de los mensajes http
  void getData() async {
    var response = await http.get('http://157.245.221.248:3000/getestados');
    Map data = jsonDecode(response.body);
    // print(data);
    this.state = data['estado'];
    this.packets = data['total_paquetes'];
    this.obstacles = data['obstaculos'];
    this.position = data['position'];
    this.weight = data['peso'];
    this.averageWeight = data['peso_promedio'];
    this.averageGoing = data['promedio_entrega'];
    this.averageReturn = data['promedio_buzon'];
  }

  void sendState(status) async {
    // 1 Para activo, 0 para inactivo
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json; charset=utf-8',
      'Accept': 'application/json'
    };
    Map data = {"status": status};
    var response = await http.post('http://157.245.221.248:3000/movercarro',
        body: jsonEncode(data), headers: requestHeaders);
    // Map data = jsonDecode(response.body);
    print(response.body);
  }

  //Posicion 1 = partida, 2 = buzon, 3 = camino
  // Estado 0 = en reposo, 1 = de ida (buzon), 2 = de regreso, 3 = detenido
  String weight = '0',
      averageWeight = '0',
      averageGoing = '0',
      averageReturn = '0',
      state = '0',
      packets = '0',
      obstacles = '0',
      position = '0';

  @override
  Widget build(BuildContext context) {
    // Push notificacions
    this.initialize();

    getData();

    return Scaffold(
      appBar: AppBar(
        title: Text('Repartidor Inteligente'),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Column(
          children: <Widget>[
            Text('Datos',
                style: TextStyle(fontSize: 18, color: Colors.blue[500])),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.location_searching,
                            size: 40,
                          ),
                          Text('Ubicacion: ' + this.position)
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.local_car_wash,
                            size: 40,
                          ),
                          Text('Estado: ' + this.state)
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.check_box,
                            size: 40,
                          ),
                          Text('Paquetes: ' + this.packets)
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.category,
                            size: 40,
                          ),
                          Text('Obstaculos: ' + this.obstacles)
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.blue[300],
              thickness: 3,
            ),
            Text(
              'Analisis',
              style: TextStyle(fontSize: 18, color: Colors.blue[500]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.multiline_chart,
                            size: 40,
                          ),
                          Text('Peso Promedio: ' + this.averageWeight)
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.timer,
                            size: 40,
                          ),
                          Text('Promedio Ida: ' + this.averageGoing)
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.timer,
                            size: 40,
                          ),
                          Text('Promedio Regreso: ' + this.averageReturn)
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.blue[300],
              thickness: 3,
            ),
            Text(
              'Funciones',
              style: TextStyle(fontSize: 18, color: Colors.blue[500]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          color: Colors.blue[400],
                          iconSize: 40,
                          onPressed: () {
                            sendState('1');
                          },
                        ),
                        Text('Activar Carro')
                      ],
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.pause),
                          color: Colors.blue[400],
                          iconSize: 40,
                          onPressed: () {
                            sendState('0');
                          },
                        ),
                        Text('Desactivar Carro')
                      ],
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.info),
        onPressed: () {
          Navigator.pushNamed(context, '/info');
        },
        backgroundColor: Colors.blue[300],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
    );
  }
}
