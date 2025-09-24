import 'package:flutter/material.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';

// Farmers ***
class DataFarmers with ChangeNotifier {
  int _period = 0;
  int _lastperiod = 0;

  Farmers _datauser = Farmers(
      id: 0,
      farmName: "" ,
      farmPassword: "",
      phonenumber: "",
      farmerEmail: "",
      profileImage: "",
      farmAddress: "",
      province: "",
      district: "",
      locality: "");

  Farmers get datauser => _datauser;  
  int get period => _period;
  int get lastperiod => _lastperiod;

  void setDataUser(Farmers user) {
    _datauser = user;
    notifyListeners();
  }

  void setLastperiod(int period) {
    _lastperiod = period;
    notifyListeners();
  }

  void setPeriod(int period) {
    _period = period;
    notifyListeners();
  }

  void updateProfileImage(String newProfileImage) {
    _datauser.profileImage = newProfileImage;
    notifyListeners();
  }
}


// Vet ***
class DataVetExpert with ChangeNotifier {
  int _period = 0;
  int _lastperiod = 0;

  VetExpert _datauser = VetExpert(
      id: 0,
      vetExpertName: "" ,
      vetExpertPassword: "",
      phonenumber: "",
      vetExpertEmail: "",
      profileImage: "",
      vetExpertAddress: "",
      province: "",
      district: "",
      locality: "",
      vetExpertPl: "");

  VetExpert get datauser => _datauser;  
  int get period => _period;
  int get lastperiod => _lastperiod;

  void setDataUser(VetExpert user) {
    _datauser = user;
    notifyListeners();
  }

  void setLastperiod(int period) {
    _lastperiod = period;
    notifyListeners();
  }

  void setPeriod(int period) {
    _period = period;
    notifyListeners();
  }

  void updateProfileImage(String newProfileImage) {
    _datauser.profileImage = newProfileImage;
    notifyListeners();
  }
}