// app.jsx — Твоя Зачіска · main app
// 12 interactive screens with smooth navigation, animations, and tweaks

const { useState, useEffect, useRef, useMemo, useCallback } = React;

// ─────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────
const TOKENS = {
  bg: '#FAFAF8',
  surface: '#FFFFFF',
  surfaceMuted: '#F4F2EE',
  ink: '#0F0F0E',
  inkSoft: '#1F1F1D',
  muted: '#78766F',
  mutedSoft: '#A8A59C',
  hairline: 'rgba(15,15,14,0.08)',
  hairlineStrong: 'rgba(15,15,14,0.14)',
  accent: '#0F0F0E',         // monochrome accent — "ink"
  pos: '#3F8159',            // sage / approve
  warn: '#B98C2D',           // ochre / caution
  serif: '"Fraunces", "Times New Roman", Georgia, serif',
  // We're allowed Fraunces is on the avoid list; use Instrument Serif instead.
};
// Override serif with a less-overused face:
TOKENS.serif = '"Instrument Serif", "Cormorant Garamond", "Times New Roman", Georgia, serif';
TOKENS.sans = '"Geist", -apple-system, system-ui, "SF Pro Text", sans-serif';

// ─────────────────────────────────────────────────────────────
// Hairstyle data
// ─────────────────────────────────────────────────────────────
const HAIRSTYLES = {
  woman: [
    // Коротке
    { id: 'w1',  name: 'Класичний піксі',     length: 'Коротке', vibe: 'Сміливе',     match: 78, hue: '#1F1812', shape: 'pixie' },
    { id: 'w2',  name: 'Піксі з чубкою',      length: 'Коротке', vibe: 'Грайливе',    match: 82, hue: '#2A1F18', shape: 'pixie-fringe' },
    { id: 'w3',  name: 'Бікси (bixie)',       length: 'Коротке', vibe: 'Сучасне',     match: 86, hue: '#3D2B1F', shape: 'bixie' },
    { id: 'w4',  name: 'Текстурний боб',      length: 'Коротке', vibe: 'Класика',     match: 94, hue: '#2A1F18', shape: 'bob' },
    { id: 'w5',  name: 'Тупий боб',           length: 'Коротке', vibe: 'Мінімал',     match: 87, hue: '#1A120C', shape: 'blunt-bob' },
    { id: 'w6',  name: 'Боб А-силует',        length: 'Коротке', vibe: 'Класика',     match: 84, hue: '#5B4030', shape: 'a-bob' },
    { id: 'w7',  name: 'Французький боб',     length: 'Коротке', vibe: 'Романтичне',  match: 80, hue: '#3D2B1F', shape: 'french-bob' },
    // Середнє
    { id: 'w8',  name: 'Лоб (long bob)',      length: 'Середнє', vibe: 'Універсальне',match: 91, hue: '#5B4030', shape: 'lob' },
    { id: 'w9',  name: 'Кучері-ліб',          length: 'Середнє', vibe: 'Романтичне',  match: 81, hue: '#8B6342', shape: 'curly-lob' },
    { id: 'w10', name: 'Пряма чубка',         length: 'Середнє', vibe: 'Сучасне',     match: 76, hue: '#1A120C', shape: 'fringe' },
    { id: 'w11', name: 'Шеґ',                 length: 'Середнє', vibe: 'Бунтарське',  match: 84, hue: '#3D2B1F', shape: 'shag' },
    { id: 'w12', name: 'Каскад',              length: 'Середнє', vibe: 'Природне',    match: 88, hue: '#5B4030', shape: 'layered' },
    { id: 'w13', name: 'Хвилясте каре',       length: 'Середнє', vibe: 'Невимушене',  match: 83, hue: '#A88563', shape: 'wavy-bob' },
    // Довге
    { id: 'w14', name: 'Довгі шари',          length: 'Довге',   vibe: 'Природне',    match: 88, hue: '#5B4030', shape: 'long-layers' },
    { id: 'w15', name: 'Балаяж-хвилі',        length: 'Довге',   vibe: 'Сонячне',     match: 91, hue: '#A88563', shape: 'long-wavy' },
    { id: 'w16', name: 'Прямі довгі',         length: 'Довге',   vibe: 'Мінімал',     match: 85, hue: '#2D1F16', shape: 'long-straight' },
    { id: 'w17', name: 'Завитки спіралькою',  length: 'Довге',   vibe: 'Грайливе',    match: 82, hue: '#3D2B1F', shape: 'long-curly' },
    { id: 'w18', name: 'Низький пучок',       length: 'Довге',   vibe: 'Мінімал',     match: 79, hue: '#2D1F16', shape: 'bun' },
    { id: 'w19', name: 'Хвіст високий',       length: 'Довге',   vibe: 'Спортивне',   match: 77, hue: '#1A120C', shape: 'ponytail' },
  ],
  man: [
    // Лисе / гоління
    { id: 'm1',  name: 'Гладко поголене',     length: 'Лисе',    vibe: 'Мінімал',     match: 84, hue: '#0F0F0E', shape: 'bald' },
    { id: 'm2',  name: 'Бузз-кат №0',         length: 'Лисе',    vibe: 'Сміливе',     match: 80, hue: '#2A1F18', shape: 'buzz-zero' },
    // Коротке
    { id: 'm3',  name: 'Бузз-кат',            length: 'Коротке', vibe: 'Мінімал',     match: 71, hue: '#2A1F18', shape: 'buzz' },
    { id: 'm4',  name: 'Кру-кат',             length: 'Коротке', vibe: 'Класика',     match: 81, hue: '#1F1812', shape: 'crew' },
    { id: 'm5',  name: 'Текстурний кроп',     length: 'Коротке', vibe: 'Сучасне',     match: 92, hue: '#1A140F', shape: 'crop' },
    { id: 'm6',  name: 'Айві ліг',            length: 'Коротке', vibe: 'Класика',     match: 85, hue: '#3D2B1F', shape: 'ivy' },
    { id: 'm7',  name: 'Цезар',               length: 'Коротке', vibe: 'Класика',     match: 79, hue: '#2A1F18', shape: 'caesar' },
    // Середнє
    { id: 'm8',  name: 'Бахрома',             length: 'Середнє', vibe: 'Природне',    match: 86, hue: '#3D2B1F', shape: 'fringe-m' },
    { id: 'm9',  name: 'Слік-бек',            length: 'Середнє', vibe: 'Класика',     match: 89, hue: '#1F1812', shape: 'slick' },
    { id: 'm10', name: 'Помпадур',            length: 'Середнє', vibe: 'Класика',     match: 78, hue: '#1A120C', shape: 'pomp' },
    { id: 'm11', name: 'Квіф',                length: 'Середнє', vibe: 'Сучасне',     match: 87, hue: '#5B4030', shape: 'quiff' },
    { id: 'm12', name: 'Розкуйовджене',       length: 'Середнє', vibe: 'Невимушене',  match: 88, hue: '#3D2B1F', shape: 'tousled' },
    { id: 'm13', name: 'Середній проділ',     length: 'Середнє', vibe: 'Ретро',       match: 76, hue: '#5B4030', shape: 'curtain' },
    // Довге
    { id: 'm14', name: 'Лонг-флоу',           length: 'Довге',   vibe: 'Бунтарське',  match: 74, hue: '#5B4030', shape: 'long-flow' },
    { id: 'm15', name: 'Чоловічий пучок',     length: 'Довге',   vibe: 'Сучасне',     match: 81, hue: '#3D2B1F', shape: 'man-bun' },
    { id: 'm16', name: 'Хвилясті до плечей',  length: 'Довге',   vibe: 'Природне',    match: 78, hue: '#5B4030', shape: 'long-wavy-m' },
  ],
};

