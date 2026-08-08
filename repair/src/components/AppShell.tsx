"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useMemo } from "react";
import { useStore } from "@/lib/store";
import { stockState } from "@/lib/format";
import { Icon, type IconName } from "./Icon";
import { cx } from "./ui";

interface NavItem {
  href: string;
  label: string;
  icon: IconName;
  match: (p: string) => boolean;
}

const TABS: NavItem[] = [
  { href: "/", label: "Accueil", icon: "home", match: (p) => p === "/" },
  { href: "/tickets", label: "Tickets", icon: "ticket", match: (p) => p.startsWith("/tickets") },
  { href: "/stock", label: "Stock", icon: "box", match: (p) => p.startsWith("/stock") },
  { href: "/clients", label: "Clients", icon: "people", match: (p) => p.startsWith("/clients") },
  { href: "/plus", label: "Plus", icon: "grid", match: (p) =>
      ["/plus", "/factures", "/planning", "/reglages"].some((x) => p.startsWith(x)) },
];

const DESKTOP_EXTRA: NavItem[] = [
  { href: "/factures", label: "Devis & Factures", icon: "doc", match: (p) => p.startsWith("/factures") },
  { href: "/planning", label: "Planning", icon: "calendar", match: (p) => p.startsWith("/planning") },
  { href: "/reglages", label: "Réglages", icon: "settings", match: (p) => p.startsWith("/reglages") },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { state } = useStore();

  const badges = useMemo(() => {
    const prets = state.tickets.filter((t) => t.status === "pret").length;
    const stockBas = state.parts.filter((p) => stockState(p) !== "ok").length;
    return { "/tickets": prets, "/stock": stockBas };
  }, [state.tickets, state.parts]);

  const showFab = !pathname.startsWith("/tickets/nouveau");

  return (
    <div className="mx-auto flex min-h-dvh w-full max-w-[1200px] lg:gap-0">
      {/* Sidebar desktop/tablette */}
      <aside className="sticky top-0 hidden h-dvh w-[248px] shrink-0 flex-col border-r-[0.5px] border-[var(--separator)] px-3 py-5 lg:flex">
        <Link href="/" className="mb-6 flex items-center gap-2.5 px-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-[10px] bg-[var(--accent)] text-white">
            <Icon name="wrench" size={20} strokeWidth={2.2} />
          </div>
          <div>
            <div className="text-[16px] font-bold leading-none">Atelier</div>
            <div className="mt-0.5 text-[11px] text-[var(--text-tertiary)]">
              Gestion réparation
            </div>
          </div>
        </Link>
        <nav className="flex-1 space-y-0.5">
          {[TABS[0], TABS[1], TABS[2], TABS[3], ...DESKTOP_EXTRA].map((t) => {
            const active = t.match(pathname);
            const badge = badges[t.href as keyof typeof badges];
            return (
              <Link
                key={t.href}
                href={t.href}
                className={cx(
                  "press flex items-center gap-3 rounded-[10px] px-3 py-2.5 text-[15px] font-medium",
                  active
                    ? "bg-[var(--accent-weak)] text-[var(--accent)]"
                    : "text-[var(--text-secondary)] hover:bg-[var(--surface-2)]",
                )}
              >
                <Icon name={t.icon} size={22} strokeWidth={active ? 2.2 : 1.9} />
                <span className="flex-1">{t.label}</span>
                {badge ? (
                  <span className="rounded-full bg-[var(--danger)] px-1.5 py-0.5 text-[11px] font-bold text-white">
                    {badge}
                  </span>
                ) : null}
              </Link>
            );
          })}
        </nav>
        <button
          onClick={() => router.push("/tickets/nouveau")}
          className="press mt-2 flex items-center justify-center gap-2 rounded-full bg-[var(--accent)] py-3 text-[15px] font-semibold text-white shadow-[var(--shadow-fab)]"
        >
          <Icon name="plus" size={20} strokeWidth={2.4} /> Nouveau ticket
        </button>
      </aside>

      {/* Contenu principal */}
      <main className="min-w-0 flex-1 pb-[calc(64px+env(safe-area-inset-bottom))] lg:pb-8">
        {children}
      </main>

      {/* FAB mobile */}
      {showFab && (
        <button
          onClick={() => router.push("/tickets/nouveau")}
          className="press fixed bottom-[calc(74px+env(safe-area-inset-bottom))] right-4 z-40 flex h-14 w-14 items-center justify-center rounded-full bg-[var(--accent)] text-white shadow-[var(--shadow-fab)] lg:hidden"
          aria-label="Nouveau ticket"
        >
          <Icon name="plus" size={26} strokeWidth={2.4} />
        </button>
      )}

      {/* Tab bar mobile */}
      <nav className="blur-bar fixed inset-x-0 bottom-0 z-50 border-t-[0.5px] border-[var(--separator)] pb-safe lg:hidden">
        <div className="mx-auto flex max-w-[560px] items-stretch justify-around">
          {TABS.map((t) => {
            const active = t.match(pathname);
            const badge = badges[t.href as keyof typeof badges];
            return (
              <Link
                key={t.href}
                href={t.href}
                className="press relative flex flex-1 flex-col items-center gap-0.5 pb-1.5 pt-2"
              >
                <div className="relative">
                  <Icon
                    name={t.icon}
                    size={25}
                    strokeWidth={active ? 2.2 : 1.8}
                    className={active ? "text-[var(--accent)]" : "text-[var(--text-tertiary)]"}
                  />
                  {badge ? (
                    <span className="absolute -right-2 -top-1 min-w-[16px] rounded-full bg-[var(--danger)] px-1 text-center text-[10px] font-bold leading-4 text-white">
                      {badge}
                    </span>
                  ) : null}
                </div>
                <span
                  className={cx(
                    "text-[10px] font-medium",
                    active ? "text-[var(--accent)]" : "text-[var(--text-tertiary)]",
                  )}
                >
                  {t.label}
                </span>
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}
