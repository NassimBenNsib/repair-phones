# H — Réparations : Créer · Imprimer (Pro + Ticket QR) · Scanner

**But** : (1) **créer** une réparation (le « ＋ » est aujourd'hui un stub), (2) l'**imprimer** en deux
formats — une **fiche Pro A4 complète** et un **petit ticket** avec **QR code**, et (3) **scanner** le QR
pour rouvrir instantanément la réparation.

**Dépendances** : Réparations (domaine `Repair`, `repairsProvider`), 00 (pipeline PDF `document_pdf.dart`,
`AppFormats`, numérotation), Clients (`Client` pour le bloc client), Company (`CompanyProfile` en-tête/logo).
**Section nav** : `repairs`. **Sûr/additif** : aucun changement de comptabilité ni de schéma existant.

**Ancrages de réutilisation**
- Domaine : `lib/features/repairs/domain/repair.dart` — `Repair` (identité = `reference` p.ex. `#R-2048` ;
  totaux `subtotal/taxAmount/total/balanceDue` déjà calculés ; `parts`, `services`, appareil, narratif).
- Contrôleur : `lib/features/repairs/application/repairs_controller.dart` — a `update/remove/setStatus/…`
  mais **pas de `add`** ; lookup `byRef(reference)`.
- Écran/route : `repairs_screen.dart` (le `＋` → `_snack(l.repairsNew)` = **stub** ; ouverture détail via
  `Navigator.push` — **aucune route GoRouter paramétrée**). Détail : `repair_detail.dart` (menu `'print'`
  tombe sur un snackbar « bientôt »).
- PDF : `lib/core/pdf/document_pdf.dart` (`printBusinessDocument`, `pdf`+`printing`, police **Amiri** RTL,
  A4). Le paquet **`barcode`** est déjà dispo **transitivement via `printing`** → QR en PDF **sans nouvelle
  dépendance** (`pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: …)`).
- Identité doc : `CompanyProfile.headerLines` + `logo` (base64) ; montants/dates via `AppFormats`.

---

## H1 — Créer une réparation (formulaire d'admission + référence + route détail)

**Contrôleur** — ajouter à `RepairsController` :
```dart
Repair add({
  required String device, DeviceKind kind = DeviceKind.phone,
  String? clientId, String? client, String? clientPhone, String? clientEmail,
  String? reportedIssue, RepairPriority priority = RepairPriority.normal,
  double deposit = 0, double taxRate = 0.20, DateTime? dueAt,
}) { … reference = _nextReference(); status = inProgress; createdAt = now; upsert; return r; }
```
- **Générateur de référence** : réutiliser la numérotation existante (`numberingProvider.next('REP', year)`
  comme `FACT`/`DEV`) → format d'affichage **`#R-<seq>`** (padding). Garantit l'**unicité** (la `reference`
  est la clé de stockage `idOf`). Repli : `1 + max(suffixe numérique des refs existantes)` si pas de service
  de numérotation branché.
- **Formulaire** `_RepairIntakeSheet` (via `showAppleSheet`, même patron que le formulaire Prestations) :
  Appareil (obligatoire) + `DeviceKind` (chips), **Client** via `showClientPickerSheet` (préremplit
  `clientId/client/clientPhone/clientEmail`), Panne signalée, Priorité, Acompte, Échéance (optionnel).
  Validation minimale : appareil + client. À l'enregistrement → `add(...)` puis ouvre le détail.
- **Câblage** : `repairs_screen.dart` — le `＋` ouvre `_RepairIntakeSheet` (remplace `_snack`).
- **Route détail deep-link** (pour le scan → ouverture) : ajouter dans `app_router.dart`
  `GoRoute(path: '/repairs/:ref', name: 'repair-detail', builder: … RepairDetailScreen(reference: decoded))`.
  La `reference` contient `#` → **encoder/décoder** (`Uri.encodeComponent`). Le `Navigator.push` actuel reste
  valide ; la route sert au scan et au deep-link web.

**Tests** : `repairs_controller_test` — `add()` crée une réf unique, incrémente, persiste (round-trip store) ;
le formulaire (widget) crée bien une réparation.

## H2 — PDF « Fiche Pro » A4 complète

Nouveau `lib/core/pdf/repair_pdf.dart` — `Future<Uint8List> buildRepairSheet({repair, client, company,
labels, rtl})` + `Future<void> printRepairSheet({...})` (= `Printing.layoutPdf`).
- **Refactor léger** : extraire de `document_pdf.dart` le chargement **thème + police Amiri** dans un helper
  partagé (`_documentTheme`) pour que les deux docs le réutilisent (pas de duplication de police).
- **Contenu** : en-tête (logo + `company.headerLines`, titre « Fiche de réparation » + `reference` + dates) ;
  **QR** (`reference`) en coin haut-droit ; bloc **Client** (nom/tél/email/adresse) ; bloc **Appareil**
  (marque/modèle/série/couleur/stockage/code/accessoires/état à l'entrée) ; **Narratif** (panne signalée,
  diagnostic, travaux) ; **tableau** pièces + services (via `pw.TableHelper`) ; **totaux**
  (sous-total/remise/TVA/acompte/**solde**) ; **garantie** (`warrantyMonths`) ; mentions + **lignes de
  signature** (client / technicien). Montants via `AppFormats.money`, dates via `AppFormats.date`.
- **Câblage** : `repair_detail.dart` — le menu `'print'` ouvre une feuille de choix
  (`showAppleSelectionSheet`) **Fiche Pro (A4)** / **Ticket (QR)** → appelle le bon générateur (remplace le
  snackbar « bientôt »).

**Tests** : `repair_pdf_test` — `buildRepairSheet` renvoie des octets non vides sans exception (smoke).

## H3 — Petit ticket avec QR

Dans `repair_pdf.dart` — `buildRepairTicket({...})` / `printRepairTicket({...})` au format **rouleau 80 mm**
(`PdfPageFormat.roll80`, fourni par `printing`).
- **Contenu compact** : nom boutique, **`reference` en gros**, **QR proéminent centré**, client, appareil,
  date de dépôt, acompte/solde, ligne « Présentez ce ticket pour récupérer l'appareil ». Police Amiri (RTL ok).
- **Codec QR partagé** — nouveau `lib/features/repairs/application/repair_qr_codec.dart` :
  `String encode(String reference)` (URL/lien profond p.ex. `repairs/%23R-2048`, repli = réf brute) et
  `String? tryDecode(String payload)` (tolérant : URL, schéma custom, ou réf brute → extrait le jeton
  `#R-…` par regex). Utilisé pour **écrire** le QR (H2/H3) et le **lire** (H4).
- **QR à l'écran** (aperçu/feuille « Afficher le QR ») si besoin : `barcode` → SVG → `flutter_svg` (déjà
  dépendance) — **pas** de `qr_flutter`.

**Tests** : `repair_qr_codec_test` — round-trip `encode`↔`tryDecode` ; parse tolérant (URL / brut / custom /
invalide→null).

## H4 — Scanner le QR → détecter la réparation

**Nouvelle dépendance** : `mobile_scanner` (caméra : web/mobile/macOS ; **pas** Windows/Linux). *Choix
retenu : caméra + repli manuel.*
- Nouvel écran `lib/features/repairs/presentation/repair_scan_screen.dart` :
  - **Caméra** (si `kIsWeb` ou plateforme supportée) : aperçu `MobileScanner` ; à la détection →
    `RepairQrCodec.tryDecode` → `repairsProvider.byRef` → trouvé : ouvre le détail (route `repair-detail`) ;
    introuvable : toast « Réparation introuvable ».
  - **Repli manuel** (toujours dispo en bas ; **seul** contenu sur Windows/Linux — ne jamais instancier le
    contrôleur caméra sur ces OS) : champ **référence** + « Ouvrir » ; bouton **« Décoder depuis une image »**
    via `file_selector` (déjà dép) → `MobileScanner.analyzeImage`.
  - Garde plateforme via `defaultTargetPlatform`/`kIsWeb`.
- **Point d'entrée** : icône **scan** dans l'app bar de `repairs_screen.dart` (à côté du `＋`).
- **Config plateforme** (tâches à part) : Android `CAMERA`, iOS `NSCameraUsageDescription`, macOS entitlement
  caméra ; web nécessite **HTTPS**. À documenter dans le README.

**Tests** : le codec (H3) + navigation depuis la **saisie manuelle** (widget). La caméra n'est pas testée
unitairement (matériel).

## H5 — Finitions

- **i18n** complet des 4 ARBs (`app_fr` template + en/ar/es) : libellés formulaire d'admission, choix
  d'impression (Fiche Pro / Ticket), sections du PDF, écran de scan, messages d'erreur.
- **RTL** (ar) sur les feuilles et le PDF (déjà géré par Amiri/`rtl`) ; **thème clair/sombre** des écrans.
- États vides / erreurs (client introuvable au scan, permission caméra refusée).
- `task verify` à chaque phase (**vérifier surtout que le build web passe toujours après l'ajout de
  `mobile_scanner`**).

---

## Fichiers

- **Nouveaux** : `core/pdf/repair_pdf.dart`, `repairs/application/repair_qr_codec.dart`,
  `repairs/presentation/repair_scan_screen.dart` (+ le formulaire d'admission, dans `repairs_screen.dart`
  ou un fichier dédié) ; tests `repair_qr_codec_test`, `repair_pdf_test`, ajouts à `repairs_controller_test`.
- **Modifiés** : `repairs_controller.dart` (`add` + générateur), `repairs_screen.dart` (＋ réel + icône scan),
  `repair_detail.dart` (menu impression), `app_router.dart` (route `/repairs/:ref`),
  `core/pdf/document_pdf.dart` (extraire le helper thème/police), `pubspec.yaml` (`mobile_scanner`),
  les 4 `l10n/app_*.arb`. **Aucun** changement domaine/comptabilité existant.

## Risques / atténuations

- **`mobile_scanner` × 6 plateformes** → ne construire le contrôleur caméra **que** sur plateformes
  supportées ; repli manuel partout (dont la machine de dev **Windows**). Vérifier le **build web** après ajout.
- **`reference` avec `#` dans une URL/route** → encodage systématique (`Uri.encode…`) ; codec de décodage
  **tolérant** (regex `#R-…`) pour absorber les variantes de payload.
- **Fiche Pro vs Facture** → la fiche Pro est un **document de réparation** (admission/travaux/garantie),
  distinct de la facture légale existante (`_generateInvoice` reste la voie de facturation).

## Ordre

**H1 → H2 → H3 → H4 → H5**, une phase à la fois (revue entre chaque).
