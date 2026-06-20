import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:razvezi/cookie.dart';
import 'package:razvezi/navigation_bar.dart';
import 'package:razvezi/storage.dart';

String newRouteUrl = "${Connection.adress}create_new_route/";

class NewRouteFormScreen extends StatefulWidget {
  @override
  _NewRouteFormScreenState createState() => _NewRouteFormScreenState();
}

class _NewRouteFormScreenState extends State<NewRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String startLocation = '';
  String endLocation = '';
  final TextEditingController numberController = TextEditingController();
  String? selectedETA;
  int numberOfBoxes = 0;

  Future<void> submitForm() async {
    final url = Uri.parse(newRouteUrl);

    try {
      final cookie = await getCookieFromStorage();
      print(cookie);
      print(numberController);
      print(selectedETA);
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': cookie,
          'X-CSRFToken': await getCSRF(),
        },
        body: jsonEncode({
          'start_location': startLocation,
          'end_location': endLocation,
          'number_of_boxes': numberOfBoxes,
          'eta': selectedETA,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nova ruta',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
      ),
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Pocetna lokacija',
                ),
                validator: (value){
                    if (value == null || value.isEmpty){
                      return "Unesi pocetnu lokaciju";
                    }
                    return null;
                  },
                  onSaved: (value) => startLocation = value!,
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Krajnja lokacija'),
                validator: (value) =>
                  value!.isEmpty ? 'Unesi krajnju lokaciju' : null,
                onSaved: (value) => endLocation = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Broj kutija',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Unesi broj kutija';
                  }

                  final number = int.tryParse(value);

                  if (number == null) {
                    return 'Invalid integer';
                  }
                  else{
                    numberOfBoxes = number;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              ETADropdown(
              selectedValue: selectedETA,
              onChanged: (value) {
                    setState(() {
                      selectedETA = value;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){ if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  submitForm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Sacuvaj'),
                ),
            ],
          ),
        ),
      ),
    );
  }

}

class ETADropdown extends StatelessWidget {
  final String? selectedValue;
  
  final List<String> etaOptions = [
    'Hitno',
    'Sat vremena',
    'Dva sata',
    'Do kraja dana',
  ];

  final ValueChanged<String?> onChanged;

  ETADropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: selectedValue,
      label: const Text('Potrebno za'),
      dropdownMenuEntries: etaOptions.map((item) {
        return DropdownMenuEntry<String>(
          value: item,
          label: item,
        );
      }).toList(),
      onSelected: onChanged,
    );
  }
}