// ─────────────────────────────────────────────────────────────
// Inline icons (stroke based, minimal)
// ─────────────────────────────────────────────────────────────
const Icon = ({ name, size = 22, stroke = TOKENS.ink, strokeWidth = 1.6 }) => {
  const p = { fill: 'none', stroke, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const s = { width: size, height: size };
  switch (name) {
    case 'camera': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M3 8.5C3 7.4 3.9 6.5 5 6.5h2.4l1.2-1.8C8.8 4.3 9.2 4 9.7 4h4.6c.5 0 .9.3 1.1.7l1.2 1.8H19c1.1 0 2 .9 2 2v9c0 1.1-.9 2-2 2H5c-1.1 0-2-.9-2-2v-9z"/><circle {...p} cx="12" cy="13" r="3.5"/></svg>);
    case 'image': return (<svg viewBox="0 0 24 24" style={s}><rect {...p} x="3" y="4" width="18" height="16" rx="2"/><circle {...p} cx="9" cy="10" r="1.6"/><path {...p} d="M3 17l4.5-4.5a2 2 0 012.8 0L21 23"/></svg>);
    case 'sparkle': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 3v4M12 17v4M3 12h4M17 12h4M5.6 5.6l2.8 2.8M15.6 15.6l2.8 2.8M5.6 18.4l2.8-2.8M15.6 8.4l2.8-2.8"/></svg>);
    case 'heart': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 20s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 10c0 5.5-7 10-7 10z"/></svg>);
    case 'heart-fill': return (<svg viewBox="0 0 24 24" style={s}><path fill={stroke} d="M12 20s-7-4.5-7-10a4 4 0 017-2.6A4 4 0 0119 10c0 5.5-7 10-7 10z"/></svg>);
    case 'user': return (<svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="8" r="4"/><path {...p} d="M4 20c1-4 4.5-6 8-6s7 2 8 6"/></svg>);
    case 'home': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6h-6v6H4a1 1 0 01-1-1v-9z"/></svg>);
    case 'grid': return (<svg viewBox="0 0 24 24" style={s}><rect {...p} x="4" y="4" width="7" height="7" rx="1"/><rect {...p} x="13" y="4" width="7" height="7" rx="1"/><rect {...p} x="4" y="13" width="7" height="7" rx="1"/><rect {...p} x="13" y="13" width="7" height="7" rx="1"/></svg>);
    case 'arrow-right': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M5 12h14M13 5l7 7-7 7"/></svg>);
    case 'arrow-left': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M19 12H5M11 5l-7 7 7 7"/></svg>);
    case 'check': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M4 12l5 5L20 6"/></svg>);
    case 'x': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M6 6l12 12M18 6L6 18"/></svg>);
    case 'plus': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 5v14M5 12h14"/></svg>);
    case 'share': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 4v12M7 9l5-5 5 5M5 15v3a2 2 0 002 2h10a2 2 0 002-2v-3"/></svg>);
    case 'settings': return (<svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="12" r="3"/><path {...p} d="M19 12.6v-1.2l1.7-1.3-1.5-2.6-2 .7a7 7 0 00-1-.6l-.3-2.1h-3l-.3 2.1a7 7 0 00-1 .6l-2-.7-1.5 2.6L4.7 11v1.2L3 13.9l1.5 2.6 2-.7a7 7 0 001 .6l.3 2.1h3l.3-2.1a7 7 0 001-.6l2 .7 1.5-2.6L19 12.6z"/></svg>);
    case 'list': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg>);
    case 'columns': return (<svg viewBox="0 0 24 24" style={s}><rect {...p} x="4" y="4" width="7" height="16" rx="1.5"/><rect {...p} x="13" y="4" width="7" height="16" rx="1.5"/></svg>);
    case 'swap': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M8 5l-4 4 4 4M4 9h12M16 19l4-4-4-4M20 15H8"/></svg>);
    case 'face': return (<svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="12" r="9"/><circle cx="9" cy="11" r="1" fill={stroke}/><circle cx="15" cy="11" r="1" fill={stroke}/><path {...p} d="M9 16c1 1 2 1.5 3 1.5s2-.5 3-1.5"/></svg>);
    case 'flash': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M13 2L4 14h7l-1 8 9-12h-7l1-8z"/></svg>);
    case 'reload': return (<svg viewBox="0 0 24 24" style={s}><path {...p} d="M21 12a9 9 0 11-3-6.7L21 8M21 3v5h-5"/></svg>);
    default: return null;
  }
};

