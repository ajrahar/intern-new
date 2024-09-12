import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class WebLauncherHomePage extends StatefulWidget {
  const WebLauncherHomePage({super.key});

  @override
  _WebLauncherHomePageState createState() => _WebLauncherHomePageState();
}

class _WebLauncherHomePageState extends State<WebLauncherHomePage> {
  final List<Map<String, dynamic>> _links = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  Color _selectedColor = Colors.blue;
  int? _editingIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Link',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F172A),
        leading: _editingIndex != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _cancelEdit,
              )
            : null,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(labelText: 'Link'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a link';
                      } else if (!value.contains('.')) {
                        return 'Please enter a valid link with a "."';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickColor,
                    child: const Text('Pick Card Color'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveLink,
                    child: Text(
                        _editingIndex == null ? 'Add Link' : 'Update Link'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _links.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_links[index]['title']),
                    subtitle: Text(_links[index]['link']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editLink(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteLink(index),
                        ),
                      ],
                    ),
                    onTap: () => _launchLink(_links[index]['link']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickColor() async {
    Color pickedColor = await showDialog(
      context: context,
      builder: (context) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop(tempColor);
              },
            ),
          ],
        );
      },
    );

    setState(() {
      _selectedColor = pickedColor;
    });
  }

  void _saveLink() {
    if (_formKey.currentState!.validate()) {
      final newLink = {
        'title': _titleController.text,
        'link': _linkController.text,
        'color': _selectedColor.value,
      };

      setState(() {
        if (_editingIndex == null) {
          _links.add(newLink);
        } else {
          _links[_editingIndex!] = newLink;
          _editingIndex = null;
        }
      });
      String uniqueId = generateUniqueId();
      _saveTitleToSharedPreferences(
          uniqueId, _titleController.text, _linkController.text, _selectedColor.value);

      _titleController.clear();
      _linkController.clear();
      _selectedColor = Colors.blue;

      // Send the updated list back to HomeScreen
      Navigator.pop(context, _links);
    }
  }

  void _editLink(int index) {
    setState(() {
      _titleController.text = _links[index]['title'];
      _linkController.text = _links[index]['link'];
      _selectedColor = Color(_links[index]['color']);
      _editingIndex = index;
    });
  }

  void _deleteLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
  }

  void _launchLink(String url) async {
    // Add https:// if missing
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _titleController.clear();
      _linkController.clear();
      _selectedColor = Colors.blue;
    });
  }

  _saveTitleToSharedPreferences(String id, String title, String link, int color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Menyimpan title, link key unik
    await prefs.setString('title_$id', title);
    await prefs.setString('link_$id', link);
    await prefs.setInt('color_$id', color);
  }

  String generateUniqueId() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();

    // Generate a 6-character string from the chars list
    String id = List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join('');

    return id;
  }
}