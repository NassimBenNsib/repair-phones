"use client";

import {
  createContext,
  useContext,
  useMemo,
  useReducer,
  type ReactNode,
} from "react";
import { buildSeed } from "./seed";
import { computeTotals } from "./format";
import type {
  AppState,
  Invoice,
  LineItem,
  Part,
  Payment,
  Ticket,
  TicketStatus,
} from "./types";

// Génération d'ID runtime (session en mémoire uniquement — pas de persistance).
let counter = 0;
const rid = (p: string) =>
  `${p}${Date.now().toString(36)}${(counter++).toString(36)}`;

// ─────────────────────────────────────────────────────────────────────────────
// Actions
// ─────────────────────────────────────────────────────────────────────────────
type Action =
  | { type: "SET_STATUS"; ticketId: string; status: TicketStatus; note?: string }
  | { type: "ASSIGN"; ticketId: string; technicienId?: string }
  | { type: "SET_PRIORITY"; ticketId: string; priority: Ticket["priority"] }
  | { type: "TOGGLE_CHECK"; ticketId: string; itemId: string }
  | { type: "ADD_LINE"; ticketId: string; line: LineItem }
  | { type: "REMOVE_LINE"; ticketId: string; lineId: string }
  | { type: "CREATE_TICKET"; ticket: Ticket }
  | { type: "GEN_INVOICE"; ticketId: string; docType: "devis" | "facture" }
  | { type: "SET_INVOICE_STATUS"; invoiceId: string; status: Invoice["status"] }
  | { type: "ADD_PAYMENT"; invoiceId: string; payment: Payment }
  | { type: "RESTOCK"; partId: string; qty: number; motif: string }
  | { type: "ADJUST"; partId: string; qty: number }
  | { type: "ADD_PART"; part: Part }
  | { type: "ADD_CLIENT"; client: AppState["clients"][number]; device?: AppState["devices"][number] }
  | { type: "ADD_DEVICE"; device: AppState["devices"][number] }
  | { type: "UPDATE_ATELIER"; patch: Partial<AppState["atelier"]> };

const FLOW: TicketStatus[] = [
  "recu",
  "diagnostic",
  "attente_piece",
  "en_reparation",
  "pret",
  "restitue",
];

