// screens-1.jsx — Splash, Onboard, Permission, Home

const { useState: uS1, useEffect: uE1, useRef: uR1 } = React;

// 01 Splash
function Splash({ ctx }) {
  return (
    <div style={{
      width: '100%', height: '100%',
      background: window.TOKENS.bg,
      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
      padding: '0 32px', boxSizing: 'border-box',
    }}>
      <div style={{
        animation: 'tz-fade-up 800ms ease-out',
      }}>
        <div style={{
          fontFamily: window.TOKENS.serif,
          fontSize: 56, lineHeight: '0.95', letterSpacing: -1.5,
          color: window.TOKENS.ink, textAlign: 'center', fontWeight: 400,
        }}>
          <em style={{ fontStyle: 'italic' }}>Твоя</em><br/>Зачіска
        </div>
        <div style={{
          marginTop: 20, fontSize: 13, letterSpacing: 2,
          textTransform: 'uppercase', color: window.TOKENS.muted,
          textAlign: 'center', fontWeight: 500,
        }}>
          AI · стиль · тобі
        </div>
      </div>
      <div style={{
        position: 'absolute', bottom: 60, left: 0, right: 0,
        display: 'flex', justifyContent: 'center',
      }}>
        <div style={{
          width: 80, height: 2, background: window.TOKENS.hairlineStrong, borderRadius: 1,
          position: 'relative', overflow: 'hidden',
        }}>
          <div style={{
            position: 'absolute', inset: 0,
            background: window.TOKENS.ink,
            animation: 'tz-progress 1800ms ease-out forwards',
            transformOrigin: 'left',
          }}/>
        </div>
      </div>
    </div>
  );
}

// 02 Onboard — 3-step paged intro
function Onboard({ ctx }) {
  const [step, setStep] = uS1(0);
  const steps = [
    {
      title: 'Знайди свій образ',
      body: 'Завантаж фото та поглянь на себе з різними зачісками — без походу в салон.',
      glyph: 'photo',
    },
    {
      title: 'AI підкаже найкраще',
      body: 'Аналізуємо форму обличчя, тип волосся й риси, щоб порекомендувати ідеальний варіант.',
      glyph: 'sparkle',
    },
    {
      title: 'Колекція стилів',
      body: 'Сотні зачісок для жінок та чоловіків — від класики до сміливих експериментів.',
      glyph: 'gallery',
    },
  ];
  const cur = steps[step];

  const next = () => {
    if (step < steps.length - 1) setStep(s => s + 1);
    else ctx.go('permission');
  };

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      display: 'flex', flexDirection: 'column',
      padding: '64px 28px 32px', boxSizing: 'border-box',
    }}>
      {/* Skip */}
      <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
        <button onClick={() => ctx.go('permission')} style={{
          background: 'transparent', border: 'none', color: window.TOKENS.muted,
          fontFamily: window.TOKENS.sans, fontSize: 14, cursor: 'pointer',
        }}>Пропустити</button>
      </div>

      {/* Glyph illustration */}
      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '20px 0' }}>
        <div key={step} style={{
          width: 220, height: 260, position: 'relative',
          animation: 'tz-fade-up 500ms ease-out',
        }}>
          {cur.glyph === 'photo' && <PhotoGlyph/>}
          {cur.glyph === 'sparkle' && <SparkleGlyph/>}
          {cur.glyph === 'gallery' && <GalleryGlyph/>}
        </div>
      </div>

      {/* Text */}
      <div key={`t-${step}`} style={{ marginBottom: 32, animation: 'tz-fade-up 500ms ease-out 80ms backwards' }}>
        <div style={{
          fontFamily: window.TOKENS.serif, fontSize: 36, lineHeight: 1.05,
          letterSpacing: -1, color: window.TOKENS.ink, fontWeight: 400, marginBottom: 12,
        }}>{cur.title}</div>
        <div style={{
          fontFamily: window.TOKENS.sans, fontSize: 16, lineHeight: 1.45,
          color: window.TOKENS.muted, letterSpacing: -0.1, textWrap: 'pretty',
        }}>{cur.body}</div>
      </div>

      {/* Dots + button */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {steps.map((_, i) => (
            <div key={i} style={{
              width: i === step ? 22 : 6, height: 6, borderRadius: 3,
              background: i === step ? window.TOKENS.ink : window.TOKENS.hairlineStrong,
              transition: 'all 220ms ease',
            }}/>
          ))}
        </div>
        <div style={{ flex: 1 }}/>
        <button onClick={next} style={{
          height: 56, padding: '0 28px', borderRadius: 100, border: 'none',
          background: window.TOKENS.ink, color: '#fff',
          fontFamily: window.TOKENS.sans, fontSize: 15, fontWeight: 500,
          display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer',
        }}>
          {step < steps.length - 1 ? 'Далі' : 'Почати'}
          <window.Icon name="arrow-right" size={16} stroke="#fff"/>
        </button>
      </div>
    </div>
  );
}

