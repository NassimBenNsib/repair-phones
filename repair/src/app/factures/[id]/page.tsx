"use client";

import { use, useState } from "react";
import Link from "next/link";
import { useSelectors, useStore } from "@/lib/store";
import type { PaymentMethod } from "@/lib/types";
import {
  INVOICE_STATUS_META,
  PAYMENT_META,
  computeTotals,
  fmtDate,
  fmtDateTime,
  fmtEuro,
} from "@/lib/format";
import { resteDu } from "@/lib/stats";
import { SubHeader } from "@/components/Header";
import { Icon, type IconName } from "@/components/Icon";
import {
  Badge,
  Button,
  Card,
  Field,
  Input,
  SectionTitle,
  cx,
} from "@/components/ui";
import { Sheet, useToast } from "@/components/Sheet";

export default function InvoiceDetail({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { state, dispatch, rid } = useStore();
  const sel = useSelectors();
  const toast = useToast();

  const inv = state.invoices.find((i) => i.id === decodeURIComponent(id));
  const [paySheet, setPaySheet] = useState(false);
  const [moyen, setMoyen] = useState<PaymentMethod>("carte");
  const [payAmount, setPayAmount] = useState(0);

  if (!inv) {
    return (
      <div>
        <SubHeader backLabel="Factures" />
        <div className="p-8 text-center text-[var(--text-secondary)]">Document introuvable.</div>
      </div>
    );
  }

  const client = sel.clientById(inv.clientId);
  const ticket = sel.ticketById(inv.ticketId);
  const totals = computeTotals(inv.lignes, inv.remisePct, inv.tvaPct);
  const reste = resteDu(inv);
  const paye = totals.totalTTC - reste;
  const im = INVOICE_STATUS_META[inv.status];

  const isFacture = inv.type === "facture";

  return (
    <div className="anim-fade pb-10">
      <SubHeader
        title={inv.id}
        backLabel="Retour"
        trailing={
          <button
            onClick={() => toast("Export PDF (démo)", { icon: "doc", tone: "info" })}
            className="press flex h-9 w-9 items-center justify-center rounded-full text-[var(--accent)]"
            aria-label="Partager"
          >
            <Icon name="send" size={20} />
          </button>
        }
      />

      <div className="mx-auto max-w-[720px] space-y-5 px-4 pt-4">
        {/* Aperçu document */}
        <Card className="!p-0 overflow-hidden">
          <div className="flex items-start justify-between p-5 pb-4">
            <div>
              <div className="text-[11px] font-bold uppercase tracking-wider text-[var(--accent)]">
                {inv.type}
              </div>
              <div className="mt-1 text-[22px] font-bold">{inv.id}</div>
              <div className="text-[13px] text-[var(--text-tertiary)]">{fmtDate(inv.createdAt)}</div>
            </div>
            <Badge tone={im.tone}>{im.label}</Badge>
          </div>

          <div
            className="flex items-center justify-between px-5 py-3 text-[13px]"
            style={{ borderTop: "0.5px solid var(--separator)", borderBottom: "0.5px solid var(--separator)" }}
          >
            <div>
              <div className="text-[var(--text-tertiary)]">Émetteur</div>
              <div className="font-semibold">{state.atelier.nom}</div>
            </div>
            <Icon name="arrowRight" size={16} className="text-[var(--text-tertiary)]" />
            <div className="text-right">
              <div className="text-[var(--text-tertiary)]">Client</div>
              <Link href={`/clients/${client?.id}`} className="font-semibold text-[var(--accent)]">
                {client?.nom}
              </Link>
            </div>
          </div>

          {/* Lignes */}
          <div className="px-5 py-2">
            {inv.lignes.map((l) => (
              <div
                key={l.id}
                className="flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] py-2.5 last:border-0"
              >
                <Icon
                  name={l.kind === "piece" ? "box" : "wrench"}
                  size={16}
                  className="text-[var(--text-tertiary)]"
                />
                <div className="min-w-0 flex-1">
                  <div className="truncate text-[14px] font-medium">{l.designation}</div>
                  <div className="text-[12px] text-[var(--text-tertiary)]">
                    {l.quantite} × {fmtEuro(l.prixUnitaire)} HT
                  </div>
                </div>
                <span className="text-[14px] font-semibold tabular-nums">
                  {fmtEuro(l.quantite * l.prixUnitaire)}
                </span>
              </div>
            ))}
          </div>

          {/* Totaux */}
          <div className="space-y-1 px-5 py-3 text-[14px]" style={{ background: "var(--surface-2)" }}>
            <TRow label="Sous-total HT" value={fmtEuro(totals.sousTotal)} />
            {inv.remisePct > 0 && <TRow label={`Remise ${inv.remisePct}%`} value={`- ${fmtEuro(totals.remise)}`} />}
            <TRow label={`TVA ${inv.tvaPct}%`} value={fmtEuro(totals.tva)} />
            <div className="flex justify-between border-t-[0.5px] border-[var(--separator)] pt-2 text-[18px] font-bold">
              <span>Total TTC</span>
              <span className="tabular-nums">{fmtEuro(totals.totalTTC)}</span>
            </div>
          </div>
        </Card>

        {/* Ticket lié */}
        {ticket && (
          <Link
            href={`/tickets/${ticket.id}`}
            className="press flex items-center gap-3 rounded-[14px] bg-[var(--surface)] p-3.5 shadow-[var(--shadow-card)]"
            style={{ border: "0.5px solid var(--separator)" }}
          >
            <Icon name="ticket" size={20} className="text-[var(--text-secondary)]" />
            <span className="flex-1 text-[14px]">
              Ticket lié <b>{ticket.id}</b>
            </span>
            <Icon name="chevron" size={16} className="text-[var(--text-tertiary)]" />
          </Link>
        )}

        {/* Encaissement */}
        {isFacture && (
          <div>
            <SectionTitle>Encaissement</SectionTitle>
            <Card>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-[13px] text-[var(--text-tertiary)]">Payé</div>
                  <div className="text-[19px] font-bold text-[var(--success)]">{fmtEuro(paye)}</div>
                </div>
                <div className="text-right">
                  <div className="text-[13px] text-[var(--text-tertiary)]">Reste dû</div>
                  <div className={cx("text-[19px] font-bold", reste > 0.01 ? "text-[var(--warning)]" : "text-[var(--text-tertiary)]")}>
                    {fmtEuro(reste)}
                  </div>
                </div>
              </div>

              {inv.paiements.length > 0 && (
                <div className="mt-3 space-y-2 border-t-[0.5px] border-[var(--separator)] pt-3">
                  {inv.paiements.map((p) => (
                    <div key={p.id} className="flex items-center gap-2.5 text-[13px]">
                      <Icon name={PAYMENT_META[p.moyen].icon as IconName} size={16} className="text-[var(--text-tertiary)]" />
                      <span className="flex-1 text-[var(--text-secondary)]">
                        {PAYMENT_META[p.moyen].label} · {fmtDateTime(p.at)}
                      </span>
                      <span className="font-semibold tabular-nums">{fmtEuro(p.montant)}</span>
                    </div>
                  ))}
                </div>
              )}

              {reste > 0.01 && (
                <Button
                  full
                  icon="euro"
                  className="mt-3.5"
                  onClick={() => {
                    setPayAmount(reste);
                    setPaySheet(true);
                  }}
                >
                  Enregistrer un paiement
                </Button>
              )}
            </Card>
          </div>
        )}

        {/* Actions devis */}
        {inv.type === "devis" && (
          <div className="grid grid-cols-2 gap-2.5">
            <Button
              variant="secondary"
              icon="send"
              onClick={() => {
                dispatch({ type: "SET_INVOICE_STATUS", invoiceId: inv.id, status: "envoye" });
                toast("Devis envoyé au client", { icon: "send", tone: "info" });
              }}
            >
              Envoyer
            </Button>
            <Button
              icon="check"
              onClick={() => {
                dispatch({ type: "SET_INVOICE_STATUS", invoiceId: inv.id, status: "accepte" });
                toast("Devis accepté");
              }}
            >
              Marquer accepté
            </Button>
          </div>
        )}
      </div>

      {/* Sheet paiement */}
      <Sheet
        open={paySheet}
        onClose={() => setPaySheet(false)}
        title="Nouveau paiement"
        footer={
          <Button
            full
            icon="check"
            disabled={payAmount <= 0}
            onClick={() => {
              dispatch({
                type: "ADD_PAYMENT",
                invoiceId: inv.id,
                payment: { id: rid("pay"), montant: payAmount, moyen, at: new Date().toISOString() },
              });
              toast(`Paiement de ${fmtEuro(payAmount)} enregistré`);
              setPaySheet(false);
            }}
          >
            Encaisser {fmtEuro(payAmount)}
          </Button>
        }
      >
        <div className="space-y-4 py-2">
          <Field label="Moyen de paiement">
            <div className="grid grid-cols-3 gap-2">
              {(Object.keys(PAYMENT_META) as PaymentMethod[]).map((m) => (
                <button
                  key={m}
                  onClick={() => setMoyen(m)}
                  className={cx(
                    "press flex flex-col items-center gap-1.5 rounded-[12px] py-3 text-[13px] font-medium",
                    moyen === m
                      ? "bg-[var(--accent-weak)] text-[var(--accent)]"
                      : "bg-[var(--surface-sunken)] text-[var(--text-secondary)]",
                  )}
                >
                  <Icon name={PAYMENT_META[m].icon as IconName} size={22} />
                  {PAYMENT_META[m].label}
                </button>
              ))}
            </div>
          </Field>
          <Field label="Montant (€)">
            <Input
              type="number"
              inputMode="decimal"
              value={payAmount}
              onChange={(e) => setPayAmount(Math.max(0, Number(e.target.value) || 0))}
            />
          </Field>
          <div className="flex gap-2">
            <button
              onClick={() => setPayAmount(reste)}
              className="press flex-1 rounded-[10px] bg-[var(--surface-sunken)] py-2 text-[13px] font-medium"
            >
              Solde ({fmtEuro(reste)})
            </button>
            <button
              onClick={() => setPayAmount(Math.round((reste / 2) * 100) / 100)}
              className="press flex-1 rounded-[10px] bg-[var(--surface-sunken)] py-2 text-[13px] font-medium"
            >
              Acompte 50%
            </button>
          </div>
        </div>
      </Sheet>
    </div>
  );
}

function TRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between text-[var(--text-secondary)]">
      <span>{label}</span>
      <span className="tabular-nums text-[var(--text)]">{value}</span>
    </div>
  );
}