// ─────────────────────────────────────────────────────────────
// Synthetic photo placeholder — shows a stylized portrait silhouette
// with a hairstyle "applied" via a hue-tinted hair shape.
// ─────────────────────────────────────────────────────────────
const FaceCanvas = ({ hair = '#2A1F18', tone = 'light', dark = false, size = '100%', style = {} }) => {
  // tone of skin
  const skin = tone === 'light' ? '#E8D5C0' : tone === 'medium' ? '#C9A380' : '#8B6A4D';
  const skinShadow = tone === 'light' ? '#D4BCA0' : tone === 'medium' ? '#A8845F' : '#6B4E36';
  return (
    <svg viewBox="0 0 200 240" preserveAspectRatio="xMidYMid slice" style={{ width: size, height: size, display: 'block', ...style }}>
      <defs>
        <linearGradient id={`bg-${hair}`} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={dark ? '#1A1A18' : '#EFEAE2'}/>
          <stop offset="100%" stopColor={dark ? '#0E0E0D' : '#DDD5C8'}/>
        </linearGradient>
      </defs>
      <rect width="200" height="240" fill={`url(#bg-${hair})`}/>
      {/* shoulders */}
      <path d="M30 240 Q 30 180, 70 170 L 130 170 Q 170 180, 170 240 Z" fill={dark ? '#2A2522' : '#3A332C'}/>
      {/* neck */}
      <rect x="86" y="155" width="28" height="25" fill={skinShadow}/>
      {/* face */}
      <ellipse cx="100" cy="115" rx="42" ry="52" fill={skin}/>
      {/* hair back */}
      <path d="M55 100 Q 50 60, 100 50 Q 150 60, 145 100 L 145 145 Q 130 130, 130 110 Q 100 95, 70 110 Q 70 130, 55 145 Z" fill={hair}/>
      {/* hair front (fringe — varies subtly by hue lightness) */}
      <path d="M65 95 Q 80 70, 100 68 Q 120 70, 135 95 Q 125 90, 115 92 Q 100 88, 85 92 Q 75 90, 65 95 Z" fill={hair}/>
      {/* features */}
      <ellipse cx="86" cy="118" rx="2.5" ry="3.5" fill={TOKENS.ink}/>
      <ellipse cx="114" cy="118" rx="2.5" ry="3.5" fill={TOKENS.ink}/>
      <path d="M95 138 Q 100 142, 105 138" stroke={skinShadow} strokeWidth="1.5" fill="none" strokeLinecap="round"/>
      <path d="M93 145 Q 100 149, 107 145" stroke="#8B5A4D" strokeWidth="2" fill="none" strokeLinecap="round"/>
    </svg>
  );
};

