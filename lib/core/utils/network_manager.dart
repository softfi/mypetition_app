
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

isNetworkAvailable()async{
  if(Platform.isAndroid){
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.isNotEmpty &&
        connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }else{
    try{
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException{
      return  false;
    }
  }
}
