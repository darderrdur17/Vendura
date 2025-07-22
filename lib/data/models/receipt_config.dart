class ReceiptConfig {
  final String cafeName;
  final String cafeSlogan;
  final String address;
  final String phone;
  final String email;
  final String website;
  final bool showLogo;
  final bool showThankYouMessage;
  final bool showContactInfo;
  final bool showOrderType;
  final bool showDiscounts;
  final String receiptFooter;
  final ReceiptSize size;
  final ReceiptFontSize fontSize;

  const ReceiptConfig({
    this.cafeName = 'VENDURA CAFE',
    this.cafeSlogan = 'Premium Coffee & Pastries',
    this.address = '123 Coffee Street, Singapore 123456',
    this.phone = '+65 6123 4567',
    this.email = 'hello@vendura.com',
    this.website = 'www.vendura.com',
    this.showLogo = true,
    this.showThankYouMessage = true,
    this.showContactInfo = true,
    this.showOrderType = true,
    this.showDiscounts = true,
    this.receiptFooter = 'Thank you for visiting Vendura Cafe!',
    this.size = ReceiptSize.standard,
    this.fontSize = ReceiptFontSize.medium,
  });

  ReceiptConfig copyWith({
    String? cafeName,
    String? cafeSlogan,
    String? address,
    String? phone,
    String? email,
    String? website,
    bool? showLogo,
    bool? showThankYouMessage,
    bool? showContactInfo,
    bool? showOrderType,
    bool? showDiscounts,
    String? receiptFooter,
    ReceiptSize? size,
    ReceiptFontSize? fontSize,
  }) {
    return ReceiptConfig(
      cafeName: cafeName ?? this.cafeName,
      cafeSlogan: cafeSlogan ?? this.cafeSlogan,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      showLogo: showLogo ?? this.showLogo,
      showThankYouMessage: showThankYouMessage ?? this.showThankYouMessage,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      showOrderType: showOrderType ?? this.showOrderType,
      showDiscounts: showDiscounts ?? this.showDiscounts,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      size: size ?? this.size,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cafeName': cafeName,
      'cafeSlogan': cafeSlogan,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'showLogo': showLogo,
      'showThankYouMessage': showThankYouMessage,
      'showContactInfo': showContactInfo,
      'showOrderType': showOrderType,
      'showDiscounts': showDiscounts,
      'receiptFooter': receiptFooter,
      'size': size.name,
      'fontSize': fontSize.name,
    };
  }

  factory ReceiptConfig.fromJson(Map<String, dynamic> json) {
    return ReceiptConfig(
      cafeName: json['cafeName'] ?? 'VENDURA CAFE',
      cafeSlogan: json['cafeSlogan'] ?? 'Premium Coffee & Pastries',
      address: json['address'] ?? '123 Coffee Street, Singapore 123456',
      phone: json['phone'] ?? '+65 6123 4567',
      email: json['email'] ?? 'hello@vendura.com',
      website: json['website'] ?? 'www.vendura.com',
      showLogo: json['showLogo'] ?? true,
      showThankYouMessage: json['showThankYouMessage'] ?? true,
      showContactInfo: json['showContactInfo'] ?? true,
      showOrderType: json['showOrderType'] ?? true,
      showDiscounts: json['showDiscounts'] ?? true,
      receiptFooter: json['receiptFooter'] ?? 'Thank you for visiting Vendura Cafe!',
      size: ReceiptSize.values.firstWhere(
        (e) => e.name == json['size'],
        orElse: () => ReceiptSize.standard,
      ),
      fontSize: ReceiptFontSize.values.firstWhere(
        (e) => e.name == json['fontSize'],
        orElse: () => ReceiptFontSize.medium,
      ),
    );
  }
}

enum ReceiptSize {
  compact(width: 300),
  standard(width: 400),
  wide(width: 500);

  const ReceiptSize({required this.width});
  final double width;
}

enum ReceiptFontSize {
  small(
    header: 16.0,
    title: 12.0,
    body: 10.0,
    detail: 8.0,
  ),
  medium(
    header: 20.0,
    title: 14.0,
    body: 12.0,
    detail: 10.0,
  ),
  large(
    header: 24.0,
    title: 16.0,
    body: 14.0,
    detail: 12.0,
  );

  const ReceiptFontSize({
    required this.header,
    required this.title,
    required this.body,
    required this.detail,
  });

  final double header;
  final double title;
  final double body;
  final double detail;
} 