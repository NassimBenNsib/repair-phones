"use client";

import { useMemo } from "react";
import { useStore } from "@/lib/store";
import { revenue } from "@/lib/stats";
import { fmtEuroCompact } from "@/lib/format";
import { LargeHeader } from "@/components/Header";
import { Avatar, Card, ListGroup, ListRow, SectionTitle } from "@/components/ui";
import { Icon, type IconName } from "@/components/Icon";

export default function PlusPage() {
  const { state } = useStore();
  const caMonth = useMemo(() => revenue(state, 30), [state]);

  const items: {
    href: string;
    icon: IconName;
    label: string;
    desc: string;
    tone: string;
  }[] = [
    { href: "/factures", icon: "doc", label: "Devis & Factures", desc: "Documents, encaissements, TVA", tone: "var(--accent)" },
    { href: "/planning", icon: "calendar", label: "Planning & Équipe", desc: "Charge par technicien, échéances", tone: "var(--info)" },
    { href: "/stock?f=alertes", icon: "alert", label: "Alertes stock", desc: "Pièces à commander", tone: "var(--warning)" },
    { href: "/reglages", icon: "settings", label: "Réglages", desc: "Atelier, TVA, garantie, thème", tone: "var(--text-secondary)" },
  ];

  return (
    <div className="anim-fade">
      <LargeHeader title="Plus" />

      <div className="space-y-6 px-4 pb-8">
        {/* Bandeau atelier */}
        <Card>
          <div className="flex items-center gap-3.5">
            <div className="flex h-12 w-12 items-center justify-center rounded-[13px] bg-[var(--accent)] text-white">
              <Icon name="wrench" size={24} strokeWidth={2.2} />
            </div>
            <div className="flex-1">
              <div className="text-[17px] font-bold">{state.atelier.nom}</div>
              <div className="text-[13px] text-[var(--text-tertiary)]">{state.atelier.adresse}</div>
            </div>
          </div>
          <div className="mt-3.5 grid grid-cols-3 gap-2 text-center">
            <MiniKpi value={String(state.tickets.filter((t) => t.status !== "restitue").length)} label="Ouverts" />
            <MiniKpi value={String(state.clients.length)} label="Clients" />
            <MiniKpi value={fmtEuroCompact(caMonth)} label="CA / mois" />
          </div>
        </Card>

        <div>
          <SectionTitle>Modules</SectionTitle>
          <ListGroup>
            {items.map((it) => (
              <ListRow
                key={it.href}
                href={it.href}
                chevron
                leading={
                  <div
                    className="flex h-9 w-9 items-center justify-center rounded-[10px]"
                    style={{ background: `color-mix(in srgb, ${it.tone} 14%, transparent)`, color: it.tone }}
                  >
                    <Icon name={it.icon} size={20} />
                  </div>
                }
              >
                <div className="text-[15px] font-medium">{it.label}</div>
                <div className="text-[12px] text-[var(--text-tertiary)]">{it.desc}</div>
              </ListRow>
            ))}
          </ListGroup>
        </div>

        {/* Équipe */}
        <div>
          <SectionTitle>Équipe</SectionTitle>
          <ListGroup>
            {state.techniciens.map((t) => (
              <ListRow key={t.id} leading={<Avatar nom={t.nom} color={t.couleur} size={36} />}>
                <div className="text-[15px] font-medium">{t.nom}</div>
                <div className="text-[12px] capitalize text-[var(--text-tertiary)]">{t.role}</div>
              </ListRow>
            ))}
          </ListGroup>
        </div>

        <div className="px-1 text-center text-[12px] text-[var(--text-tertiary)]">
          Atelier v1.0 · Prototype de démonstration
        </div>
      </div>
    </div>
  );
}

function MiniKpi({ value, label }: { value: string; label: string }) {
  return (
    <div className="rounded-[12px] bg-[var(--surface-2)] py-2.5">
      <div className="text-[17px] font-bold tabular-nums">{value}</div>
      <div className="text-[11px] text-[var(--text-tertiary)]">{label}</div>
    </div>
  );
}
