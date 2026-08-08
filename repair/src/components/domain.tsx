"use client";

import Link from "next/link";
import type { Ticket } from "@/lib/types";
import {
  DEVICE_META,
  PRIORITY_META,
  TICKET_STATUS_META,
  computeTotals,
  fmtEuro,
  relativeDue,
} from "@/lib/format";
import { useSelectors } from "@/lib/store";
import { Icon, type IconName } from "./Icon";
import { Avatar, Badge, cx } from "./ui";

// ── Ligne de ticket (liste, dashboard, planning) ─────────────────────────────
export function TicketRow({ ticket, showDue = true }: { ticket: Ticket; showDue?: boolean }) {
  const { clientById, deviceById, techById } = useSelectors();
  const client = clientById(ticket.clientId);
  const device = deviceById(ticket.deviceId);
  const tech = techById(ticket.technicienId);
  const meta = TICKET_STATUS_META[ticket.status];
  const { totalTTC } = computeTotals(ticket.lignes, 0, 20);
  const due = relativeDue(ticket.promisAt);
  const late = ticket.promisAt
    ? new Date(ticket.promisAt).getTime() < Date.now() &&
      ticket.status !== "restitue" &&
      ticket.status !== "pret"
    : false;

  return (
    <Link
      href={`/tickets/${ticket.id}`}
      className="press flex items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-4 py-3 last:border-0 active:bg-[var(--surface-2)]"
    >
      <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-[12px] bg-[var(--surface-sunken)] text-[var(--text-secondary)]">
        <Icon name={(DEVICE_META[device?.type ?? "autre"].icon as IconName)} size={22} />
      </div>
      <div className="min-w-0 flex-1">
        <div className="flex items-center gap-2">
          <span className="truncate text-[15px] font-semibold">
            {device?.marque} {device?.modele}
          </span>
          {ticket.priority === "urgente" && (
            <Icon name="alert" size={14} className="shrink-0 text-[var(--danger)]" />
          )}
        </div>
        <div className="mt-0.5 flex items-center gap-1.5 text-[13px] text-[var(--text-secondary)]">
          <span className="truncate">{client?.nom}</span>
          <span className="text-[var(--text-tertiary)]">·</span>
          <span className="shrink-0 text-[var(--text-tertiary)]">{ticket.id}</span>
        </div>
        <div className="mt-1.5 flex items-center gap-2">
          <Badge tone={meta.tone} icon={meta.icon as IconName}>
            {meta.label}
          </Badge>
          {tech && (
            <span className="inline-flex items-center gap-1 text-[12px] text-[var(--text-tertiary)]">
              <Avatar nom={tech.nom} color={tech.couleur} size={16} />
            </span>
          )}
        </div>
      </div>
      <div className="flex shrink-0 flex-col items-end gap-1">
        <span className="text-[15px] font-semibold tabular-nums">{fmtEuro(totalTTC)}</span>
        {showDue && ticket.status !== "restitue" && (
          <span
            className={cx(
              "text-[12px] font-medium",
              late ? "text-[var(--danger)]" : "text-[var(--text-tertiary)]",
            )}
          >
            {due}
          </span>
        )}
      </div>
    </Link>
  );
}

// ── Tuile statistique (dashboard) ────────────────────────────────────────────
export function StatTile({
  label,
  value,
  icon,
  tone = "accent",
  sub,
  href,
}: {
  label: string;
  value: string;
  icon: IconName;
  tone?: "accent" | "success" | "warning" | "danger" | "info";
  sub?: string;
  href?: string;
}) {
  const toneVar = {
    accent: "var(--accent)",
    success: "var(--success)",
    warning: "var(--warning)",
    danger: "var(--danger)",
    info: "var(--info)",
  }[tone];
  const inner = (
    <>
      <div className="flex items-center justify-between">
        <div
          className="flex h-8 w-8 items-center justify-center rounded-[9px]"
          style={{ background: `color-mix(in srgb, ${toneVar} 14%, transparent)`, color: toneVar }}
        >
          <Icon name={icon} size={18} strokeWidth={2} />
        </div>
        {href && <Icon name="chevron" size={16} className="text-[var(--text-tertiary)]" />}
      </div>
      <div className="mt-2.5 text-[24px] font-bold leading-none tracking-[-0.02em] tabular-nums">
        {value}
      </div>
      <div className="mt-1 text-[13px] font-medium text-[var(--text-secondary)]">{label}</div>
      {sub && <div className="mt-0.5 text-[12px]" style={{ color: toneVar }}>{sub}</div>}
    </>
  );
  const cls =
    "block rounded-[var(--radius-card)] bg-[var(--surface)] p-3.5 shadow-[var(--shadow-card)] press";
  const style = { border: "0.5px solid var(--separator)" };
  return href ? (
    <Link href={href} className={cls} style={style}>
      {inner}
    </Link>
  ) : (
    <div className={cls} style={style}>
      {inner}
    </div>
  );
}

// ── Sparkline / mini-graphique (SVG) ─────────────────────────────────────────
export function Sparkline({
  data,
  height = 64,
  fill = true,
}: {
  data: number[];
  height?: number;
  fill?: boolean;
}) {
  const w = 300;
  const max = Math.max(...data, 1);
  const min = Math.min(...data, 0);
  const range = max - min || 1;
  const step = w / (data.length - 1 || 1);
  const pts = data.map((d, i) => {
    const x = i * step;
    const y = height - 6 - ((d - min) / range) * (height - 12);
    return [x, y] as const;
  });
  const line = pts.map(([x, y], i) => `${i === 0 ? "M" : "L"}${x.toFixed(1)},${y.toFixed(1)}`).join(" ");
  const area = `${line} L${w},${height} L0,${height} Z`;
  return (
    <svg viewBox={`0 0 ${w} ${height}`} className="w-full" preserveAspectRatio="none" style={{ height }}>
      <defs>
        <linearGradient id="spark" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="var(--accent)" stopOpacity="0.28" />
          <stop offset="100%" stopColor="var(--accent)" stopOpacity="0" />
        </linearGradient>
      </defs>
      {fill && <path d={area} fill="url(#spark)" />}
      <path d={line} fill="none" stroke="var(--accent)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
      {pts.length > 0 && (
        <circle cx={pts[pts.length - 1][0]} cy={pts[pts.length - 1][1]} r="3.5" fill="var(--accent)" />
      )}
    </svg>
  );
}

// ── Chip de priorité ─────────────────────────────────────────────────────────
export function PriorityBadge({ priority }: { priority: Ticket["priority"] }) {
  const m = PRIORITY_META[priority];
  return <Badge tone={m.tone}>{m.label}</Badge>;
}
