import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const Map());
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home:const HomeActivity(),
    );
  }
}

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  LocationData? currentLocation;
  StreamSubscription? _locationSubscription ;


  void polylineLatLong(){
    var polyline = [ currentLocation!.latitude!, currentLocation!.latitude!];
    print(polyline);
  }



  @override
  void initState() {
    getCurrentLocation();
    listenLocation();
    initialize();
    super.initState();
  }
  void initialize(){
    Location.instance.changeSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      interval: 3000,
    );
  }

  void listenLocation() {
   _locationSubscription =
        Location.instance.onLocationChanged.listen((listenLocation) {
      if (listenLocation != currentLocation) {
        currentLocation = listenLocation;
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void getCurrentLocation() async {
    await Location.instance.hasPermission().then((requestPermission) {
      print(requestPermission);
    });

    Location.instance.getLocation().then((location) {
      currentLocation = location;
    });
    if(mounted){
      setState(() {});
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real time Location Tracker"),
      ),
      body: currentLocation == null
          ? const Center(
              child: Text("Loading"),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                  zoom: 15,
                  bearing: 30,
                  tilt: 15,
                  target: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!)),
              markers: <Marker>{
                Marker(
                    markerId: const MarkerId("current Location"),
                    position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(
                        title: "My current Location ${currentLocation!.latitude!},${currentLocation!.longitude!}"

                    ))
              },
        polylines: <Polyline>{
          Polyline(
              polylineId: const PolylineId("polyline"),
              width: 7,
              jointType: JointType.round,
              color: Colors.deepOrangeAccent,
              points: [

               LatLng(23.797136328033588, 90.37265815091968),
               LatLng(currentLocation!.latitude!, currentLocation!.longitude!),

              ])
        },
            ),
    );
  }
  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
