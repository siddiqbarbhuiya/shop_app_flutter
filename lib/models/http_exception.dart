

class HttpException implements Exception{
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    
    return message;
    // return super.toString(); // Intance of HttpException
  }
}


//for printing messade base don statuscode 
//products.dart;