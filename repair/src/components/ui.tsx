"use client";

import Link from "next/link";
import type { ButtonHTMLAttributes, InputHTMLAttributes, ReactNode } from "react";
import type { BadgeTone } from "@/lib/format";
import { initials } from "@/lib/format";
import { Icon, type IconName } from "./Icon";

const cx = (...a: (string | false | undefined | null)[]) =>
  a.filter(Boolean).join(" ");

// ── Badge de statut ──────────────────────────────────────────────────────────
const TONE: Record<BadgeTone, { bg: string; fg: string }> = {
  neutral: { bg: "var(--surface-sunken)", fg: "var(--text-secondary)" },
  muted: { bg: "var(--surface-sunken)", fg: "var(--text-tertiary)" },
  accent: { bg: "var(--accent-weak)", fg: "var(--accent)" },
  info: { bg: "var(--info-weak)", fg: "var(--info)" },
  success: { bg: "var(--success-weak)", fg: "var(--success)" },
  warning: { bg: "var(--warning-weak)", fg: "var(--warning)" },
  danger: { bg: "var(--danger-weak)", fg: "var(--danger)" },
};

export function Badge({
  tone = "neutral",
  children,
  icon,
  dot,
}: {
  tone?: BadgeTone;
  children: ReactNode;
  icon?: IconName;
  dot?: boolean;
}) {
  const t = TONE[tone];
  return (
    <span
      className="inline-flex items-center gap-1 rounded-full px-2 py-[3px] text-[12px] font-semibold leading-none"
      style={{ background: t.bg, color: t.fg }}
    >
      {dot && (
        <span
          className="h-1.5 w-1.5 rounded-full"
          style={{ background: t.fg }}
        />
      )}
      {icon && <Icon name={icon} size={12} strokeWidth={2.4} />}
      {children}
    </span>
  );
}

// ── Avatar / monogramme ──────────────────────────────────────────────────────
export function Avatar({
  nom,
  color,
  size = 40,
}: {
  nom: string;
  color?: string;
  size?: number;
}) {
  return (
    <div
      className="flex shrink-0 items-center justify-center rounded-full font-semibold text-white"
      style={{
        width: size,
        height: size,
        fontSize: size * 0.36,
        background: color ?? "var(--accent)",
      }}
    >
      {initials(nom)}
    </div>
  );
}

// ── Carte ────────────────────────────────────────────────────────────────────
export function Card({
  children,
  className,
  as,
  href,
  onClick,
  pad = true,
}: {
  children: ReactNode;
  className?: string;
  as?: "div" | "section";
  href?: string;
  onClick?: () => void;
  pad?: boolean;
}) {
  const cls = cx(
    "rounded-[var(--radius-card)] bg-[var(--surface)] shadow-[var(--shadow-card)]",
    pad && "p-4",
    (href || onClick) && "press cursor-pointer",
    className,
  );
  const style = { border: "0.5px solid var(--separator)" };
  if (href)
    return (
      <Link href={href} className={cls} style={style}>
        {children}
      </Link>
    );
  if (onClick)
    return (
      <button className={cx(cls, "w-full text-left")} style={style} onClick={onClick}>
        {children}
      </button>
    );
  const Tag = as ?? "div";
  return (
    <Tag className={cls} style={style}>
      {children}
    </Tag>
  );
}

// ── Groupe de lignes (list inset iOS) ────────────────────────────────────────
export function ListGroup({
  children,
  title,
  className,
}: {
  children: ReactNode;
  title?: string;
  className?: string;
}) {
  return (
    <div className={className}>
      {title && (
        <div className="mb-1.5 px-4 text-[13px] font-medium uppercase tracking-wide text-[var(--text-tertiary)]">
          {title}
        </div>
      )}
      <div
        className="overflow-hidden rounded-[var(--radius-card)] bg-[var(--surface)] shadow-[var(--shadow-card)]"
        style={{ border: "0.5px solid var(--separator)" }}
      >
        {children}
      </div>
    </div>
  );
}

