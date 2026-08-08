// ─────────────────────────────────────────────────────────────────────────────
// Modèle de données « Atelier »
// Schéma logique : Client → Appareils → Tickets → Lignes (pièces/main d'œuvre)
//                  Ticket → Devis/Facture → Paiements
//                  Pièce (stock) ⇄ mouvements liés aux tickets
// ─────────────────────────────────────────────────────────────────────────────

export type ID = string;

/** Cycle de vie d'un ticket de réparation. */
export type TicketStatus =
  | "recu"
  | "diagnostic"
  | "attente_piece"
  | "en_reparation"
  | "pret"
  | "restitue";

export const TICKET_FLOW: TicketStatus[] = [
  "recu",
  "diagnostic",
  "attente_piece",
  "en_reparation",
  "pret",
  "restitue",
];

export type Priority = "basse" | "normale" | "haute" | "urgente";

export type DeviceType =
  | "smartphone"
  | "tablette"
  | "ordinateur"
  | "console"
  | "montre"
  | "autre";

export interface Client {
  id: ID;
  nom: string;
  telephone: string;
  email?: string;
  note?: string;
  createdAt: string; // ISO
}

export interface Device {
  id: ID;
  clientId: ID;
  type: DeviceType;
  marque: string;
  modele: string;
  serie?: string; // IMEI / n° de série
  couleur?: string;
}

/** Ligne d'un ticket / devis / facture. */
export interface LineItem {
  id: ID;
  kind: "piece" | "main_oeuvre";
  partId?: ID; // si kind === "piece"
  designation: string;
  quantite: number;
  prixUnitaire: number; // € HT
}

export interface ChecklistItem {
  id: ID;
  label: string;
  checked: boolean;
}

export interface StatusEvent {
  status: TicketStatus;
  at: string; // ISO
  note?: string;
}

export interface Ticket {
  id: ID; // n° affiché, ex. "R-2451"
  clientId: ID;
  deviceId: ID;
  symptomes: string;
  status: TicketStatus;
  priority: Priority;
  technicienId?: ID;
  recuAt: string; // date de réception (ISO)
  promisAt?: string; // date promise (ISO)
  clotureAt?: string; // date de clôture (ISO)
  photos: string[]; // emojis/placeholders — pas de vrais binaires en démo
  checklist: ChecklistItem[];
  lignes: LineItem[];
  history: StatusEvent[];
  garantieMois: number;
  codeDeverrouillage?: string;
  invoiceId?: ID;
}

export type InvoiceStatus =
  | "brouillon"
  | "envoye"
  | "accepte"
  | "paye"
  | "impaye";

export type PaymentMethod = "especes" | "carte" | "virement";

export interface Payment {
  id: ID;
  montant: number;
  moyen: PaymentMethod;
  at: string; // ISO
}

/** Document unifié Devis/Facture (un devis accepté devient facture). */
export interface Invoice {
  id: ID; // ex. "F-2451" ou "D-2451"
  ticketId: ID;
  clientId: ID;
  type: "devis" | "facture";
  status: InvoiceStatus;
  lignes: LineItem[];
  remisePct: number;
  tvaPct: number;
  createdAt: string;
  paiements: Payment[];
}

export type StockState = "ok" | "bas" | "rupture";

export interface StockMovement {
  id: ID;
  at: string; // ISO
  delta: number; // + entrée, - sortie
  motif: string; // ex. "Sortie ticket R-2451", "Réception fournisseur"
  ticketId?: ID;
}

export interface Part {
  id: ID;
  reference: string;
  designation: string;
  categorie: string;
  compatibilite: string[]; // modèles compatibles
  quantite: number;
  seuil: number; // seuil d'alerte
  prixAchat: number;
  prixVente: number;
  fournisseurId?: ID;
  emplacement?: string;
  mouvements: StockMovement[];
}

export type Role = "gerant" | "technicien";

export interface Technicien {
  id: ID;
  nom: string;
  role: Role;
  couleur: string; // pour l'avatar/monogramme
}

export interface Fournisseur {
  id: ID;
  nom: string;
  contact?: string;
  delaiJours: number;
}

export interface Atelier {
  nom: string;
  tvaPct: number;
  garantieMoisDefaut: number;
  adresse: string;
  telephone: string;
}

export interface AppState {
  atelier: Atelier;
  clients: Client[];
  devices: Device[];
  tickets: Ticket[];
  parts: Part[];
  invoices: Invoice[];
  techniciens: Technicien[];
  fournisseurs: Fournisseur[];
}
