enum NotiType {
  system,
  order;
}

class NotificationVO {
  int? id;
  String? title;
  String? shortContent;
  String? content;
  String? image;
  int? sort;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? type;
  //this is from api
  NotiType? notiType; //to seperate order and system noti for ui tabs

  NotificationVO({
    this.id,
    this.title,
    this.shortContent,
    this.content,
    this.image,
    this.sort,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.type,
    this.notiType = NotiType.system,
  });

  // Manual fromJson factory constructor
  factory NotificationVO.fromJson(Map<String, dynamic> json) {
    // Custom fromJsonInt logic is implemented inline for 'id', 'sort', and 'status'
    int? _fromJsonInt(dynamic value) {
      return int.tryParse(value.toString()) ?? 0;
    }

    return NotificationVO(
      id: _fromJsonInt(json['id']),
      title: json['title'] as String?,
      shortContent: json['short_content'] as String?,
      content: json['content'] as String?,
      image: json['image'] as String?,
      sort: _fromJsonInt(json['sort']),
      status: _fromJsonInt(json['status']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      type: json['type'] as String?,
      // Assign notiType with a default or based on some logic if needed
      // Here, it defaults to NotiType.system if not explicitly set/needed from JSON
      notiType: NotiType.system,
    );
  }

  // Manual toJson method
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id, // _toJsonInt (identity function) is no longer needed
      'title': title,
      'short_content': shortContent,
      'content': content,
      'image': image,
      'sort': sort,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'type': type,
      // notiType is usually not serialized back to the API unless needed
      // If needed, you might convert it to a string or int: 'notiType': notiType?.name,
    };
  }

  @override
  String toString() {
    return 'NotificationVO(id: $id, title: $title,   shortContent: $shortContent,   content: $content,  image: $image, sort: $sort, status: $status, createdAt: $createdAt, updatedAt: $updatedAt,  orderType ${notiType?.name})';
  }
}