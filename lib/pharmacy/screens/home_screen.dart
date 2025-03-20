import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../models/pharmacy_model.dart';
import 'message_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> pharmacies;
  final MapController mapController;

  const HomeScreen({
    Key? key,
    required this.pharmacies,
    required this.mapController,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<dynamic> _pharmacies = [];
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Initialize Animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward(); // Start the animation

    _initData();
  }

  void _initData() {
    setState(() {
      _pharmacies = widget.pharmacies;
    });
    _addPharmacyMarkers();
  }

  void _addPharmacyMarkers({int retryCount = 0}) async {
    try {
      for (var pharmacy in _pharmacies) {
        await widget.mapController.addMarker(
          GeoPoint(latitude: pharmacy.lat, longitude: pharmacy.lon),
          markerIcon: MarkerIcon(
            icon: const Icon(Icons.location_on, color: Colors.red, size: 48),
          ),
        );
      }
    } catch (e) {
      if (retryCount < 5) {
        // Retry up to 5 times
        await Future.delayed(const Duration(milliseconds: 500));
        _addPharmacyMarkers(retryCount: retryCount + 1);
      } else {
        print("Failed to add markers after multiple attempts: $e");
      }
    }
  }

  void _searchPharmacy(String query) {
    final filteredPharmacies = widget.pharmacies
        .where((pharmacy) =>
            pharmacy.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _pharmacies = filteredPharmacies;
    });
    _addPharmacyMarkers();
  }

  void _openMessageScreen(Pharmacy pharmacy, String messageType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MessageScreen(pharmacy: pharmacy, messageType: messageType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-Screen Gradient Background
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.buttonColor,
                  Colors.grey.shade400,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content with overlapping white background
          Column(
            children: [
              // Header with Gradient (Fixed Height)
              Container(
                height: 150,
                alignment: Alignment.center,
                child: Text(
                  'Nearby Pharmacies',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              // Expanded section with fixed map and scrollable list
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Fixed map container
                      Container(
                        margin: const EdgeInsets.all(16),
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildMap(),
                      ),
                      // Scrollable pharmacy list
                      Expanded(child: _buildPharmacyList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: OSMFlutter(
        controller: widget.mapController,
        osmOption: OSMOption(
          enableRotationByGesture: true,
          userTrackingOption: UserTrackingOption(
            enableTracking: false,
            unFollowUser: true,
          ),
          zoomOption: const ZoomOption(
            initZoom: 17,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildPharmacyList() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search box (fixed at the top of the list)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for a pharmacy',
                        prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: _searchPharmacy,
                    ),
                  ),
                  // Expanded scrollable list for pharmacies
                  Expanded(
                    child: ListView.builder(
                      // Calculate the total number of items (list items + dividers)
                      itemCount: _pharmacies.length * 2 - 1,
                      itemBuilder: (context, index) {
                        if (index.isOdd) {
                          // For odd indices, return a Divider widget.
                          return const Divider(
                            height: 1,
                            color: Colors.grey,
                          );
                        } else {
                          // For even indices, calculate the real index in the pharmacies list.
                          final realIndex = index ~/ 2;
                          final pharmacy = _pharmacies[realIndex];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue[800],
                              child: const Icon(Icons.local_pharmacy,
                                  color: Colors.white),
                            ),
                            title: Text(
                              pharmacy.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(pharmacy.phoneNumber),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(FontAwesomeIcons.whatsapp,
                                      color: Colors.green),
                                  onPressed: () =>
                                      _openMessageScreen(pharmacy, 'WhatsApp'),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.sms, color: Colors.blue),
                                  onPressed: () =>
                                      _openMessageScreen(pharmacy, 'SMS'),
                                ),
                              ],
                            ),
                            onTap: () {
                              widget.mapController.moveTo(
                                GeoPoint(
                                    latitude: pharmacy.lat,
                                    longitude: pharmacy.lon),
                                animate: true,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