export function ListRow({
  children,
  href,
  onClick,
  leading,
  trailing,
  chevron,
  className,
}: {
  children: ReactNode;
  href?: string;
  onClick?: () => void;
  leading?: ReactNode;
  trailing?: ReactNode;
  chevron?: boolean;
  className?: string;
}) {
  const inner = (
    <>
      {leading && <div className="shrink-0">{leading}</div>}
      <div className="min-w-0 flex-1">{children}</div>
      {trailing && <div className="shrink-0">{trailing}</div>}
      {chevron && (
        <Icon
          name="chevron"
          size={18}
          className="shrink-0 text-[var(--text-tertiary)]"
        />
      )}
    </>
  );
  const cls = cx(
    "flex w-full items-center gap-3 px-4 py-3 text-left",
    "border-b-[0.5px] border-[var(--separator)] last:border-b-0",
    (href || onClick) && "press active:bg-[var(--surface-2)]",
    className,
  );
  if (href)
    return (
      <Link href={href} className={cls}>
        {inner}
      </Link>
    );
  if (onClick)
    return (
      <button className={cls} onClick={onClick}>
        {inner}
      </button>
    );
  return <div className={cls}>{inner}</div>;
}

// ── Boutons ──────────────────────────────────────────────────────────────────
type BtnVariant = "primary" | "secondary" | "tertiary" | "destructive";
export function Button({
  variant = "primary",
  icon,
  children,
  full,
  size = "md",
  className,
  ...rest
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: BtnVariant;
  icon?: IconName;
  full?: boolean;
  size?: "sm" | "md" | "lg";
}) {
  const base =
    "press inline-flex items-center justify-center gap-2 rounded-full font-semibold disabled:opacity-40 disabled:pointer-events-none";
  const sizes = {
    sm: "px-3.5 py-2 text-[14px]",
    md: "px-5 py-3 text-[15px]",
    lg: "px-6 py-3.5 text-[16px]",
  };
  const variants: Record<BtnVariant, string> = {
    primary: "bg-[var(--accent)] text-white shadow-sm",
    secondary:
      "bg-[var(--accent-weak)] text-[var(--accent)]",
    tertiary: "bg-[var(--surface-sunken)] text-[var(--text)]",
    destructive: "bg-[var(--danger-weak)] text-[var(--danger)]",
  };
  return (
    <button
      className={cx(base, sizes[size], variants[variant], full && "w-full", className)}
      {...rest}
    >
      {icon && <Icon name={icon} size={size === "sm" ? 16 : 18} strokeWidth={2.2} />}
      {children}
    </button>
  );
}

