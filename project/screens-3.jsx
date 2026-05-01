// screens-3.jsx — Analyzing, Result, Saved, Profile

const { useState: uS3, useEffect: uE3, useRef: uR3 } = React;

// 09 Analyzing — skeleton/loader
function Analyzing({ ctx }) {
  const [stage, setStage] = uS3(0);
  const stages = [
    'Аналіз обличчя',
    'Визначення типу волосся',
    'Підбір сумісності',
    'Готуємо рекомендації',
  ];

  uE3(() => {
    if (stage < stages.length - 1) {
      const t = setTimeout(() => setStage(s => s + 1), 700);
      return () => clearTimeout(t);
    } else {
      const t = setTimeout(() => ctx.go('result'), 800);
      return () => clearTimeout(t);
    }
  }, [stage]);

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      display: 'flex', flexDirection: 'column', padding: '60px 28px 32px', boxSizing: 'border-box',
    }}>
      <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
        <button onClick={ctx.back} style={{
          width: 36, height: 36, borderRadius: 18, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="x" size={16}/>
        </button>
      </div>

      <div style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
        {/* scanning portrait */}
        <div style={{ width: 220, height: 280, position: 'relative', borderRadius: 28, overflow: 'hidden' }}>
          <window.FaceCanvas hair={ctx.selectedStyle?.hue || '#3D2B1F'} tone="medium" size="100%"/>
          {/* scan line */}
          <div style={{
            position: 'absolute', left: 0, right: 0, height: 60,
            background: 'linear-gradient(to bottom, transparent, rgba(255,255,255,0.4), transparent)',
            animation: 'tz-scan 2s linear infinite',
          }}/>
          {/* grid overlay */}
          <svg viewBox="0 0 220 280" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', opacity: 0.4 }}>
            {[60, 120, 180].map(y => <line key={y} x1="20" y1={y} x2="200" y2={y} stroke="#fff" strokeWidth="0.5" strokeDasharray="2 4"/>)}
            {[60, 110, 160].map(x => <line key={x} x1={x} y1="40" x2={x} y2="240" stroke="#fff" strokeWidth="0.5" strokeDasharray="2 4"/>)}
            {/* anchor points */}
            {[[60, 110], [110, 110], [160, 110], [85, 145], [135, 145], [110, 175]].map(([x, y], i) => (
              <circle key={i} cx={x} cy={y} r="3" fill="#fff" style={{ animation: `tz-twinkle 1.6s ${i*0.1}s infinite` }}/>
            ))}
          </svg>
        </div>
      </div>

      <div style={{ marginBottom: 24 }}>
        <div style={{
          fontFamily: window.TOKENS.serif, fontSize: 28, lineHeight: 1.1,
          letterSpacing: -0.8, color: window.TOKENS.ink, marginBottom: 20,
        }}>
          AI <em>аналізує</em><br/>твій тип
        </div>

        {stages.map((s, i) => (
          <div key={i} style={{
            display: 'flex', alignItems: 'center', gap: 12, padding: '10px 0',
            opacity: i > stage ? 0.3 : 1, transition: 'opacity 250ms',
          }}>
            <div style={{
              width: 22, height: 22, borderRadius: 11,
              background: i < stage ? window.TOKENS.ink : 'transparent',
              border: i >= stage ? `1.5px solid ${window.TOKENS.hairlineStrong}` : 'none',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              position: 'relative',
            }}>
              {i < stage && <window.Icon name="check" size={12} stroke="#fff" strokeWidth={2.4}/>}
              {i === stage && (
                <div style={{
                  width: 8, height: 8, borderRadius: 4, background: window.TOKENS.ink,
                  animation: 'tz-pulse-dot 1s ease-in-out infinite',
                }}/>
              )}
            </div>
            <div style={{
              fontFamily: window.TOKENS.sans, fontSize: 14, color: window.TOKENS.ink,
              fontWeight: i === stage ? 600 : 400, letterSpacing: -0.1,
            }}>{s}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// 10 Result — full AI analysis
function Result({ ctx }) {
  const s = ctx.selectedStyle || window.HAIRSTYLES[ctx.gender || 'woman'][0];
  const [score, setScore] = uS3(0);
  const detailed = (ctx.tweaks.analysisStyle || 'detailed') === 'detailed';

  uE3(() => {
    let raf;
    const start = Date.now();
    const tick = () => {
      const t = Math.min(1, (Date.now() - start) / 1400);
      const eased = 1 - Math.pow(1 - t, 3);
      setScore(Math.round(eased * s.match));
      if (t < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [s.match]);

  const breakdown = [
    { label: 'Форма обличчя', value: 92, note: 'Овальна — підходить майже все' },
    { label: 'Тип волосся', value: 85, note: 'Середня густина, легка хвиля' },
    { label: 'Стиль', value: 88, note: 'Узгоджується з твоїм гардеробом' },
    { label: 'Догляд', value: 78, note: '~15 хв ранкового стайлінгу' },
  ];

  const tips = [
    'Текстуруючий спрей надасть бажаний обʼєм біля коренів.',
    'Запитай майстра про точкове філіювання — підкреслить шари.',
    'Використовуй термозахист перед укладкою феном.',
  ];

  const alts = window.HAIRSTYLES[ctx.gender || 'woman'].filter(h => h.id !== s.id).slice(0, 3);

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      overflowY: 'auto', overflowX: 'hidden',
    }}>
      {/* Hero */}
      <div style={{
        padding: '60px 0 0', position: 'relative',
        background: 'linear-gradient(180deg, #EFEAE2 0%, transparent 100%)',
      }}>
        <div style={{ padding: '0 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <button onClick={ctx.back} style={{
            width: 40, height: 40, borderRadius: 20, background: 'rgba(255,255,255,0.7)',
            backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
          }}>
            <window.Icon name="arrow-left" size={18}/>
          </button>
          <div style={{ display: 'flex', gap: 8 }}>
            <button onClick={() => ctx.toggleFavorite(s.id)} style={{
              width: 40, height: 40, borderRadius: 20, background: 'rgba(255,255,255,0.7)',
              backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <window.Icon name={ctx.favorites.has(s.id) ? 'heart-fill' : 'heart'} size={17} stroke={ctx.favorites.has(s.id) ? '#C44' : window.TOKENS.ink}/>
            </button>
            <button style={{
              width: 40, height: 40, borderRadius: 20, background: 'rgba(255,255,255,0.7)',
              backdropFilter: 'blur(10px)', border: 'none', cursor: 'pointer',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}>
              <window.Icon name="share" size={16}/>
            </button>
          </div>
        </div>

        <div style={{ padding: '24px 24px 0' }}>
          <div style={{ fontSize: 11, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase', marginBottom: 8 }}>
            AI-аналіз · повний звіт
          </div>
          <div style={{
            fontFamily: window.TOKENS.serif, fontSize: 36, lineHeight: 1.05, letterSpacing: -1,
            color: window.TOKENS.ink, fontWeight: 400,
          }}>
            <em>{s.name}</em> тобі<br/>{s.match >= 85 ? 'дуже личить' : s.match >= 75 ? 'добре пасує' : 'пасує помірно'}
          </div>
        </div>

        {/* Photo + score ring */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 16, padding: '20px 24px 0' }}>
          <div style={{ width: 130, height: 160, borderRadius: 20, overflow: 'hidden', flexShrink: 0 }}>
            <window.FaceCanvas hair={s.hue} tone="medium" size="100%"/>
          </div>
          <div style={{ flex: 1, position: 'relative' }}>
            <ScoreRing value={score} max={s.match}/>
          </div>
        </div>
      </div>

      {/* Breakdown */}
      <div style={{ padding: '32px 24px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: 14 }}>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 22, letterSpacing: -0.4 }}>
            <em>Розбивка</em> аналізу
          </div>
          <button onClick={() => ctx.setTweak('analysisStyle', detailed ? 'minimal' : 'detailed')} style={{
            background: 'transparent', border: 'none', cursor: 'pointer',
            color: window.TOKENS.muted, fontSize: 12, fontFamily: window.TOKENS.sans,
          }}>{detailed ? 'Компактно' : 'Детально'}</button>
        </div>

        {detailed ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {breakdown.map((b, i) => (
              <div key={i} style={{
                background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
                borderRadius: 18, padding: 16,
              }}>
                <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
                  <div style={{ fontFamily: window.TOKENS.sans, fontSize: 14, fontWeight: 500, color: window.TOKENS.ink }}>{b.label}</div>
                  <div style={{ fontFamily: window.TOKENS.serif, fontSize: 22, color: window.TOKENS.ink, letterSpacing: -0.4 }}>{b.value}<span style={{ fontSize: 12, color: window.TOKENS.muted }}>/100</span></div>
                </div>
                <div style={{ marginTop: 8, height: 4, background: window.TOKENS.surfaceMuted, borderRadius: 2, overflow: 'hidden' }}>
                  <div style={{ width: `${b.value}%`, height: '100%', background: window.TOKENS.ink, transition: 'width 800ms ease-out' }}/>
                </div>
                <div style={{ marginTop: 10, fontSize: 13, color: window.TOKENS.muted, lineHeight: 1.4, letterSpacing: -0.1 }}>{b.note}</div>
              </div>
            ))}
          </div>
        ) : (
          <div style={{
            background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
            borderRadius: 18, padding: 6,
          }}>
            {breakdown.map((b, i) => (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                padding: '14px 14px', borderBottom: i < breakdown.length - 1 ? `1px solid ${window.TOKENS.hairline}` : 'none',
              }}>
                <div style={{ fontSize: 14, color: window.TOKENS.ink, letterSpacing: -0.1 }}>{b.label}</div>
                <div style={{ fontFamily: window.TOKENS.serif, fontSize: 18, color: window.TOKENS.ink, letterSpacing: -0.3 }}>{b.value}<span style={{ fontSize: 11, color: window.TOKENS.muted }}>/100</span></div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Tips */}
      {detailed && (
        <div style={{ padding: '32px 24px 0' }}>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 22, letterSpacing: -0.4, marginBottom: 14 }}>
            <em>Поради</em> від AI
          </div>
          <div style={{
            background: window.TOKENS.ink, color: '#fff', borderRadius: 24, padding: 20,
            position: 'relative', overflow: 'hidden',
          }}>
            <window.Icon name="sparkle" size={24} stroke="#fff" strokeWidth={1.4}/>
            <div style={{ marginTop: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
              {tips.map((t, i) => (
                <div key={i} style={{ display: 'flex', gap: 10 }}>
                  <div style={{ flexShrink: 0, fontFamily: window.TOKENS.serif, fontSize: 18, opacity: 0.4 }}>0{i+1}</div>
                  <div style={{ fontSize: 14, lineHeight: 1.45, opacity: 0.95, letterSpacing: -0.1, textWrap: 'pretty' }}>{t}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Alternatives */}
      <div style={{ padding: '32px 24px 0' }}>
        <div style={{ fontFamily: window.TOKENS.serif, fontSize: 22, letterSpacing: -0.4, marginBottom: 14 }}>
          <em>Альтернативи</em>, що теж личать
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          {alts.map(a => (
            <button key={a.id} onClick={() => { ctx.setSelectedStyle(a); ctx.go('preview'); }} style={{
              flex: 1, background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'left',
              fontFamily: window.TOKENS.sans,
            }}>
              <div style={{ width: '100%', aspectRatio: '0.85', borderRadius: 14, overflow: 'hidden' }}>
                <window.HairGlyph hair={a.hue} length={a.length} shape={a.shape}/>
              </div>
              <div style={{ marginTop: 6, fontSize: 12, color: window.TOKENS.ink, fontWeight: 500, letterSpacing: -0.1 }}>{a.name}</div>
              <div style={{ fontSize: 11, color: window.TOKENS.muted }}>{a.match}% match</div>
            </button>
          ))}
        </div>
      </div>

      {/* CTA */}
      <div style={{ padding: '28px 24px 40px', display: 'flex', gap: 10 }}>
        <window.GhostButton onClick={ctx.back} style={{ flex: 1 }}>Назад</window.GhostButton>
        <window.PrimaryButton onClick={() => {
          ctx.setSaved([{ styleId: s.id, date: 'Щойно' }, ...ctx.saved]);
          ctx.go('saved');
        }} style={{ flex: 1.4 }} icon="heart">
          Зберегти
        </window.PrimaryButton>
      </div>
    </div>
  );
}

function ScoreRing({ value, max }) {
  const r = 38;
  const c = 2 * Math.PI * r;
  const off = c - (value / 100) * c;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
      <div style={{ position: 'relative', width: 100, height: 100 }}>
        <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%', transform: 'rotate(-90deg)' }}>
          <circle cx="50" cy="50" r={r} fill="none" stroke={window.TOKENS.hairline} strokeWidth="6"/>
          <circle cx="50" cy="50" r={r} fill="none" stroke={window.TOKENS.ink} strokeWidth="6"
            strokeLinecap="round" strokeDasharray={c} strokeDashoffset={off}
            style={{ transition: 'stroke-dashoffset 100ms linear' }}/>
        </svg>
        <div style={{
          position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
        }}>
          <div style={{
            fontFamily: window.TOKENS.serif, fontSize: 28, color: window.TOKENS.ink,
            letterSpacing: -1, lineHeight: 1,
          }}>{value}<span style={{ fontSize: 14, opacity: 0.4 }}>%</span></div>
        </div>
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 12, color: window.TOKENS.muted, letterSpacing: 1.2, textTransform: 'uppercase', marginBottom: 4 }}>Загальна оцінка</div>
        <div style={{ fontFamily: window.TOKENS.serif, fontSize: 18, color: window.TOKENS.ink, letterSpacing: -0.3, lineHeight: 1.2 }}>
          {value >= 85 ? 'Сильний матч' : value >= 75 ? 'Хороший вибір' : 'Помірно пасує'}
        </div>
      </div>
    </div>
  );
}

// 11 Saved
function Saved({ ctx }) {
  const allFavs = [...ctx.favorites].map(id => {
    return [...window.HAIRSTYLES.woman, ...window.HAIRSTYLES.man].find(s => s.id === id);
  }).filter(Boolean);

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      overflowY: 'auto', paddingBottom: 110,
    }}>
      <div style={{ padding: '60px 24px 0', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={ctx.back} style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="arrow-left" size={18}/>
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 11, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase' }}>Колекція</div>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 26, letterSpacing: -0.6, color: window.TOKENS.ink }}>
            <em>Обране</em>
          </div>
        </div>
      </div>

      {allFavs.length === 0 ? (
        <EmptyState ctx={ctx}/>
      ) : (
        <div style={{ padding: '20px 24px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
          {allFavs.map(s => (
            <button key={s.id} onClick={() => { ctx.setSelectedStyle(s); ctx.go('preview'); }} style={{
              background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, textAlign: 'left',
              fontFamily: window.TOKENS.sans,
            }}>
              <div style={{ width: '100%', aspectRatio: '0.82', borderRadius: 18, overflow: 'hidden', position: 'relative' }}>
                <window.HairGlyph hair={s.hue} length={s.length} shape={s.shape}/>
                <div style={{
                  position: 'absolute', top: 8, right: 8, width: 28, height: 28, borderRadius: 14,
                  background: 'rgba(255,255,255,0.95)', display: 'flex', alignItems: 'center', justifyContent: 'center',
                }}>
                  <window.Icon name="heart-fill" size={13} stroke="#C44"/>
                </div>
              </div>
              <div style={{ marginTop: 8, fontSize: 14, color: window.TOKENS.ink, fontWeight: 500, letterSpacing: -0.2 }}>{s.name}</div>
              <div style={{ fontSize: 12, color: window.TOKENS.muted }}>{s.match}% match</div>
            </button>
          ))}
        </div>
      )}

      <window.TabBar ctx={ctx} active="saved"/>
    </div>
  );
}

function EmptyState({ ctx }) {
  return (
    <div style={{
      padding: '40px 24px', display: 'flex', flexDirection: 'column', alignItems: 'center',
      textAlign: 'center', gap: 16,
    }}>
      <svg viewBox="0 0 200 160" style={{ width: 200, height: 160 }}>
        <ellipse cx="100" cy="140" rx="70" ry="6" fill={window.TOKENS.hairline}/>
        <path d="M60 80 Q 60 50, 100 50 Q 140 50, 140 80 Q 140 110, 100 130 Q 60 110, 60 80 Z"
          fill="none" stroke={window.TOKENS.hairlineStrong} strokeWidth="1.5" strokeDasharray="4 6"/>
        <path d="M85 70 Q 85 60, 95 60 Q 100 60, 100 65 Q 100 60, 105 60 Q 115 60, 115 70 Q 115 78, 100 90 Q 85 78, 85 70 Z"
          fill={window.TOKENS.surfaceMuted} stroke={window.TOKENS.ink} strokeWidth="1.5"/>
      </svg>
      <div style={{ fontFamily: window.TOKENS.serif, fontSize: 24, letterSpacing: -0.5, color: window.TOKENS.ink }}>
        Поки <em>порожньо</em>
      </div>
      <div style={{ fontSize: 14, color: window.TOKENS.muted, maxWidth: 260, lineHeight: 1.45, textWrap: 'pretty' }}>
        Збережи зачіски, які тобі сподобались, щоб повернутись до них пізніше.
      </div>
      <window.PrimaryButton onClick={() => ctx.go('gender')} style={{ width: 'auto', padding: '0 24px', marginTop: 8 }}>
        Переглянути стилі
      </window.PrimaryButton>
    </div>
  );
}

// 12 Profile
function Profile({ ctx }) {
  const tries = ctx.saved.length + 4;
  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      overflowY: 'auto', paddingBottom: 110,
    }}>
      <div style={{ padding: '60px 24px 0', display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={ctx.back} style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="arrow-left" size={18}/>
        </button>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 11, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase' }}>Профіль</div>
        </div>
        <button style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="settings" size={17}/>
        </button>
      </div>

      <div style={{ padding: '20px 24px 0', display: 'flex', alignItems: 'center', gap: 16 }}>
        <div style={{ width: 76, height: 76, borderRadius: 38, overflow: 'hidden', background: window.TOKENS.surfaceMuted }}>
          <window.FaceCanvas hair="#3D2B1F" tone="medium" size="100%"/>
        </div>
        <div>
          <div style={{ fontFamily: window.TOKENS.serif, fontSize: 28, letterSpacing: -0.6, color: window.TOKENS.ink, lineHeight: 1.1 }}>Олена</div>
          <div style={{ fontSize: 13, color: window.TOKENS.muted, marginTop: 2 }}>З нами 2 місяці · Pro-план</div>
        </div>
      </div>

      {/* Stats */}
      <div style={{ padding: '20px 24px 0', display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
        {[
          { v: tries, l: 'Примірок' },
          { v: ctx.favorites.size, l: 'В обраному' },
          { v: 12, l: 'Аналізів' },
        ].map((st, i) => (
          <div key={i} style={{
            background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
            borderRadius: 16, padding: '14px 12px', textAlign: 'center',
          }}>
            <div style={{ fontFamily: window.TOKENS.serif, fontSize: 26, color: window.TOKENS.ink, letterSpacing: -0.6, lineHeight: 1 }}>{st.v}</div>
            <div style={{ fontSize: 11, color: window.TOKENS.muted, marginTop: 4, letterSpacing: -0.1 }}>{st.l}</div>
          </div>
        ))}
      </div>

      {/* Face profile section */}
      <div style={{ padding: '24px 24px 0' }}>
        <div style={{ fontSize: 11, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase', marginBottom: 10 }}>
          Твій типаж
        </div>
        <div style={{
          background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
          borderRadius: 18, padding: 0, overflow: 'hidden',
        }}>
          {[
            { k: 'Форма обличчя', v: 'Овальна' },
            { k: 'Тип волосся', v: 'Хвилясте, середнє' },
            { k: 'Тон шкіри', v: 'Теплий світлий' },
            { k: 'Колір очей', v: 'Карі' },
          ].map((r, i, arr) => (
            <div key={i} style={{
              display: 'flex', justifyContent: 'space-between', alignItems: 'center',
              padding: '14px 16px',
              borderBottom: i < arr.length - 1 ? `1px solid ${window.TOKENS.hairline}` : 'none',
            }}>
              <div style={{ fontSize: 14, color: window.TOKENS.muted, letterSpacing: -0.1 }}>{r.k}</div>
              <div style={{ fontSize: 14, color: window.TOKENS.ink, fontWeight: 500, letterSpacing: -0.1 }}>{r.v}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Menu */}
      <div style={{ padding: '24px 24px 0' }}>
        <div style={{
          background: window.TOKENS.surface, border: `1px solid ${window.TOKENS.hairline}`,
          borderRadius: 18, overflow: 'hidden',
        }}>
          {[
            { k: 'Сповіщення', icon: 'sparkle' },
            { k: 'Конфіденційність', icon: 'face' },
            { k: 'Підписка', icon: 'heart' },
            { k: 'Допомога', icon: 'check' },
          ].map((r, i, arr) => (
            <button key={i} style={{
              width: '100%', display: 'flex', alignItems: 'center', gap: 14,
              padding: '14px 16px', background: 'transparent', border: 'none', cursor: 'pointer',
              borderBottom: i < arr.length - 1 ? `1px solid ${window.TOKENS.hairline}` : 'none',
              fontFamily: window.TOKENS.sans, textAlign: 'left',
            }}>
              <window.Icon name={r.icon} size={18} stroke={window.TOKENS.muted}/>
              <div style={{ flex: 1, fontSize: 14, color: window.TOKENS.ink, letterSpacing: -0.1 }}>{r.k}</div>
              <window.Icon name="arrow-right" size={14} stroke={window.TOKENS.mutedSoft}/>
            </button>
          ))}
        </div>
      </div>

      <window.TabBar ctx={ctx} active="profile"/>
    </div>
  );
}

Object.assign(window, { Analyzing, Result, Saved, Profile });
