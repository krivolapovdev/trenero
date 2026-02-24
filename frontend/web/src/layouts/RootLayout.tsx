import { Link, Outlet } from 'react-router-dom';

type NavItem = {
  label: string;
  path: string;
};

const navItems: NavItem[] = [
  { label: 'Home', path: '/' },
  { label: 'Privacy Policy', path: '/privacy-policy' }
];

export const RootLayout = () => (
  <div>
    <nav>
      <ul
        style={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          gap: '20px',
          listStyle: 'none',
          padding: '1rem',
          fontFamily: 'sans-serif'
        }}
      >
        {navItems.map(item => (
          <li key={item.path}>
            <Link
              to={item.path}
              style={{
                textDecoration: 'none',
                color: 'inherit',
                fontWeight: 'bold'
              }}
            >
              {item.label}
            </Link>
          </li>
        ))}
      </ul>
    </nav>

    <main style={{ padding: '1rem' }}>
      <Outlet />
    </main>
  </div>
);
