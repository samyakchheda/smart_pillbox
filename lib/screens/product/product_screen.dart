import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../helpers/email_service.dart';
import '../../helpers/pdf_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late Razorpay _razorpay;
  String userName = '';
  String email = '';
  late User currentUser;
  bool _isLoading = true;

  final Map<String, dynamic> product = {
    'name': 'Smart Pillbox',
    'price': 1999,
    'features': [
      'Automatic Dispensing',
      'Reminder Alerts',
      'Mobile App Integration',
      'Secure Locking Mechanism',
      'Multiple Compartments'
    ],
    'description':
        'The Smart Pillbox is an innovative device designed to help you manage your medications effectively. With features like automatic dispensing, reminder alerts, and mobile app integration, it ensures you never miss a dose. The secure locking mechanism and multiple compartments provide added safety and organization for all your medications.',
    'imageUrl': 'https://m.media-amazon.com/images/I/71quMCa8PEL.jpg',
  };

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _initializeUser();
  }

  Future<void> _initializeUser() async {
    currentUser = FirebaseAuth.instance.currentUser!;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc['name'];
        email = userDoc['email'];
        _isLoading = false;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    PdfService.generatePdf(product, userName, 'N/A').then((file) {
      EmailService.sendEmail(email, file);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Successful!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment Failed!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _startPayment() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var options = {
        'key': 'rzp_test_BM4Uum7jvmrFBX',
        'amount': product['price'] * 100,
        'name': 'Product Checkout',
        'description': product['name'],
        'prefill': {'email': email},
      };
      _razorpay.open(options);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(product['name'],
                        style: const TextStyle(color: Colors.white)),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue, Colors.indigo],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            product['imageUrl'],
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '₹${product['price']}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Key Features',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        ...product['features'].map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.blue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: 24),
                        Text(
                          'Description',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product['description'],
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: ElevatedButton(
                            onPressed: _startPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Buy Now - ₹${product['price']}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
