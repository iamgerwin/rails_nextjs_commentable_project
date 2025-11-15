import './global.css';
import { ReactQueryProvider } from '@/contexts/react-query-provider';
import { AuthProvider } from '@/contexts/auth-context';

export const metadata = {
  title: 'Rails Next.js Commentable Project',
  description: 'Full-stack monorepo with Rails API and Next.js frontend',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        <ReactQueryProvider>
          <AuthProvider>{children}</AuthProvider>
        </ReactQueryProvider>
      </body>
    </html>
  );
}
