import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wastexchange_mobile/features/home/presentation/bloc/map_bloc.dart';
import 'package:wastexchange_mobile/models/result.dart';
import 'package:wastexchange_mobile/models/ui_state.dart';
import 'package:wastexchange_mobile/models/user.dart';
import 'package:wastexchange_mobile/core/utils/constants.dart';
import 'package:wastexchange_mobile/features/home/presentation/widgets/seller_item_bottom_sheet.dart';
import 'package:wastexchange_mobile/features/home/presentation/widgets/drawer_view.dart';
import 'package:wastexchange_mobile/core/widgets/error_view.dart';
import 'package:wastexchange_mobile/core/widgets/loading_progress_indicator.dart';
import 'package:wastexchange_mobile/core/widgets/menu_app_bar.dart';

// TODO(Sayeed): Extract all map related logic to its own class
class MapScreen extends StatefulWidget {
  static const routeName = '/mapScreen';
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapScreen> {
  GoogleMapController _mapController;
  static const double _mapPinHue = 200.0;
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  String _errorMessage = Constants.GENERIC_ERROR_MESSAGE;

  final SellerItemBottomSheet _bottomSheet =
      SellerItemBottomSheet(seller: null);
  static const double _bottomSheetMinHeight = 120.0;

  static final _initialCameraPosition = CameraPosition(
    target: const LatLng(Constants.CHENNAI_LAT, Constants.CHENNAI_LONG),
  );

  static final _animateCameraTo = CameraUpdate.newLatLngZoom(
      const LatLng(Constants.CHENNAI_LAT, Constants.CHENNAI_LONG),
      Constants.DEFAULT_MAP_ZOOM);

  UIState _uiState = UIState.LOADING;
  MapBloc _bloc;

  @override
  void initState() {
    _bloc = MapBloc();
    _bloc.allUsersStream.listen((_snapshot) {
      switch (_snapshot.status) {
        case Status.LOADING:
          setState(() {
            _uiState = UIState.LOADING;
          });
          break;
        case Status.ERROR:
          setState(() {
            _uiState = UIState.ERROR;
            _errorMessage = _snapshot.message;
          });
          break;
        case Status.COMPLETED:
          setState(() {
            _uiState = UIState.COMPLETED;
            _setMarkers(_snapshot.data);
          });
          break;
      }
    });
    _bloc.getAllUsers();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _mapController.animateCamera(_animateCameraTo);
  }

  void _onMarkerTapped(int userId) {
    _bottomSheet.setUser(_bloc.getUser(userId));
  }

  // TODO(Sayeed): Should we move markers logic to its own class
  void _setMarkers(List<User> users) {
    final markers = users.map((user) {
      void callback() => _onMarkerTapped(user.id);
      return Marker(
        markerId: MarkerId(
          user.id.toString(),
        ),
        position: LatLng(
          user.lat,
          user.long,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _mapPinHue,
        ),
        infoWindow: InfoWindow(
          title: '${user.name}',
        ),
        onTap: callback,
      );
    });
    _markers = Map.fromIterable(markers,
        key: (marker) => marker.markerId, value: (marker) => marker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: DrawerView(),
      ),
      appBar: MenuAppBar(),
      body: SlidingUpPanel(
        minHeight: _bottomSheetMinHeight,
        maxHeight: _screenHeight() * 0.6,
        backdropEnabled: true,
        backdropOpacity: 0.4,
        backdropColor: Colors.black,
        panel: _bottomSheet,
        body: _widgetForUIState(),
      ),
    );
  }

// TODO(Sayeed): Is it bad that we have created a new method for getting widgets instead of having it in build()
  Widget _widgetForUIState() {
    switch (_uiState) {
      case UIState.LOADING:
        return FractionallySizedBox(
            heightFactor:
                (_screenHeight() - _bottomSheetMinHeight) / _screenHeight(),
            alignment: Alignment.topCenter,
            child: const LoadingProgressIndicator());
      case UIState.COMPLETED:
        return GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: onMapCreated,
            mapType: MapType.normal,
            markers: Set<Marker>.of(_markers.values));
      default:
        return ErrorView(message: _errorMessage);
    }
  }

  double _screenHeight() => MediaQuery.of(context).size.height;
}