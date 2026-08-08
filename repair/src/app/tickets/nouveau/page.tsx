"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useStore } from "@/lib/store";
import type { Device, DeviceType, Priority, Ticket } from "@/lib/types";
import { DEVICE_META, PRIORITY_META } from "@/lib/format";
import { SubHeader } from "@/components/Header";
import { Icon, type IconName } from "@/components/Icon";
import {
  Avatar,
  Button,
  Card,
  Field,
  Input,
  Textarea,
  cx,
} from "@/components/ui";
import { useToast } from "@/components/Sheet";

const STEPS = ["Client", "Appareil", "Problème", "Détails"];

export default function NouveauTicket() {
  const { state, dispatch, rid } = useStore();
  const router = useRouter();
  const toast = useToast();

  const [step, setStep] = useState(0);
  // Client
  const [clientId, setClientId] = useState<string | null>(null);
  const [newClient, setNewClient] = useState({ nom: "", telephone: "", email: "" });
  const [clientQuery, setClientQuery] = useState("");
  // Appareil
  const [dType, setDType] = useState<DeviceType>("smartphone");
  const [marque, setMarque] = useState("");
  const [modele, setModele] = useState("");
  const [serie, setSerie] = useState("");
  const [code, setCode] = useState("");
  // Problème
  const [symptomes, setSymptomes] = useState("");
  const [photos, setPhotos] = useState<string[]>([]);
  // Détails
  const [priority, setPriority] = useState<Priority>("normale");
  const [techId, setTechId] = useState<string | undefined>(undefined);
  const [promisDays, setPromisDays] = useState(2);

  const filteredClients = useMemo(() => {
    const n = clientQuery.trim().toLowerCase();
    return state.clients
      .filter((c) => !n || c.nom.toLowerCase().includes(n) || c.telephone.includes(n))
      .slice(0, 6);
  }, [state.clients, clientQuery]);

  const usingNewClient = clientId === null && newClient.nom.trim().length > 0;

  const canNext =
    step === 0
      ? clientId !== null || (newClient.nom.trim() && newClient.telephone.trim())
      : step === 1
        ? marque.trim() && modele.trim()
        : step === 2
          ? symptomes.trim().length > 0
          : true;

  const finish = () => {
    let cid = clientId;
    let device: Device;

    if (!cid) {
      cid = rid("c");
      const dev: Device = {
        id: rid("d"),
        clientId: cid,
        type: dType,
        marque: marque.trim(),
        modele: modele.trim(),
        serie: serie.trim() || undefined,
      };
      dispatch({
        type: "ADD_CLIENT",
        client: {
          id: cid,
          nom: newClient.nom.trim(),
          telephone: newClient.telephone.trim(),
          email: newClient.email.trim() || undefined,
          createdAt: new Date().toISOString(),
        },
        device: dev,
      });
      device = dev;
    } else {
      device = {
        id: rid("d"),
        clientId: cid,
        type: dType,
        marque: marque.trim(),
        modele: modele.trim(),
        serie: serie.trim() || undefined,
      };
      dispatch({ type: "ADD_DEVICE", device });
    }

    const num = `R-${2471 + state.tickets.length}`;
    const now = new Date();
    const promis = new Date(now.getTime() + promisDays * 86_400_000);
    const ticket: Ticket = {
      id: num,
      clientId: cid,
      deviceId: device.id,
      symptomes: symptomes.trim(),
      status: "recu",
      priority,
      technicienId: techId,
      recuAt: now.toISOString(),
      promisAt: promis.toISOString(),
      photos: photos.length ? photos : ["📱"],
      checklist: [
        { id: rid("ck"), label: "Appareil s'allume", checked: false },
        { id: rid("ck"), label: "Accessoires laissés", checked: false },
      ],
      lignes: [],
      history: [{ status: "recu", at: now.toISOString() }],
      garantieMois: state.atelier.garantieMoisDefaut,
      codeDeverrouillage: code.trim() || undefined,
    };
    dispatch({ type: "CREATE_TICKET", ticket });
    toast(`Ticket ${num} créé`);
    router.replace(`/tickets/${num}`);
  };

  return (
    <div className="anim-fade pb-10">
      <SubHeader title="Nouveau ticket" backLabel="Annuler" />

      {/* Progression */}
      <div className="mx-auto flex max-w-[560px] items-center gap-1.5 px-5 pt-4">
        {STEPS.map((s, i) => (
          <div key={s} className="flex flex-1 flex-col gap-1.5">
            <div
              className={cx(
                "h-1 rounded-full transition-colors",
                i <= step ? "bg-[var(--accent)]" : "bg-[var(--surface-sunken)]",
              )}
            />
            <span
              className={cx(
                "text-[11px] font-medium",
                i === step ? "text-[var(--accent)]" : "text-[var(--text-tertiary)]",
              )}
            >
              {s}
            </span>
          </div>
        ))}
      </div>

      <div className="mx-auto max-w-[560px] px-4 pt-5">
        {/* ── Étape 1 : Client ─────────────────────────────────────────────── */}
        {step === 0 && (
          <div className="space-y-4 anim-pop">
            <Field label="Rechercher un client existant">
              <Input
                placeholder="Nom ou téléphone…"
                value={clientQuery}
                onChange={(e) => setClientQuery(e.target.value)}
              />
            </Field>
            {clientQuery && (
              <Card pad={false} className="overflow-hidden">
                {filteredClients.length ? (
                  filteredClients.map((c) => (
                    <button
                      key={c.id}
                      onClick={() => {
                        setClientId(c.id);
                        setClientQuery(c.nom);
                      }}
                      className={cx(
                        "press flex w-full items-center gap-3 border-b-[0.5px] border-[var(--separator)] px-3 py-2.5 text-left last:border-0",
                        clientId === c.id ? "bg-[var(--accent-weak)]" : "active:bg-[var(--surface-2)]",
                      )}
                    >
                      <Avatar nom={c.nom} size={34} />
                      <div className="flex-1">
                        <div className="text-[15px] font-medium">{c.nom}</div>
                        <div className="text-[12px] text-[var(--text-tertiary)]">{c.telephone}</div>
                      </div>
                      {clientId === c.id && <Icon name="check" size={18} className="text-[var(--accent)]" />}
                    </button>
                  ))
                ) : (
                  <div className="px-4 py-3 text-[14px] text-[var(--text-secondary)]">
                    Aucun client trouvé — créez-en un ci-dessous.
                  </div>
                )}
              </Card>
            )}

            <div className="flex items-center gap-3 py-1">
              <div className="h-px flex-1 bg-[var(--separator)]" />
              <span className="text-[12px] font-medium text-[var(--text-tertiary)]">OU NOUVEAU CLIENT</span>
              <div className="h-px flex-1 bg-[var(--separator)]" />
            </div>

            <Field label="Nom complet">
              <Input
                placeholder="Ex. Marie Dupont"
                value={newClient.nom}
                onChange={(e) => {
                  setNewClient({ ...newClient, nom: e.target.value });
                  setClientId(null);
                }}
              />
            </Field>
            <div className="grid grid-cols-2 gap-3">
              <Field label="Téléphone">
                <Input
                  inputMode="tel"
                  placeholder="06 …"
                  value={newClient.telephone}
                  onChange={(e) => setNewClient({ ...newClient, telephone: e.target.value })}
                />
              </Field>
              <Field label="Email (option.)">
                <Input
                  inputMode="email"
                  placeholder="@"
                  value={newClient.email}
                  onChange={(e) => setNewClient({ ...newClient, email: e.target.value })}
                />
              </Field>
            </div>
          </div>
        )}

        {/* ── Étape 2 : Appareil ───────────────────────────────────────────── */}
        {step === 1 && (
          <div className="space-y-4 anim-pop">
            <Field label="Type d'appareil">
              <div className="grid grid-cols-3 gap-2">
                {(Object.keys(DEVICE_META) as DeviceType[]).map((t) => (
                  <button
                    key={t}
                    onClick={() => setDType(t)}
                    className={cx(
                      "press flex flex-col items-center gap-1.5 rounded-[12px] py-3 text-[12px] font-medium",
                      dType === t
                        ? "bg-[var(--accent-weak)] text-[var(--accent)]"
                        : "bg-[var(--surface)] text-[var(--text-secondary)]",
                    )}
                    style={{ border: "0.5px solid var(--separator)" }}
                  >
                    <Icon name={DEVICE_META[t].icon as IconName} size={22} />
                    {DEVICE_META[t].label}
                  </button>
                ))}
              </div>
            </Field>
            <div className="grid grid-cols-2 gap-3">
              <Field label="Marque">
                <Input placeholder="Apple, Samsung…" value={marque} onChange={(e) => setMarque(e.target.value)} />
              </Field>
              <Field label="Modèle">
                <Input placeholder="iPhone 15…" value={modele} onChange={(e) => setModele(e.target.value)} />
              </Field>
            </div>
            <Field label="IMEI / N° de série (option.)">
              <Input placeholder="35…" value={serie} onChange={(e) => setSerie(e.target.value)} />
            </Field>
            <Field label="Code de déverrouillage (option.)" hint="Utile pour tester la réparation.">
              <Input placeholder="Code / schéma / Face ID" value={code} onChange={(e) => setCode(e.target.value)} />
            </Field>
          </div>
        )}

        {/* ── Étape 3 : Problème ───────────────────────────────────────────── */}
        {step === 2 && (
          <div className="space-y-4 anim-pop">
            <Field label="Symptômes / panne constatée">
              <Textarea
                rows={4}
                placeholder="Ex. Écran fissuré, tactile ne répond plus en haut à droite…"
                value={symptomes}
                onChange={(e) => setSymptomes(e.target.value)}
              />
            </Field>
            <div className="flex flex-wrap gap-2">
              {["Écran cassé", "Batterie HS", "Port de charge", "Oxydation", "Ne s'allume plus"].map((s) => (
                <button
                  key={s}
                  onClick={() => setSymptomes((v) => (v ? `${v}, ${s.toLowerCase()}` : s))}
                  className="press rounded-full bg-[var(--surface-sunken)] px-3 py-1.5 text-[13px] font-medium"
                >
                  + {s}
                </button>
              ))}
            </div>
            <Field label="Photos de l'appareil">
              <div className="flex gap-2.5">
                {photos.map((p, i) => (
                  <div key={i} className="flex h-20 w-20 items-center justify-center rounded-[14px] bg-[var(--surface-sunken)] text-3xl">
                    {p}
                  </div>
                ))}
                <button
                  onClick={() => setPhotos((p) => [...p, ["📱", "🔧", "🔋", "💧"][p.length % 4]])}
                  className="press flex h-20 w-20 flex-col items-center justify-center gap-1 rounded-[14px] text-[var(--text-tertiary)]"
                  style={{ border: "1.5px dashed var(--separator-strong)" }}
                >
                  <Icon name="camera" size={20} />
                  <span className="text-[11px]">Photo</span>
                </button>
              </div>
            </Field>
          </div>
        )}

        {/* ── Étape 4 : Détails ────────────────────────────────────────────── */}
        {step === 3 && (
          <div className="space-y-5 anim-pop">
            <Field label="Priorité">
              <div className="grid grid-cols-4 gap-2">
                {(Object.keys(PRIORITY_META) as Priority[]).map((p) => (
                  <button
                    key={p}
                    onClick={() => setPriority(p)}
                    className={cx(
                      "press rounded-[10px] py-2.5 text-[13px] font-semibold",
                      priority === p
                        ? "bg-[var(--accent)] text-white"
                        : "bg-[var(--surface-sunken)] text-[var(--text-secondary)]",
                    )}
                  >
                    {PRIORITY_META[p].label}
                  </button>
                ))}
              </div>
            </Field>
            <Field label="Technicien assigné">
              <div className="flex flex-wrap gap-2">
                <button
                  onClick={() => setTechId(undefined)}
                  className={cx(
                    "press rounded-full px-3.5 py-2 text-[14px] font-medium",
                    techId === undefined ? "bg-[var(--accent-weak)] text-[var(--accent)]" : "bg-[var(--surface-sunken)]",
                  )}
                >
                  Non assigné
                </button>
                {state.techniciens.map((t) => (
                  <button
                    key={t.id}
                    onClick={() => setTechId(t.id)}
                    className={cx(
                      "press flex items-center gap-2 rounded-full py-1 pl-1 pr-3 text-[14px] font-medium",
                      techId === t.id ? "bg-[var(--accent-weak)] text-[var(--accent)]" : "bg-[var(--surface-sunken)]",
                    )}
                  >
                    <Avatar nom={t.nom} color={t.couleur} size={26} />
                    {t.nom.split(" ")[0]}
                  </button>
                ))}
              </div>
            </Field>
            <Field label={`Délai promis : ${promisDays} jour${promisDays > 1 ? "s" : ""}`}>
              <input
                type="range"
                min={1}
                max={10}
                value={promisDays}
                onChange={(e) => setPromisDays(Number(e.target.value))}
                className="w-full accent-[var(--accent)]"
              />
            </Field>

            {/* Récap */}
            <Card className="space-y-1.5 text-[14px]">
              <div className="mb-1 text-[13px] font-semibold uppercase text-[var(--text-tertiary)]">Récapitulatif</div>
              <RecapRow label="Client" value={clientId ? state.clients.find((c) => c.id === clientId)?.nom ?? "" : newClient.nom} />
              <RecapRow label="Appareil" value={`${marque} ${modele}`} />
              <RecapRow label="Panne" value={symptomes.slice(0, 40) + (symptomes.length > 40 ? "…" : "")} />
            </Card>
          </div>
        )}
      </div>

      {/* Barre d'action */}
      <div className="blur-bar fixed inset-x-0 bottom-0 z-40 border-t-[0.5px] border-[var(--separator)] p-4 pb-safe lg:sticky">
        <div className="mx-auto flex max-w-[560px] gap-3">
          {step > 0 && (
            <Button variant="tertiary" onClick={() => setStep((s) => s - 1)}>
              Retour
            </Button>
          )}
          {step < STEPS.length - 1 ? (
            <Button full disabled={!canNext} onClick={() => setStep((s) => s + 1)}>
              Continuer
            </Button>
          ) : (
            <Button full icon="check" onClick={finish}>
              Créer le ticket
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

function RecapRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex justify-between gap-3">
      <span className="text-[var(--text-secondary)]">{label}</span>
      <span className="truncate text-right font-medium">{value || "—"}</span>
    </div>
  );
}
