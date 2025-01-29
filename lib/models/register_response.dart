class RegisterResponse {
  final dynamic message;
  final String? error;
  final int statusCode;
  final String? dataMessage;

  RegisterResponse({
    this.message,
    this.error,
    required this.statusCode,
    this.dataMessage,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
      dataMessage: json['data'] != null ? json['data']['message'] : null,
    );
  }

  String getMessageAsString() {
    if (message is List) {
      return (message as List).join('\n');
    } else if (message is String) {
      return message as String;
    }
    return 'An unknown error occurred';
  }
}