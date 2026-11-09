import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_kit_network/core/network/connectivity/network_info.dart';

// --- Manual Mock Handlers ---

class MockRequestInterceptorHandler implements RequestInterceptorHandler {
  final completer = Completer<void>();
  RequestOptions? nextOptions;
  Response? resolvedResponse;
  DioException? rejectedError;

  @override
  void next(RequestOptions options) {
    nextOptions = options;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void resolve(Response response, [bool primary = false]) {
    resolvedResponse = response;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void reject(DioException error, [bool primary = false]) {
    rejectedError = error;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockResponseInterceptorHandler implements ResponseInterceptorHandler {
  final completer = Completer<void>();
  Response? nextResponse;
  Response? resolvedResponse;
  DioException? rejectedError;

  @override
  void next(Response response) {
    nextResponse = response;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void resolve(Response response) {
    resolvedResponse = response;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void reject(DioException error, [bool primary = false]) {
    rejectedError = error;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockErrorInterceptorHandler implements ErrorInterceptorHandler {
  final completer = Completer<void>();
  DioException? nextError;
  Response? resolvedResponse;
  DioException? rejectedError;

  @override
  void next(DioException err) {
    nextError = err;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void resolve(Response response) {
    resolvedResponse = response;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void reject(DioException error, [bool primary = false]) {
    rejectedError = error;
    if (!completer.isCompleted) completer.complete();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// --- Mock NetworkInfo ---

class MockNetworkInfo implements NetworkInfo {
  bool isConnectedResult = true;
  Stream<bool>? onConnectivityChangedStream;

  @override
  Future<bool> get isConnected => Future.value(isConnectedResult);

  @override
  Stream<bool> get onConnectivityChanged =>
      onConnectivityChangedStream ?? Stream.value(isConnectedResult);
}

class MockNetworkInfoThrowing implements NetworkInfo {
  @override
  Future<bool> get isConnected =>
      Future.error(Exception('Connectivity check error'));

  @override
  Stream<bool> get onConnectivityChanged =>
      Stream.error(Exception('Connectivity check error'));
}

// --- Mock X509Certificate ---

class MockX509Certificate implements X509Certificate {
  @override
  final Uint8List der;

  MockX509Certificate(List<int> derBytes) : der = Uint8List.fromList(derBytes);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// --- Mock HttpClientAdapter ---

class MockAdapter implements HttpClientAdapter {
  late Future<ResponseBody> Function(RequestOptions options) fetchHandler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return fetchHandler(options);
  }

  @override
  void close({bool force = false}) {}
}

// --- Mock Connectivity MethodChannel Helper ---

void mockConnectivityChannel(List<String> results) {
  const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return results;
        }
        return null;
      });
}
