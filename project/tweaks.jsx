// tweaks.jsx — Tweaks panel for the prototype

function Tweaks({ tweaks, setTweak, ctx }) {
  return (
    <window.TweaksPanel title="Tweaks">
      <window.TweakSection title="Галерея">
        <window.TweakRadio
          label="Layout"
          value={tweaks.galleryLayout}
          onChange={(v) => setTweak('galleryLayout', v)}
          options={[
            { value: 'grid', label: 'Grid' },
            { value: 'carousel', label: 'Carousel' },
            { value: 'list', label: 'List' },
          ]}
        />
      </window.TweakSection>

      <window.TweakSection title="AI-аналіз">
        <window.TweakRadio
          label="Стиль звіту"
          value={tweaks.analysisStyle}
          onChange={(v) => setTweak('analysisStyle', v)}
          options={[
            { value: 'minimal', label: 'Мінімал' },
            { value: 'detailed', label: 'Детальний' },
          ]}
        />
      </window.TweakSection>

      <window.TweakSection title="Швидкий перехід">
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 6 }}>
          {[
            ['splash', '01 Splash'],
            ['onboard', '02 Onboard'],
            ['permission', '03 Permission'],
            ['home', '04 Home'],
            ['capture', '05 Camera'],
            ['gender', '06 Gender'],
            ['hairquiz', '07 Quiz'],
            ['gallery', '08 Gallery'],
            ['preview', '09 Preview'],
            ['analyzing', '10 Analyzing'],
            ['result', '11 Result'],
            ['saved', '12 Saved'],
            ['profile', '13 Profile'],
          ].map(([id, label]) => (
            <button key={id} onClick={() => ctx.go(id)} style={{
              padding: '8px 10px', borderRadius: 10, border: '1px solid rgba(0,0,0,0.1)',
              background: ctx.screen === id ? '#0F0F0E' : '#fff',
              color: ctx.screen === id ? '#fff' : '#0F0F0E',
              fontSize: 11, fontWeight: 500, cursor: 'pointer',
              fontFamily: '-apple-system, system-ui',
            }}>{label}</button>
          ))}
        </div>
      </window.TweakSection>
    </window.TweaksPanel>
  );
}

window.Tweaks = Tweaks;
