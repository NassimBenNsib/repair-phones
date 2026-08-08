"use client";

import { useMemo, useState } from "react";
import { useStore } from "@/lib/store";
import { techLoad } from "@/lib/stats";
import { TICKET_STATUS_META, fmtDate } from "@/lib/format";
import { LargeHeader } from "@/components/Header";
import { TicketRow } from "@/components/domain";
import { Avatar, Card, ListGroup, ProgressBar, SectionTitle, Segmented, cx } from "@/components/ui";
import { Icon, type IconName } from "@/components/Icon";

export default function PlanningPage() {
  const { state } = useStore();
  const [view, setView] = useState<"equipe" | "semaine">("equipe");

  const loads = useMemo(() => techLoad(state), [state]);
  const maxLoad = Math.max(1, ...loads.map((l) => l.tickets.length));

  // Regroupe les tickets ouverts par jour de promesse sur 7 jours.
  const week = useMemo(() => {
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const days: { date: Date; tickets: typeof state.tickets }[] = [];
    for (let i = 0; i < 7; i++) {
      const d = new Date(now.getTime() + i * 86_400_000);
      const tickets = state.tickets.filter((t) => {
        if (t.status === "restitue" || !t.promisAt) return false;
        const p = new Date(t.promisAt);
        return p.getFullYear() === d.getFullYear() && p.getMonth() === d.getMonth() && p.getDate() === d.getDate();
      });
      days.push({ date: d, tickets });
    }
    // tickets en retard (avant aujourd'hui)
    const late = state.tickets.filter(
      (t) => t.status !== "restitue" && t.promisAt && new Date(t.promisAt) < now,
    );
    return { days, late };
  }, [state.tickets]);

  return (
    <div className="anim-fade">
      <LargeHeader title="Planning" subtitle="Charge & échéances">
        <Segmented
          value={view}
          onChange={setView}
          options={[
            { value: "equipe", label: "Par technicien" },
            { value: "semaine", label: "Semaine" },
          ]}
        />
      </LargeHeader>

      <div className="space-y-6 px-4 pb-8 pt-2">
        {view === "equipe" ? (
          <div className="space-y-3">
            {loads
              .sort((a, b) => b.tickets.length - a.tickets.length)
              .map(({ tech, tickets, urgent }) => (
                <Card key={tech.id}>
                  <div className="flex items-center gap-3">
                    <Avatar nom={tech.nom} color={tech.couleur} size={44} />
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className="text-[16px] font-semibold">{tech.nom}</span>
                        {urgent > 0 && (
                          <span className="flex items-center gap-1 text-[12px] font-medium text-[var(--danger)]">
                            <Icon name="alert" size={13} /> {urgent}
                          </span>
                        )}
                      </div>
                      <div className="text-[13px] capitalize text-[var(--text-tertiary)]">{tech.role}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-[24px] font-bold leading-none tabular-nums">{tickets.length}</div>
                      <div className="text-[11px] text-[var(--text-tertiary)]">tickets</div>
                    </div>
                  </div>
                  <div className="mt-3">
                    <ProgressBar value={tickets.length / maxLoad} tone={urgent > 1 ? "danger" : "accent"} />
                  </div>
                  {tickets.length > 0 && (
                    <div className="mt-3 flex flex-wrap gap-1.5">
                      {tickets.slice(0, 6).map((t) => {
                        const m = TICKET_STATUS_META[t.status];
                        return (
                          <span
                            key={t.id}
                            className="inline-flex items-center gap-1 rounded-full bg-[var(--surface-2)] px-2 py-1 text-[11px] font-medium"
                          >
                            <Icon name={m.icon as IconName} size={11} style={{ color: `var(--${m.tone === "accent" ? "accent" : "text-secondary"})` }} />
                            {t.id}
                          </span>
                        );
                      })}
                      {tickets.length > 6 && (
                        <span className="rounded-full bg-[var(--surface-2)] px-2 py-1 text-[11px] font-medium text-[var(--text-tertiary)]">
                          +{tickets.length - 6}
                        </span>
                      )}
                    </div>
                  )}
                </Card>
              ))}
            {/* Non assignés */}
            <UnassignedCard tickets={state.tickets.filter((t) => !t.technicienId && t.status !== "restitue")} />
          </div>
        ) : (
          <div className="space-y-5">
            {week.late.length > 0 && (
              <div>
                <SectionTitle>
                  <span className="text-[var(--danger)]">En retard ({week.late.length})</span>
                </SectionTitle>
                <ListGroup>
                  {week.late.map((t) => (
                    <TicketRow key={t.id} ticket={t} />
                  ))}
                </ListGroup>
              </div>
            )}
            {week.days.map(({ date, tickets }, i) => (
              <div key={i}>
                <SectionTitle>
                  <span className="flex items-center gap-2">
                    <span className="capitalize">
                      {i === 0 ? "Aujourd'hui" : i === 1 ? "Demain" : date.toLocaleDateString("fr-FR", { weekday: "long" })}
                    </span>
                    <span className="text-[13px] font-normal text-[var(--text-tertiary)]">{fmtDate(date.toISOString())}</span>
                  </span>
                </SectionTitle>
                {tickets.length ? (
                  <ListGroup>
                    {tickets.map((t) => (
                      <TicketRow key={t.id} ticket={t} showDue={false} />
                    ))}
                  </ListGroup>
                ) : (
                  <div className="rounded-[14px] border border-dashed border-[var(--separator-strong)] px-4 py-3 text-[13px] text-[var(--text-tertiary)]">
                    Aucune réparation promise
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function UnassignedCard({ tickets }: { tickets: ReturnType<typeof useStore>["state"]["tickets"] }) {
  if (!tickets.length) return null;
  return (
    <Card>
      <div className="flex items-center gap-3">
        <div className="flex h-11 w-11 items-center justify-center rounded-full bg-[var(--warning-weak)] text-[var(--warning)]">
          <Icon name="user" size={22} />
        </div>
        <div className="flex-1">
          <div className="text-[16px] font-semibold">Non assignés</div>
          <div className="text-[13px] text-[var(--text-tertiary)]">À répartir dans l'équipe</div>
        </div>
        <div className="text-[24px] font-bold tabular-nums text-[var(--warning)]">{tickets.length}</div>
      </div>
    </Card>
  );
}
