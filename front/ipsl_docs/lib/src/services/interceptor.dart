/*import 'package:dio/dio.dart';
import 'package:ipsl_docs/services/token_service.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenService tokens;
  Dio? _refreshDio;
  bool isRefreshing = false;
  List<QueuedRequest> queue = [];

  AuthInterceptor({required this.dio, required this.tokens}) {
    _refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
  }

  Future<bool> get isAccessValid async {
    final token = await tokens.accessToken;
    if (token == null) return false;
    final decoded = Jwt.parseJwt(token);
    final exp = decoded['exp'] as int;
    return DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(exp * 1000));
  }

  @override
  Future<void> onRequest(RequestOptions opts, handler) async {
    final access = await tokens.accessToken;
    if (access != null) opts.headers['Authorization'] = 'Bearer $access';
    handler.next(opts);
  }

  @override
  Future<void> onError(DioException err, handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final refresh = await tokens.refreshToken;
    if (refresh == null) return handler.next(err);

    queueRequest(err, handler);

    if (!isRefreshing) {
      isRefreshing = true;
      try {
        final resp = await _refreshDio!.post('/refresh', data: {'refresh_token': refresh});
        await tokens.saveTokens(resp.data['access_token'], resp.data['refresh_token'] ?? refresh);
        retryQueue();
      } catch (e) {
        await tokens.clear();
        for (var q in queue) {
          q.handler.reject(err);
        }
      } finally {
        isRefreshing = false;
        queue.clear();
      }
    }
  }

  void queueRequest(DioException err, ErrorInterceptorHandler handler) {
    queue.add(QueuedRequest(err.requestOptions, handler));
  }

  void retryQueue() async {
    final newAccess = await tokens.accessToken;
    for (var q in queue) {
      q.request.headers['Authorization'] = 'Bearer $newAccess';
      dio.fetch(q.request).then(q.handler.resolve).catchError((error, [stackTrace]) => q.handler.reject(error));
    }
  }
}

class QueuedRequest {
  RequestOptions request;
  ErrorInterceptorHandler handler;
  QueuedRequest(this.request, this.handler);
}*/
