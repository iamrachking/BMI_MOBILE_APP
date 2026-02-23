/// Réponse standard API : success, message, data
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final ApiMeta? meta;
  final ApiLinks? links;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.links,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null
          ? ApiMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      links: json['links'] != null
          ? ApiLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApiMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ApiMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
    );
  }
}

class ApiLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  ApiLinks({this.first, this.last, this.prev, this.next});

  factory ApiLinks.fromJson(Map<String, dynamic> json) {
    return ApiLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}