// ── Segmented control ────────────────────────────────────────────────────────
export function Segmented<T extends string>({
  value,
  onChange,
  options,
  scroll,
}: {
  value: T;
  onChange: (v: T) => void;
  options: { value: T; label: string; count?: number }[];
  scroll?: boolean;
}) {
  return (
    <div
      className={cx(
        "flex gap-1 rounded-[12px] bg-[var(--surface-sunken)] p-1",
        scroll && "no-scrollbar overflow-x-auto",
      )}
    >
      {options.map((o) => {
        const active = o.value === value;
        return (
          <button
            key={o.value}
            onClick={() => onChange(o.value)}
            className={cx(
              "press flex-1 whitespace-nowrap rounded-[9px] px-3 py-1.5 text-[13px] font-semibold transition-colors",
              active
                ? "bg-[var(--surface)] text-[var(--text)] shadow-sm"
                : "text-[var(--text-secondary)]",
            )}
            style={active ? { border: "0.5px solid var(--separator)" } : undefined}
          >
            {o.label}
            {o.count !== undefined && (
              <span
                className={cx(
                  "ml-1.5 text-[12px]",
                  active ? "text-[var(--accent)]" : "text-[var(--text-tertiary)]",
                )}
              >
                {o.count}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}

// ── Champs de saisie ─────────────────────────────────────────────────────────
export function Field({
  label,
  hint,
  children,
}: {
  label?: string;
  hint?: string;
  children: ReactNode;
}) {
  return (
    <label className="block">
      {label && (
        <span className="mb-1.5 block px-1 text-[13px] font-medium text-[var(--text-secondary)]">
          {label}
        </span>
      )}
      {children}
      {hint && (
        <span className="mt-1 block px-1 text-[12px] text-[var(--text-tertiary)]">
          {hint}
        </span>
      )}
    </label>
  );
}

const inputCls =
  "w-full rounded-[12px] bg-[var(--surface)] px-3.5 py-3 text-[16px] text-[var(--text)] placeholder:text-[var(--text-tertiary)] outline-none focus:ring-2 focus:ring-[var(--accent)]/40";
const inputStyle = { border: "0.5px solid var(--separator-strong)" };

export function Input(props: InputHTMLAttributes<HTMLInputElement>) {
  return <input className={inputCls} style={inputStyle} {...props} />;
}

export function Textarea(
  props: React.TextareaHTMLAttributes<HTMLTextAreaElement>,
) {
  return (
    <textarea
      rows={3}
      className={cx(inputCls, "resize-none")}
      style={inputStyle}
      {...props}
    />
  );
}

export function SearchBar({
  value,
  onChange,
  placeholder,
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
}) {
  return (
    <div
      className="flex items-center gap-2 rounded-[12px] bg-[var(--surface-sunken)] px-3 py-2.5"
    >
      <Icon name="search" size={18} className="text-[var(--text-tertiary)]" />
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder ?? "Rechercher"}
        className="w-full bg-transparent text-[16px] text-[var(--text)] placeholder:text-[var(--text-tertiary)] outline-none"
      />
      {value && (
        <button onClick={() => onChange("")} className="press text-[var(--text-tertiary)]">
          <Icon name="close" size={16} />
        </button>
      )}
    </div>
  );
}

// ── Stepper quantité ─────────────────────────────────────────────────────────
export function Stepper({
  value,
  onChange,
  min = 1,
  max = 999,
}: {
  value: number;
  onChange: (v: number) => void;
  min?: number;
  max?: number;
}) {
  return (
    <div className="flex items-center gap-0.5 rounded-full bg-[var(--surface-sunken)] p-0.5">
      <button
        className="press flex h-8 w-8 items-center justify-center rounded-full bg-[var(--surface)] shadow-sm disabled:opacity-30"
        onClick={() => onChange(Math.max(min, value - 1))}
        disabled={value <= min}
        aria-label="Diminuer"
      >
        <Icon name="minus" size={16} />
      </button>
      <span className="w-8 text-center text-[15px] font-semibold tabular-nums">
        {value}
      </span>
      <button
        className="press flex h-8 w-8 items-center justify-center rounded-full bg-[var(--surface)] shadow-sm disabled:opacity-30"
        onClick={() => onChange(Math.min(max, value + 1))}
        disabled={value >= max}
        aria-label="Augmenter"
      >
        <Icon name="plus" size={16} />
      </button>
    </div>
  );
}

// ── État vide ────────────────────────────────────────────────────────────────
export function EmptyState({
  icon,
  title,
  desc,
  action,
}: {
  icon: IconName;
  title: string;
  desc?: string;
  action?: ReactNode;
}) {
  return (
    <div className="flex flex-col items-center justify-center px-8 py-16 text-center anim-fade">
      <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-[20px] bg-[var(--surface-sunken)] text-[var(--text-tertiary)]">
        <Icon name={icon} size={30} />
      </div>
      <h3 className="text-[17px] font-semibold text-[var(--text)]">{title}</h3>
      {desc && (
        <p className="mt-1 max-w-[260px] text-[14px] text-[var(--text-secondary)]">
          {desc}
        </p>
      )}
      {action && <div className="mt-5">{action}</div>}
    </div>
  );
}

// ── Skeleton ─────────────────────────────────────────────────────────────────
export function Skeleton({ className }: { className?: string }) {
  return <div className={cx("skeleton rounded-[10px]", className)} />;
}

// ── Barre de progression ─────────────────────────────────────────────────────
export function ProgressBar({
  value,
  tone = "accent",
}: {
  value: number; // 0..1
  tone?: BadgeTone;
}) {
  return (
    <div className="h-1.5 w-full overflow-hidden rounded-full bg-[var(--surface-sunken)]">
      <div
        className="h-full rounded-full transition-all"
        style={{
          width: `${Math.min(100, Math.max(0, value * 100))}%`,
          background: TONE[tone].fg,
        }}
      />
    </div>
  );
}

// ── En-tête de section ───────────────────────────────────────────────────────
export function SectionTitle({
  children,
  action,
}: {
  children: ReactNode;
  action?: ReactNode;
}) {
  return (
    <div className="mb-2 flex items-center justify-between px-1">
      <h2 className="text-[15px] font-semibold text-[var(--text)]">{children}</h2>
      {action}
    </div>
  );
}

export { cx };
