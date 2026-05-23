import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirestoreService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _db;

  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    final reference = _db.doc(path);
    await reference.set(data, SetOptions(merge: merge));
  }

  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = _db.doc(path);
    await reference.update(data);
  }

  Future<void> deleteData({required String path}) async {
    final reference = _db.doc(path);
    await reference.delete();
  }

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = _db.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) =>
              builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) {
    final reference = _db.doc(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) {
      final data = snapshot.data();
      if (data == null) return null as T;
      return builder(data, snapshot.id);
    });
  }

  Future<T> getDocument<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentID) builder,
  }) async {
    final reference = _db.doc(path);
    final snapshot = await reference.get();
    final data = snapshot.data();
    if (data == null) {
      return null as T; 
    }
    return builder(data, snapshot.id);
  }
}
