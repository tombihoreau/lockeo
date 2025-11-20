import 'package:flutter/material.dart';
import '../models/offerDraft.dart';
import '../widgets/button.dart';

class CreateOfferSummary extends StatefulWidget {
  final OfferDraft draft;

  const CreateOfferSummary({super.key, required this.draft});

  @override
  State<CreateOfferSummary> createState() => _CreateOfferSummaryState();
}

class _CreateOfferSummaryState extends State<CreateOfferSummary> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    );
  }
  
}
