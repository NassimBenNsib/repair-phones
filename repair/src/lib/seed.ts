import type {
  AppState,
  Invoice,
  LineItem,
  Part,
  Ticket,
  TicketStatus,
} from "./types";

// Toutes les dates sont relatives à l'ouverture de la session (démo crédible).
const now = Date.now();
const day = 86_400_000;
const at = (offsetDays: number, hour = 9) => {
  const d = new Date(now + offsetDays * day);
  d.setHours(hour, offsetDays % 2 ? 30 : 0, 0, 0);
  return d.toISOString();
};

let seq = 0;
const uid = (p: string) => `${p}${(++seq).toString().padStart(4, "0")}`;

const line = (
  designation: string,
  prixUnitaire: number,
  opts: Partial<LineItem> = {},
): LineItem => ({
  id: uid("l"),
  kind: opts.partId ? "piece" : opts.kind ?? "piece",
  designation,
  quantite: opts.quantite ?? 1,
  prixUnitaire,
  ...opts,
});

// ── Techniciens ──────────────────────────────────────────────────────────────
const techniciens = [
  { id: "u1", nom: "Karim Belkacem", role: "gerant" as const, couleur: "#4f46e5" },
  { id: "u2", nom: "Léa Fontaine", role: "technicien" as const, couleur: "#0ea5e9" },
  { id: "u3", nom: "Marco Rossi", role: "technicien" as const, couleur: "#10b981" },
  { id: "u4", nom: "Sophie Nguyen", role: "technicien" as const, couleur: "#f59e0b" },
];

// ── Fournisseurs ─────────────────────────────────────────────────────────────
const fournisseurs = [
  { id: "f1", nom: "MobiParts France", contact: "contact@mobiparts.fr", delaiJours: 2 },
  { id: "f2", nom: "iScreen Distribution", contact: "pro@iscreen.eu", delaiJours: 4 },
  { id: "f3", nom: "TechSupply EU", contact: "orders@techsupply.eu", delaiJours: 5 },
];

// ── Clients ──────────────────────────────────────────────────────────────────
const clients = [
  { id: "c1", nom: "Julien Moreau", telephone: "06 12 34 56 78", email: "j.moreau@gmail.com", note: "Client fidèle, préfère être appelé.", createdAt: at(-210) },
  { id: "c2", nom: "Amina Cherif", telephone: "07 88 45 12 90", email: "amina.cherif@outlook.fr", createdAt: at(-180) },
  { id: "c3", nom: "Thomas Petit", telephone: "06 45 78 21 33", email: "t.petit@free.fr", createdAt: at(-160) },
  { id: "c4", nom: "Camille Durand", telephone: "07 23 65 98 11", email: "camille.d@gmail.com", note: "Paye toujours en carte.", createdAt: at(-140) },
  { id: "c5", nom: "Boutique Le Comptoir", telephone: "01 45 22 33 44", email: "contact@lecomptoir.fr", note: "Compte pro — facturation mensuelle.", createdAt: at(-120) },
  { id: "c6", nom: "Nadia Benali", telephone: "06 77 88 99 10", email: "nadia.benali@gmail.com", createdAt: at(-95) },
  { id: "c7", nom: "Éric Lefebvre", telephone: "07 11 22 33 44", createdAt: at(-80) },
  { id: "c8", nom: "Sarah Cohen", telephone: "06 99 12 45 78", email: "sarah.cohen@icloud.com", createdAt: at(-60) },
  { id: "c9", nom: "Mehdi Aouad", telephone: "07 55 66 77 88", email: "mehdi.aouad@gmail.com", createdAt: at(-40) },
  { id: "c10", nom: "Laura Bianchi", telephone: "06 33 44 55 66", email: "laura.b@hotmail.fr", createdAt: at(-25) },
  { id: "c11", nom: "Paul Girard", telephone: "07 01 02 03 04", createdAt: at(-12) },
  { id: "c12", nom: "Fatou Diallo", telephone: "06 40 50 60 70", email: "f.diallo@gmail.com", createdAt: at(-4) },
];

