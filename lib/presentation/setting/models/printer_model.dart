enum PrinterType {
  wifi('Wifi'),
  bluetooth('Bluetooth');

  final String value;
  const PrinterType(this.value);

  bool get isWifi => this == PrinterType.wifi;
  bool get isBluetooth => this == PrinterType.bluetooth;

  factory PrinterType.fromValue(String value) {
    return values.firstWhere(
      (element) => element.value == value,
      orElse: () => PrinterType.wifi,
    );
  }
}

class PrinterModel {
  final String name;
  final String ipAddress;
  final String macAddress;
  final String size;
  final PrinterType type;
  final bool isDefault;

  PrinterModel({
    required this.name,
    this.ipAddress = '',
    this.macAddress = '',
    this.size = '58',
    required this.type,
    this.isDefault = false,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'size': size,
      'type': type.value,
      'isDefault': isDefault,
    };
  }

  // Create from JSON
  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String? ?? '',
      macAddress: json['macAddress'] as String? ?? '',
      size: json['size'] as String? ?? '58',
      type: PrinterType.fromValue(json['type'] as String? ?? 'Bluetooth'),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  // Create a copy with updated fields
  PrinterModel copyWith({
    String? name,
    String? ipAddress,
    String? macAddress,
    String? size,
    PrinterType? type,
    bool? isDefault,
  }) {
    return PrinterModel(
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      size: size ?? this.size,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Get the connection address (MAC for Bluetooth, IP for WiFi)
  String get connectionAddress {
    return type == PrinterType.bluetooth ? macAddress : ipAddress;
  }
}
