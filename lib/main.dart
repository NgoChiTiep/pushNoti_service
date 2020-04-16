import 'package:flutter/material.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void backgroundFetchHeadlessTask(String taskId) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  print('[BackgroundFetch] Headless event received.');
  print("killlllllllllllllll");
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      playSound: false, importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics =
      new IOSNotificationDetails(presentSound: false);
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'New Post',
    'How to Show Notification in Flutter',
    platformChannelSpecifics,
    payload: 'No_Sound',
  );
  BackgroundFetch.finish(taskId);
}

void main() {
  runApp(
    new MaterialApp(home: new MyApp()),
  );
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];

  @override
  initState() {
    super.initState();
// to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    initPlatformState();
    // BackgroundFetch.start().then((int status) {
    //   print('[BackgroundFetch] start success: $status');
    // }).catchError((e) {
    //   print('[BackgroundFetch] start FAILURE: $e');
    // });
  }

  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
            BackgroundFetchConfig(
                minimumFetchInterval: 1,
                stopOnTerminate: false,
                enableHeadless: true,
                startOnBoot: true
                // requiresBatteryNotLow: false,
                // requiresCharging: false,
                // requiresStorageNotLow: false,
                // requiresDeviceIdle: false,
                // requiredNetworkType: NetworkType.NONE,
                
                ),
            _onBackgroundFetch)
        .then((int status) {
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });
    }).catchError((e) {
      print('[BackgroundFetch] configure ERROR: $e');
      setState(() {
        _status = e;
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) {
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received $taskId");
    _showNotificationWithoutSound();
    setState(() {
      _events.insert(0, new DateTime.now());
    });
    // IMPORTANT:  You must signal completion of your task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: new Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new SizedBox(
                height: 30.0,
              ),
              new RaisedButton(
                onPressed: _showNotificationWithoutSound,
                child: new Text('Show Notification With Default Sound'),
              ),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (BuildContext context, int index) {
                        DateTime timestamp = _events[index];
                        return InputDecorator(
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(
                                    left: 10.0, top: 10.0, bottom: 0.0),
                                labelStyle: TextStyle(
                                    color: Colors.amberAccent, fontSize: 20.0),
                                labelText: "[background fetch event]"),
                            child: new Text(timestamp.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0)));
                      }),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Row(children: <Widget>[
          RaisedButton(onPressed: _onClickStatus, child: Text('Status')),
          Container(
              child: Text("$_status"), margin: EdgeInsets.only(left: 20.0))
        ])),
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  Future _showNotificationWithoutSound() async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: false, importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics =
        new IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      'How to Show Notification in Flutter',
      platformChannelSpecifics,
      payload: 'No_Sound',
    );
  }
}