// ── Appareils ────────────────────────────────────────────────────────────────
const devices = [
  { id: "d1", clientId: "c1", type: "smartphone" as const, marque: "Apple", modele: "iPhone 14 Pro", serie: "356789102345678", couleur: "Noir sidéral" },
  { id: "d2", clientId: "c1", type: "tablette" as const, marque: "Apple", modele: "iPad Air (5e gén.)", serie: "DMPX4567JCLM", couleur: "Bleu" },
  { id: "d3", clientId: "c2", type: "smartphone" as const, marque: "Samsung", modele: "Galaxy S23", serie: "352011113456789", couleur: "Vert" },
  { id: "d4", clientId: "c3", type: "smartphone" as const, marque: "Apple", modele: "iPhone 13", serie: "358234561234567", couleur: "Rose" },
  { id: "d5", clientId: "c4", type: "ordinateur" as const, marque: "Apple", modele: "MacBook Air M1", serie: "C02XL0AAJGH5", couleur: "Gris sidéral" },
  { id: "d6", clientId: "c5", type: "smartphone" as const, marque: "Apple", modele: "iPhone 15", serie: "359876543210987", couleur: "Titane naturel" },
  { id: "d7", clientId: "c6", type: "smartphone" as const, marque: "Xiaomi", modele: "Redmi Note 12", serie: "861234567890123", couleur: "Bleu" },
  { id: "d8", clientId: "c7", type: "console" as const, marque: "Nintendo", modele: "Switch OLED", serie: "XKW10023456789", couleur: "Blanc" },
  { id: "d9", clientId: "c8", type: "smartphone" as const, marque: "Apple", modele: "iPhone 12", serie: "357111223344556", couleur: "Bleu" },
  { id: "d10", clientId: "c9", type: "smartphone" as const, marque: "Samsung", modele: "Galaxy A54", serie: "353998877665544", couleur: "Noir" },
  { id: "d11", clientId: "c10", type: "tablette" as const, marque: "Samsung", modele: "Galaxy Tab S8", serie: "R52T90ABCDE", couleur: "Graphite" },
  { id: "d12", clientId: "c11", type: "smartphone" as const, marque: "Apple", modele: "iPhone 14", serie: "356010203040506", couleur: "Minuit" },
  { id: "d13", clientId: "c12", type: "smartphone" as const, marque: "Google", modele: "Pixel 7", serie: "864111222333444", couleur: "Obsidienne" },
  { id: "d14", clientId: "c2", type: "montre" as const, marque: "Apple", modele: "Apple Watch SE", serie: "GH8L2K3M4N5P", couleur: "Lumière stellaire" },
  { id: "d15", clientId: "c3", type: "smartphone" as const, marque: "Apple", modele: "iPhone 11", serie: "357222333444555", couleur: "Noir" },
  { id: "d16", clientId: "c8", type: "ordinateur" as const, marque: "Dell", modele: "XPS 13", serie: "DELLXPS13-7788", couleur: "Argent" },
];

