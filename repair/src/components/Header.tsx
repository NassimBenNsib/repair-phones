"use client";

import { useRouter } from "next/navigation";
import type { ReactNode } from "react";
import { Icon } from "./Icon";

/** En-tête à Large Title (style iOS) pour les écrans de premier niveau. */
export function LargeHeader({
  title,
  subtitle,
  trailing,
  children,
}: {
  title: string;
  subtitle?: string;
  trailing?: ReactNode;
  children?: ReactNode; // contenu collant sous le titre (recherche, segmented…)
}) {
  return (
    <header className="px-4 pt-safe">
      <div className="flex items-end justify-between pb-1 pt-3">
        <div>
          {subtitle && (
            <div className="text-[13px] font-medium text-[var(--text-tertiary)]">
              {subtitle}
            </div>
          )}
          <h1 className="text-[30px] font-bold leading-tight tracking-[-0.02em]">
            {title}
          </h1>
        </div>
        {trailing && <div className="pb-1">{trailing}</div>}
      </div>
      {children && <div className="pb-2 pt-1">{children}</div>}
    </header>
  );
}

/** En-tête de sous-page avec bouton retour. */
export function SubHeader({
  title,
  trailing,
  backLabel,
}: {
  title?: string;
  trailing?: ReactNode;
  backLabel?: string;
}) {
  const router = useRouter();
  return (
    <header className="blur-bar sticky top-0 z-30 border-b-[0.5px] border-[var(--separator)] pt-safe">
      <div className="flex h-12 items-center justify-between gap-2 px-2">
        <button
          onClick={() => router.back()}
          className="press flex items-center gap-0.5 rounded-full px-2 py-1 text-[16px] font-medium text-[var(--accent)]"
        >
          <Icon name="back" size={24} />
          {backLabel && <span className="max-w-[110px] truncate">{backLabel}</span>}
        </button>
        {title && (
          <h1 className="absolute left-1/2 -translate-x-1/2 text-[16px] font-semibold">
            {title}
          </h1>
        )}
        <div className="min-w-[44px] text-right">{trailing}</div>
      </div>
    </header>
  );
}

/** Icône ronde pour bouton d'action d'en-tête. */
export function HeaderIconButton({
  icon,
  onClick,
  label,
}: {
  icon: Parameters<typeof Icon>[0]["name"];
  onClick?: () => void;
  label?: string;
}) {
  return (
    <button
      onClick={onClick}
      aria-label={label}
      className="press flex h-9 w-9 items-center justify-center rounded-full bg-[var(--surface-sunken)] text-[var(--text)]"
    >
      <Icon name={icon} size={20} />
    </button>
  );
}