// Glyph card for hairstyle (used in galleries — schematic silhouette per shape)
const HairGlyph = ({ hair = '#2A1F18', length = 'Середнє', shape = 'bob', dark = false }) => {
  const bg = dark ? '#1A1A18' : '#F4F2EE';
  // Hair path map keyed by shape — falls back to length defaults
  const path = (() => {
    switch (shape) {
      // Bald / shaved
      case 'bald':       return null;
      case 'buzz-zero':  return <path d="M40 56 Q 40 42, 60 40 Q 80 42, 80 56 Q 78 50, 70 51 Q 60 49, 50 51 Q 42 50, 40 56 Z" fill={hair} opacity="0.55"/>;
      case 'buzz':       return <path d="M38 56 Q 38 40, 60 38 Q 82 40, 82 56 Q 78 51, 70 52 Q 60 50, 50 52 Q 42 51, 38 56 Z" fill={hair}/>;
      case 'crew':       return <path d="M38 54 Q 38 38, 60 36 Q 82 38, 82 54 Q 78 47, 70 48 Q 60 46, 50 48 Q 42 47, 38 54 Z" fill={hair}/>;
      case 'caesar':     return <path d="M38 60 Q 38 38, 60 36 Q 82 38, 82 60 L 82 58 Q 75 56, 60 56 Q 45 56, 38 58 Z" fill={hair}/>;
      case 'crop':       return <path d="M37 58 Q 36 36, 60 33 Q 84 36, 83 58 Q 78 50, 72 52 Q 65 47, 50 50 Q 44 49, 37 58 Z" fill={hair}/>;
      case 'ivy':        return <path d="M37 58 Q 36 36, 60 33 Q 84 36, 83 58 L 80 56 Q 70 50, 56 53 Q 48 51, 37 58 Z" fill={hair}/>;
      // Pixie family
      case 'pixie':      return <path d="M37 60 Q 35 33, 60 30 Q 84 33, 83 60 Q 78 50, 72 53 Q 60 46, 48 53 Q 42 51, 37 60 Z" fill={hair}/>;
      case 'pixie-fringe': return <g><path d="M37 60 Q 35 33, 60 30 Q 84 33, 83 60 L 81 56 Q 65 52, 50 56 Q 42 53, 37 60 Z" fill={hair}/><path d="M44 47 Q 50 60, 60 60 Q 70 60, 76 47 Q 70 52, 60 52 Q 50 52, 44 47 Z" fill={hair}/></g>;
      case 'bixie':      return <path d="M36 64 Q 33 32, 60 29 Q 87 32, 84 64 L 86 78 Q 76 72, 76 65 Q 60 58, 44 65 Q 44 72, 34 78 Z" fill={hair}/>;
      // Bob family
      case 'bob':        return <path d="M36 60 Q 32 32, 60 28 Q 88 32, 84 60 L 86 88 Q 76 76, 78 65 Q 60 56, 42 65 Q 44 76, 34 88 Z" fill={hair}/>;
      case 'blunt-bob':  return <path d="M34 60 Q 30 30, 60 26 Q 90 30, 86 60 L 88 92 L 32 92 Z" fill={hair}/>;
      case 'a-bob':      return <path d="M36 60 Q 32 32, 60 28 Q 88 32, 84 60 L 96 96 L 24 96 Z" fill={hair}/>;
      case 'french-bob': return <g><path d="M34 62 Q 30 32, 60 28 Q 90 32, 86 62 L 88 86 Q 76 80, 78 70 Q 60 60, 42 70 Q 44 80, 32 86 Z" fill={hair}/><path d="M40 50 Q 50 64, 60 64 Q 70 64, 80 50 Q 72 56, 60 57 Q 48 56, 40 50 Z" fill={hair}/></g>;
      // Mid-length
      case 'lob':        return <path d="M34 60 Q 30 32, 60 28 Q 90 32, 86 60 L 90 110 Q 76 96, 78 70 Q 60 60, 42 70 Q 44 96, 30 110 Z" fill={hair}/>;
      case 'curly-lob':  return <g><path d="M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 94 110 Q 80 100, 80 70 Q 60 60, 40 70 Q 40 100, 26 110 Z" fill={hair}/>{[[28,72],[36,86],[26,98],[92,72],[84,86],[94,98]].map(([x,y],i)=><circle key={i} cx={x} cy={y} r="6" fill={hair}/>)}</g>;
      case 'fringe':     return <g><path d="M34 60 Q 30 32, 60 28 Q 90 32, 86 60 L 90 100 Q 76 92, 78 68 Q 60 58, 42 68 Q 44 92, 30 100 Z" fill={hair}/><path d="M40 48 Q 50 66, 60 66 Q 70 66, 80 48 Q 72 58, 60 59 Q 48 58, 40 48 Z" fill={hair}/></g>;
      case 'shag':       return <g><path d="M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 108 Q 78 96, 80 70 Q 60 60, 40 70 Q 42 96, 28 108 Z" fill={hair}/><path d="M42 50 Q 50 64, 60 64 Q 70 64, 78 50 L 75 62 L 70 56 L 64 64 L 56 64 L 50 56 L 45 62 Z" fill={hair}/></g>;
      case 'layered':    return <g><path d="M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 110 Q 78 98, 80 70 Q 60 60, 40 70 Q 42 98, 28 110 Z" fill={hair}/><path d="M30 84 L 36 90 L 28 96 M 92 84 L 86 90 L 94 96" stroke={hair} strokeWidth="3" fill="none" opacity="0.7"/></g>;
      case 'wavy-bob':   return <path d="M32 60 Q 30 30, 60 26 Q 90 30, 88 60 Q 86 70, 92 78 Q 84 84, 88 96 Q 76 90, 78 70 Q 60 60, 42 70 Q 44 90, 32 96 Q 36 84, 28 78 Q 34 70, 32 60 Z" fill={hair}/>;
      // Long
      case 'long-layers':   return <path d="M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 96 132 Q 78 110, 80 70 Q 60 60, 40 70 Q 42 110, 24 132 Z" fill={hair}/>;
      case 'long-wavy':     return <g><path d="M28 60 Q 26 26, 60 22 Q 94 26, 92 60 L 100 130 Q 80 116, 82 70 Q 60 60, 38 70 Q 40 116, 20 130 Z" fill={hair}/><path d="M22 100 Q 30 108, 24 116 M 98 100 Q 90 108, 96 116" stroke={hair} strokeWidth="4" fill="none"/></g>;
      case 'long-straight': return <path d="M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 92 134 L 28 134 Z" fill={hair}/>;
      case 'long-curly':    return <g><path d="M26 60 Q 24 26, 60 22 Q 96 26, 94 60 L 102 128 Q 80 116, 82 70 Q 60 60, 38 70 Q 40 116, 18 128 Z" fill={hair}/>{[[20,80],[16,96],[22,112],[14,124],[100,80],[104,96],[98,112],[106,124],[28,128],[92,128]].map(([x,y],i)=><circle key={i} cx={x} cy={y} r="7" fill={hair}/>)}</g>;
      case 'bun':           return <g><path d="M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 100 Q 78 90, 80 70 Q 60 60, 40 70 Q 42 90, 28 100 Z" fill={hair}/><circle cx="60" cy="22" r="14" fill={hair}/></g>;
      case 'ponytail':      return <g><path d="M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 96 Q 78 88, 80 70 Q 60 60, 40 70 Q 42 88, 28 96 Z" fill={hair}/><path d="M82 50 Q 110 70, 100 130 Q 92 130, 90 110 Q 88 90, 78 65 Z" fill={hair}/></g>;
      // Men mid
      case 'fringe-m':   return <path d="M36 56 Q 35 33, 60 30 Q 85 33, 84 56 L 84 60 Q 65 60, 40 64 Z" fill={hair}/>;
      case 'slick':      return <path d="M36 54 Q 60 28, 86 56 L 88 64 Q 76 56, 60 56 Q 44 56, 36 64 Z" fill={hair}/>;
      case 'pomp':       return <g><path d="M36 56 Q 36 30, 60 22 Q 84 30, 84 56 Q 76 50, 60 50 Q 44 50, 36 56 Z" fill={hair}/></g>;
      case 'quiff':      return <path d="M36 58 Q 30 28, 56 22 Q 78 18, 84 56 Q 76 50, 60 50 Q 44 50, 36 58 Z" fill={hair}/>;
      case 'tousled':    return <g><path d="M34 58 Q 32 30, 60 26 Q 88 30, 86 58 L 88 70 Q 76 64, 78 60 Q 60 52, 42 60 Q 44 64, 32 70 Z" fill={hair}/><path d="M44 38 L 52 28 M 60 24 L 64 32 M 76 30 L 72 38" stroke={hair} strokeWidth="3" strokeLinecap="round"/></g>;
      case 'curtain':    return <g><path d="M34 58 Q 32 30, 60 26 Q 88 30, 86 58 L 86 70 Q 76 60, 60 60 Q 44 60, 34 70 Z" fill={hair}/><path d="M58 30 L 58 60 M 62 30 L 62 60" stroke={bg} strokeWidth="2"/></g>;
      // Men long
      case 'long-flow':   return <path d="M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 96 120 Q 80 108, 82 70 Q 60 60, 38 70 Q 40 108, 24 120 Z" fill={hair}/>;
      case 'man-bun':     return <g><path d="M34 56 Q 32 32, 60 28 Q 88 32, 86 56 L 88 70 Q 76 64, 78 62 Q 60 54, 42 62 Q 44 64, 32 70 Z" fill={hair}/><circle cx="60" cy="22" r="12" fill={hair}/></g>;
      case 'long-wavy-m': return <path d="M32 58 Q 30 30, 60 26 Q 90 30, 88 58 L 94 110 Q 78 100, 80 68 Q 60 58, 40 68 Q 42 100, 26 110 Z" fill={hair}/>;
      default:           return <path d="M36 60 Q 32 32, 60 28 Q 88 32, 84 60 L 86 88 Q 76 76, 78 65 Q 60 56, 42 65 Q 44 76, 34 88 Z" fill={hair}/>;
    }
  })();

  return (
    <svg viewBox="0 0 120 140" preserveAspectRatio="xMidYMid slice" style={{ width: '100%', height: '100%', display: 'block' }}>
      <rect width="120" height="140" fill={bg}/>
      <path d="M10 140 Q 10 110, 38 105 L 82 105 Q 110 110, 110 140 Z" fill={dark ? '#28231F' : '#D4CDC0'}/>
      <rect x="52" y="92" width="16" height="18" fill={dark ? '#3F352C' : '#C9A380'}/>
      <ellipse cx="60" cy="65" rx="22" ry="28" fill={dark ? '#5C4A3D' : '#E8D5C0'}/>
      {/* shaved scalp shadow for bald */}
      {shape === 'bald' && <ellipse cx="60" cy="50" rx="22" ry="22" fill={dark ? '#574638' : '#D9C2A8'}/>}
      {path}
      <ellipse cx="51" cy="68" rx="1.6" ry="2.2" fill={TOKENS.ink}/>
      <ellipse cx="69" cy="68" rx="1.6" ry="2.2" fill={TOKENS.ink}/>
      <path d="M55 82 Q 60 85, 65 82" stroke="#8B5A4D" strokeWidth="1.4" fill="none" strokeLinecap="round"/>
    </svg>
  );
};

