import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String output = '0';
  String _output = '0';
  double num1 = 0;
  double num2 = 0;
  String operand = '';

  // Button press logic
  bool isResultDisplayed = false;

  String temperature = 'Fetching...';

  static const String apiKey = '1d9d9b4e77b8f27871b3006d741fff1a';
  static const String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';


  Future<double?> fetchTemperatureByCityId(int cityId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?id=$cityId&appid=$apiKey&units=metric'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['main']['temp'] as double?;
      } else {
        print('Failed to fetch temperature');
        return null;
      }
    } catch (e) {
      print('Error fetching temperature: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTemperatureByCityId(1283240).then((temp) {
      setState(() {
        temperature = temp != null ? '$temp°C' : 'Error';
      });
    });
  }

  void _buttonPressed(String btntxt) {
    setState(() {
      if (RegExp(r'[0-9.]').hasMatch(btntxt)) {
        // Handle numbers and decimal point
        if (isResultDisplayed) {
          _output = btntxt == "." ? "0." : btntxt;
          isResultDisplayed = false;
        } else {
          if (btntxt == "." && _output.contains(".")) return; //to prevent addition of multiple decimal
          _output = _output == "0" && btntxt != "." ? btntxt : _output + btntxt;
        }
        output = _output;
      } else if (btntxt == "AC") {
        // Clear everything
        output = '0';
        _output = '0';
        num1 = 0;
        num2 = 0;
        operand = '';
      } else if (btntxt == "+/-") {
        // Change sign
        if (_output != "0") {
          if (_output.startsWith("-")) {
            _output = _output.substring(1);
          } else {
            _output = "-$_output";
          }
        }
        output = _output;
      } else if (btntxt == "%") {
        // Percentage
        if (_output != "0") {
          _output = (double.parse(_output) / 100).toString();
          output = _output.endsWith(".0") ? _output.split(".")[0] : _output;
        }
      } else if (RegExp(r'[+-×÷]').hasMatch(btntxt)) {
        // Operator
        if (operand.isNotEmpty) {
          num2 = double.parse(_output);
          _output = _calculate().toString();
          output = _output.endsWith(".0") ? _output.split(".")[0] : _output;
        }
        num1 = double.parse(output);
        operand = btntxt;
        _output = "0";
      } else if (btntxt == "=") {
        // Equals
        if (operand.isNotEmpty) {
          num2 = double.parse(_output);
          _output = _calculate().toString();
          output = _output.endsWith(".0") ? _output.split(".")[0] : _output;
          operand = '';
          isResultDisplayed = true;
        }
      }
    });
  }

  double _calculate() {
    switch (operand) {
      case "+":
        return num1 + num2;
      case "-":
        return num1 - num2;
      case "×":
        return num1 * num2;
      case "÷":
        return num2 != 0 ? num1 / num2 : double.infinity;
      default:
        return num1;
    }
  }

  Widget Cbuttons(String btntxt, Color btncolor, Color txtcolor) {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          _buttonPressed(btntxt);
        },
        child: Text(
          btntxt,
          style: TextStyle(color: txtcolor, fontSize: 29),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: btncolor,
          shape: CircleBorder(),
          fixedSize: Size(90, 90),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Calculator", style: TextStyle(color: Colors.white)),
            Text('Temp(Ktm): $temperature', style: TextStyle(color: Colors.white))
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 24, 0),
                child: Text(
                  output.length > 10 ? output.substring(0, 10) : output,
                  style: TextStyle(color: Colors.white, fontSize: 100),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Cbuttons('AC', Colors.grey, Colors.black),
              Cbuttons('+/-', Colors.grey, Colors.black),
              Cbuttons('%', Colors.grey, Colors.black),
              Cbuttons('÷', Colors.orange, Colors.white),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Cbuttons('7', Colors.grey[850]!, Colors.white),
              Cbuttons('8', Colors.grey[850]!, Colors.white),
              Cbuttons('9', Colors.grey[850]!, Colors.white),
              Cbuttons('×', Colors.orange, Colors.white),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Cbuttons('4', Colors.grey[850]!, Colors.white),
              Cbuttons('5', Colors.grey[850]!, Colors.white),
              Cbuttons('6', Colors.grey[850]!, Colors.white),
              Cbuttons('-', Colors.orange, Colors.white),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Cbuttons('1', Colors.grey[850]!, Colors.white),
              Cbuttons('2', Colors.grey[850]!, Colors.white),
              Cbuttons('3', Colors.grey[850]!, Colors.white),
              Cbuttons('+', Colors.orange, Colors.white),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _buttonPressed('0'),
                child: Text(
                  '0',
                  style: TextStyle(color: Colors.white, fontSize: 35),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850]!,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.fromLTRB(34, 19, 128, 19),
                ),
              ),
              Cbuttons('.', Colors.grey[850]!, Colors.white),
              Cbuttons('=', Colors.orange, Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}