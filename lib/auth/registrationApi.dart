import 'package:dio/dio.dart';
import 'package:gallery/ipaddress_page.dart';


final Dio dio =Dio();

Future <void>regapi(data)async{
  try{

    Response response=await dio.post('$baseurl/user?ff=hii',data:data );

    print(response);
    print(response.statusCode);
    if(response.statusCode==200){
      print("Success");
    }else{
      throw Exception('Failed to get');
    }
  } catch (e){
    print(e.toString());
  }
}