// ─────────────────────────────────────────────────────────────
// Reusable: button, chip, scrim, transitions
// ─────────────────────────────────────────────────────────────
const PrimaryButton = ({ children, onClick, dark = false, icon, style = {} }) => (
  <button
    onClick={onClick}
    style={{
      width: '100%', height: 56, borderRadius: 100, border: 'none',
      background: dark ? '#fff' : TOKENS.ink,
      color: dark ? TOKENS.ink : '#fff',
      fontFamily: TOKENS.sans, fontSize: 16, fontWeight: 500, letterSpacing: -0.2,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      cursor: 'pointer', transition: 'transform 120ms ease, opacity 120ms ease',
      ...style,
    }}
    onMouseDown={e => e.currentTarget.style.transform = 'scale(0.98)'}
    onMouseUp={e => e.currentTarget.style.transform = 'scale(1)'}
    onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}
  >
    {children}
    {icon && <Icon name={icon} size={18} stroke={dark ? TOKENS.ink : '#fff'}/>}
  </button>
);

const GhostButton = ({ children, onClick, style = {} }) => (
  <button
    onClick={onClick}
    style={{
      width: '100%', height: 52, borderRadius: 100,
      background: 'transparent', border: `1px solid ${TOKENS.hairlineStrong}`,
      color: TOKENS.ink,
      fontFamily: TOKENS.sans, fontSize: 15, fontWeight: 500, letterSpacing: -0.2,
      display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      cursor: 'pointer',
      ...style,
    }}
  >{children}</button>
);

