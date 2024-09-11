import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ParkedCar {
  final String id;
  final String carNumber;
  final String firstName;
  final String lastName;
  final DateTime parkedAt;
  final DateTime createdAt;

  ParkedCar(
      {required this.id,
      required this.carNumber,
      required this.firstName,
      required this.lastName,
      required this.parkedAt,
      required this.createdAt});

  factory ParkedCar.fromJson(Map<String, dynamic> json) {
    return ParkedCar(
      id: json['_id'],
      parkedAt: DateTime.parse(json['parkedAt']),
      carNumber: json['carNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class PunishPage extends StatefulWidget {
  const PunishPage({super.key});

  @override
  State<PunishPage> createState() => _PunishPageState();
}

class _PunishPageState extends State<PunishPage> {
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
          await http.get(Uri.parse('http://localhost:3000/punish'));
      print("COMING DATA ${jsonDecode(parkedCarsResponse.body)}");
      final List<dynamic> parkedCarsJson = jsonDecode(parkedCarsResponse.body);
      setState(() {
        _parkedCars =
            parkedCarsJson.map((json) => ParkedCar.fromJson(json)).toList();
      });
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

  double _calculateAmount(
    DateTime parkedTime,
  ) {
    final now = DateTime.now();
    final duration = now.difference(parkedTime);
    final hours = duration.inHours + duration.inMinutes % 60 / 60.0;
    return hours * _hourlyRate + 100;
  }

  Future<void> _stopParking(String carId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final car = _parkedCars.firstWhere((car) => car.id == carId);
        final formattedTime =
            DateFormat('yyyy-MM-dd – kk:mm').format(car.createdAt);
        final amountToPay = _calculateAmount(car.parkedAt);

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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.w900),
                    backgroundColor: Color.fromARGB(255, 218, 8, 61),
                  ),
                  child: Text("Cancel"),
                ),
                SizedBox(
                  width: 1.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Delete the car
                      final deleteResponse = await http.delete(
                        Uri.parse('http://localhost:3000/punish/$carId'),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
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
            )
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Punished Car"),
        backgroundColor: Color.fromARGB(255, 4, 97, 7),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Color.fromARGB(255, 18, 228, 25),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _parkedCars.length,
                itemBuilder: (context, index) {
                  final car = _parkedCars[index];
                  final formattedTimeForParkedAt =
                      DateFormat('yyyy-MM-dd – kk:mm').format(car.parkedAt);
                  final formattedTimeForCreatedAt =
                      DateFormat('yyyy-MM-dd – kk:mm').format(car.createdAt);
                  return ListTile(
                    title: Text(car.carNumber,
                        style: TextStyle(color: Colors.white)),
                    subtitle: Column(
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
                        Text('Parked at: $formattedTimeForParkedAt',
                            style: TextStyle(color: Colors.white70)),
                        SizedBox(
                          width: 16.0,
                        ),
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
    );
  }
}
