// hair-quiz.jsx — Hair-type questionnaire screen

const { useState: uSQ } = React;

function HairQuiz({ ctx }) {
  const [step, setStep] = uSQ(0);
  const [profile, setProfile] = uSQ(ctx.hairProfile || {});

  const questions = [
    {
      key: 'texture',
      title: 'Яка текстура волосся?',
      sub: 'Коли волосся висихає природно — як воно лежить?',
      options: [
        { v: 'straight', label: 'Прямі', desc: 'Без хвиль, гладкі' },
        { v: 'wavy', label: 'Хвилясті', desc: 'Легка S-форма' },
        { v: 'curly', label: 'Кучеряві', desc: 'Виражені кучері' },
        { v: 'coily', label: 'Спіральні', desc: 'Тугі завитки' },
      ],
    },
    {
      key: 'thickness',
      title: 'Густина волосся?',
      sub: 'Зроби хвостик — наскільки він товстий?',
      options: [
        { v: 'thin', label: 'Тонке', desc: 'Хвостик ~1.5 см' },
        { v: 'medium', label: 'Середнє', desc: 'Хвостик ~2.5 см' },
        { v: 'thick', label: 'Густе', desc: 'Хвостик 4+ см' },
      ],
    },
    {
      key: 'porosity',
      title: 'Як швидко волосся вбирає воду?',
      sub: 'Це впливає на стайлінг і вибір продуктів',
      options: [
        { v: 'low', label: 'Повільно', desc: 'Волосся вологе довго' },
        { v: 'normal', label: 'Нормально', desc: 'Висихає за 1–2 год' },
        { v: 'high', label: 'Швидко', desc: 'Висихає миттєво, пушиться' },
      ],
    },
    {
      key: 'faceShape',
      title: 'Форма обличчя',
      sub: 'AI підтвердить, але обери що тобі ближче',
      options: [
        { v: 'oval', label: 'Овальна', desc: 'Збалансована' },
        { v: 'round', label: 'Кругла', desc: 'Мʼякі лінії' },
        { v: 'square', label: 'Квадратна', desc: 'Виразна щелепа' },
        { v: 'heart', label: 'Серце', desc: 'Широке чоло' },
        { v: 'long', label: 'Видовжена', desc: 'Висока та вузька' },
      ],
    },
    {
      key: 'timeStyling',
      title: 'Скільки часу на укладку зранку?',
      sub: 'Підбираємо стилі під твій ритм',
      options: [
        { v: '<5', label: '< 5 хв', desc: 'Помив — пішов' },
        { v: '5-15', label: '5–15 хв', desc: 'Швидкий стайлінг' },
        { v: '15-30', label: '15–30 хв', desc: 'Завжди акуратно' },
        { v: '30+', label: '30+ хв', desc: 'Стиль = ритуал' },
      ],
    },
  ];

  const q = questions[step];
  const selected = profile[q.key];

  const next = () => {
    if (step < questions.length - 1) setStep(s => s + 1);
    else {
      ctx.setHairProfile(profile);
      ctx.go('gallery');
    }
  };

  const skip = () => {
    ctx.setHairProfile(profile);
    ctx.go('gallery');
  };

  return (
    <div style={{
      width: '100%', height: '100%', background: window.TOKENS.bg,
      display: 'flex', flexDirection: 'column',
      padding: '60px 24px 32px', boxSizing: 'border-box',
    }}>
      {/* Top: back + progress + skip */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <button onClick={() => step === 0 ? ctx.back() : setStep(s => s - 1)} style={{
          width: 40, height: 40, borderRadius: 20, background: window.TOKENS.surfaceMuted,
          border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
        }}>
          <window.Icon name="arrow-left" size={18}/>
        </button>
        <div style={{ flex: 1, display: 'flex', gap: 4 }}>
          {questions.map((_, i) => (
            <div key={i} style={{
              flex: 1, height: 3, borderRadius: 2,
              background: i <= step ? window.TOKENS.ink : window.TOKENS.hairlineStrong,
              transition: 'background 250ms',
            }}/>
          ))}
        </div>
        <button onClick={skip} style={{
          background: 'transparent', border: 'none', color: window.TOKENS.muted,
          fontFamily: window.TOKENS.sans, fontSize: 13, cursor: 'pointer',
        }}>Пропустити</button>
      </div>

      {/* Step indicator */}
      <div style={{ marginTop: 28, fontSize: 11, color: window.TOKENS.muted, letterSpacing: 1.5, textTransform: 'uppercase' }}>
        Крок {step + 1} з {questions.length}
      </div>

      {/* Question */}
      <div key={`q-${step}`} style={{ marginTop: 8, animation: 'tz-fade-up 350ms ease-out' }}>
        <div style={{
          fontFamily: window.TOKENS.serif, fontSize: 32, lineHeight: 1.05,
          letterSpacing: -0.9, color: window.TOKENS.ink, marginBottom: 8,
        }}>{q.title}</div>
        <div style={{ fontSize: 14, color: window.TOKENS.muted, lineHeight: 1.4, letterSpacing: -0.1 }}>
          {q.sub}
        </div>
      </div>

      {/* Options */}
      <div key={`o-${step}`} style={{
        flex: 1, marginTop: 24, display: 'flex', flexDirection: 'column', gap: 8, overflowY: 'auto',
        animation: 'tz-fade-up 400ms ease-out 60ms backwards',
      }}>
        {q.options.map(o => {
          const active = selected === o.v;
          return (
            <button key={o.v} onClick={() => setProfile(p => ({ ...p, [q.key]: o.v }))} style={{
              background: active ? window.TOKENS.ink : window.TOKENS.surface,
              color: active ? '#fff' : window.TOKENS.ink,
              border: `1px solid ${active ? window.TOKENS.ink : window.TOKENS.hairline}`,
              borderRadius: 18, padding: '16px 18px', cursor: 'pointer',
              display: 'flex', alignItems: 'center', gap: 14, textAlign: 'left',
              fontFamily: window.TOKENS.sans, transition: 'all 180ms ease',
            }}>
              <QuizGlyph kind={q.key} v={o.v} active={active}/>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 16, fontWeight: 500, letterSpacing: -0.2 }}>{o.label}</div>
                <div style={{ fontSize: 12, opacity: active ? 0.7 : 0.55, marginTop: 2 }}>{o.desc}</div>
              </div>
              <div style={{
                width: 22, height: 22, borderRadius: 11,
                border: `1.5px solid ${active ? '#fff' : window.TOKENS.hairlineStrong}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {active && <window.Icon name="check" size={12} stroke="#fff" strokeWidth={2.5}/>}
              </div>
            </button>
          );
        })}
      </div>

      {/* Continue */}
      <div style={{ marginTop: 16 }}>
        <window.PrimaryButton onClick={next} icon="arrow-right">
          {step < questions.length - 1 ? 'Далі' : 'Готово'}
        </window.PrimaryButton>
      </div>
    </div>
  );
}

// Tiny visual icon per quiz answer — schematic, not iconographic clipart
function QuizGlyph({ kind, v, active }) {
  const c = active ? '#fff' : window.TOKENS.ink;
  const dim = active ? 'rgba(255,255,255,0.3)' : window.TOKENS.hairline;
  const size = 44;
  return (
    <svg width={size} height={size} viewBox="0 0 44 44" style={{ flexShrink: 0 }}>
      <rect width="44" height="44" rx="12" fill={dim}/>
      {kind === 'texture' && {
        straight: <g><path d="M14 10 L 14 34 M 22 10 L 22 34 M 30 10 L 30 34" stroke={c} strokeWidth="1.6" strokeLinecap="round"/></g>,
        wavy:     <g><path d="M14 10 Q 18 16, 14 22 Q 10 28, 14 34 M 22 10 Q 26 16, 22 22 Q 18 28, 22 34 M 30 10 Q 34 16, 30 22 Q 26 28, 30 34" stroke={c} strokeWidth="1.6" fill="none" strokeLinecap="round"/></g>,
        curly:    <g><path d="M14 10 Q 20 14, 14 18 Q 8 22, 14 26 Q 20 30, 14 34 M 26 10 Q 32 14, 26 18 Q 20 22, 26 26 Q 32 30, 26 34" stroke={c} strokeWidth="1.6" fill="none" strokeLinecap="round"/></g>,
        coily:    <g>{[12,18,24,30].map(y => <circle key={y} cx="16" cy={y+2} r="3" fill="none" stroke={c} strokeWidth="1.6"/>)}{[12,18,24,30].map(y => <circle key={`b${y}`} cx="28" cy={y+2} r="3" fill="none" stroke={c} strokeWidth="1.6"/>)}</g>,
      }[v]}
      {kind === 'thickness' && {
        thin:   <rect x="20" y="10" width="4" height="24" rx="2" fill={c}/>,
        medium: <rect x="18" y="10" width="8" height="24" rx="3" fill={c}/>,
        thick:  <rect x="14" y="10" width="16" height="24" rx="4" fill={c}/>,
      }[v]}
      {kind === 'porosity' && {
        low:    <g><path d="M22 8 L 28 18 Q 28 24, 22 24 Q 16 24, 16 18 Z" fill={c}/><path d="M22 28 L 22 36" stroke={c} strokeWidth="1.6"/></g>,
        normal: <g><path d="M22 8 L 28 18 Q 28 24, 22 24 Q 16 24, 16 18 Z" fill={c}/><path d="M22 28 L 22 32 M 18 30 L 18 34 M 26 30 L 26 34" stroke={c} strokeWidth="1.6" strokeLinecap="round"/></g>,
        high:   <g><path d="M22 8 L 28 18 Q 28 24, 22 24 Q 16 24, 16 18 Z" fill={c}/>{[14,18,22,26,30].map(x => <path key={x} d={`M${x} 28 L ${x} 36`} stroke={c} strokeWidth="1.6" strokeLinecap="round"/>)}</g>,
      }[v]}
      {kind === 'faceShape' && {
        oval:   <ellipse cx="22" cy="22" rx="9" ry="12" fill="none" stroke={c} strokeWidth="1.6"/>,
        round:  <circle cx="22" cy="22" r="11" fill="none" stroke={c} strokeWidth="1.6"/>,
        square: <rect x="12" y="12" width="20" height="20" rx="3" fill="none" stroke={c} strokeWidth="1.6"/>,
        heart:  <path d="M22 33 L 12 22 Q 12 14, 17 14 Q 22 14, 22 18 Q 22 14, 27 14 Q 32 14, 32 22 Z" fill="none" stroke={c} strokeWidth="1.6" strokeLinejoin="round"/>,
        long:   <ellipse cx="22" cy="22" rx="7" ry="13" fill="none" stroke={c} strokeWidth="1.6"/>,
      }[v]}
      {kind === 'timeStyling' && (
        <g>
          <circle cx="22" cy="22" r="11" fill="none" stroke={c} strokeWidth="1.6"/>
          <path d={`M22 22 L 22 ${22 - {'<5':6,'5-15':8,'15-30':9,'30+':10}[v]} M 22 22 L ${22 + {'<5':4,'5-15':2,'15-30':-3,'30+':-7}[v]} ${22 + {'<5':6,'5-15':5,'15-30':5,'30+':3}[v]}`} stroke={c} strokeWidth="1.8" strokeLinecap="round"/>
        </g>
      )}
    </svg>
  );
}

window.HairQuiz = HairQuiz;