// ── Pièces / Stock ───────────────────────────────────────────────────────────
type PSeed = Omit<Part, "mouvements"> & { mouvements?: Part["mouvements"] };
const partsSeed: PSeed[] = [
  { id: "p1", reference: "ECR-IP14P", designation: "Écran OLED iPhone 14 Pro", categorie: "Écrans", compatibilite: ["iPhone 14 Pro"], quantite: 4, seuil: 2, prixAchat: 95, prixVente: 189, fournisseurId: "f2", emplacement: "A1-03" },
  { id: "p2", reference: "ECR-IP13", designation: "Écran LCD iPhone 13", categorie: "Écrans", compatibilite: ["iPhone 13", "iPhone 13 mini"], quantite: 1, seuil: 2, prixAchat: 62, prixVente: 139, fournisseurId: "f2", emplacement: "A1-05" },
  { id: "p3", reference: "ECR-S23", designation: "Écran AMOLED Galaxy S23", categorie: "Écrans", compatibilite: ["Galaxy S23"], quantite: 0, seuil: 2, prixAchat: 110, prixVente: 219, fournisseurId: "f1", emplacement: "A2-01" },
  { id: "p4", reference: "BAT-IP14P", designation: "Batterie iPhone 14 Pro", categorie: "Batteries", compatibilite: ["iPhone 14 Pro"], quantite: 8, seuil: 3, prixAchat: 22, prixVente: 69, fournisseurId: "f1", emplacement: "B1-02" },
  { id: "p5", reference: "BAT-IP13", designation: "Batterie iPhone 13", categorie: "Batteries", compatibilite: ["iPhone 13"], quantite: 6, seuil: 3, prixAchat: 19, prixVente: 59, fournisseurId: "f1", emplacement: "B1-03" },
  { id: "p6", reference: "BAT-S23", designation: "Batterie Galaxy S23", categorie: "Batteries", compatibilite: ["Galaxy S23"], quantite: 2, seuil: 3, prixAchat: 24, prixVente: 65, fournisseurId: "f1", emplacement: "B2-01" },
  { id: "p7", reference: "CON-IP-L", designation: "Connecteur de charge Lightning", categorie: "Connecteurs", compatibilite: ["iPhone 11", "iPhone 12", "iPhone 13", "iPhone 14"], quantite: 12, seuil: 4, prixAchat: 8, prixVente: 39, fournisseurId: "f1", emplacement: "C1-01" },
  { id: "p8", reference: "CON-USBC", designation: "Connecteur de charge USB-C", categorie: "Connecteurs", compatibilite: ["Galaxy S23", "iPhone 15", "Pixel 7"], quantite: 3, seuil: 4, prixAchat: 9, prixVente: 42, fournisseurId: "f1", emplacement: "C1-02" },
  { id: "p9", reference: "VIT-IP14P", designation: "Vitre arrière iPhone 14 Pro", categorie: "Vitres", compatibilite: ["iPhone 14 Pro"], quantite: 5, seuil: 2, prixAchat: 15, prixVente: 59, fournisseurId: "f2", emplacement: "D1-01" },
  { id: "p10", reference: "VIT-S23", designation: "Vitre arrière Galaxy S23", categorie: "Vitres", compatibilite: ["Galaxy S23"], quantite: 0, seuil: 2, prixAchat: 14, prixVente: 55, fournisseurId: "f1", emplacement: "D1-02" },
  { id: "p11", reference: "NAP-IP13-CAM", designation: "Nappe caméra iPhone 13", categorie: "Nappes", compatibilite: ["iPhone 13"], quantite: 7, seuil: 2, prixAchat: 11, prixVente: 45, fournisseurId: "f3", emplacement: "E1-01" },
  { id: "p12", reference: "HP-IP14", designation: "Haut-parleur iPhone 14", categorie: "Audio", compatibilite: ["iPhone 14", "iPhone 14 Pro"], quantite: 9, seuil: 3, prixAchat: 6, prixVente: 35, fournisseurId: "f3", emplacement: "F1-01" },
  { id: "p13", reference: "ECR-IP15", designation: "Écran OLED iPhone 15", categorie: "Écrans", compatibilite: ["iPhone 15"], quantite: 3, seuil: 2, prixAchat: 105, prixVente: 209, fournisseurId: "f2", emplacement: "A1-08" },
  { id: "p14", reference: "BAT-MBA-M1", designation: "Batterie MacBook Air M1", categorie: "Batteries", compatibilite: ["MacBook Air M1"], quantite: 2, seuil: 1, prixAchat: 48, prixVente: 149, fournisseurId: "f3", emplacement: "B3-01" },
  { id: "p15", reference: "ECR-TABS8", designation: "Écran Galaxy Tab S8", categorie: "Écrans", compatibilite: ["Galaxy Tab S8"], quantite: 1, seuil: 1, prixAchat: 88, prixVente: 179, fournisseurId: "f1", emplacement: "A3-01" },
  { id: "p16", reference: "CON-SW-OLED", designation: "Connecteur de charge Switch OLED", categorie: "Connecteurs", compatibilite: ["Switch OLED"], quantite: 4, seuil: 2, prixAchat: 12, prixVente: 49, fournisseurId: "f3", emplacement: "C2-01" },
  { id: "p17", reference: "VIT-IP12", designation: "Vitre tactile iPhone 12", categorie: "Vitres", compatibilite: ["iPhone 12"], quantite: 6, seuil: 3, prixAchat: 10, prixVente: 49, fournisseurId: "f2", emplacement: "D2-01" },
  { id: "p18", reference: "BAT-PIX7", designation: "Batterie Pixel 7", categorie: "Batteries", compatibilite: ["Pixel 7"], quantite: 2, seuil: 2, prixAchat: 21, prixVente: 62, fournisseurId: "f1", emplacement: "B2-04" },
  { id: "p19", reference: "ECR-IP11", designation: "Écran LCD iPhone 11", categorie: "Écrans", compatibilite: ["iPhone 11"], quantite: 5, seuil: 3, prixAchat: 34, prixVente: 99, fournisseurId: "f2", emplacement: "A1-11" },
  { id: "p20", reference: "OUT-KIT", designation: "Kit joint d'étanchéité + colle B7000", categorie: "Consommables", compatibilite: ["Universel"], quantite: 22, seuil: 10, prixAchat: 2, prixVente: 12, fournisseurId: "f3", emplacement: "G1-01" },
];

