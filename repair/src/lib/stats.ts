import { computeTotals } from "./format";
import type { AppState, Invoice } from "./types";

const DAY = 86_400_000;

const paidTotal = (inv: Invoice) =>
  inv.paiements.reduce((s, p) => s + p.montant, 0);

const startOfDay = (d: Date) => {
  const x = new Date(d);
  x.setHours(0, 0, 0, 0);
  return x.getTime();
};

/** Chiffre d'affaires encaissé sur une fenêtre glissante (paiements). */
export function revenue(state: AppState, sinceDays: number, now = Date.now()) {
  const from = now - sinceDays * DAY;
  let total = 0;
  for (const inv of state.invoices) {
    for (const p of inv.paiements) {
      if (new Date(p.at).getTime() >= from) total += p.montant;
    }
  }
  return total;
}

export function revenueToday(state: AppState, now = new Date()) {
  const from = startOfDay(now);
  let total = 0;
  for (const inv of state.invoices)
    for (const p of inv.paiements)
      if (new Date(p.at).getTime() >= from) total += p.montant;
  return total;
}

/** Série de CA encaissé par jour sur N jours (pour le sparkline). */
export function revenueSeries(state: AppState, days: number, now = new Date()) {
  const today = startOfDay(now);
  const buckets = new Array(days).fill(0);
  for (const inv of state.invoices) {
    for (const p of inv.paiements) {
      const idx = Math.floor((startOfDay(new Date(p.at)) - today) / DAY) + days - 1;
      if (idx >= 0 && idx < days) buckets[idx] += p.montant;
    }
  }
  return buckets;
}

export function dashboardStats(state: AppState, now = new Date()) {
  const open = state.tickets.filter((t) => t.status !== "restitue");
  const prets = state.tickets.filter((t) => t.status === "pret");
  const late = open.filter(
    (t) =>
      t.promisAt &&
      new Date(t.promisAt).getTime() < now.getTime() &&
      t.status !== "pret",
  );
  const stockBas = state.parts.filter((p) => p.quantite <= p.seuil);
  const ruptures = state.parts.filter((p) => p.quantite <= 0);
  const impayes = state.invoices.filter((i) => {
    const { totalTTC } = computeTotals(i.lignes, i.remisePct, i.tvaPct);
    return i.type === "facture" && paidTotal(i) < totalTTC - 0.01;
  });
  return { open, prets, late, stockBas, ruptures, impayes };
}

/** Charge par technicien (tickets ouverts assignés). */
export function techLoad(state: AppState) {
  return state.techniciens.map((tech) => {
    const tickets = state.tickets.filter(
      (t) => t.technicienId === tech.id && t.status !== "restitue",
    );
    const urgent = tickets.filter(
      (t) => t.priority === "urgente" || t.priority === "haute",
    ).length;
    return { tech, tickets, urgent };
  });
}

/** Reste dû d'une facture. */
export function resteDu(inv: Invoice) {
  const { totalTTC } = computeTotals(inv.lignes, inv.remisePct, inv.tvaPct);
  return Math.max(0, totalTTC - paidTotal(inv));
}
