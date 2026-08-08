import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/local_store.dart';
import '../../../core/data/storage.dart';
import '../domain/company_profile.dart';

/// Mapper du profil d'établissement (document unique).
class _CompanyMapper implements EntityMapper<CompanyProfile> {
  @override
  String get collection => 'company';

  @override
  String idOf(CompanyProfile c) => CompanyProfile.docId;

  @override
  Map<String, Object?> toJson(CompanyProfile c) => c.toJson();

  @override
  CompanyProfile fromJson(Map<String, Object?> j) => CompanyProfile.fromJson(j);
}

final companyStoreProvider = Provider<CollectionStore<CompanyProfile>>(
  (ref) => CollectionStore<CompanyProfile>(
      ref.watch(localStoreProvider), _CompanyMapper()),
);

/// Profil de l'établissement, adossé au stockage local (document unique).
class CompanyController extends Notifier<CompanyProfile> {
  CollectionStore<CompanyProfile> get _store => ref.read(companyStoreProvider);

  @override
  CompanyProfile build() {
    final all = _store.loadAll();
    return all.isEmpty ? const CompanyProfile() : all.first;
  }

  void save(CompanyProfile profile) {
    _store.upsert(profile);
    state = profile;
  }
}

final companyProvider =
    NotifierProvider<CompanyController, CompanyProfile>(CompanyController.new);
