class AzkarCategory {
  final String id;
  final String name;
  final String icon;
  final List<Zikr> items;

  AzkarCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
  });

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    return AzkarCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      items: (json['items'] as List)
          .map((item) => Zikr.fromJson(item))
          .toList(),
    );
  }

  static List<AzkarCategory> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AzkarCategory.fromJson(json)).toList();
  }

  // Get total count of zikr items in this category
  int get totalCount {
    return items.fold(0, (sum, item) => sum + item.count);
  }
}

class Zikr {
  final String id;
  final String text;
  final String? fadl;
  final String? source;
  final int count;

  Zikr({
    required this.id,
    required this.text,
    this.fadl,
    this.source,
    required this.count,
  });

  factory Zikr.fromJson(Map<String, dynamic> json) {
    return Zikr(
      id: json['id'],
      text: json['text'],
      fadl: json['fadl'],
      source: json['source'],
      count: json['count'],
    );
  }
} 