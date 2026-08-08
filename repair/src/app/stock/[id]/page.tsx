"use client";

import { use, useState } from "react";
import { useSelectors, useStore } from "@/lib/store";
import { fmtEuro, fmtDateTime, stockState } from "@/lib/format";
import { SubHeader } from "@/components/Header";
import { Icon } from "@/components/Icon";
import {
  Badge,
  Button,
  Card,
  Field,
  Input,
  ListGroup,
  SectionTitle,
  Stepper,
  cx,
} from "@/components/ui";
import { Sheet, useToast } from "@/components/Sheet";

export default function PartDetail({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { state, dispatch } = useStore();
  const sel = useSelectors();
  const toast = useToast();

  const part = state.parts.find((p) => p.id === id);
  const [restockSheet, setRestockSheet] = useState(false);
  const [adjustSheet, setAdjustSheet] = useState(false);
  const [qty, setQty] = useState(5);
  const [newQty, setNewQty] = useState(part?.quantite ?? 0);

  if (!part) {
    return (
      <div>
        <SubHeader backLabel="Stock" />
        <div className="p-8 text-center text-[var(--text-secondary)]">Pièce introuvable.</div>
      </div>
    );
  }

  const st = stockState(part);
  const tone = st === "ok" ? "success" : st === "bas" ? "warning" : "danger";
  const fournisseur = state.fournisseurs.find((f) => f.id === part.fournisseurId);
  const marge = part.prixVente - part.prixAchat;
  const margePct = part.prixAchat ? Math.round((marge / part.prixAchat) * 100) : 0;

  return (
    <div className="anim-fade pb-10">
      <SubHeader title={part.reference} backLabel="Stock" />

      <div className="mx-auto max-w-[720px] space-y-5 px-4 pt-4">
        {/* En-tête */}
        <Card>
          <div className="flex items-start gap-3.5">
            <div
              className={cx(
                "flex h-14 w-14 shrink-0 items-center justify-center rounded-[15px]",
                st === "rupture"
                  ? "bg-[var(--danger-weak)] text-[var(--danger)]"
                  : st === "bas"
                    ? "bg-[var(--warning-weak)] text-[var(--warning)]"
                    : "bg-[var(--accent-weak)] text-[var(--accent)]",
              )}
            >
              <Icon name="box" size={28} />
            </div>
            <div className="min-w-0 flex-1">
              <h2 className="text-[19px] font-bold leading-tight">{part.designation}</h2>
              <div className="mt-0.5 text-[13px] text-[var(--text-secondary)]">
                {part.categorie} · Réf. {part.reference}
              </div>
              <div className="mt-2">
                <Badge tone={tone} dot>
                  {st === "rupture" ? "Rupture de stock" : st === "bas" ? "Stock bas" : "En stock"}
                </Badge>
              </div>
            </div>
          </div>

          {/* Quantité + seuil */}
          <div className="mt-4 flex items-end justify-between rounded-[12px] bg-[var(--surface-2)] p-3.5">
            <div>
              <div className="text-[13px] text-[var(--text-tertiary)]">Quantité disponible</div>
              <div className="mt-0.5 flex items-baseline gap-1.5">
                <span className="text-[32px] font-bold leading-none tabular-nums">{part.quantite}</span>
                <span className="text-[14px] text-[var(--text-tertiary)]">/ seuil {part.seuil}</span>
              </div>
            </div>
            <div className="flex gap-2">
              <Button size="sm" variant="secondary" icon="edit" onClick={() => { setNewQty(part.quantite); setAdjustSheet(true); }}>
                Ajuster
              </Button>
              <Button size="sm" icon="arrowDown" onClick={() => setRestockSheet(true)}>
                Réassort
              </Button>
            </div>
          </div>
        </Card>

        {/* Prix & compat */}
        <div className="grid grid-cols-3 gap-3">
          <MiniStat label="Prix d'achat" value={fmtEuro(part.prixAchat)} />
          <MiniStat label="Prix de vente" value={fmtEuro(part.prixVente)} />
          <MiniStat label="Marge" value={`+${margePct}%`} tone="success" />
        </div>

        <ListGroup title="Détails">
          <Info icon="tag" label="Compatibilité" value={part.compatibilite.join(", ")} />
          <Info icon="location" label="Emplacement" value={part.emplacement ?? "—"} />
          <Info icon="people" label="Fournisseur" value={fournisseur?.nom ?? "—"} />
          {fournisseur && (
            <Info icon="clock" label="Délai réassort" value={`${fournisseur.delaiJours} jours`} />
          )}
        </ListGroup>

        {/* Mouvements */}
        <div>
          <SectionTitle>Mouvements récents</SectionTitle>
          <ListGroup>
            {part.mouvements.slice(0, 12).map((m) => {
              const isTicket = m.ticketId;
              return (
                <div
                  key={m.id}
                  className="flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 last:border-0"
                >
                  <div
                    className={cx(
                      "flex h-8 w-8 items-center justify-center rounded-full",
                      m.delta > 0
                        ? "bg-[var(--success-weak)] text-[var(--success)]"
                        : "bg-[var(--danger-weak)] text-[var(--danger)]",
                    )}
                  >
                    <Icon name={m.delta > 0 ? "arrowDown" : "arrowUp"} size={16} strokeWidth={2.4} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="text-[14px] font-medium">{m.motif}</div>
                    <div className="text-[12px] text-[var(--text-tertiary)]">{fmtDateTime(m.at)}</div>
                  </div>
                  <span
                    className={cx(
                      "text-[15px] font-bold tabular-nums",
                      m.delta > 0 ? "text-[var(--success)]" : "text-[var(--danger)]",
                    )}
                  >
                    {m.delta > 0 ? "+" : ""}
                    {m.delta}
                  </span>
                </div>
              );
            })}
          </ListGroup>
        </div>
      </div>

      {/* Sheet réassort */}
      <Sheet
        open={restockSheet}
        onClose={() => setRestockSheet(false)}
        title="Réception fournisseur"
        footer={
          <Button
            full
            icon="check"
            onClick={() => {
              dispatch({ type: "RESTOCK", partId: part.id, qty, motif: `Réception ${fournisseur?.nom ?? "fournisseur"}` });
              toast(`+${qty} en stock`);
              setRestockSheet(false);
              setQty(5);
            }}
          >
            Valider l'entrée · +{qty}
          </Button>
        }
      >
        <div className="space-y-4 py-2">
          <p className="text-[14px] text-[var(--text-secondary)]">
            Ajouter des unités reçues de <b>{fournisseur?.nom ?? "votre fournisseur"}</b> pour{" "}
            <b>{part.designation}</b>.
          </p>
          <div className="flex items-center justify-between rounded-[12px] bg-[var(--surface-2)] p-3.5">
            <span className="text-[15px] font-medium">Quantité reçue</span>
            <Stepper value={qty} onChange={setQty} min={1} max={200} />
          </div>
          <div className="rounded-[12px] bg-[var(--surface-2)] p-3.5 text-[14px]">
            <div className="flex justify-between">
              <span className="text-[var(--text-secondary)]">Nouveau stock</span>
              <span className="font-semibold">{part.quantite} → {part.quantite + qty}</span>
            </div>
            <div className="mt-1 flex justify-between">
              <span className="text-[var(--text-secondary)]">Coût total</span>
              <span className="font-semibold">{fmtEuro(qty * part.prixAchat)}</span>
            </div>
          </div>
        </div>
      </Sheet>

      {/* Sheet ajustement */}
      <Sheet
        open={adjustSheet}
        onClose={() => setAdjustSheet(false)}
        title="Ajustement d'inventaire"
        footer={
          <Button
            full
            onClick={() => {
              dispatch({ type: "ADJUST", partId: part.id, qty: newQty });
              toast("Stock ajusté");
              setAdjustSheet(false);
            }}
          >
            Enregistrer
          </Button>
        }
      >
        <div className="space-y-4 py-2">
          <Field label="Quantité réelle constatée">
            <Input
              type="number"
              inputMode="numeric"
              value={newQty}
              onChange={(e) => setNewQty(Math.max(0, Number(e.target.value) || 0))}
            />
          </Field>
          <div className="text-[13px] text-[var(--text-tertiary)]">
            Écart : {newQty - part.quantite > 0 ? "+" : ""}
            {newQty - part.quantite} unité(s)
          </div>
        </div>
      </Sheet>
    </div>
  );
}

function MiniStat({ label, value, tone }: { label: string; value: string; tone?: "success" }) {
  return (
    <Card pad={false} className="p-3">
      <div className="text-[12px] text-[var(--text-tertiary)]">{label}</div>
      <div
        className={cx("mt-1 text-[17px] font-bold tabular-nums", tone === "success" && "text-[var(--success)]")}
      >
        {value}
      </div>
    </Card>
  );
}

function Info({ icon, label, value }: { icon: Parameters<typeof Icon>[0]["name"]; label: string; value: string }) {
  return (
    <div className="flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 last:border-0">
      <Icon name={icon} size={18} className="text-[var(--text-tertiary)]" />
      <span className="text-[14px] text-[var(--text-secondary)]">{label}</span>
      <span className="ml-auto max-w-[55%] truncate text-right text-[14px] font-medium">{value}</span>
    </div>
  );
}
