class DeviceModel {
  final String sno;
  final String imei;
  final String username;
  final String? mode;
  final String? regulerData;
  final String? examData;
  final String? holidayData;
  final String lastSync;
  final String? data;
  final String? fitterId;
  final String deviceName;
  final String status;
  final String? qrCode;
  final String? expiryDate;
  final String? paymentStatus;
  final String? price;
  final String? image;
  final String? addedDate;
  final String? storeDate;
  final String? outDate;
  final String? fitterDate;
  final String? userDate;
  final String? rechargeDate;
  final String swVersion;
  final String releaseDate;

  DeviceModel({
    required this.sno,
    required this.imei,
    required this.username,
    required this.mode,
    required this.regulerData,
    required this.examData,
    required this.holidayData,
    required this.lastSync,
    required this.data,
    required this.fitterId,
    required this.deviceName,
    required this.status,
    required this.qrCode,
    required this.expiryDate,
    required this.paymentStatus,
    required this.price,
    required this.image,
    required this.addedDate,
    required this.storeDate,
    required this.outDate,
    required this.fitterDate,
    required this.userDate,
    required this.rechargeDate,
    this.swVersion = '',
    this.releaseDate = '',
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      sno: json['sno'] ?? '',
      imei: json['imei'] ?? '',
      username: json['username'] ?? '',
      mode: json['mode'],
      regulerData: json['reguler_data'],
      examData: json['exam_data'],
      holidayData: json['holiday_data'],
      lastSync: json['last_sync'] ?? '',
      data: json['data'],
      fitterId: json['fitter_id'],
      deviceName: json['device_name'] ?? '',
      status: json['status'] ?? '',
      qrCode: json['qr_code'],
      expiryDate: json['expiry_dt'],
      paymentStatus: json['payment_status'],
      price: json['price'],
      image: json['image'],
      addedDate: json['added_date'],
      storeDate: json['store_date'],
      outDate: json['out_date'],
      fitterDate: json['fitter_date'],
      userDate: json['user_date'],
      rechargeDate: json['recharge_date'],
      swVersion: json['sw_version'] ?? '',
      releaseDate: json['release_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sno": sno,
      "imei": imei,
      "username": username,
      "mode": mode,
      "reguler_data": regulerData,
      "exam_data": examData,
      "holiday_data": holidayData,
      "last_sync": lastSync,
      "data": data,
      "fitter_id": fitterId,
      "device_name": deviceName,
      "status": status,
      "qr_code": qrCode,
      "expiry_dt": expiryDate,
      "payment_status": paymentStatus,
      "price": price,
      "image": image,
      "added_date": addedDate,
      "store_date": storeDate,
      "out_date": outDate,
      "fitter_date": fitterDate,
      "user_date": userDate,
      "recharge_date": rechargeDate,
      "sw_version": swVersion,
      "release_date": releaseDate,
    };
  }

  DeviceModel copyWith({
    String? swVersion,
    String? releaseDate,
  }) {
    return DeviceModel(
      sno: sno,
      imei: imei,
      username: username,
      mode: mode,
      regulerData: regulerData,
      examData: examData,
      holidayData: holidayData,
      lastSync: lastSync,
      data: data,
      fitterId: fitterId,
      deviceName: deviceName,
      status: status,
      qrCode: qrCode,
      expiryDate: expiryDate,
      paymentStatus: paymentStatus,
      price: price,
      image: image,
      addedDate: addedDate,
      storeDate: storeDate,
      outDate: outDate,
      fitterDate: fitterDate,
      userDate: userDate,
      rechargeDate: rechargeDate,
      swVersion: swVersion ?? this.swVersion,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }
}
