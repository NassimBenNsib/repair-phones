"use client";

import { TICKET_FLOW, type TicketStatus } from "@/lib/types";
import { TICKET_STATUS_META, fmtDateTime } from "@/lib/format";
import type { StatusEvent } from "@/lib/types";
import { Icon } from "./Icon";
import { cx } from "./ui";

/** Timeline de statut interactive : étapes atteintes, courante, à venir. */
export function StatusTimeline({
  current,
  history,
  onPick,
}: {
  current: TicketStatus;
  history: StatusEvent[];
  onPick?: (s: TicketStatus) => void;
}) {
  const currentStep = TICKET_STATUS_META[current].step;

  return (
    <ol className="relative">
      {TICKET_FLOW.map((status, i) => {
        const meta = TICKET_STATUS_META[status];
        const done = i < currentStep;
        const active = i === currentStep;
        const event = [...history].reverse().find((h) => h.status === status);
        const reached = done || active;
        return (
          <li key={status} className="flex gap-3">
            {/* Rail */}
            <div className="flex flex-col items-center">
              <button
                disabled={!onPick}
                onClick={() => onPick?.(status)}
                className={cx(
                  "press flex h-8 w-8 items-center justify-center rounded-full transition-colors",
                  active && "bg-[var(--accent)] text-white ring-4 ring-[var(--accent-weak)]",
                  done && "bg-[var(--success)] text-white",
                  !reached && "bg-[var(--surface-sunken)] text-[var(--text-tertiary)]",
                  onPick && "cursor-pointer",
                )}
                aria-label={meta.label}
              >
                <Icon name={done ? "check" : (meta.icon as never)} size={16} strokeWidth={2.4} />
              </button>
              {i < TICKET_FLOW.length - 1 && (
                <span
                  className="my-0.5 w-0.5 flex-1"
                  style={{
                    minHeight: 22,
                    background: i < currentStep ? "var(--success)" : "var(--separator-strong)",
                  }}
                />
              )}
            </div>
            {/* Libellé */}
            <div className={cx("pb-4", !reached && "opacity-55")}>
              <div
                className={cx(
                  "text-[15px] font-semibold",
                  active ? "text-[var(--accent)]" : "text-[var(--text)]",
                )}
              >
                {meta.label}
              </div>
              <div className="text-[12px] text-[var(--text-tertiary)]">
                {event ? fmtDateTime(event.at) : active ? "En cours" : "À venir"}
              </div>
            </div>
          </li>
        );
      })}
    </ol>
  );
}
