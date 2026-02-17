import 'dart:convert';

import 'package:cow_booking/model/response/Farms_response.dart';
import 'package:flutter/material.dart';
import 'package:cow_booking/model/response/Farmers_response.dart';
import 'package:cow_booking/model/response/Vet_response.dart';
import 'package:http/http.dart' as http;
import 'package:cow_booking/config/internal_config.dart';

// Farmers ***
class DataFarmers with ChangeNotifier {
  int _period = 0;
  int _lastperiod = 0;

  Farmers _datauser = Farmers(
      farmersId: 0,
      farmersName: "" ,
      // farmesHashpassword: "",
      // farmersPassword : "",
      farmersPhonenumber: "",
      farmersEmail: "",
      farmersProfileImage: "",
      farmersAddress: "",
      farmersProvince: "",
      farmersDistrict: "",
      farmersLocality: "",
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

  void clear() {
    _datauser = Farmers(
      farmersId: 0,
      farmersName: "",
      farmersPhonenumber: "",
      farmersEmail: "",
      farmersProfileImage: "",
      farmersAddress: "",
      farmersProvince: "",
      farmersDistrict: "",
      farmersLocality: "",
      farmersLocLat: null,
      farmersLocLong: null,
    );
    _period = 0;
    _lastperiod = 0;
    notifyListeners();
  }

  Future<void> fetchFarmerById(int farmerId) async {
    try {
      final res = await http.get(
        Uri.parse("$apiEndpoint/farmer/$farmerId"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        Farmers farmer = Farmers.fromJson(data);

        _datauser = farmer;
        notifyListeners();
      } else {
        throw Exception("Failed to load farmer");
      }
    } catch (e) {
      debugPrint("fetchFarmerById error: $e");
    }
  }

}


// Vet ***
class DataVetExpert with ChangeNotifier {
  int _period = 0;
  int _lastperiod = 0;

  VetExpert _datauser = VetExpert(
    id: 0,
    vetExpertName: "",
    vetExpertPassword: "",
    password: "",
    phonenumber: "",
    vetExpertEmail: "",
    profileImage: "",
    province: "",
    district: "",
    locality: "",
    vetExpertAddress: "",
    vetExpertPl: "",
    totalSemenStock: 0,
  );

  VetExpert get datauser => _datauser;
  int get period => _period;
  int get lastperiod => _lastperiod;

  void setDataUser(VetExpert user) {
    _datauser = user;
    notifyListeners();
  }

  void setPeriod(int value) {
  _period = value;
  notifyListeners();
}

  void clear() {
    _datauser = VetExpert(
      id: 0,
      vetExpertName: "",
      vetExpertPassword: "",
      password: "",
      phonenumber: "",
      vetExpertEmail: "",
      profileImage: "",
      province: "",
      district: "",
      locality: "",
      vetExpertAddress: "",
      vetExpertPl: "",
      totalSemenStock: 0,
    );
    _period = 0;
    _lastperiod = 0;
    notifyListeners();
  }

  void updateProfileImage(String newImage) {
    _datauser.profileImage = newImage;
    notifyListeners();
  }

  /// ✅ fetch vet expert by id
  Future<void> fetchVetById(int vetId) async {
    try {
      final res = await http.get(
        Uri.parse("$apiEndpoint/vetexpert/$vetId"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        _datauser = VetExpert.fromJson(data);
        notifyListeners();
      } else {
        throw Exception("Failed to load vet expert");
      }
    } catch (e) {
      debugPrint("fetchVetById error: $e");
      rethrow;
    }
  }
}

// class DataVetExpert with ChangeNotifier {
//   int _period = 0;
//   int _lastperiod = 0;

//   VetExpert _datauser = VetExpert(
//       id: 0,
//       vetExpertName: "" ,
//       vetExpertPassword: "",
//       password:"",
//       phonenumber: "",
//       vetExpertEmail: "",
//       profileImage: "",
//       vetExpertAddress: "",
//       province: "",
//       district: "",
//       locality: "",
//       vetExpertPl: "",
//       totalSemenStock: 0,);

//   VetExpert get datauser => _datauser;  
//   int get period => _period;
//   int get lastperiod => _lastperiod;

//   void setDataUser(VetExpert user) {
//     _datauser = user;
//     notifyListeners();
//   }

//   void setLastperiod(int period) {
//     _lastperiod = period;
//     notifyListeners();
//   }

//   void setPeriod(int period) {
//     _period = period;
//     notifyListeners();
//   }

//   void updateProfileImage(String newProfileImage) {
//     _datauser.profileImage = newProfileImage;
//     notifyListeners();
//   }

//   Future<void> fetchVetById(int vetId) async {
//     try {
//       final res = await http.get(
//         Uri.parse("$apiEndpoint/vetexpert/$vetId"),
//         headers: {
//           "Content-Type": "application/json",
//         },
//       );

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         _datauser = VetExpert.fromJson(data);
//         notifyListeners();
//       } else {
//         throw Exception("Failed to load vet expert");
//       }
//     } catch (e) {
//       debugPrint("fetchVetById error: $e");
//       rethrow;
//     }
//   }

// }


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



