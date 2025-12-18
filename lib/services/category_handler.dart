typedef StreamGetter = Stream<List<dynamic>> Function();
typedef AddFunction = Future<void> Function(dynamic result);
typedef UpdateFunction = Future<void> Function(dynamic result);
typedef DeleteFunction = Future<void> Function(String id);
typedef CreateResultFunction = dynamic Function({
  String? id,
  required DateTime date,
  required int amount,
  String? betType,
  required String memo,
  required DateTime createdAt,
  String? type,
  String? umaRate,
  String? priceRate,
  int? chipRate,
  List<String>? member,
  String? place,
  String? machine,
});

class CategoryHandler {
  final StreamGetter streamGetter;
  final AddFunction add;
  final UpdateFunction update;
  final DeleteFunction delete;
  final CreateResultFunction? createResult;

  const CategoryHandler({
    required this.streamGetter,
    required this.add,
    required this.update,
    required this.delete,
    this.createResult,
  });
}
