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

  /// Factory constructor to deserialize JSON into AddressModel with safe fallbacks
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

  /// Serialize AddressModel to Map
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
      'postalCode': postalCode,
    };
  }

  /// Helper getter for formatted full address in Thai layout
  String get formattedAddress {
    final parts = <String>[];
    if (street != '-' && street.isNotEmpty) parts.add(street);
    if (subdistrict != '-' && subdistrict.isNotEmpty) parts.add('ต.$subdistrict');
    if (district != '-' && district.isNotEmpty) parts.add('อ.$district');
    if (province != '-' && province.isNotEmpty) parts.add('จ.$province');
    if (postalCode != '-' && postalCode.isNotEmpty) parts.add(postalCode);

    return parts.isEmpty ? 'ไม่ระบุที่อยู่' : parts.join(' ');
  }

  /// Short summary for compact card view (e.g., "คลองเตย, กรุงเทพมหานคร")
  String get shortAddress {
    if (district != '-' && province != '-') {
      return '$district, $province $postalCode';
    }
    return province != '-' ? province : formattedAddress;
  }
}
