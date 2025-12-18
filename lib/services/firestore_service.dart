abstract class FirestoreService<T> {
  Future<void> addResult(T result);
  Stream<List<T>> getResults();
  Future<void> updateResult(T result);
  Future<void> deleteResult(String id);
}
