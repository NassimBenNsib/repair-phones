"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { useStore, useSelectors } from "@/lib/store";
import type { TicketStatus } from "@/lib/types";
import { LargeHeader } from "@/components/Header";
import { TicketRow } from "@/components/domain";
import { EmptyState, ListGroup, SearchBar, Segmented } from "@/components/ui";

type Filter = "tous" | "ouverts" | "pret" | "restitue";

const OPEN_STATUSES: TicketStatus[] = [
  "recu",
  "diagnostic",
  "attente_piece",
  "en_reparation",
];

function TicketsInner() {
  const { state } = useStore();
  const { clientById, deviceById } = useSelectors();
  const params = useSearchParams();
  const [q, setQ] = useState("");
  const [filter, setFilter] = useState<Filter>(
    params.get("f") === "pret" ? "pret" : "ouverts",
  );

  const counts = useMemo(() => {
    return {
      tous: state.tickets.length,
      ouverts: state.tickets.filter((t) => OPEN_STATUSES.includes(t.status)).length,
      pret: state.tickets.filter((t) => t.status === "pret").length,
      restitue: state.tickets.filter((t) => t.status === "restitue").length,
    };
  }, [state.tickets]);

  const list = useMemo(() => {
    const needle = q.trim().toLowerCase();
    return state.tickets
      .filter((t) => {
        if (filter === "ouverts" && !OPEN_STATUSES.includes(t.status)) return false;
        if (filter === "pret" && t.status !== "pret") return false;
        if (filter === "restitue" && t.status !== "restitue") return false;
        if (!needle) return true;
        const client = clientById(t.clientId);
        const device = deviceById(t.deviceId);
        return [
          t.id,
          client?.nom,
          client?.telephone,
          device?.marque,
          device?.modele,
          device?.serie,
        ]
          .join(" ")
          .toLowerCase()
          .includes(needle);
      })
      .sort((a, b) => new Date(b.recuAt).getTime() - new Date(a.recuAt).getTime());
  }, [state.tickets, q, filter, clientById, deviceById]);

  return (
    <div className="anim-fade">
      <LargeHeader title="Tickets">
        <div className="space-y-2.5">
          <SearchBar
            value={q}
            onChange={setQ}
            placeholder="Client, IMEI, n° ticket…"
          />
          <Segmented<Filter>
            value={filter}
            onChange={setFilter}
            scroll
            options={[
              { value: "ouverts", label: "En cours", count: counts.ouverts },
              { value: "pret", label: "Prêts", count: counts.pret },
              { value: "restitue", label: "Restitués", count: counts.restitue },
              { value: "tous", label: "Tous", count: counts.tous },
            ]}
          />
        </div>
      </LargeHeader>

      <div className="px-4 pb-8 pt-2">
        {list.length ? (
          <ListGroup>
            {list.map((t) => (
              <TicketRow key={t.id} ticket={t} />
            ))}
          </ListGroup>
        ) : (
          <EmptyState
            icon="ticket"
            title="Aucun ticket"
            desc={
              q
                ? "Aucun résultat pour cette recherche."
                : "Aucun ticket dans cette catégorie."
            }
          />
        )}
      </div>
    </div>
  );
}

export default function TicketsPage() {
  return (
    <Suspense>
      <TicketsInner />
    </Suspense>
  );
}
