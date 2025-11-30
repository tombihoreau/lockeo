import 'package:flutter/material.dart';

class ReservationPaymentScreen extends StatelessWidget {
  const ReservationPaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Payment'),
      ),
      body: Center(
        child: const Text('Reservation Payment Screen'),
      ),
    );
  }
}