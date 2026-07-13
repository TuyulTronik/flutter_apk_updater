// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_apk_updater/flutter_apk_updater.dart';
// import 'package:flutter_apk_updater/flutter_apk_updater_platform_interface.dart';
// import 'package:flutter_apk_updater/flutter_apk_updater_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
// class MockFlutterApkUpdaterPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterApkUpdaterPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
// void main() {
//   final FlutterApkUpdaterPlatform initialPlatform = FlutterApkUpdaterPlatform.instance;
//   test('$MethodChannelFlutterApkUpdater is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterApkUpdater>());
//   });
//   test('getPlatformVersion', () async {
//     FlutterApkUpdater flutterApkUpdaterPlugin = FlutterApkUpdater();
//     MockFlutterApkUpdaterPlatform fakePlatform = MockFlutterApkUpdaterPlatform();
//     FlutterApkUpdaterPlatform.instance = fakePlatform;
//     expect(await flutterApkUpdaterPlugin.getPlatformVersion(), '42');
//   });
// }
