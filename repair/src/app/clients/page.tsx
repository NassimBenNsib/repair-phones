"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { useStore } from "@/lib/store";
import { computeTotals, fmtEuro } from "@/lib/format";
import { LargeHeader } from "@/components/Header";
import { Avatar, Badge, EmptyState, ListGroup, SearchBar } from "@/components/ui";
import { Icon } from "@/components/Icon";

export default function ClientsPage() {
  const { state } = useStore();
  const [q, setQ] = useState("");

  const enriched = useMemo(() => {
    return state.clients
      .map((c) => {
        const tickets = state.tickets.filter((t) => t.clientId === c.id);
        const open = tickets.filter((t) => t.status !== "restitue").length;
        const spent = state.invoices
          .filter((i) => i.clientId === c.id)
          .reduce((s, i) => s + i.paiements.reduce((x, p) => x + p.montant, 0), 0);
        const lastAt = tickets.reduce(
          (m, t) => Math.max(m, new Date(t.recuAt).getTime()),
          0,
        );
        return { client: c, tickets: tickets.length, open, spent, lastAt };
      })
      .filter((e) => {
        const n = q.trim().toLowerCase();
        return (
          !n ||
          e.client.nom.toLowerCase().includes(n) ||
          e.client.telephone.includes(n) ||
          (e.client.email ?? "").toLowerCase().includes(n)
        );
      })
      .sort((a, b) => b.lastAt - a.lastAt);
  }, [state.clients, state.tickets, state.invoices, q]);

  return (
    <div className="anim-fade">
      <LargeHeader title="Clients" subtitle={`${state.clients.length} fiches`}>
        <SearchBar value={q} onChange={setQ} placeholder="Nom, téléphone, email…" />
      </LargeHeader>

      <div className="px-4 pb-8 pt-2">
        {enriched.length ? (
          <ListGroup>
            {enriched.map(({ client, tickets, open, spent }) => (
              <Link
                key={client.id}
                href={`/clients/${client.id}`}
                className="press flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 last:border-0 active:bg-[var(--surface-2)]"
              >
                <Avatar nom={client.nom} size={44} />
                <div className="min-w-0 flex-1">
                  <div className="truncate text-[15px] font-semibold">{client.nom}</div>
                  <div className="mt-0.5 text-[13px] text-[var(--text-tertiary)]">
                    {client.telephone}
                  </div>
                  <div className="mt-1.5 flex items-center gap-2">
                    <span className="text-[12px] text-[var(--text-secondary)]">
                      {tickets} réparation{tickets > 1 ? "s" : ""}
                    </span>
                    {open > 0 && <Badge tone="accent">{open} en cours</Badge>}
                  </div>
                </div>
                <div className="flex shrink-0 flex-col items-end">
                  <span className="text-[15px] font-semibold tabular-nums">{fmtEuro(spent)}</span>
                  <Icon name="chevron" size={16} className="mt-1 text-[var(--text-tertiary)]" />
                </div>
              </Link>
            ))}
          </ListGroup>
        ) : (
          <EmptyState icon="people" title="Aucun client" desc="Aucun résultat pour cette recherche." />
        )}
      </div>
    </div>
  );
}
