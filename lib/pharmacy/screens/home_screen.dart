import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
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
  TextEditingController _searchController = TextEditingController();
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
        await Future.delayed(
            const Duration(milliseconds: 500)); // Wait before retrying
        _addPharmacyMarkers(
            retryCount: retryCount + 1); // Retry with increased count
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
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _buildMap(),
                  ),
                  Expanded(
                    child: _buildPharmacyList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Nearby Pharmacies',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
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
              child: ListView.builder(
                itemCount: _pharmacies.length,
                itemBuilder: (context, index) {
                  final pharmacy = _pharmacies[index];
                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) =>
                              _openMessageScreen(pharmacy, 'WhatsApp'),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.chat_outlined,
                          label: 'WhatsApp',
                        ),
                        SlidableAction(
                          onPressed: (context) =>
                              _openMessageScreen(pharmacy, 'SMS'),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.sms,
                          label: 'SMS',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        pharmacy.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(pharmacy.phoneNumber),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[800],
                        child: const Icon(Icons.local_pharmacy,
                            color: Colors.white),
                      ),
                      onTap: () {
                        widget.mapController.moveTo(
                          GeoPoint(
                            latitude: pharmacy.lat,
                            longitude: pharmacy.lon,
                          ),
                          animate: true,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
