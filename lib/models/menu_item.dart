class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final int price;
  final double rating;
  final int reviewCount;
  final int minOrder;
  final String imageEmoji;
  final List<String> packageContents;
  final String? badgeText;

  const MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviewCount,
    this.minOrder = 5,
    required this.imageEmoji,
    required this.packageContents,
    this.badgeText,
  });
}