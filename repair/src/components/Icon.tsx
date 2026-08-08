// Jeu d'icônes en trait cohérent (inspiration SF Symbols). Une icône = une intention.
import type { SVGProps } from "react";

const P: Record<string, string> = {
  home: "M3 10.5 12 3l9 7.5M5 9.5V20a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1V9.5",
  ticket:
    "M4 7a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v2a2 2 0 0 0 0 6v2a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2a2 2 0 0 0 0-6zM14 5v14",
  box: "M3.3 7.5 12 3l8.7 4.5M3.3 7.5 12 12m-8.7-4.5V16.5L12 21m0-9 8.7-4.5M12 12v9m8.7-13.5V16.5L12 21",
  people:
    "M16 19c0-2.2-1.8-4-4-4s-4 1.8-4 4M12 11a3 3 0 1 0 0-6 3 3 0 0 0 0 6M18.5 13.5a2.4 2.4 0 0 0 0-4.6M20.5 19c0-1.6-.9-3-2.3-3.6M5.5 13.5a2.4 2.4 0 0 1 0-4.6M3.5 19c0-1.6.9-3 2.3-3.6",
  grid: "M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z",
  plus: "M12 5v14M5 12h14",
  search: "M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM20 20l-4-4",
  chevron: "M9 6l6 6-6 6",
  chevronDown: "M6 9l6 6 6-6",
  back: "M15 6l-6 6 6 6",
  close: "M6 6l12 12M18 6L6 18",
  check: "M5 12.5l4.5 4.5L19 7",
  checkCircle: "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM8.5 12l2.5 2.5 4.5-5",
  clock: "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 7v5l3.5 2",
  wrench:
    "M14.7 6.3a4 4 0 0 0-5.2 5.2L4 17l3 3 5.5-5.5a4 4 0 0 0 5.2-5.2l-2.4 2.4-2.1-.6-.6-2.1z",
  inbox:
    "M4 13l2.5-7A2 2 0 0 1 8.4 4.6h7.2a2 2 0 0 1 1.9 1.4L20 13v5a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2zM4 13h4a2 2 0 0 1 4 0h0a2 2 0 0 1 4 0h4",
  handshake:
    "M8 12l2.5 2.5a1.4 1.4 0 0 0 2 0M6 7l3-1 3 1.5L15 6l3 1 2 4-2 2-3-3-1.5 1.5M4 11l2-4",
  phone:
    "M6 3h3l1.5 4-2 1.5a12 12 0 0 0 5 5l1.5-2 4 1.5V17a2 2 0 0 1-2 2A15 15 0 0 1 4 5a2 2 0 0 1 2-2z",
  mobile:
    "M9 2.5h6a1.5 1.5 0 0 1 1.5 1.5v16a1.5 1.5 0 0 1-1.5 1.5H9A1.5 1.5 0 0 1 7.5 20V4A1.5 1.5 0 0 1 9 2.5zM10.5 19h3",
  tablet:
    "M6 3h12a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM11 18h2",
  laptop: "M6 5h12a1 1 0 0 1 1 1v9H5V6a1 1 0 0 1 1-1zM3 18h18l-1 2H4z",
  gamepad:
    "M8 9h8a4 4 0 0 1 4 4 3 3 0 0 1-5.2 2H9.2A3 3 0 0 1 4 13a4 4 0 0 1 4-4zM7 12v2M6 13h2M15 12h.01M17 14h.01",
  watch:
    "M8 7V4h8v3M8 17v3h8v-3M6 7h12v10H6zM12 10v2.5l1.5 1",
  device: "M7 3h10a1 1 0 0 1 1 1v16a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1z",
  cash: "M3 7h18v10H3zM12 12a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM6 9v6M18 9v6",
  card: "M3 6h18v12H3zM3 10h18M7 15h4",
  bank: "M4 10h16M5 10l7-5 7 5M6 10v7M10 10v7M14 10v7M18 10v7M4 20h16",
  bell: "M6 10a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6M10 20a2 2 0 0 0 4 0",
  euro: "M15 6a5.5 5.5 0 1 0 0 12M5 10h7M5 14h6",
  chart: "M4 20V4M4 20h16M8 16v-4M12 16V8M16 16v-7",
  trend: "M4 15l5-5 3 3 7-7M15 6h4v4",
  alert: "M12 3l9 16H3zM12 10v4M12 17h.01",
  settings:
    "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM12 2l1.6 2.6 3-.5.6 3L21 9l-1.6 2.6L21 14l-2.8 1.4-.6 3-3-.5L12 22l-1.6-2.6-3 .5-.6-3L4 14l1.6-2.6L4 9l2.8-1.4.6-3 3 .5z",
  user: "M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21a8 8 0 0 1 16 0",
  calendar:
    "M4 6a1 1 0 0 1 1-1h14a1 1 0 0 1 1 1v14a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zM4 9h16M8 3v4M16 3v4",
  doc: "M6 3h8l4 4v13a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1zM14 3v4h4M8 13h8M8 17h5",
  camera:
    "M4 8a1 1 0 0 1 1-1h2l1.2-2h5.6L16 7h3a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zM12 16a3 3 0 1 0 0-6 3 3 0 0 0 0 6z",
  trash: "M5 7h14M9 7V4h6v3M6 7l1 13h10l1-13",
  edit: "M4 20h4L18 10l-4-4L4 16zM14 6l4 4",
  refresh:
    "M4 12a8 8 0 0 1 13.7-5.7L20 8M20 4v4h-4M20 12a8 8 0 0 1-13.7 5.7L4 16M4 20v-4h4",
  arrowDown: "M12 5v14M6 13l6 6 6-6",
  arrowUp: "M12 19V5M6 11l6-6 6 6",
  arrowRight: "M5 12h14M13 6l6 6-6 6",
  filter: "M4 6h16M7 12h10M10 18h4",
  send: "M4 12l16-8-6 16-2.5-6z",
  minus: "M5 12h14",
  tag: "M4 4h7l9 9-7 7-9-9zM8 8h.01",
  sun: "M12 7a5 5 0 1 0 0 10 5 5 0 0 0 0-10zM12 2v2M12 20v2M4 12H2M22 12h-2M5 5l1.5 1.5M17.5 17.5 19 19M19 5l-1.5 1.5M6.5 17.5 5 19",
  moon: "M20 14a8 8 0 1 1-9-11 6 6 0 0 0 9 11z",
  shield:
    "M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6zM9 12l2 2 4-4",
  location: "M12 21s7-6 7-11a7 7 0 1 0-14 0c0 5 7 11 7 11zM12 12a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5z",
  hash: "M6 9h14M4 15h14M9 4l-2 16M17 4l-2 16",
  battery: "M4 8h13a1 1 0 0 1 1 1v6a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V9a1 1 0 0 1 1-1zM21 11v2M6 11v2",
  sparkles: "M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5zM18 15l.8 2.2L21 18l-2.2.8L18 21l-.8-2.2L15 18l2.2-.8z",
  list: "M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01",
  more: "M6 12h.01M12 12h.01M18 12h.01",
  play: "M7 5l11 7-11 7z",
};

export type IconName = keyof typeof P;

interface Props extends SVGProps<SVGSVGElement> {
  name: IconName;
  size?: number;
}

export function Icon({ name, size = 22, strokeWidth = 1.8, ...rest }: Props) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
      {...rest}
    >
      <path d={P[name] ?? P.device} />
    </svg>
  );
}
