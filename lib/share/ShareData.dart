import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:flutter/material.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';

// Farmers ***
class DataFarmers with ChangeNotifier {
  int _period = 0;
  int _lastperiod = 0;

  Farmers _datauser = Farmers(
      farmersId: 0,
      farmersName: "" ,
      farmesHashpassword: "",
      farmersPassword : "",
      farmersPhonenumber: "",
      farmersEmail: "",
      farmersProfileImage: "",
      farmersAddress: "",
      farmersProvince: "",
      farmersDistrict: "",
      farnersLocality: "",
      farmersLocLat: null,
      farmersLocLong: null,);

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
    _datauser.farmersProfileImage = newProfileImage;
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
      password:"",
      phonenumber: "",
      vetExpertEmail: "",
      profileImage: "",
      vetExpertAddress: "",
      province: "",
      district: "",
      locality: "",
      vetExpertPl: "",
      totalSemenStock: 0,);

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
    bullId: 0,
    bullsName: '',
    bullsBreed: '',
    bullsAge: 0,
    bullsCharacteristics: '',
    contestRecords: '',
    pricePerDose: 0,
    semenStock: 0,
    farm: Farm(
      farmId: 0,
      farmName: '',
      province: '',
      district: '',
      locality: '',
      address: '',
    ),
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



