"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { useStore } from "@/lib/store";
import {
  dashboardStats,
  revenue,
  revenueSeries,
  revenueToday,
} from "@/lib/stats";
import { fmtEuro, fmtEuroCompact } from "@/lib/format";
import { LargeHeader } from "@/components/Header";
import { StatTile, TicketRow, Sparkline } from "@/components/domain";
import {
  Badge,
  Card,
  ListGroup,
  SectionTitle,
  Segmented,
  cx,
} from "@/components/ui";
import { Icon } from "@/components/Icon";

export default function DashboardPage() {
  const { state } = useStore();
  const [range, setRange] = useState<"7" | "30">("7");

  const stats = useMemo(() => dashboardStats(state), [state]);
  const caToday = useMemo(() => revenueToday(state), [state]);
  const caWeek = useMemo(() => revenue(state, 7), [state]);
  const caMonth = useMemo(() => revenue(state, 30), [state]);
  const series = useMemo(
    () => revenueSeries(state, range === "7" ? 7 : 30),
    [state, range],
  );

  const todo = useMemo(() => {
    const now = Date.now();
    return [...stats.open]
      .filter((t) => t.status !== "restitue")
      .sort((a, b) => {
        const prio = { urgente: 0, haute: 1, normale: 2, basse: 3 } as const;
        const pa = prio[a.priority] - prio[b.priority];
        if (pa !== 0) return pa;
        return (
          new Date(a.promisAt ?? now).getTime() -
          new Date(b.promisAt ?? now).getTime()
        );
      })
      .slice(0, 5);
  }, [stats.open]);

  const now = new Date();
  const greeting =
    now.getHours() < 12
      ? "Bonjour"
      : now.getHours() < 18
        ? "Bon après-midi"
        : "Bonsoir";

  return (
    <div className="anim-fade">
      <LargeHeader title="Accueil" subtitle={`${greeting}, Karim 👋`} />

      <div className="space-y-6 px-4 pb-8">
        {/* CA + tendance */}
        <Card pad={false} className="overflow-hidden">
          <div className="flex items-start justify-between p-4 pb-2">
            <div>
              <div className="text-[13px] font-medium text-[var(--text-secondary)]">
                CA encaissé aujourd'hui
              </div>
              <div className="mt-1 text-[32px] font-bold leading-none tracking-[-0.02em] tabular-nums">
                {fmtEuro(caToday)}
              </div>
              <div className="mt-2 flex gap-4 text-[13px]">
                <span className="text-[var(--text-secondary)]">
                  Semaine{" "}
                  <span className="font-semibold text-[var(--text)]">
                    {fmtEuroCompact(caWeek)}
                  </span>
                </span>
                <span className="text-[var(--text-secondary)]">
                  Mois{" "}
                  <span className="font-semibold text-[var(--text)]">
                    {fmtEuroCompact(caMonth)}
                  </span>
                </span>
              </div>
            </div>
            <div className="w-28">
              <Segmented
                value={range}
                onChange={setRange}
                options={[
                  { value: "7", label: "7 j" },
                  { value: "30", label: "30 j" },
                ]}
              />
            </div>
          </div>
          <Sparkline data={series} height={72} />
        </Card>

        {/* Tuiles de synthèse */}
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
          <StatTile
            label="Tickets ouverts"
            value={String(stats.open.length)}
            icon="ticket"
            tone="accent"
            href="/tickets"
          />
          <StatTile
            label="Prêts à restituer"
            value={String(stats.prets.length)}
            icon="checkCircle"
            tone="success"
            href="/tickets?f=pret"
            sub={stats.prets.length ? "À notifier" : undefined}
          />
          <StatTile
            label="En retard"
            value={String(stats.late.length)}
            icon="clock"
            tone="danger"
            href="/tickets"
            sub={stats.late.length ? "Action requise" : undefined}
          />
          <StatTile
            label="Stock bas"
            value={String(stats.stockBas.length)}
            icon="alert"
            tone="warning"
            href="/stock?f=alertes"
            sub={stats.ruptures.length ? `${stats.ruptures.length} en rupture` : undefined}
          />
        </div>

        {/* Alertes */}
        {(stats.late.length > 0 || stats.ruptures.length > 0 || stats.impayes.length > 0) && (
          <div className="space-y-2">
            {stats.ruptures.length > 0 && (
              <AlertBanner
                icon="box"
                tone="warning"
                text={`${stats.ruptures.length} pièce(s) en rupture de stock`}
                href="/stock?f=alertes"
              />
            )}
            {stats.late.length > 0 && (
              <AlertBanner
                icon="clock"
                tone="danger"
                text={`${stats.late.length} ticket(s) en retard sur l'échéance`}
                href="/tickets"
              />
            )}
            {stats.impayes.length > 0 && (
              <AlertBanner
                icon="euro"
                tone="info"
                text={`${stats.impayes.length} facture(s) impayée(s)`}
                href="/factures?f=impaye"
              />
            )}
          </div>
        )}

        {/* À traiter aujourd'hui */}
        <div>
          <SectionTitle
            action={
              <Link href="/tickets" className="text-[14px] font-medium text-[var(--accent)]">
                Tout voir
              </Link>
            }
          >
            À traiter aujourd'hui
          </SectionTitle>
          {todo.length ? (
            <ListGroup>
              {todo.map((t) => (
                <TicketRow key={t.id} ticket={t} />
              ))}
            </ListGroup>
          ) : (
            <Card>
              <div className="flex items-center gap-3 text-[var(--text-secondary)]">
                <Icon name="checkCircle" size={22} className="text-[var(--success)]" />
                <span className="text-[14px]">Tout est à jour. Rien d'urgent 🎉</span>
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  );
}

function AlertBanner({
  icon,
  tone,
  text,
  href,
}: {
  icon: Parameters<typeof Icon>[0]["name"];
  tone: "warning" | "danger" | "info";
  text: string;
  href: string;
}) {
  const c = {
    warning: "var(--warning)",
    danger: "var(--danger)",
    info: "var(--info)",
  }[tone];
  return (
    <Link
      href={href}
      className="press flex items-center gap-3 rounded-[14px] px-3.5 py-3"
      style={{ background: `color-mix(in srgb, ${c} 12%, transparent)` }}
    >
      <Icon name={icon} size={20} style={{ color: c }} />
      <span className="flex-1 text-[14px] font-medium" style={{ color: c }}>
        {text}
      </span>
      <Icon name="chevron" size={16} style={{ color: c }} />
    </Link>
  );
}
