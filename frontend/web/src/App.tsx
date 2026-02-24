import '@/index.css';

import {
  createBrowserRouter,
  Navigate,
  RouterProvider
} from 'react-router-dom';
import { RootLayout } from '@/layouts/RootLayout.tsx';
import { HomePage } from '@/pages/HomePage.tsx';
import { PrivacyPolicyPage } from '@/pages/PrivacyPolicyPage.tsx';

const router = createBrowserRouter([
  {
    path: '/',
    element: <RootLayout />,
    children: [
      {
        index: true,
        element: <HomePage />
      },
      {
        path: 'privacy-policy',
        element: <PrivacyPolicyPage />
      }
    ]
  },
  {
    path: '*',
    element: (
      <Navigate
        to='/'
        replace={true}
      />
    )
  }
]);

export const App = () => (
  <div className='app'>
    <RouterProvider router={router} />
  </div>
);
