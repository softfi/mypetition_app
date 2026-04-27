import 'package:flutter/material.dart';

class LocationProvider extends ChangeNotifier {
  String? _selectedState;
  String? _selectedCity;
  bool _isLoading = false;

  // Sample data - replace with API data later
  final List<String> _states = [
    'Andhra Pradesh',
    'Bihar',
    'Chhattisgarh',
    'Delhi',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Tamil Nadu',
    'Telangana',
    'Uttar Pradesh',
    'West Bengal',
  ];

  final Map<String, List<String>> _citiesMap = {
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Nellore'],
    'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur'],
    'Chhattisgarh': ['Raipur', 'Bilaspur', 'Durg', 'Korba'],
    'Delhi': ['New Delhi', 'North Delhi', 'South Delhi', 'East Delhi'],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat', 'Ambala'],
    'Himachal Pradesh': ['Shimla', 'Manali', 'Dharamshala', 'Kullu'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro'],
    'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode', 'Thrissur'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi'],
    'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri'],
  };

  // Getters
  String? get selectedState => _selectedState;
  String? get selectedCity => _selectedCity;
  bool get isLoading => _isLoading;
  List<String> get states => _states;
  List<String> get cities =>
      _selectedState != null ? (_citiesMap[_selectedState] ?? []) : [];

  // Select state
  void selectState(String? state) {
    _selectedState = state;
    _selectedCity = null; // Reset city when state changes
    notifyListeners();
  }

  // Select city
  void selectCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  // Submit location
  Future<bool> submitLocation() async {
    if (_selectedState == null || _selectedCity == null) return false;

    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();

    return true;
  }

  // Reset
  void reset() {
    _selectedState = null;
    _selectedCity = null;
    _isLoading = false;
    notifyListeners();
  }
}