const Chip = ({ children, active, onClick, style = {} }) => (
  <button
    onClick={onClick}
    style={{
      height: 34, padding: '0 14px', borderRadius: 100,
      background: active ? TOKENS.ink : 'transparent',
      color: active ? '#fff' : TOKENS.inkSoft,
      border: `1px solid ${active ? TOKENS.ink : TOKENS.hairlineStrong}`,
      fontFamily: TOKENS.sans, fontSize: 13, fontWeight: 500, letterSpacing: -0.1,
      cursor: 'pointer', whiteSpace: 'nowrap',
      transition: 'all 150ms ease',
      ...style,
    }}
  >{children}</button>
);

// Tap ripple — a tiny dot that pulses on press to suggest haptic feedback
const useTap = () => {
  const [taps, setTaps] = useState([]);
  const trigger = useCallback((e) => {
    const id = Math.random();
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    setTaps(t => [...t, { id, x, y }]);
    setTimeout(() => setTaps(t => t.filter(tp => tp.id !== id)), 500);
  }, []);
  const Ripple = () => taps.map(t => (
    <span key={t.id} style={{
      position: 'absolute', left: t.x, top: t.y, width: 0, height: 0,
      borderRadius: '50%', pointerEvents: 'none',
      animation: 'tz-ripple 500ms ease-out forwards',
      background: 'rgba(15,15,14,0.18)',
      transform: 'translate(-50%,-50%)',
    }}/>
  ));
  return { trigger, Ripple };
};

