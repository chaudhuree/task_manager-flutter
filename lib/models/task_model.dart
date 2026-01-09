class TaskModel {
  final String? sId;
  final String? title;
  final String? description;
  final String? status;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;

  TaskModel({
    this.sId,
    this.title,
    this.description,
    this.status,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      sId: json['_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['status'] = status;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
