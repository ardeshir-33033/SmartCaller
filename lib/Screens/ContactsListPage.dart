import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:phone_contact/Widget/ContactDetails.dart';

final iOSLocalizedLabels = false;

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  _ContactListPageState() {
    filter.addListener(() {
      if (filter.text.isNotEmpty) {
        setState(() {
          searchText = filter.text;
        });
        SearchFunc();
      }
    });
  }

  List<Contact> contacts;
  List<Contact> DeployedContact;
  String searchText;
  String searchQuery = "Search query";
  final TextEditingController filter = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  void SearchFunc() {
    if (searchText.isNotEmpty) {
      contacts.clear();
      for (int i = 0; i < DeployedContact.length; i++) {
        if (DeployedContact[i]
            .displayName
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          contacts.add(DeployedContact[i]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create),
            onPressed: _openContactForm,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed("/add").then((_) {
            refreshContacts();
          });
        },
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: TextField(
                controller: filter,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search...",
                ),
              ),
            ),
            contacts != null
                ? Container(
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView.builder(
                      itemCount: contacts?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        Contact c = contacts?.elementAt(index);
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ContactDetailsPage(
                                      c,
                                      onContactDeviceSave:
                                          contactOnDeviceHasBeenUpdated,
                                    )));
                          },
                          leading: (c.avatar != null && c.avatar.length > 0)
                              ? CircleAvatar(
                                  backgroundImage: MemoryImage(c.avatar))
                              : CircleAvatar(child: Text(c.initials())),
                          title: Text(c.displayName ?? ""),
                        );
                      },
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ],
        ),
      )),
    );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = contacts.indexWhere((c) => c.identifier == contact.identifier);
      contacts[id] = contact;
    });
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

  void updateContact() async {
    refreshContacts();
  }

  _openContactForm() async {
    var contact = await ContactsService.openContactForm(
        iOSLocalizedLabels: iOSLocalizedLabels);
    refreshContacts();
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';
import 'package:phone_contact/Widget/ContactDetails.dart';
import 'package:phone_contact/Widget/updateContactPage.dart';

final iOSLocalizedLabels = false;

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts = [];
  List<Contact> contacts;
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery;

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search Data...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (value) => updateSearchQuery(value),
    );
  }

  void updateSearchQuery(String searchText) {
    print(contacts.length);

    if (searchText.isNotEmpty) {
      _contacts.clear();
      print(contacts.length);

      setState(() {});
      print(contacts.length);

      for (int i = 0; i >= contacts.length; i++) {
        if (contacts[i]
            .displayName
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          _contacts.add(contacts[i]);
          print(i);
          setState(() {});
        }
      }
    } else {
      // _contacts = contacts;
      setState(() {});
    }
    searchQuery = searchText;
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              _isSearching = false;
              setState(() {});
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
//     _contacts = contacts;

    // setState(() {
    // });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  // void updateContact() async {
  //   refreshContacts();
  // }

  // _openContactForm() async {
  //   var contact = await ContactsService.openContactForm(
  //       iOSLocalizedLabels: iOSLocalizedLabels);
  //   refreshContacts();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField()
            : GestureDetector(
                onTap: () {
                  _isSearching = true;
                  setState(() {});
                },
                child: Text(
                  'Contacts',
                ),
              ),
        actions: _buildActions(),
        // IconButton(
        //   icon: Icon(Icons.create),
        //   onPressed: _openContactForm,
        // )

        leading: _isSearching ? BackButton() : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed("/add").then((_) {
            refreshContacts();
          });
        },
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts?.elementAt(index);
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ContactDetailsPage(
                                c,
                                onContactDeviceSave:
                                    contactOnDeviceHasBeenUpdated,
                              )));
                    },
                    leading: (c.avatar != null && c.avatar.length > 0)
                        ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                        : CircleAvatar(child: Text(c.initials())),
                    title: Text(c.displayName ?? ""),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

 */
