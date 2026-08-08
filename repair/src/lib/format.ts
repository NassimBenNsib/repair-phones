import type {
  DeviceType,
  InvoiceStatus,
  PaymentMethod,
  Priority,
  TicketStatus,
} from "./types";

// ── Monnaie & nombres ────────────────────────────────────────────────────────
const euro = new Intl.NumberFormat("fr-FR", {
  style: "currency",
  currency: "EUR",
  minimumFractionDigits: 2,
});

export const fmtEuro = (n: number) => euro.format(n);

export const fmtEuroCompact = (n: number) =>
  new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format(n);

// ── Dates ────────────────────────────────────────────────────────────────────
export const fmtDate = (iso?: string) =>
  iso
    ? new Date(iso).toLocaleDateString("fr-FR", {
        day: "2-digit",
        month: "short",
      })
    : "—";

export const fmtDateLong = (iso?: string) =>
  iso
    ? new Date(iso).toLocaleDateString("fr-FR", {
        weekday: "long",
        day: "numeric",
        month: "long",
        year: "numeric",
      })
    : "—";

export const fmtDateTime = (iso?: string) =>
  iso
    ? new Date(iso).toLocaleString("fr-FR", {
        day: "2-digit",
        month: "short",
        hour: "2-digit",
        minute: "2-digit",
      })
    : "—";

/** Écart en jours par rapport à « maintenant » (négatif = passé). */
export function daysFromNow(iso?: string, now: Date = new Date()): number | null {
  if (!iso) return null;
  const ms = new Date(iso).getTime() - now.getTime();
  return Math.round(ms / 86_400_000);
}

export function relativeDue(iso?: string, now?: Date): string {
  const d = daysFromNow(iso, now);
  if (d === null) return "—";
  if (d === 0) return "Aujourd'hui";
  if (d === 1) return "Demain";
  if (d === -1) return "Hier";
  if (d < 0) return `Retard ${-d} j`;
  return `Dans ${d} j`;
}

// ── Libellés de statut ───────────────────────────────────────────────────────
export const TICKET_STATUS_META: Record<
  TicketStatus,
  { label: string; tone: BadgeTone; icon: string; step: number }
> = {
  recu: { label: "Reçu", tone: "neutral", icon: "inbox", step: 0 },
  diagnostic: { label: "Diagnostic", tone: "info", icon: "search", step: 1 },
  attente_piece: {
    label: "Attente pièce",
    tone: "warning",
    icon: "clock",
    step: 2,
  },
  en_reparation: {
    label: "En réparation",
    tone: "accent",
    icon: "wrench",
    step: 3,
  },
  pret: { label: "Prêt", tone: "success", icon: "check", step: 4 },
  restitue: { label: "Restitué", tone: "muted", icon: "handshake", step: 5 },
};

export const PRIORITY_META: Record<
  Priority,
  { label: string; tone: BadgeTone }
> = {
  basse: { label: "Basse", tone: "muted" },
  normale: { label: "Normale", tone: "neutral" },
  haute: { label: "Haute", tone: "warning" },
  urgente: { label: "Urgente", tone: "danger" },
};

export const INVOICE_STATUS_META: Record<
  InvoiceStatus,
  { label: string; tone: BadgeTone }
> = {
  brouillon: { label: "Brouillon", tone: "muted" },
  envoye: { label: "Envoyé", tone: "info" },
  accepte: { label: "Accepté", tone: "accent" },
  paye: { label: "Payé", tone: "success" },
  impaye: { label: "Impayé", tone: "danger" },
};

export const PAYMENT_META: Record<PaymentMethod, { label: string; icon: string }> =
  {
    especes: { label: "Espèces", icon: "cash" },
    carte: { label: "Carte", icon: "card" },
    virement: { label: "Virement", icon: "bank" },
  };

export const DEVICE_META: Record<DeviceType, { label: string; icon: string }> = {
  smartphone: { label: "Smartphone", icon: "mobile" },
  tablette: { label: "Tablette", icon: "tablet" },
  ordinateur: { label: "Ordinateur", icon: "laptop" },
  console: { label: "Console", icon: "gamepad" },
  montre: { label: "Montre", icon: "watch" },
  autre: { label: "Autre", icon: "device" },
};

export type BadgeTone =
  | "neutral"
  | "muted"
  | "accent"
  | "info"
  | "success"
  | "warning"
  | "danger";

// ── Calculs facture ──────────────────────────────────────────────────────────
export function computeTotals(
  lignes: { quantite: number; prixUnitaire: number }[],
  remisePct = 0,
  tvaPct = 20,
) {
  const sousTotal = lignes.reduce(
    (s, l) => s + l.quantite * l.prixUnitaire,
    0,
  );
  const remise = sousTotal * (remisePct / 100);
  const baseHT = sousTotal - remise;
  const tva = baseHT * (tvaPct / 100);
  const totalTTC = baseHT + tva;
  return { sousTotal, remise, baseHT, tva, totalTTC };
}

export function initials(nom: string): string {
  return nom
    .split(/\s+/)
    .slice(0, 2)
    .map((p) => p[0]?.toUpperCase() ?? "")
    .join("");
}

export function stockState(p: { quantite: number; seuil: number }): "ok" | "bas" | "rupture" {
  if (p.quantite <= 0) return "rupture";
  if (p.quantite <= p.seuil) return "bas";
  return "ok";
}
