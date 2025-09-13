import 'package:calculator/buttons.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var userInput = '';
  var result = '';
  bool isResultDisplayed = false; // flag to track if last action was '='

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            userInput,
                            style: const TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          result.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Buttons(
                            text: 'AC',
                            onPress: () {
                              userInput = '';
                              result = '';
                              isResultDisplayed = false;
                              setState(() {});
                            },
                            color: const Color(0xffffa00a),
                          ),
                          Buttons(
                            text: 'Del',
                            onPress: () {
                              if (userInput.isNotEmpty) {
                                userInput = userInput.substring(0, userInput.length - 1);
                              }
                              setState(() {});
                            },
                            color: const Color(0xffffa00a),
                          ),
                          Buttons(
                            text: '%',
                            onPress: () => applyPercentage(),
                            color: const Color(0xffffa00a),
                          ),
                          Buttons(
                            text: '/',
                            onPress: () => appendInput('/'),
                            color: const Color(0xffffa00a),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Buttons(text: '7', onPress: () => appendInput('7')),
                          Buttons(text: '8', onPress: () => appendInput('8')),
                          Buttons(text: '9', onPress: () => appendInput('9')),
                          Buttons(
                            text: 'x',
                            onPress: () => appendInput('x'),
                            color: const Color(0xffffa00a),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Buttons(text: '4', onPress: () => appendInput('4')),
                          Buttons(text: '5', onPress: () => appendInput('5')),
                          Buttons(text: '6', onPress: () => appendInput('6')),
                          Buttons(
                            text: '-',
                            onPress: () => appendInput('-'),
                            color: const Color(0xffffa00a),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Buttons(text: '1', onPress: () => appendInput('1')),
                          Buttons(text: '2', onPress: () => appendInput('2')),
                          Buttons(text: '3', onPress: () => appendInput('3')),
                          Buttons(
                            text: '+',
                            onPress: () => appendInput('+'),
                            color: const Color(0xffffa00a),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Buttons(text: '0', onPress: () => appendInput('0')),
                          Buttons(text: '00', onPress: () => appendInput('00')),
                          Buttons(text: '.', onPress: () => appendInput('.')),
                          Buttons(
                            text: '=',
                            onPress: () {
                              onEqualPress();
                            },
                            color: const Color(0xffffa00a),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Append input safely
  void appendInput(String value) {
    if (isResultDisplayed) {
      userInput = result; // continue from last result
      isResultDisplayed = false;
    }
    userInput += value;
    setState(() {});
  }

  // ✅ Percentage logic (contextual like Android/iOS calculators)
  void applyPercentage() {
    if (userInput.isEmpty) return;

    final operatorRegex = RegExp(r'[\+\-x\/]');
    final lastOperatorMatch = operatorRegex.allMatches(userInput).isNotEmpty
        ? operatorRegex.allMatches(userInput).last
        : null;

    if (lastOperatorMatch != null) {
      final operator = lastOperatorMatch.group(0)!;
      final leftPart = userInput.substring(0, lastOperatorMatch.start);
      final rightPart = userInput.substring(lastOperatorMatch.end);

      if (rightPart.isNotEmpty) {
        final baseValue = double.tryParse(leftPart) ?? 0;
        final percentValue = double.tryParse(rightPart) ?? 0;

        double calculatedPercent;

        switch (operator) {
          case '+':
          case '-':
            // 200 + 10% = 200 + (200 * 0.1)
            calculatedPercent = (baseValue * percentValue) / 100;
            break;
          case 'x':
            // 200 x 10% = 200 x 0.1
            calculatedPercent = percentValue / 100;
            break;
          case '/':
            // 200 ÷ 10% = 200 ÷ 0.1
            calculatedPercent = percentValue / 100;
            break;
          default:
            calculatedPercent = percentValue;
        }

        userInput = "$leftPart$operator$calculatedPercent";
      }
    } else {
      // No operator → just convert last number to % (divide by 100)
      final regex = RegExp(r'(\d+\.?\d*)$');
      final match = regex.firstMatch(userInput);

      if (match != null) {
        final numberStr = match.group(0)!;
        final number = double.parse(numberStr) / 100;

        userInput = userInput.replaceRange(
          match.start,
          match.end,
          number.toString(),
        );
      }
    }

    // ✅ Show result immediately after percentage
    onEqualPress();
  }

  // ✅ Equal logic
  void onEqualPress() {
    try {
      String finalUserInput = userInput.replaceAll('x', '*');
      Parser p = Parser();
      Expression exp = p.parse(finalUserInput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      result = eval.toString();
      isResultDisplayed = true; // mark result showing
    } catch (e) {
      result = "Error";
    }
    setState(() {});
  }
}
