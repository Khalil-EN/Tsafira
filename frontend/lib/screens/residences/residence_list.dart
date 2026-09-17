import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/residence.dart';
import 'residence_details.dart';
import 'search_residence.dart';
import '../../services/api_services.dart';
import '../../exceptions/session_expired_exception.dart';
import '../auth/login_screen.dart';


class ResidencesPage extends StatefulWidget {
  final bool isFromSearch;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final String location;
  final double minPrice;
  final double maxPrice;

  const ResidencesPage({
    Key? key,
    this.isFromSearch = false,
    this.location = '',
    this.checkInDate,
    this.checkOutDate,
    this.minPrice = 0,
    this.maxPrice = 0,
  }) : super(key: key);

  @override
  _ResidencesPageState createState() => _ResidencesPageState();
}

class _ResidencesPageState extends State<ResidencesPage> {
  List<Residence> residences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResidences();
  }

  Future<void> _loadResidences() async {
    try {
      List<Map<String, dynamic>> rawData;
      if (widget.isFromSearch) {
        final pdata = {
          'checkInDate': widget.checkInDate != null
              ? DateFormat('yyyy-MM-dd').format(widget.checkInDate!)
              : null,
          'checkOutDate': widget.checkOutDate != null
              ? DateFormat('yyyy-MM-dd').format(widget.checkOutDate!)
              : null,
          'minPrice': widget.minPrice,
          'maxPrice': widget.maxPrice,
          'location': widget.location,
        };
        rawData = await SearchService.searchResidences(pdata);
      } else {
        rawData = await ResidenceService.getAll();
      }

      setState(() {
        residences = rawData.map((json) => Residence.fromJson(json)).toList();
        isLoading = false;
      });
    } on SessionExpiredException {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(showSessionExpired: true),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(
          child: Text(
            'Search Residences',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchResidence()),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: residences.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _residenceCard(context, residences[index]),
        ),
      ),
    );
  }

  Widget _residenceCard(BuildContext context, Residence residence) {
    return GestureDetector(
      onTap: () => _openDetails(context, residence),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                residence.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    residence.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: const [
                            Icon(Icons.bed, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('01 Room'),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: const [
                            Icon(Icons.people, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('02 Guests'),
                          ]),
                        ],
                      ),
                      Text(
                        '~ ${residence.price} MAD',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'View More Details',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _openDetails(context, residence),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Select Option',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, Residence residence) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResidenceDetails(residence: residence),
      ),
    );
  }
}