"use client";

import { useStore } from "@/lib/store";
import { useTheme } from "@/components/Providers";
import { LargeHeader } from "@/components/Header";
import { Avatar, Card, Field, Input, ListGroup, ListRow, SectionTitle, cx } from "@/components/ui";
import { Icon, type IconName } from "@/components/Icon";
import { useToast } from "@/components/Sheet";

export default function ReglagesPage() {
  const { state, dispatch } = useStore();
  const { pref, setPref } = useTheme();
  const toast = useToast();
  const a = state.atelier;

  const themes: { value: "system" | "light" | "dark"; label: string; icon: IconName }[] = [
    { value: "light", label: "Clair", icon: "sun" },
    { value: "dark", label: "Sombre", icon: "moon" },
    { value: "system", label: "Auto", icon: "settings" },
  ];

  return (
    <div className="anim-fade">
      <LargeHeader title="Réglages" />

      <div className="space-y-6 px-4 pb-8">
        {/* Apparence */}
        <div>
          <SectionTitle>Apparence</SectionTitle>
          <div className="grid grid-cols-3 gap-2.5">
            {themes.map((t) => (
              <button
                key={t.value}
                onClick={() => setPref(t.value)}
                className={cx(
                  "press flex flex-col items-center gap-2 rounded-[14px] py-4 text-[13px] font-semibold",
                  pref === t.value
                    ? "bg-[var(--accent-weak)] text-[var(--accent)] ring-2 ring-[var(--accent)]"
                    : "bg-[var(--surface)] text-[var(--text-secondary)]",
                )}
                style={pref === t.value ? undefined : { border: "0.5px solid var(--separator)" }}
              >
                <Icon name={t.icon} size={24} />
                {t.label}
              </button>
            ))}
          </div>
        </div>

        {/* Atelier */}
        <div>
          <SectionTitle>Profil de l'atelier</SectionTitle>
          <Card className="space-y-3.5">
            <Field label="Nom de l'atelier">
              <Input
                defaultValue={a.nom}
                onBlur={(e) => dispatch({ type: "UPDATE_ATELIER", patch: { nom: e.target.value } })}
              />
            </Field>
            <Field label="Adresse">
              <Input
                defaultValue={a.adresse}
                onBlur={(e) => dispatch({ type: "UPDATE_ATELIER", patch: { adresse: e.target.value } })}
              />
            </Field>
            <Field label="Téléphone">
              <Input
                defaultValue={a.telephone}
                onBlur={(e) => dispatch({ type: "UPDATE_ATELIER", patch: { telephone: e.target.value } })}
              />
            </Field>
          </Card>
        </div>

        {/* Facturation */}
        <div>
          <SectionTitle>Facturation & garantie</SectionTitle>
          <Card className="grid grid-cols-2 gap-3">
            <Field label="Taux de TVA (%)">
              <Input
                type="number"
                defaultValue={a.tvaPct}
                onBlur={(e) => {
                  dispatch({ type: "UPDATE_ATELIER", patch: { tvaPct: Number(e.target.value) || 20 } });
                  toast("TVA mise à jour");
                }}
              />
            </Field>
            <Field label="Garantie (mois)">
              <Input
                type="number"
                defaultValue={a.garantieMoisDefaut}
                onBlur={(e) =>
                  dispatch({ type: "UPDATE_ATELIER", patch: { garantieMoisDefaut: Number(e.target.value) || 3 } })
                }
              />
            </Field>
          </Card>
        </div>

        {/* Techniciens */}
        <div>
          <SectionTitle>Techniciens</SectionTitle>
          <ListGroup>
            {state.techniciens.map((t) => (
              <ListRow
                key={t.id}
                leading={<Avatar nom={t.nom} color={t.couleur} size={36} />}
                trailing={
                  <span className="rounded-full bg-[var(--surface-sunken)] px-2 py-1 text-[12px] font-medium capitalize text-[var(--text-secondary)]">
                    {t.role}
                  </span>
                }
              >
                <div className="text-[15px] font-medium">{t.nom}</div>
              </ListRow>
            ))}
          </ListGroup>
        </div>

        {/* Fournisseurs */}
        <div>
          <SectionTitle>Fournisseurs</SectionTitle>
          <ListGroup>
            {state.fournisseurs.map((f) => (
              <ListRow
                key={f.id}
                leading={
                  <div className="flex h-9 w-9 items-center justify-center rounded-[10px] bg-[var(--surface-sunken)] text-[var(--text-secondary)]">
                    <Icon name="box" size={18} />
                  </div>
                }
                trailing={<span className="text-[13px] text-[var(--text-tertiary)]">{f.delaiJours} j</span>}
              >
                <div className="text-[15px] font-medium">{f.nom}</div>
                <div className="text-[12px] text-[var(--text-tertiary)]">{f.contact}</div>
              </ListRow>
            ))}
          </ListGroup>
        </div>

        <div className="px-1 text-center text-[12px] text-[var(--text-tertiary)]">
          Les modifications sont conservées en mémoire pour la durée de la session.
        </div>
      </div>
    </div>
  );
}
