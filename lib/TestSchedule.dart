import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'Alarm/AlarmHelper.dart';
import 'Alarm/AlarmInfo.dart';
import 'main.dart';

class ScheduleTEst extends StatefulWidget {
  @override
  _ScheduleTEstState createState() => _ScheduleTEstState();
}

class _ScheduleTEstState extends State<ScheduleTEst> {
  DateTime _alarmTime;
  String _alarmTimeString;
  AlarmHelper _alarmHelper = AlarmHelper();
  Future<List<AlarmInfo>> _alarms;
  List<AlarmInfo> _currentAlarms;

  @override
  void initState() {
    _alarmTime = DateTime.now();
    _alarmHelper.initializeDatabase().then((value) {
      print('------database intialized');
      loadAlarms();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: FutureBuilder<List<AlarmInfo>>(
            future: _alarms,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _currentAlarms = snapshot.data;
                return ListView(
                  children: snapshot.data.map<Widget>((alarm) {
                    var alarmTime =
                        DateFormat('hh:mm aa').format(alarm.alarmDateTime);
                    // var gradientColor = GradientTemplate
                    //     .gradientTemplate[alarm.gradientColorIndex].colors;
                    return Container(
                      margin:  EdgeInsets.only(bottom: 32),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // decoration: BoxDecoration(
                      //   gradient: LinearGradient(
                      //     colors: gradientColor,
                      //     begin: Alignment.centerLeft,
                      //     end: Alignment.centerRight,
                      //   ),
                      //   boxShadow: [
                      //     BoxShadow(
                      //       color: gradientColor.last.withOpacity(0.4),
                      //       blurRadius: 8,
                      //       spreadRadius: 2,
                      //       offset: Offset(4, 4),
                      //     ),
                      //   ],
                      //   borderRadius: BorderRadius.all(Radius.circular(24)),
                      // ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.label,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    alarm.title,
                                  ),
                                ],
                              ),
                              Switch(
                                onChanged: (bool value) {},
                                value: true,
                                activeColor: Colors.white,
                              ),
                            ],
                          ),
                          Text(
                            'Mon-Fri',

                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                alarmTime,
                                style: TextStyle(
                                    fontFamily: 'avenir',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deleteAlarm(alarm.id);
                                  }),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).followedBy([
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // color: CustomColors.clockBG,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      child: FlatButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        onPressed: () {
                          _alarmTimeString =
                              DateFormat('HH:mm').format(DateTime.now());
                          showModalBottomSheet(
                            useRootNavigator: true,
                            context: context,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Container(
                                    height: 200,
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        FlatButton(
                                          onPressed: () async {
                                            var selectedTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            if (selectedTime != null) {
                                              final now = DateTime.now();
                                              var selectedDateTime = DateTime(
                                                  now.year,
                                                  now.month,
                                                  now.day,
                                                  selectedTime.hour,
                                                  selectedTime.minute);
                                              _alarmTime = selectedDateTime;
                                              setModalState(() {
                                                _alarmTimeString =
                                                    DateFormat('HH:mm')
                                                        .format(selectedDateTime);
                                              });
                                            }
                                          },
                                          child: Text(
                                            _alarmTimeString,
                                            style: TextStyle(fontSize: 32),
                                          ),
                                        ),

                                        FloatingActionButton.extended(
                                          onPressed: onSaveAlarm,
                                          icon: Icon(Icons.alarm),
                                          label: Text('Save'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                          // scheduleAlarm();
                        },
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/Artboard1.png',
                              scale: 1.5,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add Alarm',

                            ),
                          ],
                        ),
                      ),
                    ),
                  ]).toList(),
                );
              } else {
                return Center(
                  child: Text(
                    'Loading..',
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void scheduleAlarm(
      DateTime scheduledNotificationDateTime, AlarmInfo alarmInfo) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif',
      'alarm_notif',
      'Channel for Alarm notification',
      icon: 'camera',
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('camera'),
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(0, 'Office', alarmInfo.title,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  void onSaveAlarm() {
    DateTime scheduleAlarmDateTime;
    if (_alarmTime.isAfter(DateTime.now()))
      scheduleAlarmDateTime = _alarmTime;
    else
      scheduleAlarmDateTime = _alarmTime.add(Duration(days: 1));

    var alarmInfo = AlarmInfo(
      alarmDateTime: scheduleAlarmDateTime,
      gradientColorIndex: _currentAlarms.length,
      title: 'alarm',
    );
    _alarmHelper.insertAlarm(alarmInfo);
    scheduleAlarm(scheduleAlarmDateTime, alarmInfo);
    Navigator.pop(context);
    loadAlarms();
  }

  void deleteAlarm(int id) {
    _alarmHelper.delete(id);
    //unsubscribe for notification
    loadAlarms();
  }

  void loadAlarms() {
    _alarms = _alarmHelper.getAlarms();
    if (mounted) setState(() {});
  }
}
