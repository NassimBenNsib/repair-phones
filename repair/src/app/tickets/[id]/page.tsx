"use client";

import { useMemo, useState, use } from "react";
import { useRouter } from "next/navigation";
import { useSelectors, useStore } from "@/lib/store";
import { TICKET_FLOW, type LineItem, type TicketStatus } from "@/lib/types";
import {
  DEVICE_META,
  INVOICE_STATUS_META,
  PRIORITY_META,
  TICKET_STATUS_META,
  computeTotals,
  fmtDateLong,
  fmtEuro,
  relativeDue,
  stockState,
} from "@/lib/format";
import { SubHeader } from "@/components/Header";
import { StatusTimeline } from "@/components/StatusTimeline";
import { Icon, type IconName } from "@/components/Icon";
import {
  Avatar,
  Badge,
  Button,
  Card,
  Field,
  Input,
  ListGroup,
  ListRow,
  SectionTitle,
  cx,
} from "@/components/ui";
import { ActionSheet, Sheet, useToast } from "@/components/Sheet";

export default function TicketDetail({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { state, dispatch, rid } = useStore();
  const sel = useSelectors();
  const router = useRouter();
  const toast = useToast();

  const ticket = state.tickets.find((t) => t.id === decodeURIComponent(id));
  const [statusSheet, setStatusSheet] = useState(false);
  const [assignSheet, setAssignSheet] = useState(false);
  const [partSheet, setPartSheet] = useState(false);
  const [laborSheet, setLaborSheet] = useState(false);
  const [moreSheet, setMoreSheet] = useState(false);
  const [gallery, setGallery] = useState<string | null>(null);

  if (!ticket) {
    return (
      <div>
        <SubHeader backLabel="Tickets" />
        <div className="p-8 text-center text-[var(--text-secondary)]">
          Ticket introuvable.
        </div>
      </div>
    );
  }

  const client = sel.clientById(ticket.clientId);
  const device = sel.deviceById(ticket.deviceId);
  const tech = sel.techById(ticket.technicienId);
  const invoices = sel.invoicesForTicket(ticket.id);
  const meta = TICKET_STATUS_META[ticket.status];
  const { sousTotal, tva, totalTTC } = computeTotals(ticket.lignes, 0, state.atelier.tvaPct);
  const late =
    ticket.promisAt &&
    new Date(ticket.promisAt).getTime() < Date.now() &&
    ticket.status !== "restitue" &&
    ticket.status !== "pret";

  const nextStatus =
    TICKET_FLOW[Math.min(TICKET_FLOW.length - 1, meta.step + 1)];

  const changeStatus = (s: TicketStatus) => {
    dispatch({ type: "SET_STATUS", ticketId: ticket.id, status: s });
    toast(`Statut : ${TICKET_STATUS_META[s].label}`, { icon: "refresh" });
  };

  const notify = () => {
    toast(`SMS envoyé à ${client?.nom?.split(" ")[0]}`, { icon: "send", tone: "info" });
  };

  const addPart = (partId: string) => {
    const part = sel.partById(partId);
    if (!part) return;
    const line: LineItem = {
      id: rid("l"),
      kind: "piece",
      partId,
      designation: part.designation,
      quantite: 1,
      prixUnitaire: part.prixVente,
    };
    dispatch({ type: "ADD_LINE", ticketId: ticket.id, line });
    toast("Pièce ajoutée");
  };

  const genInvoice = (docType: "devis" | "facture") => {
    if (!ticket.lignes.length) {
      toast("Ajoutez d'abord des lignes", { icon: "alert" });
      return;
    }
    dispatch({ type: "GEN_INVOICE", ticketId: ticket.id, docType });
    toast(docType === "facture" ? "Facture générée" : "Devis généré");
  };

  return (
    <div className="anim-fade pb-10">
      <SubHeader
        backLabel="Tickets"
        title={ticket.id}
        trailing={
          <button
            onClick={() => setMoreSheet(true)}
            className="press flex h-9 w-9 items-center justify-center rounded-full text-[var(--accent)]"
            aria-label="Actions"
          >
            <Icon name="more" size={22} />
          </button>
        }
      />

      <div className="mx-auto max-w-[720px] space-y-5 px-4 pt-4">
        {/* En-tête appareil / client */}
        <Card>
          <div className="flex items-start gap-3.5">
            <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-[15px] bg-[var(--accent-weak)] text-[var(--accent)]">
              <Icon name={DEVICE_META[device?.type ?? "autre"].icon as IconName} size={28} />
            </div>
            <div className="min-w-0 flex-1">
              <h2 className="text-[19px] font-bold leading-tight">
                {device?.marque} {device?.modele}
              </h2>
              <div className="mt-0.5 text-[13px] text-[var(--text-secondary)]">
                {device?.couleur} · IMEI {device?.serie ?? "—"}
              </div>
              <div className="mt-2 flex flex-wrap items-center gap-2">
                <Badge tone={meta.tone} icon={meta.icon as IconName}>
                  {meta.label}
                </Badge>
                <Badge tone={PRIORITY_META[ticket.priority].tone}>
                  {PRIORITY_META[ticket.priority].label}
                </Badge>
                {ticket.garantieMois > 0 && (
                  <Badge tone="info" icon="shield">
                    Garantie {ticket.garantieMois} mois
                  </Badge>
                )}
              </div>
            </div>
          </div>
          <div
            role="button"
            tabIndex={0}
            onClick={() => router.push(`/clients/${client?.id}`)}
            className="press mt-3.5 flex cursor-pointer items-center gap-3 rounded-[12px] bg-[var(--surface-2)] p-2.5"
          >
            <Avatar nom={client?.nom ?? "?"} size={38} />
            <div className="min-w-0 flex-1">
              <div className="text-[15px] font-semibold">{client?.nom}</div>
              <div className="text-[13px] text-[var(--text-secondary)]">
                {client?.telephone}
              </div>
            </div>
            <a
              href={`tel:${client?.telephone.replace(/\s/g, "")}`}
              onClick={(e) => e.stopPropagation()}
              className="press flex h-9 w-9 items-center justify-center rounded-full bg-[var(--success-weak)] text-[var(--success)]"
            >
              <Icon name="phone" size={18} />
            </a>
          </div>

          {/* Dates */}
          <div className="mt-3 grid grid-cols-2 gap-2 text-[13px]">
            <div className="rounded-[10px] bg-[var(--surface-2)] p-2.5">
              <div className="text-[var(--text-tertiary)]">Reçu le</div>
              <div className="mt-0.5 font-semibold">{fmtDateLong(ticket.recuAt)}</div>
            </div>
            <div className={cx("rounded-[10px] p-2.5", late ? "bg-[var(--danger-weak)]" : "bg-[var(--surface-2)]")}>
              <div className="text-[var(--text-tertiary)]">Promis</div>
              <div
                className={cx("mt-0.5 font-semibold", late && "text-[var(--danger)]")}
              >
                {relativeDue(ticket.promisAt)}
              </div>
            </div>
          </div>
        </Card>

        {/* Actions rapides */}
        <div className="grid grid-cols-3 gap-2.5">
          <QuickAction
            icon="refresh"
            label={ticket.status === "restitue" ? "Terminé" : `→ ${TICKET_STATUS_META[nextStatus].label}`}
            highlight
            disabled={ticket.status === "restitue"}
            onClick={() => ticket.status !== "restitue" && changeStatus(nextStatus)}
          />
          <QuickAction icon="user" label="Assigner" onClick={() => setAssignSheet(true)} />
          <QuickAction icon="send" label="Notifier" onClick={notify} />
        </div>

        {/* Timeline de statut */}
        <div>
          <SectionTitle
            action={
              <button
                onClick={() => setStatusSheet(true)}
                className="text-[14px] font-medium text-[var(--accent)]"
              >
                Modifier
              </button>
            }
          >
            Suivi de réparation
          </SectionTitle>
          <Card>
            <StatusTimeline
              current={ticket.status}
              history={ticket.history}
              onPick={changeStatus}
            />
          </Card>
        </div>

        {/* Symptômes */}
        <div>
          <SectionTitle>Symptômes & diagnostic</SectionTitle>
          <Card>
            <p className="text-[15px] leading-relaxed text-[var(--text)]">
              {ticket.symptomes}
            </p>
            {ticket.codeDeverrouillage && (
              <div className="mt-3 flex items-center gap-2 rounded-[10px] bg-[var(--surface-2)] px-3 py-2 text-[13px]">
                <Icon name="shield" size={16} className="text-[var(--text-tertiary)]" />
                <span className="text-[var(--text-secondary)]">Déverrouillage :</span>
                <span className="font-semibold">{ticket.codeDeverrouillage}</span>
              </div>
            )}
          </Card>
        </div>

        {/* Photos */}
        <div>
          <SectionTitle>Photos ({ticket.photos.length})</SectionTitle>
          <div className="flex gap-2.5 overflow-x-auto no-scrollbar">
            {ticket.photos.map((p, i) => (
              <button
                key={i}
                onClick={() => setGallery(p)}
                className="press flex h-24 w-24 shrink-0 items-center justify-center rounded-[14px] bg-[var(--surface-sunken)] text-4xl"
                style={{ border: "0.5px solid var(--separator)" }}
              >
                {p}
              </button>
            ))}
            <button
              onClick={() => toast("Appareil photo (démo)", { icon: "camera", tone: "info" })}
              className="press flex h-24 w-24 shrink-0 flex-col items-center justify-center gap-1 rounded-[14px] text-[var(--text-tertiary)]"
              style={{ border: "1.5px dashed var(--separator-strong)" }}
            >
              <Icon name="camera" size={22} />
              <span className="text-[11px] font-medium">Ajouter</span>
            </button>
          </div>
        </div>

        {/* Checklist */}
        {ticket.checklist.length > 0 && (
          <div>
            <SectionTitle>État à la réception</SectionTitle>
            <ListGroup>
              {ticket.checklist.map((c) => (
                <button
                  key={c.id}
                  onClick={() => dispatch({ type: "TOGGLE_CHECK", ticketId: ticket.id, itemId: c.id })}
                  className="press flex w-full items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 text-left last:border-0 active:bg-[var(--surface-2)]"
                >
                  <span
                    className={cx(
                      "flex h-6 w-6 items-center justify-center rounded-full transition-colors",
                      c.checked
                        ? "bg-[var(--success)] text-white"
                        : "bg-[var(--surface-sunken)] text-transparent",
                    )}
                  >
                    <Icon name="check" size={15} strokeWidth={3} />
                  </span>
                  <span className={cx("text-[15px]", c.checked && "text-[var(--text-secondary)]")}>
                    {c.label}
                  </span>
                </button>
              ))}
            </ListGroup>
          </div>
        )}

        {/* Lignes pièces + main d'œuvre */}
        <div>
          <SectionTitle
            action={
              <div className="flex gap-3">
                <button onClick={() => setPartSheet(true)} className="text-[14px] font-medium text-[var(--accent)]">
                  + Pièce
                </button>
                <button onClick={() => setLaborSheet(true)} className="text-[14px] font-medium text-[var(--accent)]">
                  + M.O.
                </button>
              </div>
            }
          >
            Pièces & main d'œuvre
          </SectionTitle>
          <Card pad={false}>
            {ticket.lignes.length === 0 ? (
              <div className="px-4 py-6 text-center text-[14px] text-[var(--text-secondary)]">
                Aucune ligne. Ajoutez une pièce ou de la main d'œuvre.
              </div>
            ) : (
              <>
                {ticket.lignes.map((l) => {
                  const part = l.partId ? sel.partById(l.partId) : undefined;
                  return (
                    <div
                      key={l.id}
                      className="flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3"
                    >
                      <div
                        className={cx(
                          "flex h-9 w-9 shrink-0 items-center justify-center rounded-[10px]",
                          l.kind === "piece"
                            ? "bg-[var(--accent-weak)] text-[var(--accent)]"
                            : "bg-[var(--surface-sunken)] text-[var(--text-secondary)]",
                        )}
                      >
                        <Icon name={l.kind === "piece" ? "box" : "wrench"} size={18} />
                      </div>
                      <div className="min-w-0 flex-1">
                        <div className="truncate text-[15px] font-medium">{l.designation}</div>
                        <div className="text-[12px] text-[var(--text-tertiary)]">
                          {l.quantite} × {fmtEuro(l.prixUnitaire)}
                          {part && (
                            <span className={cx("ml-2", stockState(part) !== "ok" && "text-[var(--warning)]")}>
                              · stock {part.quantite}
                            </span>
                          )}
                        </div>
                      </div>
                      <span className="text-[15px] font-semibold tabular-nums">
                        {fmtEuro(l.quantite * l.prixUnitaire)}
                      </span>
                      <button
                        onClick={() => dispatch({ type: "REMOVE_LINE", ticketId: ticket.id, lineId: l.id })}
                        className="press text-[var(--text-tertiary)]"
                        aria-label="Retirer"
                      >
                        <Icon name="close" size={16} />
                      </button>
                    </div>
                  );
                })}
                {/* Totaux */}
                <div className="space-y-1 px-4 py-3 text-[14px]">
                  <Row label="Sous-total HT" value={fmtEuro(sousTotal)} />
                  <Row label={`TVA ${state.atelier.tvaPct}%`} value={fmtEuro(tva)} />
                  <div className="flex justify-between pt-1 text-[17px] font-bold">
                    <span>Total TTC</span>
                    <span className="tabular-nums">{fmtEuro(totalTTC)}</span>
                  </div>
                </div>
              </>
            )}
          </Card>
        </div>

        {/* Devis / factures */}
        <div>
          <SectionTitle>Devis & factures</SectionTitle>
          {invoices.length > 0 ? (
            <ListGroup>
              {invoices.map((inv) => {
                const im = INVOICE_STATUS_META[inv.status];
                const t = computeTotals(inv.lignes, inv.remisePct, inv.tvaPct);
                return (
                  <ListRow
                    key={inv.id}
                    href={`/factures/${inv.id}`}
                    chevron
                    leading={
                      <div className="flex h-9 w-9 items-center justify-center rounded-[10px] bg-[var(--surface-sunken)] text-[var(--text-secondary)]">
                        <Icon name="doc" size={18} />
                      </div>
                    }
                    trailing={<span className="font-semibold tabular-nums">{fmtEuro(t.totalTTC)}</span>}
                  >
                    <div className="flex items-center gap-2">
                      <span className="text-[15px] font-medium">{inv.id}</span>
                      <Badge tone={im.tone}>{im.label}</Badge>
                    </div>
                    <div className="text-[12px] capitalize text-[var(--text-tertiary)]">{inv.type}</div>
                  </ListRow>
                );
              })}
            </ListGroup>
          ) : (
            <Card>
              <div className="text-[14px] text-[var(--text-secondary)]">
                Aucun document rattaché à ce ticket.
              </div>
            </Card>
          )}
          <div className="mt-2.5 grid grid-cols-2 gap-2.5">
            <Button variant="secondary" icon="doc" onClick={() => genInvoice("devis")}>
              Générer devis
            </Button>
            <Button variant="primary" icon="euro" onClick={() => genInvoice("facture")}>
              Générer facture
            </Button>
          </div>
        </div>
      </div>

      {/* ── Sheets ─────────────────────────────────────────────────────────── */}
      <Sheet open={statusSheet} onClose={() => setStatusSheet(false)} title="Changer le statut">
        <div className="space-y-1 pb-4">
          {TICKET_FLOW.map((s) => {
            const m = TICKET_STATUS_META[s];
            const active = s === ticket.status;
            return (
              <button
                key={s}
                onClick={() => {
                  changeStatus(s);
                  setStatusSheet(false);
                }}
                className={cx(
                  "press flex w-full items-center gap-3 rounded-[12px] px-3 py-3",
                  active ? "bg-[var(--accent-weak)]" : "active:bg-[var(--surface-2)]",
                )}
              >
                <Badge tone={m.tone} icon={m.icon as IconName}>
                  {m.label}
                </Badge>
                {active && <Icon name="check" size={18} className="ml-auto text-[var(--accent)]" />}
              </button>
            );
          })}
        </div>
      </Sheet>

      <Sheet open={assignSheet} onClose={() => setAssignSheet(false)} title="Assigner un technicien">
        <div className="space-y-1 pb-4">
          {state.techniciens.map((t) => {
            const active = t.id === ticket.technicienId;
            return (
              <button
                key={t.id}
                onClick={() => {
                  dispatch({ type: "ASSIGN", ticketId: ticket.id, technicienId: t.id });
                  toast(`Assigné à ${t.nom.split(" ")[0]}`);
                  setAssignSheet(false);
                }}
                className={cx(
                  "press flex w-full items-center gap-3 rounded-[12px] px-3 py-2.5",
                  active ? "bg-[var(--accent-weak)]" : "active:bg-[var(--surface-2)]",
                )}
              >
                <Avatar nom={t.nom} color={t.couleur} size={38} />
                <div className="text-left">
                  <div className="text-[15px] font-medium">{t.nom}</div>
                  <div className="text-[12px] capitalize text-[var(--text-tertiary)]">{t.role}</div>
                </div>
                {active && <Icon name="check" size={18} className="ml-auto text-[var(--accent)]" />}
              </button>
            );
          })}
        </div>
      </Sheet>

      <AddPartSheet
        open={partSheet}
        onClose={() => setPartSheet(false)}
        onPick={addPart}
      />

      <AddLaborSheet
        open={laborSheet}
        onClose={() => setLaborSheet(false)}
        onAdd={(designation, prix) => {
          dispatch({
            type: "ADD_LINE",
            ticketId: ticket.id,
            line: { id: rid("l"), kind: "main_oeuvre", designation, quantite: 1, prixUnitaire: prix },
          });
          toast("Main d'œuvre ajoutée");
        }}
      />

      <ActionSheet
        open={moreSheet}
        onClose={() => setMoreSheet(false)}
        title={`Ticket ${ticket.id}`}
        actions={[
          { label: "Changer le statut", icon: "refresh", onClick: () => setStatusSheet(true) },
          { label: "Notifier le client", icon: "send", onClick: notify },
          { label: "Générer une facture", icon: "euro", onClick: () => genInvoice("facture") },
        ]}
      />

      {/* Visionneuse photo */}
      {gallery && (
        <div
          className="fixed inset-0 z-[80] flex items-center justify-center bg-black/80 anim-fade"
          onClick={() => setGallery(null)}
        >
          <div className="text-[120px]">{gallery}</div>
        </div>
      )}
    </div>
  );
}

function QuickAction({
  icon,
  label,
  onClick,
  highlight,
  disabled,
}: {
  icon: IconName;
  label: string;
  onClick?: () => void;
  highlight?: boolean;
  disabled?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={cx(
        "press flex flex-col items-center gap-1.5 rounded-[14px] py-3 text-[12px] font-semibold disabled:opacity-40",
        highlight
          ? "bg-[var(--accent)] text-white shadow-sm"
          : "bg-[var(--surface)] text-[var(--text)] shadow-[var(--shadow-card)]",
      )}
      style={highlight ? undefined : { border: "0.5px solid var(--separator)" }}
    >
      <Icon name={icon} size={22} strokeWidth={2} />
      <span className="px-1 text-center leading-tight">{label}</span>
    </button>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between text-[var(--text-secondary)]">
      <span>{label}</span>
      <span className="tabular-nums text-[var(--text)]">{value}</span>
    </div>
  );
}

// ── Sheet : ajout de pièce depuis le stock ──────────────────────────────────
function AddPartSheet({
  open,
  onClose,
  onPick,
}: {
  open: boolean;
  onClose: () => void;
  onPick: (partId: string) => void;
}) {
  const { state } = useStore();
  const [q, setQ] = useState("");
  const list = useMemo(() => {
    const n = q.trim().toLowerCase();
    return state.parts.filter(
      (p) =>
        !n ||
        p.designation.toLowerCase().includes(n) ||
        p.reference.toLowerCase().includes(n) ||
        p.compatibilite.join(" ").toLowerCase().includes(n),
    );
  }, [state.parts, q]);

  return (
    <Sheet open={open} onClose={onClose} title="Ajouter une pièce">
      <div className="pb-4">
        <div className="mb-3">
          <Input placeholder="Rechercher une pièce…" value={q} onChange={(e) => setQ(e.target.value)} />
        </div>
        <div className="space-y-1">
          {list.map((p) => {
            const st = stockState(p);
            return (
              <button
                key={p.id}
                onClick={() => {
                  onPick(p.id);
                  onClose();
                }}
                className="press flex w-full items-center gap-3 rounded-[12px] px-2 py-2.5 text-left active:bg-[var(--surface-2)]"
              >
                <div className="flex h-9 w-9 items-center justify-center rounded-[10px] bg-[var(--surface-sunken)] text-[var(--text-secondary)]">
                  <Icon name="box" size={18} />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="truncate text-[15px] font-medium">{p.designation}</div>
                  <div className="text-[12px] text-[var(--text-tertiary)]">{p.reference}</div>
                </div>
                <div className="text-right">
                  <div className="text-[15px] font-semibold tabular-nums">{fmtEuro(p.prixVente)}</div>
                  <div
                    className={cx(
                      "text-[11px] font-medium",
                      st === "ok"
                        ? "text-[var(--text-tertiary)]"
                        : st === "bas"
                          ? "text-[var(--warning)]"
                          : "text-[var(--danger)]",
                    )}
                  >
                    {st === "rupture" ? "Rupture" : `Stock ${p.quantite}`}
                  </div>
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </Sheet>
  );
}

// ── Sheet : ajout main d'œuvre ──────────────────────────────────────────────
function AddLaborSheet({
  open,
  onClose,
  onAdd,
}: {
  open: boolean;
  onClose: () => void;
  onAdd: (designation: string, prix: number) => void;
}) {
  const [designation, setDesignation] = useState("");
  const [prix, setPrix] = useState(45);

  const presets = [
    ["Diagnostic", 30],
    ["Remplacement écran", 45],
    ["Remplacement batterie", 35],
    ["Micro-soudure", 80],
  ] as const;

  return (
    <Sheet
      open={open}
      onClose={onClose}
      title="Main d'œuvre"
      footer={
        <Button
          full
          disabled={!designation.trim()}
          onClick={() => {
            onAdd(designation.trim(), prix);
            setDesignation("");
            setPrix(45);
            onClose();
          }}
        >
          Ajouter · {fmtEuro(prix)}
        </Button>
      }
    >
      <div className="space-y-4 pb-2">
        <div className="flex flex-wrap gap-2">
          {presets.map(([label, p]) => (
            <button
              key={label}
              onClick={() => {
                setDesignation(label);
                setPrix(p);
              }}
              className="press rounded-full bg-[var(--surface-sunken)] px-3 py-1.5 text-[13px] font-medium"
            >
              {label}
            </button>
          ))}
        </div>
        <Field label="Description">
          <Input value={designation} onChange={(e) => setDesignation(e.target.value)} placeholder="Ex. Remplacement écran" />
        </Field>
        <Field label="Prix HT (€)">
          <Input
            type="number"
            inputMode="decimal"
            value={prix}
            onChange={(e) => setPrix(Number(e.target.value) || 0)}
          />
        </Field>
      </div>
    </Sheet>
  );
}
