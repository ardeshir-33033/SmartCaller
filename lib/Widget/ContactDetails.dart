import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_contact/Screens/ContactsListPage.dart';
import 'package:phone_contact/Widget/updateContactPage.dart';
import 'AdressTile.dart';

class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact, {this.onContactDeviceSave});

  final Contact _contact;
  final Function(Contact) onContactDeviceSave;

  _openExistingContactOnDevice(BuildContext context) async {
    var contact = await ContactsService.openExistingContact(_contact,
        iOSLocalizedLabels: iOSLocalizedLabels);
    if (onContactDeviceSave != null) {
      onContactDeviceSave(contact);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
        actions: <Widget>[
//          IconButton(
//            icon: Icon(Icons.share),
//            onPressed: () => shareVCFCard(context, contact: _contact),
//          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => ContactsService.deleteContact(_contact),
          ),
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UpdateContactsPage(
                  contact: _contact,
                ),
              ),
            ),
          ),
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _openExistingContactOnDevice(context)),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Name"),
              trailing: Text(_contact.givenName ?? ""),
            ),
            ListTile(
              title: Text("Middle name"),
              trailing: Text(_contact.middleName ?? ""),
            ),
            ListTile(
              title: Text("Family name"),
              trailing: Text(_contact.familyName ?? ""),
            ),
            ListTile(
              title: Text("Prefix"),
              trailing: Text(_contact.prefix ?? ""),
            ),
            ListTile(
              title: Text("Suffix"),
              trailing: Text(_contact.suffix ?? ""),
            ),
            ListTile(
              title: Text("Birthday"),
              trailing: Text(_contact.birthday != null
                  ? DateFormat('dd-MM-yyyy').format(_contact.birthday)
                  : ""),
            ),
            ListTile(
              title: Text("Company"),
              trailing: Text(_contact.company ?? ""),
            ),
            ListTile(
              title: Text("Job"),
              trailing: Text(_contact.jobTitle ?? ""),
            ),
            ListTile(
              title: Text("Account Type"),
              trailing: Text((_contact.androidAccountType != null)
                  ? _contact.androidAccountType.toString()
                  : ""),
            ),
            AddressesTile(_contact.postalAddresses),
            ItemsTile("Phones", _contact.phones),
            ItemsTile("Emails", _contact.emails)
          ],
        ),
      ),
    );
  }
}