/** Consomme les pièces d'un ticket dans le stock (idempotent par ticket+pièce). */
function consumeParts(state: AppState, ticket: Ticket): Part[] {
  return state.parts.map((part) => {
    const ligne = ticket.lignes.find(
      (l) => l.kind === "piece" && l.partId === part.id,
    );
    if (!ligne) return part;
    const already = part.mouvements.some(
      (m) => m.ticketId === ticket.id && m.delta < 0,
    );
    if (already) return part;
    return {
      ...part,
      quantite: part.quantite - ligne.quantite,
      mouvements: [
        {
          id: rid("mv"),
          at: new Date().toISOString(),
          delta: -ligne.quantite,
          motif: `Sortie ticket ${ticket.id}`,
          ticketId: ticket.id,
        },
        ...part.mouvements,
      ],
    };
  });
}

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case "SET_STATUS": {
      const now = new Date().toISOString();
      let parts = state.parts;
      const tickets = state.tickets.map((t) => {
        if (t.id !== action.ticketId) return t;
        const updated: Ticket = {
          ...t,
          status: action.status,
          clotureAt: action.status === "restitue" ? now : t.clotureAt,
          history: [
            ...t.history,
            { status: action.status, at: now, note: action.note },
          ],
        };
        // Interconnexion : passer « en réparation » consomme les pièces du stock.
        if (
          action.status === "en_reparation" ||
          action.status === "pret" ||
          action.status === "restitue"
        ) {
          parts = consumeParts({ ...state, parts }, updated);
        }
        return updated;
      });
      return { ...state, tickets, parts };
    }

    case "ASSIGN":
      return {
        ...state,
        tickets: state.tickets.map((t) =>
          t.id === action.ticketId
            ? { ...t, technicienId: action.technicienId }
            : t,
        ),
      };

    case "SET_PRIORITY":
      return {
        ...state,
        tickets: state.tickets.map((t) =>
          t.id === action.ticketId ? { ...t, priority: action.priority } : t,
        ),
      };

    case "TOGGLE_CHECK":
      return {
        ...state,
        tickets: state.tickets.map((t) =>
          t.id === action.ticketId
            ? {
                ...t,
                checklist: t.checklist.map((c) =>
                  c.id === action.itemId ? { ...c, checked: !c.checked } : c,
                ),
              }
            : t,
        ),
      };

    case "ADD_LINE":
      return {
        ...state,
        tickets: state.tickets.map((t) =>
          t.id === action.ticketId
            ? { ...t, lignes: [...t.lignes, action.line] }
            : t,
        ),
      };

    case "REMOVE_LINE":
      return {
        ...state,
        tickets: state.tickets.map((t) =>
          t.id === action.ticketId
            ? { ...t, lignes: t.lignes.filter((l) => l.id !== action.lineId) }
            : t,
        ),
      };

    case "CREATE_TICKET":
      return { ...state, tickets: [action.ticket, ...state.tickets] };

    case "GEN_INVOICE": {
      const ticket = state.tickets.find((t) => t.id === action.ticketId);
      if (!ticket) return state;
      const num = ticket.id.replace("R-", action.docType === "facture" ? "F-" : "D-");
      const inv: Invoice = {
        id: state.invoices.some((i) => i.id === num) ? `${num}-${rid("")}` : num,
        ticketId: ticket.id,
        clientId: ticket.clientId,
        type: action.docType,
        status: action.docType === "facture" ? "impaye" : "brouillon",
        lignes: ticket.lignes.map((l) => ({ ...l, id: rid("il") })),
        remisePct: 0,
        tvaPct: state.atelier.tvaPct,
        createdAt: new Date().toISOString(),
        paiements: [],
      };
      return {
        ...state,
        invoices: [inv, ...state.invoices],
        tickets: state.tickets.map((t) =>
          t.id === ticket.id && action.docType === "facture"
            ? { ...t, invoiceId: inv.id }
            : t,
        ),
      };
    }

    case "SET_INVOICE_STATUS":
      return {
        ...state,
        invoices: state.invoices.map((i) =>
          i.id === action.invoiceId ? { ...i, status: action.status } : i,
        ),
      };

    case "ADD_PAYMENT":
      return {
        ...state,
        invoices: state.invoices.map((i) => {
          if (i.id !== action.invoiceId) return i;
          const paiements = [...i.paiements, action.payment];
          const { totalTTC } = computeTotals(i.lignes, i.remisePct, i.tvaPct);
          const paye = paiements.reduce((s, p) => s + p.montant, 0);
          return {
            ...i,
            paiements,
            status: paye >= totalTTC - 0.01 ? "paye" : i.status,
          };
        }),
      };

    case "RESTOCK":
      return {
        ...state,
        parts: state.parts.map((p) =>
          p.id === action.partId
            ? {
                ...p,
                quantite: p.quantite + action.qty,
                mouvements: [
                  {
                    id: rid("mv"),
                    at: new Date().toISOString(),
                    delta: action.qty,
                    motif: action.motif,
                  },
                  ...p.mouvements,
                ],
              }
            : p,
        ),
      };

    case "ADJUST":
      return {
        ...state,
        parts: state.parts.map((p) =>
          p.id === action.partId
            ? {
                ...p,
                mouvements: [
                  {
                    id: rid("mv"),
                    at: new Date().toISOString(),
                    delta: action.qty - p.quantite,
                    motif: "Ajustement d'inventaire",
                  },
                  ...p.mouvements,
                ],
                quantite: action.qty,
              }
            : p,
        ),
      };

    case "ADD_PART":
      return { ...state, parts: [action.part, ...state.parts] };

    case "ADD_CLIENT":
      return {
        ...state,
        clients: [action.client, ...state.clients],
        devices: action.device
          ? [action.device, ...state.devices]
          : state.devices,
      };

    case "ADD_DEVICE":
      return { ...state, devices: [action.device, ...state.devices] };

    case "UPDATE_ATELIER":
      return { ...state, atelier: { ...state.atelier, ...action.patch } };

    default:
      return state;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contexte + hook
// ─────────────────────────────────────────────────────────────────────────────
interface Store {
  state: AppState;
  dispatch: React.Dispatch<Action>;
  rid: (p: string) => string;
}

const StoreCtx = createContext<Store | null>(null);

export function StoreProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(reducer, undefined, buildSeed);
  const value = useMemo(() => ({ state, dispatch, rid }), [state]);
  return <StoreCtx.Provider value={value}>{children}</StoreCtx.Provider>;
}

export function useStore() {
  const ctx = useContext(StoreCtx);
  if (!ctx) throw new Error("useStore doit être utilisé dans <StoreProvider>");
  return ctx;
}

// ── Sélecteurs pratiques ─────────────────────────────────────────────────────
export function useSelectors() {
  const { state } = useStore();
  return useMemo(() => {
    const clientById = (id?: string) => state.clients.find((c) => c.id === id);
    const deviceById = (id?: string) => state.devices.find((d) => d.id === id);
    const techById = (id?: string) => state.techniciens.find((t) => t.id === id);
    const partById = (id?: string) => state.parts.find((p) => p.id === id);
    const invoiceById = (id?: string) => state.invoices.find((i) => i.id === id);
    const ticketById = (id?: string) => state.tickets.find((t) => t.id === id);
    const invoicesForTicket = (id: string) =>
      state.invoices.filter((i) => i.ticketId === id);
    const ticketsForClient = (id: string) =>
      state.tickets.filter((t) => t.clientId === id);
    const devicesForClient = (id: string) =>
      state.devices.filter((d) => d.clientId === id);
    return {
      clientById,
      deviceById,
      techById,
      partById,
      invoiceById,
      ticketById,
      invoicesForTicket,
      ticketsForClient,
      devicesForClient,
    };
  }, [state]);
}
