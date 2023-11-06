import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({Key? key}) : super(key: key);

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  List<String> prices = []; //initiallizing some values for backend processing
  double taxVal = 1.08875;
  List<Map<String, String?>> userInputVal = [];

  //controllers for user inputs in 3 separate text fields
  TextEditingController taxEditingController = TextEditingController();
  TextEditingController nameEditingController =
      TextEditingController(text: null);
  TextEditingController priceEditingController =
      TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(
        //appbar
        title: const Text('Price Calculator'),
        backgroundColor: const Color.fromARGB(255, 0, 128, 128),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              top: 3,
              bottom: 0,
              right: 0,
            ),
            child: Row(
              children: [
                SizedBox(
                  height: double.infinity,
                  child: TextButton(
                    //button to confirm tax change in the textfield within app bar
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          color: Color.fromARGB(255, 75, 74, 74),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    onPressed: () {
                      changeTax(taxEditingController.text);
                      taxEditingController.clear();
                    },
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    //textfield that allows user to change tax amount. couldn't figure out how to allow it to change dynamically as users input value like i did with the price text field
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    controller: taxEditingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,4}')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                      hintText:
                          'Tax: ${double.parse((((taxVal - 1) * 100)).toStringAsFixed(5)).toString()}%',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: TextField(
                              //field where user inputs a price
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              maxLines: 1,
                              controller: priceEditingController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                //this is how text field is able to change dynamically as user inputs values
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                                CurrencyTextInputFormatter(
                                  customPattern: '\$###,###,###.##',
                                ),
                              ],
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                border: OutlineInputBorder(),
                                hintText: '\$0.00',
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: TextField(
                              //field where user can input a description
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              maxLines: 1,
                              controller: nameEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                hintText: 'Note [Optional]',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 75,
                    child: TextButton(
                      //button to add the price in the textfield
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(
                          const BorderSide(
                            color: Color.fromARGB(255, 102, 205, 204),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      onPressed: () {
                        addToList(nameEditingController.text,
                            priceEditingController.text);
                        nameEditingController.clear();
                        priceEditingController.clear();
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 75,
                    child: TextButton(
                      //button to clear current list
                      style: ButtonStyle(
                          side: MaterialStateProperty.all(const BorderSide(
                        color: Color.fromARGB(255, 102, 205, 204),
                      ))),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      onPressed: () {
                        clearList();
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      //this is how the user's inputted prices and descriptions are displayed
                      itemCount: userInputVal.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            '${prices[index].padRight(30 - prices[index].length, ' ')} ${userInputVal[index][prices[index]]}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          trailing: TextButton(
                            //a button that is displayed at every index of a list. will remove that item when pressed
                            style: ButtonStyle(
                              side: MaterialStateProperty.all(
                                const BorderSide(
                                  color: Color.fromARGB(255, 102, 205, 204),
                                ),
                              ),
                            ),
                            onPressed: () {
                              removeIndex(index);
                            },
                            child: const Text(
                              'Remove',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    //this is where total before and after taxes are displayed
                    width: double.infinity,
                    height: 100,
                    color: const Color.fromARGB(255, 0, 128, 128),
                    alignment: AlignmentDirectional.bottomCenter,
                    child: Column(children: [
                      Text(
                          style: const TextStyle(
                            fontSize: 40,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          'Before Tax: \$${beforeTax()}'),
                      Text(
                          style: const TextStyle(
                            fontSize: 40,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          'Total: \$${afterTax()}'),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  changeTax(String taxNum) {
    setState(() {
      taxVal = strToDouble(taxNum) + 1;
    });
  }

  double strToDouble(String input) {
    input = input.replaceAll('r[%,]', '');
    double result = double.tryParse(input) ?? 0.0;
    return result /
        100; // If parsing fails, return a default value (0.0 in this case)
  }

  addToList(String? name, String price) {
    //When "Add" button is pressed, add price and description to both lists. NEEDS price but not description
    if (price.isNotEmpty) {
      setState(() {
        userInputVal.add({price: name});
        prices.add(price);
      });
    }
  }

  removeIndex(int index) {
    //remove specific item from list when button is pressed. will be next to every item of the list
    setState(() {
      userInputVal.removeAt(index);
      prices.removeAt(index);
    });
  }

  void clearList() {
    //completely clears list when button is pressed
    setState(() {
      userInputVal.clear();
      prices.clear();
    });
  }

  double calcTotal() {
    double total = 0;
    for (String i in prices) {
      total += double.parse(i.replaceAll(RegExp(r'[,.$]'), '')) / 100;
    }
    return total;
  }

  String beforeTax() {
    List<String> ans = [];
    ans = double.parse((calcTotal()).toStringAsFixed(2)).toString().split('.');
    if (ans[1].length < 2) {
      return '${ans[0]}.${ans[1]}0';
    }
    return double.parse((calcTotal()).toStringAsFixed(2)).toString();
  }

  String afterTax() {
    //calculates total after tax
    List<String> ans = [];
    ans = double.parse((calcTotal() * taxVal).toStringAsFixed(2))
        .toString()
        .split('.');
    if (ans[1].length < 2) {
      return '${ans[0]}.${ans[1]}0';
    }
    return double.parse((calcTotal() * taxVal).toStringAsFixed(2)).toString();
  }
}
