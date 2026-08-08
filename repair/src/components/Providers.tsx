"use client";

import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { StoreProvider } from "@/lib/store";
import { ToastProvider } from "./Sheet";

type ThemePref = "system" | "light" | "dark";
const ThemeCtx = createContext<{
  pref: ThemePref;
  setPref: (p: ThemePref) => void;
}>({ pref: "system", setPref: () => {} });

export const useTheme = () => useContext(ThemeCtx);

function ThemeProvider({ children }: { children: ReactNode }) {
  // Persistance interdite (localStorage) → préférence en mémoire de session.
  const [pref, setPref] = useState<ThemePref>("system");

  useEffect(() => {
    const root = document.documentElement;
    if (pref === "system") root.removeAttribute("data-theme");
    else root.setAttribute("data-theme", pref);
  }, [pref]);

  return (
    <ThemeCtx.Provider value={{ pref, setPref }}>{children}</ThemeCtx.Provider>
  );
}

export function Providers({ children }: { children: ReactNode }) {
  return (
    <ThemeProvider>
      <StoreProvider>
        <ToastProvider>{children}</ToastProvider>
      </StoreProvider>
    </ThemeProvider>
  );
}
