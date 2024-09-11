import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ParkedCar {
  final String id;
  final String carNumber;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  ParkedCar(
      {required this.id,
      required this.carNumber,
      required this.firstName,
      required this.lastName,
      required this.createdAt});

  factory ParkedCar.fromJson(Map<String, dynamic> json) {
    return ParkedCar(
      id: json['_id'],
      carNumber: json['carNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AddCar extends StatefulWidget {
  const AddCar({super.key});

  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  final _carNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  List<ParkedCar> _parkedCars = [];
  late double _hourlyRate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    print("FETCH DATA START");
    try {
      // Fetch parked cars
      final parkedCarsResponse =
          await http.get(Uri.parse('http://localhost:3000/car'));
      print("COMING DATA ${jsonDecode(parkedCarsResponse.body)}");
      final List<dynamic> parkedCarsJson = jsonDecode(parkedCarsResponse.body);
      setState(() {
        _parkedCars =
            parkedCarsJson.map((json) => ParkedCar.fromJson(json)).toList();
      });

      // Fetch hourly rate
      final rateResponse =
          await http.get(Uri.parse('http://localhost:3000/rate'));
      final rateJson = jsonDecode(rateResponse.body);
      setState(() {
        _hourlyRate = rateJson['rate'];
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _addCar() async {
    final carNumber = _carNumberController.text;
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    if (carNumber.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/car'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'carNumber': carNumber,
            'firstName': firstName,
            'lastName': lastName
          }),
        );

        if (response.statusCode == 201) {
          _fetchData();
        } else {
          print('Failed to add car: ${response.body}');
        }
      } catch (e) {
        print('Error adding car: $e');
      } finally {
        _carNumberController.clear();
        _firstNameController.clear();
        _lastNameController.clear();
      }
    }
  }

  Future<void> _stopParking(String carId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final car = _parkedCars.firstWhere((car) => car.id == carId);
        final formattedTime =
            DateFormat('yyyy-MM-dd – kk:mm').format(car.createdAt);
        final amountToPay = _calculateAmount(car.createdAt);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          title: Text('Payment Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Car Number: ${car.carNumber}'),
              Text('Parked at: $formattedTime'),
              SizedBox(height: 16.0),
              Text('Amount to Pay: \$${amountToPay.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                try {
                  // Delete the car
                  final deleteResponse = await http.delete(
                    Uri.parse('http://localhost:3000/car/$carId'),
                  );

                  if (deleteResponse.statusCode == 200) {
                    // Create a punishment record
                    final punishmentResponse = await http.post(
                      Uri.parse('http://localhost:3000/punish'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'firstName': car.firstName,
                        'lastName': car.lastName,
                        'parkedAt': car.createdAt.toIso8601String(),
                        'carNumber': car.carNumber
                      }),
                    );

                    if (punishmentResponse.statusCode == 200) {
                      // Successfully handled both actions
                      await _fetchData();
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/punish");
                    } else {
                      print(
                          'Failed to create punishment: ${punishmentResponse.body}');
                    }
                  } else {
                    print(
                        'Failed to delete parked car: ${deleteResponse.body}');
                  }
                } catch (e) {
                  print('Error stopping parking: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle:
                    TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                backgroundColor: Color.fromARGB(255, 218, 8, 61),
              ),
              child: Text("Refuse"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Delete the car
                  final deleteResponse = await http.delete(
                    Uri.parse('http://localhost:3000/car/$carId'),
                  );

                  if (deleteResponse.statusCode == 200) {
                    await _fetchData();
                    Navigator.of(context).pop();
                  } else {
                    print(
                        'Failed to delete parked car: ${deleteResponse.body}');
                  }
                } catch (e) {
                  print('Error stopping parking: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                textStyle:
                    TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                backgroundColor: Color.fromARGB(255, 18, 228, 25),
              ),
              child: Text("Pay"),
            ),
          ],
        );
      },
    );
  }

  double _calculateAmount(DateTime parkedTime) {
    final now = DateTime.now();
    final duration = now.difference(parkedTime);
    final hours = duration.inHours + duration.inMinutes % 60 / 60.0;
    return hours * _hourlyRate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Car",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 4, 97, 7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/punish"),
            icon: Icon(Icons.person_off_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, "/rate"),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 18, 228, 25),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "First Name",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16.0,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _carNumberController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Car Number",
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: _addCar,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w900),
                      backgroundColor: Color.fromARGB(255, 218, 8, 61),
                    ),
                    child: Text("Park"),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _parkedCars.length,
                  itemBuilder: (context, index) {
                    final car = _parkedCars[index];
                    final formattedTime =
                        DateFormat('yyyy-MM-dd – kk:mm').format(car.createdAt);
                    return ListTile(
                      title: Text(car.carNumber,
                          style: TextStyle(color: Colors.white)),
                      subtitle: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('First Name: ${car.firstName}',
                              style: TextStyle(color: Colors.white70)),
                          SizedBox(
                            width: 16.0,
                          ),
                          Text('Last Name: ${car.lastName}',
                              style: TextStyle(color: Colors.white70)),
                          SizedBox(
                            width: 16.0,
                          ),
                          Text('Parked at: $formattedTime',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _stopParking(car.id),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color.fromARGB(255, 218, 8, 61),
                        ),
                        child: Text("Stop"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
