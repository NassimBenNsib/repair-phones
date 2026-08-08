"use client";

import { use } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useSelectors, useStore } from "@/lib/store";
import { DEVICE_META, fmtEuro } from "@/lib/format";
import { SubHeader } from "@/components/Header";
import { TicketRow } from "@/components/domain";
import { Icon, type IconName } from "@/components/Icon";
import {
  Avatar,
  Button,
  Card,
  EmptyState,
  ListGroup,
  ListRow,
  SectionTitle,
} from "@/components/ui";

export default function ClientDetail({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { state } = useStore();
  const sel = useSelectors();
  const router = useRouter();

  const client = state.clients.find((c) => c.id === id);
  if (!client) {
    return (
      <div>
        <SubHeader backLabel="Clients" />
        <div className="p-8 text-center text-[var(--text-secondary)]">Client introuvable.</div>
      </div>
    );
  }

  const devices = sel.devicesForClient(client.id);
  const tickets = sel
    .ticketsForClient(client.id)
    .sort((a, b) => new Date(b.recuAt).getTime() - new Date(a.recuAt).getTime());
  const spent = state.invoices
    .filter((i) => i.clientId === client.id)
    .reduce((s, i) => s + i.paiements.reduce((x, p) => x + p.montant, 0), 0);
  const tel = client.telephone.replace(/\s/g, "");

  return (
    <div className="anim-fade pb-10">
      <SubHeader backLabel="Clients" />

      <div className="mx-auto max-w-[720px] space-y-5 px-4 pt-2">
        {/* Profil */}
        <div className="flex flex-col items-center py-2 text-center">
          <Avatar nom={client.nom} size={80} />
          <h1 className="mt-3 text-[24px] font-bold">{client.nom}</h1>
          <div className="mt-1 text-[14px] text-[var(--text-secondary)]">{client.telephone}</div>
          {client.email && (
            <div className="text-[14px] text-[var(--text-secondary)]">{client.email}</div>
          )}
          <div className="mt-4 flex gap-2.5">
            <Button
              size="sm"
              variant="secondary"
              icon="phone"
              onClick={() => {
                window.location.href = `tel:${tel}`;
              }}
            >
              Appeler
            </Button>
            <Button size="sm" icon="plus" onClick={() => router.push("/tickets/nouveau")}>
              Nouveau ticket
            </Button>
          </div>
        </div>

        {/* Stats */}
        <div className="grid grid-cols-3 gap-3">
          <Stat label="Réparations" value={String(tickets.length)} />
          <Stat label="Appareils" value={String(devices.length)} />
          <Stat label="Total dépensé" value={fmtEuro(spent)} />
        </div>

        {client.note && (
          <Card>
            <div className="flex gap-2.5">
              <Icon name="edit" size={18} className="mt-0.5 shrink-0 text-[var(--text-tertiary)]" />
              <p className="text-[14px] text-[var(--text-secondary)]">{client.note}</p>
            </div>
          </Card>
        )}

        {/* Appareils */}
        <div>
          <SectionTitle>Appareils</SectionTitle>
          <ListGroup>
            {devices.map((d) => (
              <ListRow
                key={d.id}
                leading={
                  <div className="flex h-9 w-9 items-center justify-center rounded-[10px] bg-[var(--surface-sunken)] text-[var(--text-secondary)]">
                    <Icon name={DEVICE_META[d.type].icon as IconName} size={18} />
                  </div>
                }
              >
                <div className="text-[15px] font-medium">
                  {d.marque} {d.modele}
                </div>
                <div className="text-[12px] text-[var(--text-tertiary)]">
                  {d.couleur ? `${d.couleur} · ` : ""}
                  {d.serie ?? "N° série inconnu"}
                </div>
              </ListRow>
            ))}
          </ListGroup>
        </div>

        {/* Historique */}
        <div>
          <SectionTitle>Historique des réparations</SectionTitle>
          {tickets.length ? (
            <ListGroup>
              {tickets.map((t) => (
                <TicketRow key={t.id} ticket={t} />
              ))}
            </ListGroup>
          ) : (
            <EmptyState icon="ticket" title="Aucune réparation" />
          )}
        </div>
      </div>
    </div>
  );
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <Card pad={false} className="p-3 text-center">
      <div className="text-[19px] font-bold tabular-nums">{value}</div>
      <div className="mt-0.5 text-[12px] text-[var(--text-tertiary)]">{label}</div>
    </Card>
  );
}
