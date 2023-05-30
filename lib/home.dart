import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? paymentIntentData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stripe Payment')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: ElevatedButton(onPressed: ()async {
            await makePayment();
          }, child: Text('Pay Now'))),
        ],
      ),
    );
  }

  Future<void> makePayment()async{
    try{
      paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentData!['client_secret'],

        style: ThemeMode.dark,
        merchantDisplayName: 'Qasim',
      ));
      displayPaymentSheet();
    }
    catch(e)
    {
      print('excaption'+e.toString());
    }
  }
  displayPaymentSheet() async{
    try{
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntentData = null;
      }).onError((error, stackTrace) {
      });
    } on StripeException catch (e) {
      print(e.toString());
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    }
    catch(e){
      print(e.toString());
    }
  }
  createPaymentIntent(String amount, String currency)
  async {
    try{
      Map<String, dynamic> body ={
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer sk_test_51ND25eAt62vCeZNWJZB7Hhp9bzwgwCtoRaKvs5yjApCEcgSnBJKUSXwSjV70OHMqhdDnb7e3Ybg9yKXviLqs1Va100g3tw6e6i',
            'Content-Type': 'application/x-www-form-urlencoded'
          }
      );
      return jsonDecode(response.body.toString());
    }
    catch(e)
    {
      print('excaption'+e.toString());
    }
  }
  calculateAmount(String amount){
    final price = int.parse(amount) * 100;
    return price.toString();
  }
}
