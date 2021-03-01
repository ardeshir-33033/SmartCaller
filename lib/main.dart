import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_contact/Screens/HomePage.dart';
import 'package:phone_contact/StateProvider/ContactSearchProvider.dart';
import 'package:provider/provider.dart';
import 'Component/Speech.dart';
import 'Screens/ContactPagepicker.dart';
import 'Screens/ContactsListPage.dart';
import 'TestSchedule.dart';
import 'Widget/AddContact.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid =
  AndroidInitializationSettings('camera');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
      });

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<SearchProvider>(
        create: (context) => SearchProvider())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        '/add': (BuildContext context) => AddContactPage(),
        '/contactsList': (BuildContext context) => ContactListPage(),
        '/nativeContactPicker': (BuildContext context) => ContactPickerPage(),
      },
    );
  }
}
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   Future<void> _askPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.contacts,
//       Permission.speech,
//     ].request();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _askPermissions();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Contacts Plugin Example')),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             RaisedButton(
//               child: Text('Contacts list'),
//               onPressed: () => Navigator.pushNamed(context, '/contactsList'),
//             ),
//             RaisedButton(
//               child: Text('Native Contacts picker'),
//               onPressed: () =>
//                   Navigator.pushNamed(context, '/nativeContactPicker'),
//             ),
//             Container(
//               // width: phoneWidth,
//               height: 100,
//               child: Speech(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
