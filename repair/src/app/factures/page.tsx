"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { useSelectors, useStore } from "@/lib/store";
import { INVOICE_STATUS_META, computeTotals, fmtDate, fmtEuro } from "@/lib/format";
import { resteDu } from "@/lib/stats";
import { LargeHeader } from "@/components/Header";
import { Badge, EmptyState, ListGroup, SearchBar, Segmented } from "@/components/ui";
import { Icon } from "@/components/Icon";

type Filter = "tous" | "devis" | "impaye" | "paye";

function FacturesInner() {
  const { state } = useStore();
  const { clientById } = useSelectors();
  const params = useSearchParams();
  const [q, setQ] = useState("");
  const [filter, setFilter] = useState<Filter>(
    (params.get("f") as Filter) || "tous",
  );

  const caEnAttente = useMemo(
    () =>
      state.invoices
        .filter((i) => i.type === "facture")
        .reduce((s, i) => s + resteDu(i), 0),
    [state.invoices],
  );

  const list = useMemo(() => {
    const n = q.trim().toLowerCase();
    return state.invoices
      .filter((i) => {
        if (filter === "devis" && i.type !== "devis") return false;
        if (filter === "paye" && i.status !== "paye") return false;
        if (filter === "impaye" && (i.type !== "facture" || i.status === "paye"))
          return false;
        if (!n) return true;
        const client = clientById(i.clientId);
        return [i.id, client?.nom].join(" ").toLowerCase().includes(n);
      })
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [state.invoices, filter, q, clientById]);

  return (
    <div className="anim-fade">
      <LargeHeader
        title="Facturation"
        subtitle="Devis · Factures · Paiements"
        trailing={
          <div className="text-right">
            <div className="text-[11px] text-[var(--text-tertiary)]">Reste à encaisser</div>
            <div className="text-[15px] font-bold tabular-nums text-[var(--warning)]">
              {fmtEuro(caEnAttente)}
            </div>
          </div>
        }
      >
        <div className="space-y-2.5">
          <SearchBar value={q} onChange={setQ} placeholder="N° document, client…" />
          <Segmented<Filter>
            value={filter}
            onChange={setFilter}
            scroll
            options={[
              { value: "tous", label: "Tous" },
              { value: "devis", label: "Devis" },
              { value: "impaye", label: "Impayées" },
              { value: "paye", label: "Payées" },
            ]}
          />
        </div>
      </LargeHeader>

      <div className="px-4 pb-8 pt-2">
        {list.length ? (
          <ListGroup>
            {list.map((inv) => {
              const im = INVOICE_STATUS_META[inv.status];
              const { totalTTC } = computeTotals(inv.lignes, inv.remisePct, inv.tvaPct);
              const client = clientById(inv.clientId);
              const reste = resteDu(inv);
              return (
                <Link
                  key={inv.id}
                  href={`/factures/${inv.id}`}
                  className="press flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 last:border-0 active:bg-[var(--surface-2)]"
                >
                  <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[12px] bg-[var(--surface-sunken)] text-[var(--text-secondary)]">
                    <Icon name={inv.type === "facture" ? "euro" : "doc"} size={22} />
                  </div>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <span className="text-[15px] font-semibold">{inv.id}</span>
                      <Badge tone={im.tone}>{im.label}</Badge>
                    </div>
                    <div className="mt-0.5 text-[13px] text-[var(--text-secondary)]">
                      {client?.nom} · {fmtDate(inv.createdAt)}
                    </div>
                  </div>
                  <div className="flex shrink-0 flex-col items-end">
                    <span className="text-[15px] font-semibold tabular-nums">{fmtEuro(totalTTC)}</span>
                    {reste > 0.01 && inv.type === "facture" && (
                      <span className="text-[12px] font-medium text-[var(--warning)]">
                        Reste {fmtEuro(reste)}
                      </span>
                    )}
                  </div>
                </Link>
              );
            })}
          </ListGroup>
        ) : (
          <EmptyState icon="doc" title="Aucun document" desc="Générez un devis ou une facture depuis un ticket." />
        )}
      </div>
    </div>
  );
}

export default function FacturesPage() {
  return (
    <Suspense>
      <FacturesInner />
    </Suspense>
  );
}
