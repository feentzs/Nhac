import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  final baseUrl = 'backend-nhac.onrender.com';
  
  try {
    final uuid = 'test-uuid-${DateTime.now().millisecondsSinceEpoch}';
    final email = 'test_${DateTime.now().millisecondsSinceEpoch}@nhac.com';
    
    print('1. Registering user...');
    final regUri = Uri.https(baseUrl, '/api/v1/auth/registrar');
    final regRequest = await client.postUrl(regUri);
    regRequest.headers.contentType = ContentType.json;
    
    final regBody = {
      'id': uuid,
      'nome': 'Test User',
      'email': email,
      'telefone': '11999999999',
      'senha': 'password123'
    };
    
    regRequest.write(jsonEncode(regBody));
    final regResponse = await regRequest.close();
    final regResponseBody = await regResponse.transform(utf8.decoder).join();
    print('Reg status: ${regResponse.statusCode}');
    print('Reg body: $regResponseBody');
    
    if (regResponse.statusCode != 201) {
      print('Failed to register user.');
      return;
    }
    
    final regData = jsonDecode(regResponseBody) as Map<String, dynamic>;
    final token = regData['token'] as String;
    final userId = regData['usuarioId'] as String;
    
    print('2. Adding address...');
    final addrUri = Uri.https(baseUrl, '/api/v1/usuarios/$userId/enderecos');
    final addrRequest = await client.postUrl(addrUri);
    addrRequest.headers.contentType = ContentType.json;
    addrRequest.headers.set('Authorization', 'Bearer $token');
    
    final addrBody = {
      'rua': 'Rua do Teste',
      'numero': '123',
      'bairro': 'Centro',
      'cidade': 'Sao Paulo',
      'estado': 'SP',
      'cep': '01001-000',
      'complemento': 'Apt 1',
      'isPadrao': true
    };
    
    addrRequest.write(jsonEncode(addrBody));
    final addrResponse = await addrRequest.close();
    print('Add address status: ${addrResponse.statusCode}');
    
    print('3. Getting addresses...');
    final getUri = Uri.https(baseUrl, '/api/v1/usuarios/$userId/enderecos');
    final getRequest = await client.getUrl(getUri);
    getRequest.headers.set('Authorization', 'Bearer $token');
    
    final getResponse = await getRequest.close();
    final getResponseBody = await getResponse.transform(utf8.decoder).join();
    print('Get addresses status: ${getResponse.statusCode}');
    print('Get addresses body: $getResponseBody');
    
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
