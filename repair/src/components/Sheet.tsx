"use client";

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { Icon, type IconName } from "./Icon";
import { cx } from "./ui";

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet / modale montante
// ─────────────────────────────────────────────────────────────────────────────
export function Sheet({
  open,
  onClose,
  title,
  children,
  footer,
}: {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: ReactNode;
  footer?: ReactNode;
}) {
  useEffect(() => {
    if (!open) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => {
      document.body.style.overflow = prev;
      window.removeEventListener("keydown", onKey);
    };
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[60] flex items-end justify-center sm:items-center">
      <div
        className="absolute inset-0 bg-black/40 anim-fade"
        onClick={onClose}
        aria-hidden
      />
      <div
        role="dialog"
        aria-modal="true"
        className="anim-sheet relative z-10 flex max-h-[90vh] w-full flex-col rounded-t-[var(--radius-sheet)] bg-[var(--bg-elevated)] shadow-[var(--shadow-sheet)] sm:max-w-[440px] sm:rounded-[var(--radius-sheet)]"
      >
        <div className="flex items-center justify-between px-4 pb-2 pt-3">
          <div className="mx-auto h-1.5 w-9 rounded-full bg-[var(--separator-strong)] sm:hidden" />
          <div className="hidden w-full items-center justify-between sm:flex">
            <h2 className="text-[17px] font-semibold">{title}</h2>
            <button onClick={onClose} className="press text-[var(--text-tertiary)]">
              <Icon name="close" size={22} />
            </button>
          </div>
        </div>
        {title && (
          <div className="flex items-center justify-between px-5 pb-2 sm:hidden">
            <h2 className="text-[19px] font-bold">{title}</h2>
            <button onClick={onClose} className="press text-[var(--text-tertiary)]">
              <Icon name="close" size={24} />
            </button>
          </div>
        )}
        <div className="flex-1 overflow-y-auto px-5 py-2">{children}</div>
        {footer && (
          <div
            className="px-5 pb-6 pt-3 pb-safe"
            style={{ borderTop: "0.5px solid var(--separator)" }}
          >
            {footer}
          </div>
        )}
      </div>
    </div>
  );
}

// ── Feuille d'actions (action sheet iOS) ─────────────────────────────────────
export function ActionSheet({
  open,
  onClose,
  title,
  actions,
}: {
  open: boolean;
  onClose: () => void;
  title?: string;
  actions: {
    label: string;
    icon?: IconName;
    onClick: () => void;
    destructive?: boolean;
  }[];
}) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-[70] flex items-end justify-center p-3 pb-safe">
      <div className="absolute inset-0 bg-black/40 anim-fade" onClick={onClose} />
      <div className="anim-sheet relative z-10 w-full max-w-[440px] space-y-2">
        <div className="overflow-hidden rounded-[16px] bg-[var(--bg-elevated)]">
          {title && (
            <div className="border-b-[0.5px] border-[var(--separator)] px-4 py-3 text-center text-[13px] text-[var(--text-secondary)]">
              {title}
            </div>
          )}
          {actions.map((a, i) => (
            <button
              key={i}
              onClick={() => {
                a.onClick();
                onClose();
              }}
              className={cx(
                "press flex w-full items-center justify-center gap-2 border-b-[0.5px] border-[var(--separator)] py-3.5 text-[17px] font-medium last:border-0 active:bg-[var(--surface-2)]",
                a.destructive ? "text-[var(--danger)]" : "text-[var(--accent)]",
              )}
            >
              {a.icon && <Icon name={a.icon} size={20} />}
              {a.label}
            </button>
          ))}
        </div>
        <button
          onClick={onClose}
          className="press w-full rounded-[16px] bg-[var(--bg-elevated)] py-3.5 text-[17px] font-semibold text-[var(--accent)]"
        >
          Annuler
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Toasts
// ─────────────────────────────────────────────────────────────────────────────
type Toast = { id: number; msg: string; icon?: IconName; tone?: "ok" | "info" };
const ToastCtx = createContext<(msg: string, opts?: Omit<Toast, "id" | "msg">) => void>(
  () => {},
);

let toastSeq = 0;

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const push = useCallback((msg: string, opts?: Omit<Toast, "id" | "msg">) => {
    const id = ++toastSeq;
    setToasts((t) => [...t, { id, msg, ...opts }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== id)), 2600);
  }, []);

  return (
    <ToastCtx.Provider value={push}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 top-0 z-[100] flex flex-col items-center gap-2 px-4 pt-safe">
        <div className="mt-3 flex w-full max-w-[440px] flex-col items-center gap-2">
          {toasts.map((t) => (
            <div
              key={t.id}
              className="anim-toast flex items-center gap-2.5 rounded-full bg-[var(--text)] px-4 py-2.5 text-[14px] font-semibold text-[var(--bg)] shadow-lg"
            >
              <span className="text-[var(--success)]">
                <Icon
                  name={t.icon ?? (t.tone === "info" ? "bell" : "checkCircle")}
                  size={18}
                  strokeWidth={2.2}
                />
              </span>
              {t.msg}
            </div>
          ))}
        </div>
      </div>
    </ToastCtx.Provider>
  );
}

export const useToast = () => useContext(ToastCtx);
