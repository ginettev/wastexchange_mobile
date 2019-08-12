import 'package:http_interceptor/http_interceptor.dart';
import 'package:wastexchange_mobile/resources/auth/token_repository.dart';
import 'package:http/http.dart';

/// Interceptor that modify API Request by adding authentication information to the request.
class AuthInterceptor implements InterceptorContract {

  RequestData _requestData;

  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    _requestData = data;
    await addAuthHeader(data);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
    if(data.statusCode == 401 || data.statusCode == 403) {

      /// If it is a 401 or 403 due to access token expired, Then refresh the token
      /// and retry internally. This retry logic should not be intercepted to avoid
      /// falling under recursive loop.
      if(await JWTTokenRepository().refreshToken()) {
        final streamedResponse = await _requestData.toHttpRequest().send();
        final response = await Response.fromStream(streamedResponse);
        return ResponseData.fromHttpResponse(response);
      }
    }
    return data;
  }

  Future<void> addAuthHeader(RequestData data) async {

    // Check token is expired already and if expired, then refresh before making API call.
    if(await JWTTokenRepository().isTokenExpired()) {
      await JWTTokenRepository().refreshToken();
    }

    final String token = await JWTTokenRepository().getToken();
    if(token != null) {
      data.headers['Authorization'] = token;
    }
  }
}