import { Hono } from 'hono';
import { cors } from 'hono/cors';

type Bindings = {
  DB: D1Database;
  HOTEL_NAME: string;
  HOTEL_ADDRESS: string;
  ENVIRONMENT: string;
};

const app = new Hono<{ Bindings: Bindings }>();

// CORS — allow Live Hub to call our API
app.use('/api/*', cors());

// Health check
app.get('/api/health', (c) => {
  return c.json({ status: 'ok', hotel: c.env.HOTEL_NAME, timestamp: new Date().toISOString() });
});

// TODO: Mount API routes (rooms, reservations, housekeeping, etc.)
// TODO: Mount webhook receivers
// TODO: Auth middleware

export default app;