const PhotoGlyph = () => (
  <svg viewBox="0 0 220 260" style={{ width: '100%', height: '100%' }}>
    {/* polaroid */}
    <g transform="rotate(-6 110 130)">
      <rect x="40" y="55" width="140" height="170" rx="6" fill="#fff" stroke={window.TOKENS.hairlineStrong}/>
      <rect x="50" y="65" width="120" height="135" fill={window.TOKENS.surfaceMuted}/>
      <ellipse cx="110" cy="130" rx="32" ry="38" fill="#E8D5C0"/>
      <path d="M78 120 Q 75 90, 110 85 Q 145 90, 142 120 L 142 140 Q 130 130, 130 118 Q 110 110, 90 118 Q 90 130, 78 140 Z" fill="#3D2B1F"/>
      <circle cx="100" cy="128" r="2" fill={window.TOKENS.ink}/>
      <circle cx="120" cy="128" r="2" fill={window.TOKENS.ink}/>
    </g>
    {/* corner clip */}
    <circle cx="172" cy="58" r="8" fill="none" stroke={window.TOKENS.ink} strokeWidth="1.5"/>
    <circle cx="172" cy="58" r="3" fill={window.TOKENS.ink}/>
  </svg>
);

const SparkleGlyph = () => (
  <svg viewBox="0 0 220 260" style={{ width: '100%', height: '100%' }}>
    <circle cx="110" cy="130" r="68" fill="none" stroke={window.TOKENS.hairlineStrong} strokeWidth="1" strokeDasharray="2 4"/>
    <circle cx="110" cy="130" r="42" fill={window.TOKENS.ink}/>
    {/* face inside circle */}
    <ellipse cx="110" cy="130" rx="20" ry="24" fill="#E8D5C0"/>
    <path d="M92 122 Q 90 105, 110 102 Q 130 105, 128 122 Q 124 116, 118 118 Q 110 113, 102 118 Q 96 116, 92 122 Z" fill="#3D2B1F"/>
    <circle cx="103" cy="128" r="1.5" fill={window.TOKENS.ink}/>
    <circle cx="117" cy="128" r="1.5" fill={window.TOKENS.ink}/>
    {/* sparks */}
    {[
      [40, 60], [180, 70], [180, 200], [40, 200], [110, 40], [110, 220],
    ].map(([x, y], i) => (
      <g key={i} transform={`translate(${x} ${y})`} style={{ animation: `tz-twinkle 2s ${i*0.2}s ease-in-out infinite` }}>
        <path d="M0 -8 L 1.5 -1.5 L 8 0 L 1.5 1.5 L 0 8 L -1.5 1.5 L -8 0 L -1.5 -1.5 Z" fill={window.TOKENS.ink}/>
      </g>
    ))}
  </svg>
);

