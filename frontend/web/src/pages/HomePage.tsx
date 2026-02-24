import Phone from '@/assets/phone.webp';

type HomePageContent = {
  title: string;
  subtitle: string;
  imageAlt: string;
  playStoreUrl: string;
};

const content: HomePageContent = {
  title: 'Trenero',
  subtitle:
    'Trenero is a comprehensive management platform designed to help independent trainers, coaches, and tutors streamline their business operations. By centralizing student coordination, scheduling, and financial tracking, it allows professionals to focus on training rather than administration.',
  imageAlt: 'Trenero App Interface Preview',
  playStoreUrl: 'https://play.google.com/store/apps/details?id=APP_ID'
};

export const HomePage = () => (
  <div
    style={{
      maxWidth: '800px',
      margin: '0 auto',
      textAlign: 'center',
      fontFamily: 'system-ui, sans-serif',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
      alignItems: 'center',
      gap: '1rem'
    }}
  >
    <h1 style={{ fontSize: '3.5rem', color: '#1a1a1a' }}>{content.title}</h1>

    <p
      style={{
        fontSize: '1.2rem',
        color: '#666',
        lineHeight: '1.6'
      }}
    >
      {content.subtitle}
    </p>

    <div
      style={{
        maxWidth: '30vh',
        overflow: 'hidden'
      }}
    >
      <img
        src={Phone}
        alt={content.imageAlt}
        style={{ width: '100%', display: 'block' }}
      />
    </div>

    <div style={{ marginBottom: '3rem' }}>
      <a
        href={content.playStoreUrl}
        target='_blank'
        rel='noopener noreferrer'
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          backgroundColor: '#000',
          color: '#fff',
          padding: '12px 24px',
          borderRadius: '8px',
          textDecoration: 'none',
          fontWeight: '600',
          fontSize: '1rem',
          transition: 'transform 0.2s'
        }}
      >
        <span>Get it on Google Play</span>
      </a>
    </div>
  </div>
);
