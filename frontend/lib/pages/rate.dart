import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Rate extends StatefulWidget {
  const Rate({super.key});

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {
  final _rateController = TextEditingController();
  double _currentRate = 5.0;

  @override
  void initState() {
    super.initState();
    _fetchCurrentRate();
  }

  Future<void> _fetchCurrentRate() async {
    try {
      final response =
          await http.get(Uri.parse('https://carparking-rfuc.vercel.app/rate'));
      if (response.statusCode == 200) {
        final rateJson = jsonDecode(response.body);
        setState(() {
          // Handle both int and double types for rate
          _currentRate = (rateJson['rate'] is int)
              ? (rateJson['rate'] as int).toDouble()
              : (rateJson['rate'] as double);
          _rateController.text = _currentRate.toStringAsFixed(2);
        });
      } else {
        print(
            "Failed to fetch rate: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Error fetching current rate: $e');
    }
  }

  void addRate() {
    final rateString = _rateController.text;
    if (rateString.isEmpty) {
      print("RATE REQUIRED");
      return;
    }

    final rate = double.tryParse(rateString);
    if (rate == null || rate <= 0) {
      print("INVALID RATE");
      return;
    }

    print("RATE FOUND $rate");
    _updateRate(rate);
  }

  Future<void> _updateRate(double rate) async {
    try {
      final response = await http.post(
        Uri.parse('https://carparking-rfuc.vercel.app/rate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rate': rate}),
      );

      if (response.statusCode == 200) {
        print("Rate updated successfully");
        // Fetch the updated rate to reflect changes
        await _fetchCurrentRate();
      } else {
        print(
            "Failed to update rate: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error updating rate: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RATE"),
        backgroundColor: const Color.fromARGB(255, 4, 97, 7),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromARGB(255, 18, 228, 25),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _rateController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: "Hourly Rate",
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
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  ElevatedButton(
                    onPressed: addRate,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40.0, vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w900),
                      backgroundColor: const Color.fromARGB(255, 218, 8, 61),
                    ),
                    child: const Text("Change rate"),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Current Rate: \$${_currentRate.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
