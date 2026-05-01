// screens-2.jsx — Capture, GenderSelect, Gallery, Preview

const { useState: uS2, useEffect: uE2, useRef: uR2 } = React;

// 05 Capture — camera viewfinder
function Capture({ ctx }) {
  const [shooting, setShooting] = uS2(false);
  const [flash, setFlash] = uS2(false);

  const shoot = () => {
    setShooting(true);
    setFlash(true);
    setTimeout(() => setFlash(false), 200);
    setTimeout(() => {
      ctx.setPhotoTaken(true);
      if (!ctx.gender) ctx.go('gender');
      else ctx.go('gallery');
    }, 700);
  };

  return (
    <div style={{
      width: '100%', height: '100%', background: '#0A0A09',
      position: 'relative', overflow: 'hidden',
    }}>
      {/* viewfinder area */}
      <div style={{
        position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
        background: 'radial-gradient(circle at 50% 40%, #2C2620 0%, #0A0A09 70%)',
      }}/>
      {/* face guide */}
      <div style={{
        position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -55%)',
        width: 240, height: 300,
      }}>
        <window.FaceCanvas dark hair="#3D2B1F" tone="medium" style={{ borderRadius: 999, opacity: shooting ? 1 : 0.85, transition: 'opacity 200ms' }}/>
        {/* oval guide */}
        <svg viewBox="0 0 240 300" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
          <ellipse cx="120" cy="140" rx="100" ry="135"
            fill="none" stroke="#fff" strokeWidth="1.5" strokeDasharray="6 8" opacity="0.5"/>
          {/* corner brackets */}
          {[
            ['M20 60 L20 30 L50 30', 0],
            ['M220 30 L250 30 L250 60', 0],
            ['M20 240 L20 270 L50 270', 0],
            ['M220 270 L250 270 L250 240', 0],
          ].map(([d], i) => (
            <path key={i} d={d} stroke="#fff" strokeWidth="2" fill="none" strokeLinecap="round" opacity="0.85"/>
          ))}
        </svg>
      </div>

      {/* Top controls */}
      <div style={{
        position: 'absolute', top: 60, left: 0, right: 0, padding: '0 20px',
        display: 'flex', justifyContent: 'space-between', alignItems: 'center', zIndex: 5,
      }}>
        <button onClick={ctx.back} style={{
          width: 40, height: 40, borderRadius: 20, background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="x" size={18} stroke="#fff"/>
        </button>
        <div style={{
          padding: '8px 14px', borderRadius: 100, background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(10px)', color: '#fff',
          fontFamily: window.TOKENS.sans, fontSize: 13, fontWeight: 500, letterSpacing: -0.1,
        }}>Тримай обличчя в рамці</div>
        <button style={{
          width: 40, height: 40, borderRadius: 20, background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="flash" size={18} stroke="#fff"/>
        </button>
      </div>

      {/* Hint chips */}
      <div style={{
        position: 'absolute', bottom: 220, left: 0, right: 0, padding: '0 20px',
        display: 'flex', justifyContent: 'center', gap: 8,
      }}>
        {['✓ Освітлення', '✓ Обличчя', '⏵ Прямий погляд'].map((t, i) => (
          <div key={i} style={{
            padding: '6px 12px', borderRadius: 100,
            background: 'rgba(255,255,255,0.16)', backdropFilter: 'blur(10px)',
            color: '#fff', fontSize: 12, fontWeight: 500, fontFamily: window.TOKENS.sans,
          }}>{t}</div>
        ))}
      </div>

      {/* Bottom shutter */}
      <div style={{
        position: 'absolute', bottom: 50, left: 0, right: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'space-around', padding: '0 32px',
      }}>
        <button onClick={() => { ctx.setPhotoTaken(true); if (!ctx.gender) ctx.go('gender'); else ctx.go('gallery'); }} style={{
          width: 50, height: 50, borderRadius: 12, background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="image" size={22} stroke="#fff"/>
        </button>
        <button onClick={shoot} style={{
          width: 78, height: 78, borderRadius: '50%', border: 'none', cursor: 'pointer',
          background: 'transparent', padding: 0,
        }}>
          <div style={{
            width: '100%', height: '100%', borderRadius: '50%',
            border: '3px solid #fff', padding: 4, boxSizing: 'border-box',
          }}>
            <div style={{
              width: '100%', height: '100%', borderRadius: '50%',
              background: '#fff',
              transform: shooting ? 'scale(0.8)' : 'scale(1)',
              transition: 'transform 200ms',
            }}/>
          </div>
        </button>
        <button style={{
          width: 50, height: 50, borderRadius: 25, background: 'rgba(255,255,255,0.18)',
          backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="reload" size={20} stroke="#fff"/>
        </button>
      </div>

      {/* flash overlay */}
      {flash && (
        <div style={{
          position: 'absolute', inset: 0, background: '#fff',
          animation: 'tz-flash 200ms ease-out forwards', pointerEvents: 'none', zIndex: 100,
        }}/>
      )}
    </div>
  );
}

// 06 Gender select
function GenderSelect({ ctx }) {
  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      padding: '64px 28px 32px', boxSizing: 'border-box',
      display: 'flex', flexDirection: 'column',
    }}>
      <button onClick={ctx.back} style={{
        width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
        border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <window.Icon name="arrow-left" size={18}/>
      </button>

      <div style={{ marginTop: 32 }}>
        <div style={{
          fontFamily: window.TOKENS.serif, fontSize: 38, lineHeight: 1.05,
          letterSpacing: -1.1, color: window.TOKENS.ink, marginBottom: 8,
        }}>Які стилі<br/><em>покажемо?</em></div>
        <div style={{ fontSize: 15, color: window.TOKENS.muted, letterSpacing: -0.2 }}>
          Це можна змінити будь-коли.
        </div>
      </div>

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 14, marginTop: 32 }}>
        {[
          { id: 'woman', label: 'Жіночі', count: window.HAIRSTYLES.woman.length, hue: '#A88563', length: 'Довге', shape: 'long-wavy' },
          { id: 'man', label: 'Чоловічі', count: window.HAIRSTYLES.man.length, hue: '#1A140F', length: 'Коротке', shape: 'crop' },
        ].map(o => (
          <button key={o.id} onClick={() => { ctx.setGender(o.id); ctx.go('hairquiz'); }} style={{
            flex: 1, background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
            borderRadius: 28, cursor: 'pointer', overflow: 'hidden',
            display: 'flex', alignItems: 'center', gap: 0, padding: 0,
            textAlign: 'left', fontFamily: window.TOKENS.sans,
          }}>
            <div style={{ width: 140, height: '100%', flexShrink: 0 }}>
              <window.HairGlyph hair={o.hue} length={o.length} shape={o.shape}/>
            </div>
            <div style={{ flex: 1, padding: 24 }}>
              <div style={{
                fontFamily: window.TOKENS.serif, fontSize: 30, letterSpacing: -0.8,
                color: window.TOKENS.ink, marginBottom: 4,
              }}>{o.label}</div>
              <div style={{ fontSize: 13, color: window.TOKENS.muted }}>{o.count} стилів</div>
            </div>
            <div style={{ paddingRight: 20 }}>
              <window.Icon name="arrow-right" size={20} stroke={window.TOKENS.ink}/>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

// 07 Gallery
function Gallery({ ctx }) {
  const layout = ctx.tweaks.galleryLayout || 'grid';
  const [filter, setFilter] = uS2('Усі');
  const styles = window.HAIRSTYLES[ctx.gender || 'woman'];

  const filters = ctx.gender === 'man' ? ['Усі', 'Лисе', 'Коротке', 'Середнє', 'Довге'] : ['Усі', 'Коротке', 'Середнє', 'Довге'];
  const filtered = filter === 'Усі' ? styles : styles.filter(s => s.length === filter);

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      overflowY: 'auto', overflowX: 'hidden', paddingBottom: 110,
    }}>
      {/* Header */}
      <div style={{ padding: '60px 24px 0', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={ctx.back} style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="arrow-left" size={18}/>
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 11, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase' }}>
            {ctx.gender === 'man' ? 'Чоловічі' : 'Жіночі'}
          </div>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 26, letterSpacing: -0.6, color: window.TOKENS.ink }}>
            Колекція
          </div>
        </div>
        {/* Layout switcher */}
        <div style={{
          display: 'flex', background: window.TOKENS.surfaceMuted, borderRadius: 100, padding: 3,
        }}>
          {[
            { id: 'grid', icon: 'grid' },
            { id: 'carousel', icon: 'columns' },
            { id: 'list', icon: 'list' },
          ].map(o => (
            <button key={o.id} onClick={() => ctx.setTweak('galleryLayout', o.id)} style={{
              width: 32, height: 32, borderRadius: 100, border: 'none',
              background: layout === o.id ? '#fff' : 'transparent', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: layout === o.id ? '0 1px 3px rgba(0,0,0,0.08)' : 'none',
              transition: 'all 200ms',
            }}>
              <window.Icon name={o.icon} size={15} stroke={layout === o.id ? window.TOKENS.ink : window.TOKENS.muted}/>
            </button>
          ))}
        </div>
      </div>

      {/* Filter chips */}
      <div style={{ padding: '20px 24px 0', display: 'flex', gap: 8, overflowX: 'auto' }}>
        {filters.map(f => (
          <window.Chip key={f} active={filter === f} onClick={() => setFilter(f)}>{f}</window.Chip>
        ))}
      </div>

      <div style={{ padding: '20px 24px 0' }}>
        <div style={{ fontSize: 13, color: window.TOKENS.muted }}>{filtered.length} стилів</div>
      </div>

      {/* Layouts */}
      {layout === 'grid' && (
        <div style={{ padding: '16px 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {filtered.map(s => <GridCard key={s.id} style={s} ctx={ctx}/>)}
        </div>
      )}
      {layout === 'carousel' && (
        <div style={{ padding: '16px 0', overflowX: 'auto', display: 'flex', gap: 12, scrollSnapType: 'x mandatory' }}>
          <div style={{ flexShrink: 0, width: 16 }}/>
          {filtered.map(s => <CarouselCard key={s.id} style={s} ctx={ctx}/>)}
          <div style={{ flexShrink: 0, width: 16 }}/>
        </div>
      )}
      {layout === 'list' && (
        <div style={{ padding: '16px 24px', display: 'flex', flexDirection: 'column', gap: 10 }}>
          {filtered.map(s => <ListRow key={s.id} style={s} ctx={ctx}/>)}
        </div>
      )}

      <window.TabBar ctx={ctx} active="gallery"/>
    </div>
  );
}

function GridCard({ style: s, ctx }) {
  const isFav = ctx.favorites.has(s.id);
  return (
    <button onClick={() => { ctx.setSelectedStyle(s); ctx.go('preview'); }} style={{
      background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'left',
      fontFamily: window.TOKENS.sans,
    }}>
      <div style={{ position: 'relative', width: '100%', aspectRatio: '0.82', borderRadius: 18, overflow: 'hidden' }}>
        <window.HairGlyph hair={s.hue} length={s.length} shape={s.shape}/>
        <button onClick={(e) => { e.stopPropagation(); ctx.toggleFavorite(s.id); }} style={{
          position: 'absolute', top: 10, right: 10,
          width: 32, height: 32, borderRadius: 16, background: 'rgba(255,255,255,0.92)',
          backdropFilter: 'blur(8px)', border: 'none', cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name={isFav ? 'heart-fill' : 'heart'} size={15} stroke={isFav ? '#C44' : window.TOKENS.ink}/>
        </button>
        <div style={{
          position: 'absolute', bottom: 10, left: 10, padding: '3px 8px',
          background: 'rgba(255,255,255,0.95)', borderRadius: 100,
          fontSize: 11, fontWeight: 600, letterSpacing: -0.1, color: window.TOKENS.ink,
        }}>{s.match}%</div>
      </div>
      <div style={{ marginTop: 8, fontSize: 14, color: window.TOKENS.ink, fontWeight: 500, letterSpacing: -0.2 }}>{s.name}</div>
      <div style={{ fontSize: 12, color: window.TOKENS.muted }}>{s.length} · {s.vibe}</div>
    </button>
  );
}

function CarouselCard({ style: s, ctx }) {
  return (
    <button onClick={() => { ctx.setSelectedStyle(s); ctx.go('preview'); }} style={{
      flexShrink: 0, width: 240, background: 'transparent', border: 'none', cursor: 'pointer',
      padding: 0, textAlign: 'left', scrollSnapAlign: 'center', fontFamily: window.TOKENS.sans,
    }}>
      <div style={{ width: 240, height: 320, borderRadius: 24, overflow: 'hidden', position: 'relative' }}>
        <window.HairGlyph hair={s.hue} length={s.length} shape={s.shape}/>
        <div style={{
          position: 'absolute', inset: 'auto 0 0 0', padding: 16,
          background: 'linear-gradient(to top, rgba(0,0,0,0.6), transparent)',
          color: '#fff',
        }}>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 22, letterSpacing: -0.4 }}>{s.name}</div>
          <div style={{ fontSize: 12, opacity: 0.85, marginTop: 2 }}>{s.length} · {s.vibe} · {s.match}% match</div>
        </div>
      </div>
    </button>
  );
}

function ListRow({ style: s, ctx }) {
  const isFav = ctx.favorites.has(s.id);
  return (
    <button onClick={() => { ctx.setSelectedStyle(s); ctx.go('preview'); }} style={{
      background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`, borderRadius: 18,
      padding: 12, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 14,
      fontFamily: window.TOKENS.sans, textAlign: 'left',
    }}>
      <div style={{ width: 70, height: 84, borderRadius: 12, overflow: 'hidden', flexShrink: 0 }}>
        <window.HairGlyph hair={s.hue} length={s.length} shape={s.shape}/>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 15, color: window.TOKENS.ink, fontWeight: 500, letterSpacing: -0.2 }}>{s.name}</div>
        <div style={{ fontSize: 12, color: window.TOKENS.muted, marginTop: 2 }}>{s.length} · {s.vibe}</div>
        {/* match bar */}
        <div style={{ marginTop: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
          <div style={{ flex: 1, height: 3, background: window.TOKENS.hairline, borderRadius: 2, overflow: 'hidden' }}>
            <div style={{ width: `${s.match}%`, height: '100%', background: window.TOKENS.ink }}/>
          </div>
          <div style={{ fontSize: 11, fontWeight: 600, color: window.TOKENS.ink }}>{s.match}%</div>
        </div>
      </div>
      <div onClick={(e) => { e.stopPropagation(); ctx.toggleFavorite(s.id); }} style={{
        width: 36, height: 36, borderRadius: 18, display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <window.Icon name={isFav ? 'heart-fill' : 'heart'} size={17} stroke={isFav ? '#C44' : window.TOKENS.muted}/>
      </div>
    </button>
  );
}

// 08 Preview — split before/after
function Preview({ ctx }) {
  const s = ctx.selectedStyle || window.HAIRSTYLES[ctx.gender || 'woman'][0];
  const [splitPos, setSplitPos] = uS2(50);
  const containerRef = uR2(null);

  const handleDrag = (e) => {
    const rect = containerRef.current.getBoundingClientRect();
    const clientX = e.touches ? e.touches[0].clientX : e.clientX;
    const pct = ((clientX - rect.left) / rect.width) * 100;
    setSplitPos(Math.max(8, Math.min(92, pct)));
  };

  const isFav = ctx.favorites.has(s.id);

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      display: 'flex', flexDirection: 'column',
    }}>
      {/* Top bar */}
      <div style={{ padding: '60px 20px 0', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <button onClick={ctx.back} style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="arrow-left" size={18}/>
        </button>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 10, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase' }}>Превʼю</div>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 18, letterSpacing: -0.3, color: window.TOKENS.ink }}>{s.name}</div>
        </div>
        <button onClick={() => ctx.toggleFavorite(s.id)} style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name={isFav ? 'heart-fill' : 'heart'} size={17} stroke={isFav ? '#C44' : window.TOKENS.ink}/>
        </button>
      </div>

      {/* Split viewer */}
      <div
        ref={containerRef}
        onMouseMove={(e) => e.buttons === 1 && handleDrag(e)}
        onTouchMove={handleDrag}
        style={{
          margin: '20px 20px 0', flex: 1, borderRadius: 28, overflow: 'hidden',
          position: 'relative', cursor: 'col-resize', background: '#000',
          userSelect: 'none', touchAction: 'none',
        }}
      >
        {/* After (full background) */}
        <div style={{ position: 'absolute', inset: 0 }}>
          <window.FaceCanvas hair={s.hue} tone="medium" size="100%"/>
          <div style={{ position: 'absolute', top: 16, right: 16, padding: '4px 10px', borderRadius: 100, background: window.TOKENS.ink, color: '#fff', fontSize: 11, fontWeight: 600, letterSpacing: 0.5 }}>ПІСЛЯ</div>
        </div>
        {/* Before (clipped) */}
        <div style={{ position: 'absolute', inset: 0, clipPath: `polygon(0 0, ${splitPos}% 0, ${splitPos}% 100%, 0 100%)` }}>
          <window.FaceCanvas hair="#3D2B1F" tone="medium" size="100%"/>
          <div style={{ position: 'absolute', top: 16, left: 16, padding: '4px 10px', borderRadius: 100, background: '#fff', color: window.TOKENS.ink, fontSize: 11, fontWeight: 600, letterSpacing: 0.5 }}>ДО</div>
        </div>
        {/* Slider handle */}
        <div style={{
          position: 'absolute', top: 0, bottom: 0, left: `${splitPos}%`, width: 2, background: '#fff',
          transform: 'translateX(-50%)', boxShadow: '0 0 12px rgba(0,0,0,0.5)',
        }}>
          <div style={{
            position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)',
            width: 44, height: 44, borderRadius: 22, background: '#fff',
            boxShadow: '0 2px 12px rgba(0,0,0,0.3)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <window.Icon name="swap" size={18} stroke={window.TOKENS.ink}/>
          </div>
        </div>
      </div>

      {/* Match strip */}
      <div style={{
        margin: '14px 20px 0', padding: '14px 16px', borderRadius: 18,
        background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
        display: 'flex', alignItems: 'center', gap: 14,
      }}>
        <div style={{
          width: 44, height: 44, borderRadius: 22, background: window.TOKENS.ink,
          color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontFamily: window.TOKENS.serif, fontSize: 16, fontWeight: 500,
        }}>{s.match}</div>
        <div style={{ flex: 1 }}>
          <div style={{ fontFamily: window.TOKENS.sans, fontSize: 14, color: window.TOKENS.ink, fontWeight: 500 }}>Сумісність</div>
          <div style={{ fontSize: 12, color: window.TOKENS.muted, marginTop: 1 }}>За попереднім аналізом</div>
        </div>
        <button onClick={() => ctx.go('analyzing')} style={{
          height: 36, padding: '0 14px', borderRadius: 100, border: 'none', cursor: 'pointer',
          background: window.TOKENS.ink, color: '#fff',
          fontFamily: window.TOKENS.sans, fontSize: 13, fontWeight: 500,
          display: 'flex', alignItems: 'center', gap: 6,
        }}>
          <window.Icon name="sparkle" size={14} stroke="#fff"/> Повний аналіз
        </button>
      </div>

      {/* Bottom actions */}
      <div style={{ padding: '14px 20px 32px', display: 'flex', gap: 10 }}>
        <window.GhostButton onClick={ctx.back} style={{ flex: 1 }}>
          <window.Icon name="grid" size={15}/> Інші
        </window.GhostButton>
        <window.PrimaryButton onClick={() => ctx.go('analyzing')} style={{ flex: 1.4 }}>
          Аналізувати
        </window.PrimaryButton>
      </div>
    </div>
  );
}

Object.assign(window, { Capture, GenderSelect, Gallery, Preview });
