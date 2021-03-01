import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_contact/Component/Speech.dart';
import 'package:url_launcher/url_launcher.dart';

import '../TestSchedule.dart';
import 'ContactsListPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // _HomePageState() {
  //   filter.addListener(() {
  //     if (filter.text.isNotEmpty) {
  //       setState(() {
  //         searchText = filter.text;
  //       });
  //       SearchFunc();
  //     }
  //   });
  // }

  List<Contact> contacts;
  List<Contact> DeployedContact;
  String searchText;
  String searchQuery = "Search query";
  TextEditingController filter = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _askPermissions();
    refreshContacts();
  }

  Future<void> _askPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
      Permission.speech,
    ].request();
  }

  void SearchFunc() {
    if (searchText != " ") {
      contacts.clear();
      for (int i = 0; i < DeployedContact.length; i++) {
        if (DeployedContact[i]
            .displayName
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          contacts.add(DeployedContact[i]);
        }
      }
      setState(() {});
      if (contacts.length == 1) {
        callnow(contacts.first.phones.first.value);
      }
    }
  }

  Future<void> callnow(String phoneNumber) async {
    if (await canLaunch("tel:${phoneNumber}")) {
      await launch("tel:${phoneNumber}");
    } else {
      throw 'call not possible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  // width: phoneWidth,
                  height: 150,
                  child: Speech(
                    SpeechTextCallBack: (reuslt) {
                      searchText = reuslt;
                      SearchFunc();
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 200,
                  child: contacts != null
                      ? ListView.builder(
                          itemCount: contacts?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            Contact contact = contacts?.elementAt(index);
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 18),
                              leading: (contact.avatar != null &&
                                      contact.avatar.isNotEmpty)
                                  ? CircleAvatar(
                                      backgroundImage:
                                          MemoryImage(contact.avatar),
                                    )
                                  : CircleAvatar(
                                      child: Text(contact.initials()),
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                    ),
                              title: Text(contact.displayName ?? ''),
                              trailing: Container(
                                width: 150,
                                child: Row(
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.alarm),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ScheduleTEst()));
                                        }),
                                    IconButton(
                                      icon: Icon(Icons.phone),
                                      onPressed: () {
                                        if (contact.phones.length == 0) {
                                          showInSnackBar(context);
                                        } else {
                                          callnow(contact.phones.first.value);
                                        }
                                      },
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _openExistingContactOnDevice(
                                                  context, contact)
                                              .then((value) {
                                            refreshContacts();
                                            // setState(() {});
                                          });
                                        })
                                  ],
                                ),
                              ),
                              //This can be further expanded to showing contacts detail
                              // onPressed().
                              // trailing: Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: <Widget>[
                              //     PhoneButton(phoneNumbers: contact.phones),
                              //     SmsButton(phoneNumbers: contact.phones)
                              //   ],
                              // ),
                            );
                          })
                      : Center(child: const CircularProgressIndicator()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _openExistingContactOnDevice(
      BuildContext context, Contact contact) async {
    await ContactsService.openExistingContact(contact,
        iOSLocalizedLabels: iOSLocalizedLabels);
    // if (onContactDeviceSave != null) {
    //   onContactDeviceSave(changeContact);
    // }
  }

  void showInSnackBar(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey[800],
        content: Container(
          height: 52.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "شماره ای برای این مخاطب وارد نشده است",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    DeployedContact = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
    setState(() {
      contacts = DeployedContact.map((e) => e).toList();
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in DeployedContact) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }
}