const GalleryGlyph = () => (
  <svg viewBox="0 0 220 260" style={{ width: '100%', height: '100%' }}>
    {[
      { x: 30, y: 50, w: 70, h: 90, hue: '#3D2B1F', d: 'short' },
      { x: 115, y: 40, w: 70, h: 100, hue: '#A88563', d: 'long' },
      { x: 30, y: 155, w: 70, h: 80, hue: '#1A140F', d: 'mid' },
      { x: 115, y: 155, w: 70, h: 80, hue: '#5B4030', d: 'mid' },
    ].map((c, i) => (
      <g key={i}>
        <rect x={c.x} y={c.y} width={c.w} height={c.h} rx="6" fill={window.TOKENS.surfaceMuted}/>
        <ellipse cx={c.x+c.w/2} cy={c.y+c.h/2} rx={c.w*0.22} ry={c.h*0.25} fill="#E8D5C0"/>
        <path d={
          c.d === 'short' ?
          `M ${c.x+c.w*0.32} ${c.y+c.h*0.4} Q ${c.x+c.w*0.3} ${c.y+c.h*0.25}, ${c.x+c.w/2} ${c.y+c.h*0.22} Q ${c.x+c.w*0.7} ${c.y+c.h*0.25}, ${c.x+c.w*0.68} ${c.y+c.h*0.4} Z`
          : c.d === 'long' ?
          `M ${c.x+c.w*0.28} ${c.y+c.h*0.4} Q ${c.x+c.w*0.25} ${c.y+c.h*0.2}, ${c.x+c.w/2} ${c.y+c.h*0.18} Q ${c.x+c.w*0.75} ${c.y+c.h*0.2}, ${c.x+c.w*0.72} ${c.y+c.h*0.4} L ${c.x+c.w*0.78} ${c.y+c.h*0.85} L ${c.x+c.w*0.22} ${c.y+c.h*0.85} Z`
          :
          `M ${c.x+c.w*0.3} ${c.y+c.h*0.4} Q ${c.x+c.w*0.27} ${c.y+c.h*0.22}, ${c.x+c.w/2} ${c.y+c.h*0.2} Q ${c.x+c.w*0.73} ${c.y+c.h*0.22}, ${c.x+c.w*0.7} ${c.y+c.h*0.4} L ${c.x+c.w*0.74} ${c.y+c.h*0.65} L ${c.x+c.w*0.26} ${c.y+c.h*0.65} Z`
        } fill={c.hue}/>
      </g>
    ))}
  </svg>
);

// 03 Permission
function Permission({ ctx }) {
  const [granted, setGranted] = uS1(false);

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      display: 'flex', flexDirection: 'column',
      padding: '64px 28px 40px', boxSizing: 'border-box',
    }}>
      <button onClick={ctx.back} style={{
        width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
        border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <window.Icon name="arrow-left" size={18}/>
      </button>

      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{
          width: 130, height: 130, borderRadius: '50%',
          background: window.TOKENS.ink,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          position: 'relative',
        }}>
          {/* pulse */}
          <div style={{
            position: 'absolute', inset: -20, borderRadius: '50%',
            border: `1px solid ${window.TOKENS.hairlineStrong}`,
            animation: 'tz-pulse 2.4s ease-out infinite',
          }}/>
          <div style={{
            position: 'absolute', inset: -40, borderRadius: '50%',
            border: `1px solid ${window.TOKENS.hairlineStrong}`,
            animation: 'tz-pulse 2.4s ease-out infinite 0.6s',
          }}/>
          <window.Icon name="camera" size={52} stroke="#fff" strokeWidth={1.4}/>
        </div>
      </div>

      <div style={{ marginBottom: 32 }}>
        <div style={{
          fontFamily: window.TOKENS.serif, fontSize: 32, lineHeight: 1.1,
          letterSpacing: -1, color: window.TOKENS.ink, marginBottom: 12,
        }}>Доступ до камери</div>
        <div style={{
          fontFamily: window.TOKENS.sans, fontSize: 15, lineHeight: 1.5,
          color: window.TOKENS.muted, textWrap: 'pretty',
        }}>
          Потрібен, щоб робити фото для прим'юванння зачісок. Знімки залишаються на вашому пристрої.
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        <window.PrimaryButton onClick={() => { setGranted(true); setTimeout(() => ctx.go('home'), 300); }}>
          {granted ? <><window.Icon name="check" size={18} stroke="#fff"/> Дозволено</> : 'Надати доступ'}
        </window.PrimaryButton>
        <window.GhostButton onClick={() => ctx.go('home')}>Завантажити з галереї натомість</window.GhostButton>
      </div>
    </div>
  );
}

