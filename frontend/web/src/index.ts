import { serve } from 'bun';
import index from './index.html';

const isProduction = process.env.NODE_ENV === 'production';

const server = serve({
  port: 3000,

  ...(isProduction
    ? {
        async fetch(req: Request) {
          const url = new URL(req.url);
          const file = Bun.file(`./${url.pathname}`);

          if (await file.exists()) {
            return new Response(file);
          }

          return new Response(Bun.file('./index.html'));
        }
      }
    : {
        routes: {
          '/*': index
        },
        development: {
          hmr: true,
          console: true
        }
      })
});

console.log(`🚀 Server running at ${server.url}`);