// ─────────────────────────────────────────────────────────────
// Top-level app
// ─────────────────────────────────────────────────────────────
const SCREENS = [
  'splash',       // 1
  'onboard',      // 2
  'permission',   // 3
  'home',         // 4
  'capture',      // 5
  'gender',       // 6
  'hairquiz',     // 7  — questionnaire
  'gallery',      // 8
  'preview',      // 9
  'analyzing',    // 10
  'result',       // 11
  'saved',        // 12
  'profile',      // 13
];

// Persisted defaults — exposed to host editmode for tweaks persistence
const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "galleryLayout": "grid",
  "analysisStyle": "detailed",
  "showScreenLabels": true
}/*EDITMODE-END*/;

function App() {
  const [tweaks, setTweak] = window.useTweaks(TWEAK_DEFAULTS);
  const [screen, setScreen] = useState('splash');
  const [history, setHistory] = useState(['splash']);
  const [direction, setDirection] = useState('forward'); // forward | back

  const [gender, setGender] = useState(null);   // 'woman' | 'man'
  const [photoTaken, setPhotoTaken] = useState(false);
  const [selectedStyle, setSelectedStyle] = useState(null);
  const [favorites, setFavorites] = useState(new Set(['w4', 'm5']));
  const [saved, setSaved] = useState([{ styleId: 'w15', date: 'Сьогодні' }]);
  const [hairProfile, setHairProfile] = useState({
    texture: null,    // 'straight' | 'wavy' | 'curly' | 'coily'
    thickness: null,  // 'thin' | 'medium' | 'thick'
    porosity: null,   // 'low' | 'normal' | 'high'
    faceShape: null,  // 'oval' | 'round' | 'square' | 'heart' | 'long'
    timeStyling: null,// '<5' | '5-15' | '15-30' | '30+'
  });

  const go = (next, dir = 'forward') => {
    setDirection(dir);
    setHistory(h => dir === 'forward' ? [...h, next] : h.slice(0, -1));
    setScreen(next);
  };
  const back = () => {
    if (history.length <= 1) return;
    const prev = history[history.length - 2];
    setDirection('back');
    setHistory(h => h.slice(0, -1));
    setScreen(prev);
  };

  const toggleFavorite = (id) => {
    setFavorites(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  };

  // Auto-advance splash
  useEffect(() => {
    if (screen === 'splash') {
      const t = setTimeout(() => go('onboard'), 1900);
      return () => clearTimeout(t);
    }
  }, [screen]);

  const ctx = {
    tweaks, setTweak,
    screen, go, back, direction,
    gender, setGender,
    photoTaken, setPhotoTaken,
    selectedStyle, setSelectedStyle,
    favorites, toggleFavorite,
    saved, setSaved,
    hairProfile, setHairProfile,
  };

  return (
    <div style={{
      minHeight: '100vh', background: '#E8E3DA',
      padding: '40px 20px', boxSizing: 'border-box',
      display: 'flex', alignItems: 'flex-start', justifyContent: 'center',
      fontFamily: TOKENS.sans,
    }}>
      <window.IOSDevice width={402} height={874} dark={false}>
        <ScreenStack ctx={ctx}/>
      </window.IOSDevice>
      <Tweaks tweaks={tweaks} setTweak={setTweak} ctx={ctx}/>
    </div>
  );
}

// Render screens with cross-fade + slight horizontal slide
function ScreenStack({ ctx }) {
  const { screen, direction } = ctx;
  const [render, setRender] = useState(screen);
  const [phase, setPhase] = useState('idle'); // 'enter' | 'idle'

  useEffect(() => {
    if (screen !== render) {
      setPhase('exit');
      const t = setTimeout(() => {
        setRender(screen);
        setPhase('enter');
        const t2 = setTimeout(() => setPhase('idle'), 280);
        return () => clearTimeout(t2);
      }, 140);
      return () => clearTimeout(t);
    }
  }, [screen, render]);

  const screenLabel = `${String(SCREENS.indexOf(render) + 1).padStart(2, '0')} ${render}`;

  const transition = (() => {
    if (phase === 'exit')  return { opacity: 0, transform: direction === 'forward' ? 'translateX(-12px)' : 'translateX(12px)' };
    if (phase === 'enter') return { opacity: 0, transform: direction === 'forward' ? 'translateX(12px)' : 'translateX(-12px)' };
    return { opacity: 1, transform: 'translateX(0)' };
  })();

  return (
    <div data-screen-label={screenLabel} style={{
      width: '100%', height: '100%', position: 'relative',
      transition: 'opacity 220ms ease, transform 280ms cubic-bezier(0.2, 0.8, 0.2, 1)',
      ...transition,
    }}>
      {render === 'splash' && <Splash ctx={ctx}/>}
      {render === 'onboard' && <Onboard ctx={ctx}/>}
      {render === 'permission' && <Permission ctx={ctx}/>}
      {render === 'home' && <Home ctx={ctx}/>}
      {render === 'capture' && <Capture ctx={ctx}/>}
      {render === 'gender' && <GenderSelect ctx={ctx}/>}
      {render === 'hairquiz' && <HairQuiz ctx={ctx}/>}
      {render === 'gallery' && <Gallery ctx={ctx}/>}
      {render === 'preview' && <Preview ctx={ctx}/>}
      {render === 'analyzing' && <Analyzing ctx={ctx}/>}
      {render === 'result' && <Result ctx={ctx}/>}
      {render === 'saved' && <Saved ctx={ctx}/>}
      {render === 'profile' && <Profile ctx={ctx}/>}
    </div>
  );
}

window.App = App;
window.TOKENS = TOKENS;
window.HAIRSTYLES = HAIRSTYLES;
window.Icon = Icon;
window.FaceCanvas = FaceCanvas;
window.HairGlyph = HairGlyph;
window.PrimaryButton = PrimaryButton;
window.GhostButton = GhostButton;
window.Chip = Chip;
window.useTap = useTap;
