import 'package:cow_booking/model/response/Farms_response.dart';
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


class DataBull with ChangeNotifier {
  FarmbullRequestResponse _selectedBull = FarmbullRequestResponse(
    id: 0,
    bullname: '',
    bullbreed: '',
    bullage: 0,
    characteristics: '',
    farmId: 0,
    pricePerDose: 0,
    semenStock: 0,
    contestRecords: '',
    addedBy: 0,
    farmName: '',
    province: '',
    district: '',
    locality: '',
    address: '',
    image1: '',
    image2: '',
    image3: '',
    image4: '',
    image5: '',
    images: [],
  );

  FarmbullRequestResponse get selectedBull => _selectedBull;

  void setSelectedBull(FarmbullRequestResponse bull) {
    _selectedBull = bull;
    notifyListeners();
  }

  void updateSemenStock(int newStock) {
    _selectedBull.semenStock = newStock;
    notifyListeners();
  }
}
