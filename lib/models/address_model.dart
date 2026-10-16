class AddressModel {
  final String street;
  final String subdistrict;
  final String district;
  final String province;
  final String postalCode;

  const AddressModel({
    required this.street,
    required this.subdistrict,
    required this.district,
    required this.province,
    required this.postalCode,
  });

  /// Factory constructor สำหรับแปลง JSON เป็น AddressModel พร้อมกำหนดค่าเริ่มต้นที่ปลอดภัยหากไม่มีข้อมูล
  factory AddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AddressModel(
        street: '-',
        subdistrict: '-',
        district: '-',
        province: '-',
        postalCode: '-',
      );
    }

    return AddressModel(
      street: (json['street'] as String?)?.trim() ?? '-',
      subdistrict: (json['subdistrict'] as String?)?.trim() ?? '-',
      district: (json['district'] as String?)?.trim() ?? '-',
      province: (json['province'] as String?)?.trim() ?? '-',
      postalCode: (json['postalCode'] as String?)?.trim() ?? '-',
    );
  }

  /// แปลง AddressModel เป็น Map เพื่อนำไปแปลงเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
      'postalCode': postalCode,
    };
  }

  /// Helper getter สำหรับจัดรูปแบบที่อยู่แบบเต็มตามรูปแบบภาษาไทย
  String get formattedAddress {
    final parts = <String>[];
    if (street != '-' && street.isNotEmpty) parts.add(street);
    if (subdistrict != '-' && subdistrict.isNotEmpty) parts.add('ต.$subdistrict');
    if (district != '-' && district.isNotEmpty) parts.add('อ.$district');
    if (province != '-' && province.isNotEmpty) parts.add('จ.$province');
    if (postalCode != '-' && postalCode.isNotEmpty) parts.add(postalCode);

    return parts.isEmpty ? 'ไม่ระบุที่อยู่' : parts.join(' ');
  }

  /// ที่อยู่แบบย่อสำหรับการแสดงผลในการ์ด (เช่น "คลองเตย, กรุงเทพมหานคร")
  String get shortAddress {
    if (district != '-' && province != '-') {
      return '$district, $province $postalCode';
    }
    return province != '-' ? province : formattedAddress;
  }
}
