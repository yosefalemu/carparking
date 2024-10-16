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

  ParkedCar({
    required this.id,
    required this.carNumber,
    required this.firstName,
    required this.lastName,
    required this.parkedAt,
    required this.createdAt,
  });

  factory ParkedCar.fromJson(Map<String, dynamic> json) {
    return ParkedCar(
      id: json['_id'],
      carNumber: json['carNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      parkedAt: DateTime.parse(json['parkedAt']),
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
  double _hourlyRate = 0.0; // Initialize with a default value

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    print("FETCH DATA START");
    try {
      // Fetch parked cars
      final parkedCarsResponse = await http
          .get(Uri.parse('https://carparking-rfuc.vercel.app/punish'));
      print("COMING DATA ${jsonDecode(parkedCarsResponse.body)}");
      final List<dynamic> parkedCarsJson = jsonDecode(parkedCarsResponse.body);
      setState(() {
        _parkedCars =
            parkedCarsJson.map((json) => ParkedCar.fromJson(json)).toList();
      });

      // Fetch hourly rate
      final rateResponse =
          await http.get(Uri.parse('https://carparking-rfuc.vercel.app/rate'));
      final rateJson = jsonDecode(rateResponse.body);
      print("RATE JSON $rateJson");

      // Extract the rate value from the JSON response, handling potential nulls
      final hourlyRate =
          rateJson['rate'] ?? 0.0; // Use a default value if rate is not found

      // Convert the rate to a double if it's an int
      _hourlyRate = hourlyRate is int ? hourlyRate.toDouble() : hourlyRate;

      setState(() {
        _hourlyRate = hourlyRate;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  double _calculateAmount(DateTime parkedTime) {
    final now = DateTime.now();
    final duration = now.difference(parkedTime);
    final hours = duration.inHours + duration.inMinutes % 60 / 60.0;
    print("duration: $duration");
    print("horlyRate $_hourlyRate");
    final baseFee = 100;
    return hours * _hourlyRate + baseFee;
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          title: const Text('Payment Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Car Number: ${car.carNumber}'),
              Text('Parked at: $formattedTime'),
              const SizedBox(height: 16.0),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w900),
                    backgroundColor: const Color.fromARGB(255, 218, 8, 61),
                  ),
                  child: const Text("Cancel"),
                ),
                SizedBox(
                  width: 16.0,
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Delete the car
                      final deleteResponse = await http.delete(
                        Uri.parse(
                            'https://carparking-rfuc.vercel.app/punish/$carId'),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    textStyle: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w900),
                    backgroundColor: const Color.fromARGB(255, 18, 228, 25),
                  ),
                  child: const Text("Pay"),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Punished Car"),
        backgroundColor: const Color.fromARGB(255, 4, 97, 7),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(255, 18, 228, 25),
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _parkedCars.length,
                itemBuilder: (context, index) {
                  final car = _parkedCars[index];
                  final formattedTime =
                      DateFormat('yyyy-MM-dd – kk:mm').format(car.createdAt);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    color: const Color.fromARGB(255, 29, 149, 33),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.carNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'First Name: ${car.firstName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Last Name: ${car.lastName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Parked at: $formattedTime',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              onPressed: () => _stopParking(car.id),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 218, 8, 61),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 12.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                "Stop",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        ],
                      ),
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
