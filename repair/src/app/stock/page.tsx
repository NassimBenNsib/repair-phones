"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { useStore } from "@/lib/store";
import { fmtEuro, stockState } from "@/lib/format";
import type { Part } from "@/lib/types";
import { LargeHeader } from "@/components/Header";
import {
  Badge,
  EmptyState,
  ListGroup,
  SearchBar,
  Segmented,
  cx,
} from "@/components/ui";
import { Icon } from "@/components/Icon";

type Filter = "tous" | "alertes" | string; // string = catégorie

function StockInner() {
  const { state } = useStore();
  const params = useSearchParams();
  const [q, setQ] = useState("");
  const [filter, setFilter] = useState<Filter>(
    params.get("f") === "alertes" ? "alertes" : "tous",
  );

  const categories = useMemo(
    () => Array.from(new Set(state.parts.map((p) => p.categorie))).sort(),
    [state.parts],
  );

  const alertes = state.parts.filter((p) => stockState(p) !== "ok");
  const valeurStock = state.parts.reduce((s, p) => s + p.quantite * p.prixAchat, 0);

  const list = useMemo(() => {
    const n = q.trim().toLowerCase();
    return state.parts
      .filter((p) => {
        if (filter === "alertes" && stockState(p) === "ok") return false;
        if (filter !== "tous" && filter !== "alertes" && p.categorie !== filter)
          return false;
        if (!n) return true;
        return [p.designation, p.reference, ...p.compatibilite]
          .join(" ")
          .toLowerCase()
          .includes(n);
      })
      .sort((a, b) => {
        const order = { rupture: 0, bas: 1, ok: 2 };
        return order[stockState(a)] - order[stockState(b)];
      });
  }, [state.parts, q, filter]);

  return (
    <div className="anim-fade">
      <LargeHeader
        title="Stock"
        trailing={
          <div className="text-right">
            <div className="text-[11px] text-[var(--text-tertiary)]">Valeur stock</div>
            <div className="text-[15px] font-bold tabular-nums">{fmtEuro(valeurStock)}</div>
          </div>
        }
      >
        <div className="space-y-2.5">
          <SearchBar value={q} onChange={setQ} placeholder="Désignation, réf., modèle…" />
          <Segmented<Filter>
            value={filter}
            onChange={setFilter}
            scroll
            options={[
              { value: "tous", label: "Tous", count: state.parts.length },
              { value: "alertes", label: "Alertes", count: alertes.length },
              ...categories.map((c) => ({ value: c, label: c })),
            ]}
          />
        </div>
      </LargeHeader>

      <div className="px-4 pb-8 pt-2">
        {list.length ? (
          <ListGroup>
            {list.map((p) => (
              <StockRow key={p.id} part={p} />
            ))}
          </ListGroup>
        ) : (
          <EmptyState
            icon="box"
            title={filter === "alertes" ? "Aucune alerte" : "Aucune pièce"}
            desc={filter === "alertes" ? "Tout le stock est au-dessus du seuil 👍" : undefined}
          />
        )}
      </div>
    </div>
  );
}

function StockRow({ part }: { part: Part }) {
  const st = stockState(part);
  const tone = st === "ok" ? "success" : st === "bas" ? "warning" : "danger";
  const label = st === "ok" ? `${part.quantite} en stock` : st === "bas" ? `Bas · ${part.quantite}` : "Rupture";
  return (
    <Link
      href={`/stock/${part.id}`}
      className="press flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 last:border-0 active:bg-[var(--surface-2)]"
    >
      <div
        className={cx(
          "flex h-11 w-11 shrink-0 items-center justify-center rounded-[12px]",
          st === "rupture"
            ? "bg-[var(--danger-weak)] text-[var(--danger)]"
            : st === "bas"
              ? "bg-[var(--warning-weak)] text-[var(--warning)]"
              : "bg-[var(--surface-sunken)] text-[var(--text-secondary)]",
        )}
      >
        <Icon name="box" size={22} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="truncate text-[15px] font-semibold">{part.designation}</div>
        <div className="mt-0.5 flex items-center gap-1.5 text-[13px] text-[var(--text-tertiary)]">
          <span>{part.reference}</span>
          <span>·</span>
          <span className="truncate">{part.categorie}</span>
        </div>
        <div className="mt-1.5">
          <Badge tone={tone} dot>
            {label}
          </Badge>
        </div>
      </div>
      <div className="flex shrink-0 flex-col items-end gap-1">
        <span className="text-[15px] font-semibold tabular-nums">{fmtEuro(part.prixVente)}</span>
        <span className="text-[12px] text-[var(--text-tertiary)]">seuil {part.seuil}</span>
      </div>
    </Link>
  );
}

export default function StockPage() {
  return (
    <Suspense>
      <StockInner />
    </Suspense>
  );
}
