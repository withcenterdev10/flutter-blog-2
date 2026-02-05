import 'package:flutter/foundation.dart';

class ScreenProvider extends ChangeNotifier {
  int state = 0;

  int get getState {
    return state;
  }

  void setScreen(int screenIndex) {
    state = screenIndex;
    notifyListeners();
  }
}
