import 'package:flutter/material.dart';

class OutletProvider with ChangeNotifier {
  // Map to store open/closed status for each outlet
  final Map<String, bool> _outletStatus = {
    'Canteen': true,
    'Nescafe': true,
    'Lipton': true,
    'Fruit Corner': true,
  };

  bool isOpen(String outletName) {
    return _outletStatus[outletName] ?? false;
  }

  void toggleStatus(String outletName) {
    if (_outletStatus.containsKey(outletName)) {
      _outletStatus[outletName] = !_outletStatus[outletName]!;
      notifyListeners();
    }
  }

  void setStatus(String outletName, bool status) {
    _outletStatus[outletName] = status;
    notifyListeners();
  }
}
