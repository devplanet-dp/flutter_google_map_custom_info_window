import 'package:flutter/material.dart';
import 'package:flutter_google_map/model/pin_data.dart';
import 'package:flutter_google_map/util/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  GoogleMapController _controller;
  Position position;

  Widget _child = Center(
    child: Text('Loading...'),
  );
  BitmapDescriptor _sourceIcon;

  double _pinPillPosition = -100;

  PinData _currentPinData = PinData(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);

  PinData _sourcePinInfo;

  void _setSourceIcon() async {
    _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/pin.png');
  }

  Future<void> getPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.location);

    if (permission == PermissionStatus.denied) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.locationAlways]);
    }

    var geolocator = Geolocator();

    GeolocationStatus geolocationStatus =
        await geolocator.checkGeolocationPermissionStatus();

    switch (geolocationStatus) {
      case GeolocationStatus.denied:
        showToast('Access denied');
        break;
      case GeolocationStatus.disabled:
        showToast('Disabled');
        break;
      case GeolocationStatus.restricted:
        showToast('restricted');
        break;
      case GeolocationStatus.unknown:
        showToast('Unknown');
        break;
      case GeolocationStatus.granted:
        showToast('Accesss Granted');
        _getCurrentLocation();
    }
  }

  void _getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _child = _mapWidget();
    });
  }

  void _setStyle(GoogleMapController controller) async {
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');

    controller.setMapStyle(value);
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('home'),
          position: LatLng(position.latitude, position.longitude),
          icon: _sourceIcon,
          onTap: () {
            setState(() {
              _currentPinData = _sourcePinInfo;
              _pinPillPosition = 0;
            });
          })
    ].toSet();
  }

  void showToast(message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  void initState() {
    getPermission();
    _setSourceIcon();
    super.initState();
  }

  Widget _mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      markers: _createMarker(),
      initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 12.0),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
        _setStyle(controller);
        _setMapPins();
      },
      tiltGesturesEnabled: false,
      onTap: (LatLng location) {
        setState(() {
          _pinPillPosition = -100;
        });
      },
    );
  }

  void _setMapPins() {
    _sourcePinInfo = PinData(
        pinPath: 'assets/pin.png',
        locationName: "My Location",
        location: LatLng(position.latitude, position.longitude),
        avatarPath: "assets/driver.jpg",
        labelColor: Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _child,
        AnimatedPositioned(
          bottom: _pinPillPosition,
          right: 0,
          left: 0,
          duration: Duration(milliseconds: 200),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(20),
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      blurRadius: 20,
                      offset: Offset.zero,
                      color: Colors.grey.withOpacity(0.5),
                    )
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildAvatar(),
                  _buildLocationInfo(),
                  _buildMarkerType()
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }

  Widget _buildAvatar() {
    return Container(
      margin: EdgeInsets.only(left: 10),
      width: 50,
      height: 50,
      child: ClipOval(
        child: Image.asset(
          _currentPinData.avatarPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _currentPinData.locationName,
              style: CustomAppTheme().data.textTheme.subtitle,
            ),
            Text(
              'Latitude : ${_currentPinData.location.latitude}',
              style: CustomAppTheme().data.textTheme.display1,
            ),
            Text(
              'Longitude : ${_currentPinData.location.longitude}',
              style: CustomAppTheme().data.textTheme.display1,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerType() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Image.asset(
        _currentPinData.pinPath,
        width: 50,
        height: 50,
      ),
    );
  }
}