// 04 Home — landing/dashboard
function Home({ ctx }) {
  const recents = window.HAIRSTYLES.woman.slice(0, 4);
  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      overflowY: 'auto', overflowX: 'hidden',
      paddingBottom: 110,
    }}>
      {/* Top bar */}
      <div style={{
        padding: '60px 24px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      }}>
        <div style={{ fontFamily: window.TOKENS.sans, fontSize: 13, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase' }}>
          П'ятниця, 30 квітня
        </div>
        <button onClick={() => ctx.go('profile')} style={{
          width: 36, height: 36, borderRadius: 18, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="user" size={18}/>
        </button>
      </div>

      {/* Greeting */}
      <div style={{ padding: '24px 24px 0' }}>
        <div style={{
          fontFamily: window.TOKENS.serif, fontSize: 44, lineHeight: 1.0,
          letterSpacing: -1.4, color: window.TOKENS.ink, fontWeight: 400,
        }}>
          Привіт, <em>Олено</em>
        </div>
        <div style={{
          marginTop: 6, fontFamily: window.TOKENS.sans, fontSize: 16,
          color: window.TOKENS.muted, letterSpacing: -0.2,
        }}>Готова знайти новий образ?</div>
      </div>

      {/* Hero CTA card */}
      <div style={{ padding: '24px' }}>
        <button onClick={() => ctx.go('capture')} style={{
          width: '100%', borderRadius: 28, background: window.TOKENS.ink, color: '#fff',
          border: 'none', cursor: 'pointer', textAlign: 'left', overflow: 'hidden', position: 'relative',
          padding: 24, fontFamily: window.TOKENS.sans,
        }}>
          <div style={{
            position: 'absolute', top: -30, right: -30, width: 180, height: 180,
            borderRadius: '50%', background: 'rgba(255,255,255,0.04)',
          }}/>
          <div style={{
            position: 'absolute', top: 20, right: 20, width: 72, height: 72,
            borderRadius: '50%', background: 'rgba(255,255,255,0.08)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <window.Icon name="camera" size={28} stroke="#fff" strokeWidth={1.4}/>
          </div>
          <div style={{ fontSize: 13, opacity: 0.6, letterSpacing: 1.2, textTransform: 'uppercase', marginBottom: 80 }}>
            Почати
          </div>
          <div style={{
            fontFamily: window.TOKENS.serif, fontSize: 32, lineHeight: 1.05, letterSpacing: -0.8,
          }}>
            Зроби фото<br/><em>і приміряй</em>
          </div>
          <div style={{ marginTop: 16, fontSize: 14, opacity: 0.7, display: 'flex', alignItems: 'center', gap: 6 }}>
            Камера або галерея <window.Icon name="arrow-right" size={14} stroke="#fff"/>
          </div>
        </button>
      </div>

      {/* Quick actions */}
      <div style={{ padding: '0 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
        <QuickCard label="Жіночі" count={window.HAIRSTYLES.woman.length} onClick={() => { ctx.setGender('woman'); ctx.go('gallery'); }} hue="#A88563"/>
        <QuickCard label="Чоловічі" count={window.HAIRSTYLES.man.length} onClick={() => { ctx.setGender('man'); ctx.go('gallery'); }} hue="#3D2B1F"/>
      </div>

      {/* Recommended */}
      <div style={{ padding: '32px 24px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
          <div style={{
            fontFamily: window.TOKENS.serif, fontSize: 22, letterSpacing: -0.5, color: window.TOKENS.ink,
          }}><em>Рекомендовано</em> для тебе</div>
          <button onClick={() => { ctx.setGender('woman'); ctx.go('gallery'); }} style={{
            background: 'transparent', border: 'none', color: window.TOKENS.muted,
            fontFamily: window.TOKENS.sans, fontSize: 13, cursor: 'pointer',
          }}>Усі</button>
        </div>
        <div style={{ display: 'flex', gap: 12, overflowX: 'auto', paddingBottom: 8, margin: '0 -24px', padding: '0 24px 8px' }}>
          {recents.map(s => (
            <button key={s.id} onClick={() => { ctx.setSelectedStyle(s); ctx.setGender('woman'); ctx.go('preview'); }} style={{
              flexShrink: 0, width: 130, background: 'transparent', border: 'none',
              cursor: 'pointer', padding: 0, textAlign: 'left',
            }}>
              <div style={{ width: 130, height: 160, borderRadius: 16, overflow: 'hidden', position: 'relative' }}>
                <window.HairGlyph hair={s.hue} length={s.length} shape={s.shape}/>
                <div style={{
                  position: 'absolute', top: 8, right: 8,
                  background: 'rgba(255,255,255,0.95)', borderRadius: 100,
                  padding: '3px 8px', fontSize: 11, fontWeight: 600,
                  color: window.TOKENS.ink, letterSpacing: -0.1,
                }}>{s.match}%</div>
              </div>
              <div style={{ marginTop: 8, fontSize: 13, color: window.TOKENS.ink, fontWeight: 500, letterSpacing: -0.1 }}>{s.name}</div>
              <div style={{ fontSize: 11, color: window.TOKENS.muted }}>{s.length} · {s.vibe}</div>
            </button>
          ))}
        </div>
      </div>

      {/* Tabbar */}
      <TabBar ctx={ctx} active="home"/>
    </div>
  );
}

function QuickCard({ label, count, onClick, hue }) {
  return (
    <button onClick={onClick} style={{
      background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
      borderRadius: 24, padding: 16, cursor: 'pointer', textAlign: 'left',
      fontFamily: window.TOKENS.sans, position: 'relative', overflow: 'hidden',
      height: 120,
    }}>
      <div style={{
        position: 'absolute', right: -20, bottom: -20, width: 80, height: 80, borderRadius: '50%',
        background: hue, opacity: 0.9,
      }}/>
      <div style={{
        position: 'absolute', right: -10, bottom: -10, width: 60, height: 60, borderRadius: '50%',
        background: hue, opacity: 0.4, mixBlendMode: 'multiply',
      }}/>
      <div style={{ fontSize: 13, color: window.TOKENS.muted, letterSpacing: -0.1 }}>{count} стилів</div>
      <div style={{
        marginTop: 4, fontFamily: window.TOKENS.serif, fontSize: 24, color: window.TOKENS.ink,
        letterSpacing: -0.5,
      }}>{label}</div>
    </button>
  );
}

function TabBar({ ctx, active }) {
  const items = [
    { id: 'home', icon: 'home', label: 'Дім', target: 'home' },
    { id: 'gallery', icon: 'grid', label: 'Стилі', target: 'gender' },
    { id: 'capture', icon: 'camera', label: 'Камера', target: 'capture' },
    { id: 'saved', icon: 'heart', label: 'Обране', target: 'saved' },
    { id: 'profile', icon: 'user', label: 'Профіль', target: 'profile' },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0,
      paddingBottom: 28, paddingTop: 8, paddingLeft: 12, paddingRight: 12,
      background: 'linear-gradient(to top, rgba(250,250,248,0.96) 60%, rgba(250,250,248,0))',
      backdropFilter: 'blur(20px)',
      WebkitBackdropFilter: 'blur(20px)',
    }}>
      <div style={{
        display: 'flex', justifyContent: 'space-around', alignItems: 'center',
        background: '#fff', border: `1px solid ${window.TOKENS.hairline}`,
        borderRadius: 100, padding: '8px 4px',
        boxShadow: '0 4px 20px rgba(0,0,0,0.04)',
      }}>
        {items.map(it => (
          <button key={it.id} onClick={() => ctx.go(it.target)} style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            padding: '8px 12px', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2,
            fontFamily: window.TOKENS.sans,
          }}>
            <window.Icon
              name={active === it.id && it.icon === 'heart' ? 'heart-fill' : it.icon}
              size={20}
              stroke={active === it.id ? window.TOKENS.ink : window.TOKENS.mutedSoft}
              strokeWidth={active === it.id ? 1.8 : 1.4}
            />
            <span style={{
              fontSize: 10, color: active === it.id ? window.TOKENS.ink : window.TOKENS.mutedSoft,
              fontWeight: active === it.id ? 600 : 500,
            }}>{it.label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, { Splash, Onboard, Permission, Home, TabBar });