// ── Tickets ──────────────────────────────────────────────────────────────────
type TSeed = {
  id: string; clientId: string; deviceId: string; symptomes: string;
  status: TicketStatus; priority: Ticket["priority"]; technicienId?: string;
  recuOffset: number; promisOffset?: number; clotureOffset?: number;
  photos: string[]; garantieMois: number; code?: string;
  lignes: LineItem[]; checklist: [string, boolean][];
};

const tSeed: TSeed[] = [
  {
    id: "R-2470", clientId: "c1", deviceId: "d1",
    symptomes: "Écran fissuré suite à une chute. Tactile partiellement inopérant en haut à droite.",
    status: "en_reparation", priority: "haute", technicienId: "u2",
    recuOffset: -1, promisOffset: 1, photos: ["📱", "🔧"], garantieMois: 3, code: "Face ID",
    lignes: [line("Écran OLED iPhone 14 Pro", 189, { partId: "p1" }), line("Main d'œuvre — remplacement écran", 45, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true], ["Face ID fonctionnel", true], ["Accessoires laissés (aucun)", true], ["Coque fournie", false]],
  },
  {
    id: "R-2469", clientId: "c2", deviceId: "d3",
    symptomes: "Ne charge plus. Port de charge oxydé, présence de résidus.",
    status: "attente_piece", priority: "normale", technicienId: "u3",
    recuOffset: -2, promisOffset: 2, photos: ["📱"], garantieMois: 3, code: "1234",
    lignes: [line("Connecteur de charge USB-C", 42, { partId: "p8" }), line("Main d'œuvre — nettoyage & remplacement port", 35, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true], ["Traces d'oxydation", true], ["SIM retirée", true]],
  },
  {
    id: "R-2468", clientId: "c3", deviceId: "d4",
    symptomes: "Batterie se décharge très vite, extinctions inopinées à 30 %.",
    status: "pret", priority: "normale", technicienId: "u2",
    recuOffset: -3, promisOffset: 0, photos: ["📱", "🔋"], garantieMois: 6,
    lignes: [line("Batterie iPhone 13", 59, { partId: "p5" }), line("Main d'œuvre — remplacement batterie", 35, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true], ["Santé batterie < 80 %", true], ["Étanchéité à refaire", true]],
  },
  {
    id: "R-2467", clientId: "c4", deviceId: "d5",
    symptomes: "N'atteint pas les 2h d'autonomie. Gonflement de la batterie suspecté.",
    status: "diagnostic", priority: "haute", technicienId: "u4",
    recuOffset: -1, promisOffset: 3, photos: ["💻"], garantieMois: 3, code: "azerty2024",
    lignes: [line("Diagnostic approfondi", 30, { kind: "main_oeuvre" })],
    checklist: [["Appareil démarre", true], ["Chargeur fourni", true], ["Sauvegarde recommandée", false]],
  },
  {
    id: "R-2466", clientId: "c6", deviceId: "d7",
    symptomes: "Écran noir mais vibre à l'allumage. Rétroéclairage HS possible.",
    status: "diagnostic", priority: "normale", technicienId: "u3",
    recuOffset: -2, promisOffset: 2, photos: ["📱"], garantieMois: 3,
    lignes: [line("Diagnostic", 25, { kind: "main_oeuvre" })],
    checklist: [["Réagit au toucher (vibration)", true], ["Chute signalée", false]],
  },
  {
    id: "R-2465", clientId: "c8", deviceId: "d9",
    symptomes: "Vitre tactile fêlée, fonctionne mais coupe par endroits.",
    status: "recu", priority: "basse", technicienId: undefined,
    recuOffset: 0, promisOffset: 4, photos: ["📱"], garantieMois: 3, code: "0000",
    lignes: [],
    checklist: [["Appareil s'allume", true], ["Coque + verre trempé fournis", true]],
  },
  {
    id: "R-2464", clientId: "c7", deviceId: "d8",
    symptomes: "Ne charge que par intermittence sur le dock. Joy-Con droit qui drift.",
    status: "attente_piece", priority: "normale", technicienId: "u4",
    recuOffset: -4, promisOffset: 1, photos: ["🎮"], garantieMois: 3,
    lignes: [line("Connecteur de charge Switch OLED", 49, { partId: "p16" }), line("Main d'œuvre", 40, { kind: "main_oeuvre" })],
    checklist: [["Console s'allume", true], ["Dock fourni", true], ["Joy-Con fournis (x2)", true]],
  },
  {
    id: "R-2463", clientId: "c5", deviceId: "d6",
    symptomes: "Haut-parleur inférieur grésille pendant les appels.",
    status: "en_reparation", priority: "normale", technicienId: "u2",
    recuOffset: -1, promisOffset: 1, photos: ["📱"], garantieMois: 3,
    lignes: [line("Haut-parleur iPhone 14", 35, { partId: "p12" }), line("Main d'œuvre", 30, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true], ["Test audio effectué", true]],
  },
  {
    id: "R-2462", clientId: "c9", deviceId: "d10",
    symptomes: "Chute dans l'eau. N'affiche plus rien, à ouvrir pour nettoyage.",
    status: "diagnostic", priority: "urgente", technicienId: "u3",
    recuOffset: 0, promisOffset: 2, photos: ["📱", "💧"], garantieMois: 0, code: "schéma",
    lignes: [line("Diagnostic oxydation + nettoyage ultrasons", 45, { kind: "main_oeuvre" })],
    checklist: [["Appareil hors tension", true], ["Client informé (données à risque)", true]],
  },
  {
    id: "R-2461", clientId: "c10", deviceId: "d11",
    symptomes: "Écran fissuré en bas, lignes verticales à l'affichage.",
    status: "attente_piece", priority: "normale", technicienId: "u4",
    recuOffset: -3, promisOffset: 3, photos: ["📱"], garantieMois: 3,
    lignes: [line("Écran Galaxy Tab S8", 179, { partId: "p15" }), line("Main d'œuvre — remplacement écran tablette", 60, { kind: "main_oeuvre" })],
    checklist: [["Tablette s'allume", true], ["Stylet S-Pen fourni", true]],
  },
  {
    id: "R-2460", clientId: "c11", deviceId: "d12",
    symptomes: "Bouton volume enfoncé, reste bloqué.",
    status: "pret", priority: "basse", technicienId: "u2",
    recuOffset: -2, promisOffset: 0, photos: ["📱"], garantieMois: 3,
    lignes: [line("Nappe boutons + réparation mécanique", 39, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true], ["Boutons testés", true]],
  },
  {
    id: "R-2459", clientId: "c12", deviceId: "d13",
    symptomes: "Batterie gonflée, écran légèrement décollé.",
    status: "recu", priority: "haute", technicienId: undefined,
    recuOffset: 0, promisOffset: 3, photos: ["📱", "🔋"], garantieMois: 6,
    lignes: [],
    checklist: [["Appareil s'allume", true], ["Gonflement confirmé", true], ["Manipulation prudente", true]],
  },
  {
    id: "R-2458", clientId: "c3", deviceId: "d15",
    symptomes: "Ne s'allume plus après mise à jour. À reflasher ou changer connecteur.",
    status: "en_reparation", priority: "normale", technicienId: "u3",
    recuOffset: -2, promisOffset: 1, photos: ["📱"], garantieMois: 3,
    lignes: [line("Connecteur de charge Lightning", 39, { partId: "p7" }), line("Main d'œuvre — diagnostic & remplacement", 40, { kind: "main_oeuvre" })],
    checklist: [["Réagit au chargeur", false], ["Écran intact", true]],
  },
  {
    id: "R-2457", clientId: "c8", deviceId: "d16",
    symptomes: "Ventilateur bruyant, surchauffe. Nettoyage + pâte thermique.",
    status: "pret", priority: "normale", technicienId: "u4",
    recuOffset: -4, promisOffset: -1, photos: ["💻"], garantieMois: 3, code: "1234",
    lignes: [line("Nettoyage complet + pâte thermique", 55, { kind: "main_oeuvre" })],
    checklist: [["Démarre correctement", true], ["Chargeur fourni", true]],
  },
  // ── Tickets restitués (historique / CA) ─────────────────────────────────────
  {
    id: "R-2456", clientId: "c1", deviceId: "d2",
    symptomes: "Vitre avant fissurée sur iPad Air.",
    status: "restitue", priority: "normale", technicienId: "u2",
    recuOffset: -12, promisOffset: -9, clotureOffset: -9, photos: ["📱"], garantieMois: 3,
    lignes: [line("Vitre tactile iPad Air", 89), line("Main d'œuvre", 50, { kind: "main_oeuvre" })],
    checklist: [["Tablette s'allume", true]],
  },
  {
    id: "R-2455", clientId: "c4", deviceId: "d5",
    symptomes: "Clavier — touches E et R non réactives.",
    status: "restitue", priority: "normale", technicienId: "u4",
    recuOffset: -18, promisOffset: -14, clotureOffset: -14, photos: ["💻"], garantieMois: 3,
    lignes: [line("Nappe clavier", 45), line("Main d'œuvre", 60, { kind: "main_oeuvre" })],
    checklist: [["Démarre", true]],
  },
  {
    id: "R-2454", clientId: "c2", deviceId: "d14",
    symptomes: "Apple Watch — batterie faible, autonomie < 1 jour.",
    status: "restitue", priority: "basse", technicienId: "u3",
    recuOffset: -22, promisOffset: -19, clotureOffset: -19, photos: ["⌚"], garantieMois: 6,
    lignes: [line("Batterie Apple Watch SE", 49), line("Main d'œuvre", 45, { kind: "main_oeuvre" })],
    checklist: [["Montre s'allume", true]],
  },
  {
    id: "R-2453", clientId: "c6", deviceId: "d7",
    symptomes: "Remplacement vitre arrière.",
    status: "restitue", priority: "basse", technicienId: "u2",
    recuOffset: -8, promisOffset: -6, clotureOffset: -6, photos: ["📱"], garantieMois: 3,
    lignes: [line("Vitre arrière", 49), line("Main d'œuvre", 30, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true]],
  },
  {
    id: "R-2452", clientId: "c9", deviceId: "d10",
    symptomes: "Changement écran Galaxy A54.",
    status: "restitue", priority: "normale", technicienId: "u3",
    recuOffset: -6, promisOffset: -4, clotureOffset: -4, photos: ["📱"], garantieMois: 3,
    lignes: [line("Écran Galaxy A54", 129), line("Main d'œuvre", 45, { kind: "main_oeuvre" })],
    checklist: [["Appareil s'allume", true]],
  },
  {
    id: "R-2451", clientId: "c10", deviceId: "d11",
    symptomes: "Diagnostic — appareil lent, nettoyage logiciel.",
    status: "restitue", priority: "basse", technicienId: "u4",
    recuOffset: -3, promisOffset: -2, clotureOffset: -1, photos: ["📱"], garantieMois: 0,
    lignes: [line("Optimisation & nettoyage logiciel", 39, { kind: "main_oeuvre" })],
    checklist: [["Appareil fonctionnel", true]],
  },
];

