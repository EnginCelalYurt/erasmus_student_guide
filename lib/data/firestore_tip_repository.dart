import 'package:cloud_firestore/cloud_firestore.dart';

import '../logic/vote_counts.dart';
import '../models/tip.dart';
import 'tip_repository.dart';

class FirestoreTipRepository implements TipRepository {
  FirestoreTipRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _tips => _db.collection('tips');

  @override
  Future<List<Tip>> fetchTips({TipCategory? category}) async {
    Query<Map<String, dynamic>> query = _tips;
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    // Ask the server: without this an offline request can answer with an empty
    // list, which would look like "no tips" and replace the saved copy.
    final snapshot = await query.get(const GetOptions(source: Source.server));
    final tips = snapshot.docs.map(_tipFromDoc).toList();
    tips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return tips;
  }

  @override
  Future<Tip> addTip(NewTip tip, {required String userId}) async {
    final ref = _tips.doc();
    final created = Tip(
      id: ref.id,
      title: tip.title.trim(),
      body: tip.body.trim(),
      category: tip.category,
      authorName: tip.authorName,
      createdAt: DateTime.now(),
    );
    await ref.set({
      'title': created.title,
      'body': created.body,
      'category': created.category.name,
      'authorName': created.authorName,
      'authorId': userId,
      'createdAt': Timestamp.fromDate(created.createdAt),
      'helpful': 0,
      'notHelpful': 0,
    });
    return created;
  }

  @override
  Future<VoteValue?> myVote({
    required String tipId,
    required String userId,
  }) async {
    final doc = await _tips.doc(tipId).collection('votes').doc(userId).get();
    if (!doc.exists) return null;
    return _voteFromName(doc.data()?['value'] as String?);
  }

  @override
  Future<Tip> vote({
    required String tipId,
    required String userId,
    required VoteValue? value,
  }) async {
    try {
      return await _voteInTransaction(tipId, userId, value);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') throw const TipPermissionException();
      rethrow;
    }
  }

  Future<Tip> _voteInTransaction(
    String tipId,
    String userId,
    VoteValue? value,
  ) {
    final tipRef = _tips.doc(tipId);
    final voteRef = tipRef.collection('votes').doc(userId);

    return _db.runTransaction((tx) async {
      // In a transaction all reads must come before any write.
      final tipSnap = await tx.get(tipRef);
      if (!tipSnap.exists) throw ArgumentError('Unknown tip: $tipId');
      final voteSnap = await tx.get(voteRef);

      final previous =
          voteSnap.exists ? _voteFromName(voteSnap.data()?['value'] as String?) : null;
      final tip = _tipFromDoc(tipSnap);
      final counts = applyVote(
        helpful: tip.helpful,
        notHelpful: tip.notHelpful,
        previous: previous,
        next: value,
      );

      tx.update(tipRef, {
        'helpful': counts.helpful,
        'notHelpful': counts.notHelpful,
      });
      if (value == null) {
        tx.delete(voteRef);
      } else {
        tx.set(voteRef, {'value': value.name});
      }

      return tip.copyWith(
        helpful: counts.helpful,
        notHelpful: counts.notHelpful,
      );
    });
  }

  Tip _tipFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final categoryName = data['category'] as String?;
    return Tip(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      category: TipCategory.values.firstWhere(
        (c) => c.name == categoryName,
        orElse: () => TipCategory.dailyLife,
      ),
      authorName: data['authorName'] as String? ?? 'TUL student',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      helpful: (data['helpful'] as num?)?.toInt() ?? 0,
      notHelpful: (data['notHelpful'] as num?)?.toInt() ?? 0,
    );
  }

  VoteValue? _voteFromName(String? name) {
    for (final v in VoteValue.values) {
      if (v.name == name) return v;
    }
    return null;
  }
}