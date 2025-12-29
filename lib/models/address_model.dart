class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String detail;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.detail,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'detail': detail,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map, String id) {
    return AddressModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      detail: map['detail'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
}