function buildTicket(t: TSeed): Ticket {
  const history: Ticket["history"] = [{ status: "recu", at: at(t.recuOffset) }];
  const idx = ["recu", "diagnostic", "attente_piece", "en_reparation", "pret", "restitue"].indexOf(t.status);
  for (let i = 1; i <= idx; i++) {
    const st = ["recu", "diagnostic", "attente_piece", "en_reparation", "pret", "restitue"][i] as TicketStatus;
    history.push({ status: st, at: at(t.recuOffset + i * 0.4) });
  }
  return {
    id: t.id, clientId: t.clientId, deviceId: t.deviceId, symptomes: t.symptomes,
    status: t.status, priority: t.priority, technicienId: t.technicienId,
    recuAt: at(t.recuOffset), promisAt: t.promisOffset !== undefined ? at(t.promisOffset) : undefined,
    clotureAt: t.clotureOffset !== undefined ? at(t.clotureOffset) : undefined,
    photos: t.photos, garantieMois: t.garantieMois, codeDeverrouillage: t.code,
    lignes: t.lignes,
    checklist: t.checklist.map(([label, checked]) => ({ id: uid("ck"), label, checked })),
    history,
  };
}

// ── Factures / Devis ─────────────────────────────────────────────────────────
const invoices: Invoice[] = [
  // Tickets restitués → factures payées (CA)
  mkInvoice("F-2456", "R-2456", "c1", "facture", "paye", -9, [line("Vitre tactile iPad Air", 89), line("Main d'œuvre", 50, { kind: "main_oeuvre" })], [{ moyen: "carte", offset: -9 }]),
  mkInvoice("F-2455", "R-2455", "c4", "facture", "paye", -14, [line("Nappe clavier", 45), line("Main d'œuvre", 60, { kind: "main_oeuvre" })], [{ moyen: "carte", offset: -14 }]),
  mkInvoice("F-2454", "R-2454", "c2", "facture", "paye", -19, [line("Batterie Apple Watch SE", 49), line("Main d'œuvre", 45, { kind: "main_oeuvre" })], [{ moyen: "especes", offset: -19 }]),
  mkInvoice("F-2453", "R-2453", "c6", "facture", "paye", -6, [line("Vitre arrière", 49), line("Main d'œuvre", 30, { kind: "main_oeuvre" })], [{ moyen: "carte", offset: -6 }]),
  mkInvoice("F-2452", "R-2452", "c9", "facture", "paye", -4, [line("Écran Galaxy A54", 129), line("Main d'œuvre", 45, { kind: "main_oeuvre" })], [{ moyen: "virement", offset: -3 }]),
  mkInvoice("F-2451", "R-2451", "c10", "facture", "paye", -1, [line("Optimisation & nettoyage logiciel", 39, { kind: "main_oeuvre" })], [{ moyen: "carte", offset: -1 }]),
  // Tickets prêts → factures émises, encaissement partiel/à venir
  mkInvoice("F-2468", "R-2468", "c3", "facture", "impaye", -1, [line("Batterie iPhone 13", 59), line("Main d'œuvre", 35, { kind: "main_oeuvre" })], []),
  mkInvoice("F-2460", "R-2460", "c11", "facture", "paye", 0, [line("Nappe boutons + réparation", 39, { kind: "main_oeuvre" })], [{ moyen: "especes", offset: 0 }]),
  mkInvoice("F-2457", "R-2457", "c8", "facture", "impaye", -1, [line("Nettoyage + pâte thermique", 55, { kind: "main_oeuvre" })], [{ moyen: "carte", offset: -1, montant: 30 }]),
  // Devis en cours
  mkInvoice("D-2470", "R-2470", "c1", "devis", "accepte", -1, [line("Écran OLED iPhone 14 Pro", 189), line("Main d'œuvre", 45, { kind: "main_oeuvre" })], []),
  mkInvoice("D-2461", "R-2461", "c10", "devis", "envoye", -3, [line("Écran Galaxy Tab S8", 179), line("Main d'œuvre", 60, { kind: "main_oeuvre" })], []),
  mkInvoice("D-2467", "R-2467", "c4", "devis", "brouillon", -1, [line("Batterie MacBook Air M1", 149), line("Main d'œuvre", 70, { kind: "main_oeuvre" })], []),
];

