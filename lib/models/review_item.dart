class ReviewItem {
  final String id;
  final String menuId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  const ReviewItem({
    required this.id,
    required this.menuId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });
}