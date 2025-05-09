// class MqttDeviceInfo {
//   final String swVersion;
//   final String releaseDate;
//   final String deviceId;
//   final String model;
//   final String make;
//   final String systemTime;
//   final String ipAddress;

//   MqttDeviceInfo({
//     required this.swVersion,
//     required this.releaseDate,
//     required this.deviceId,
//     required this.model,
//     required this.make,
//     required this.systemTime,
//     required this.ipAddress,
//   });

//   factory MqttDeviceInfo.fromJson(Map<String, dynamic> json) {
//     return MqttDeviceInfo(
//       swVersion: json['SW Version'] ?? '',
//       releaseDate: json['Release date'] ?? '',
//       deviceId: json['Device ID'] ?? '',
//       model: json['Model'] ?? '',
//       make: json['Make'] ?? '',
//       systemTime: json['System Time'] ?? '',
//       ipAddress: json['IP Address'] ?? '',
//     );
//   }
// }