function mkInvoice(
  id: string, ticketId: string, clientId: string,
  type: Invoice["type"], status: Invoice["status"], offset: number,
  lignes: LineItem[],
  paiements: { moyen: "especes" | "carte" | "virement"; offset: number; montant?: number }[],
): Invoice {
  const totalTTC = lignes.reduce((s, l) => s + l.quantite * l.prixUnitaire, 0) * 1.2;
  return {
    id, ticketId, clientId, type, status,
    lignes: lignes.map((l) => ({ ...l, id: uid("il") })),
    remisePct: 0, tvaPct: 20, createdAt: at(offset),
    paiements: paiements.map((p) => ({
      id: uid("pay"), moyen: p.moyen, at: at(p.offset),
      montant: p.montant ?? +totalTTC.toFixed(2),
    })),
  };
}

export function buildSeed(): AppState {
  const tickets = tSeed.map(buildTicket);
  // Rattache les factures aux tickets
  for (const inv of invoices) {
    if (inv.type === "facture") {
      const tk = tickets.find((t) => t.id === inv.ticketId);
      if (tk) tk.invoiceId = inv.id;
    }
  }
  const parts: Part[] = partsSeed.map((p) => ({
    ...p,
    mouvements: [
      { id: uid("mv"), at: at(-30), delta: p.quantite + 4, motif: "Réception fournisseur" },
      { id: uid("mv"), at: at(-8), delta: -2, motif: "Sortie tickets" },
    ],
  }));

  return {
    atelier: {
      nom: "Atelier Réparation Express",
      tvaPct: 20,
      garantieMoisDefaut: 3,
      adresse: "24 rue des Artisans, 75011 Paris",
      telephone: "01 43 55 22 10",
    },
    clients, devices, tickets, parts, invoices, techniciens, fournisseurs,
  };
}
