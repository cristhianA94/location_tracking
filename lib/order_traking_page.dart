import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracking/keys/constants.dart';

class OrderTrakingPage extends StatefulWidget {
  OrderTrakingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrakingPage> createState() => _OrderTrakingPageState();
}

class _OrderTrakingPageState extends State<OrderTrakingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(-4.0134, -79.2037);
  static const LatLng destination =
      LatLng(-4.010656065515219, -79.20393187149583);
  LocationData? currentLocation;

  List<LatLng> polylineCoordinates = [];

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    getCurrentLocation();
    setCustomMarkerIcon();
    getPolyLinePoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: currentLocation != null
          ? GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 13.5,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              // TODO Trazar lineas
              polylines: {
                Polyline(
                  polylineId: const PolylineId('routes'),
                  points: polylineCoordinates,
                  color: Theme.of(context).primaryColor,
                  width: 8,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  icon: currentLocationIcon,
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                Marker(
                  markerId: MarkerId('source'),
                  icon: sourceIcon,
                  position: sourceLocation,
                ),
                Marker(
                  icon: destinationIcon,
                  markerId: MarkerId('destination'),
                  position: destination,
                ),
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToHome,
        child: Icon(Icons.gps_fixed),
      ),
    );
  }

  Future<void> _goToHome() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            zoom: 17),
      ),
    );
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/images/pin_init.png')
        .then((icon) {
      sourceIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/images/pin_fin.jpg')
        .then((icon) {
      destinationIcon = icon;
    });

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/images/pinCurrent.png')
        .then((icon) {
      currentLocationIcon = icon;
    });
  }

  // Obtiene la ruta para trazarla
  Future<void> getPolyLinePoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      setState(() {});
    }
  }

  // Get Current Location
  void getCurrentLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    GoogleMapController _googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLoc.latitude!, newLoc.longitude!),
            zoom: 19,
          ),
        ),
      );
      setState(() {});
    });
  }
}
