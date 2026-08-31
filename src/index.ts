import { Hono } from 'hono';
import { cors } from 'hono/cors';

type Bindings = {
  DB: D1Database;
  HOTEL_NAME: string;
  ADMIN_SECRET: string;
};

type Variables = {
  room_number: string;
};

const app = new Hono<{ Bindings: Bindings; Variables: Variables }>();

app.use('/*', cors());

// Health check
app.get('/api/health', (c) => c.json({ status: 'ok', hotel: c.env.HOTEL_NAME }));

// ==========================================
// MIDDLEWARES
// ==========================================

// Agent Auth (Bearer Token = access_token from rooms)
const agentAuth = async (c: any, next: any) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Missing or invalid token' }, 401);
  }
  const token = authHeader.split(' ')[1];
  
  const room = await c.env.DB.prepare('SELECT number FROM rooms WHERE access_token = ?')
    .bind(token).first<{ number: string }>();

  if (!room) {
    return c.json({ error: 'Unauthorized token' }, 401);
  }
  
  c.set('room_number', room.number);
  await next();
};

// Admin Auth (Bearer Token = ADMIN_SECRET)
const adminAuth = async (c: any, next: any) => {
  const authHeader = c.req.header('Authorization');
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized Admin' }, 401);
  }
  const token = authHeader.split(' ')[1];
  
  if (token !== c.env.ADMIN_SECRET) {
    return c.json({ error: 'Invalid Admin Token' }, 403);
  }
  await next();
};

// Auto-login context based on wildcard subdomain (e.g., 1001.audiocodes.live)
app.get('/api/auth/context', async (c) => {
  const host = c.req.header('Host') || '';
  const match = host.match(/^(\d{4})\./); // Szuka 4 cyfr na początku subdomeny
  
  if (match) {
    const roomNum = match[1];
    const room = await c.env.DB.prepare('SELECT access_token FROM rooms WHERE number = ?')
      .bind(roomNum).first<{ access_token: string }>();
      
    if (room) {
      return c.json({ room: roomNum, token: room.access_token });
    }
  }
  return c.json({ room: null, token: null });
});

// ==========================================
// AI AGENT ENDPOINTS (Requires Agent Auth)
// ==========================================

// 1. Report Maintenance (HVAC global check)
app.post('/api/agent/maintenance', agentAuth, async (c) => {
  const room_number = c.get('room_number');
  const body = await c.req.json();
  const category = body.category || 'other';
  const description = body.description || 'No description';
  
  const ticketId = `MNT-${room_number}-${Math.floor(Math.random() * 1000)}`;

  await c.env.DB.prepare(
    'INSERT INTO maintenance_tickets (id, room_number, category, description) VALUES (?, ?, ?, ?)'
  ).bind(ticketId, room_number, category, description).run();

  // Sprawdzamy czy inne pokoje zglosily juz to samo (global issue)
  const otherTickets = await c.env.DB.prepare(
    'SELECT count(*) as count FROM maintenance_tickets WHERE category = ? AND room_number != ? AND status != ?'
  ).bind(category, room_number, 'resolved').first<{ count: number }>();

  const isGlobalIssue = otherTickets && otherTickets.count > 0;

  return c.json({
    ticket_id: ticketId,
    status: 'open',
    eta_minutes: 30,
    global_issue: isGlobalIssue,
    global_message: isGlobalIssue 
      ? 'Inne pokoje również zgłosiły ten problem. Technicy już nad tym pracują (awaria wielopokojowa).' 
      : 'Przyjęto zgłoszenie. Technik wkrótce się zjawi.'
  }, 201);
});

// 2. Check Maintenance Status
app.get('/api/agent/maintenance/status', agentAuth, async (c) => {
  const room_number = c.get('room_number');
  
  const tickets = await c.env.DB.prepare(
    'SELECT id, category, status, description, technician, created_at FROM maintenance_tickets WHERE room_number = ? ORDER BY created_at DESC LIMIT 1'
  ).bind(room_number).all();

  if (!tickets.results || tickets.results.length === 0) {
    return c.json({ has_active_tickets: false, message: 'Brak aktywnych zgłoszeń.' });
  }

  return c.json({
    has_active_tickets: true,
    ticket: tickets.results[0]
  });
});

// 3. Request Housekeeping
app.post('/api/agent/housekeeping', agentAuth, async (c) => {
  const room_number = c.get('room_number');
  const body = await c.req.json();
  const items = JSON.stringify(body.items || []);

  const requestId = `HK-${room_number}-${Math.floor(Math.random() * 1000)}`;
  
  await c.env.DB.prepare(
    'INSERT INTO housekeeping_requests (id, room_number, items) VALUES (?, ?, ?)'
  ).bind(requestId, room_number, items).run();

  return c.json({
    request_id: requestId,
    status: 'pending',
    eta_minutes: 15,
    message: 'Prośba o serwis sprzątający została przyjęta.'
  }, 201);
});

// 4. Check Housekeeping Status (Do panelu uczestnika i dla Agenta)
app.get('/api/agent/housekeeping/status', agentAuth, async (c) => {
  const room_number = c.get('room_number');
  
  const tickets = await c.env.DB.prepare(
    'SELECT id, items, status, eta_minutes, created_at FROM housekeeping_requests WHERE room_number = ? ORDER BY created_at DESC LIMIT 1'
  ).bind(room_number).all();

  if (!tickets.results || tickets.results.length === 0) {
    return c.json({ has_active_requests: false });
  }

  return c.json({ has_active_requests: true, ticket: tickets.results[0] });
});

// ==========================================
// ADMIN ENDPOINTS (Requires Admin Auth)
// ==========================================

// 1. Get all rooms/participants
app.get('/api/admin/rooms', adminAuth, async (c) => {
  const rooms = await c.env.DB.prepare('SELECT * FROM rooms ORDER BY number ASC').all();
  return c.json(rooms.results);
});

// 2. Create a new participant room dynamically
app.post('/api/admin/rooms', adminAuth, async (c) => {
  const body = await c.req.json();
  const email = body.participant_email || 'brak@email.pl';
  const name = body.participant_name || 'Nowy Uczestnik';
  
  // Znajdź najwyższy numer pokoju i dodaj 1 (zaczynamy od 1000)
  const maxRoom = await c.env.DB.prepare('SELECT MAX(CAST(number as INTEGER)) as max_num FROM rooms').first<{ max_num: number }>();
  const nextNum = (maxRoom && maxRoom.max_num >= 1001) ? maxRoom.max_num + 1 : 1001;
  const roomNumberStr = nextNum.toString();
  
  // Wygeneruj numer tel (np. +48 111 222 {number})
  const phoneNumber = `+48111222${roomNumberStr.substring(roomNumberStr.length - 3)}`;
  
  // Token
  const token = `wk-${roomNumberStr}-${Math.random().toString(36).substr(2, 6)}`;
  
  await c.env.DB.prepare(`
    INSERT INTO rooms (number, phone_number, participant_email, participant_name, access_token) 
    VALUES (?, ?, ?, ?, ?)
  `).bind(roomNumberStr, phoneNumber, email, name, token).run();

  return c.json({ message: 'Room created', number: roomNumberStr, token, phone_number: phoneNumber }, 201);
});

// 3. Delete a room
app.delete('/api/admin/rooms/:number', adminAuth, async (c) => {
  const number = c.req.param('number');
  
  // Kasujemy pokój (i w idealnym świecie powiązane z nim tickety)
  await c.env.DB.prepare('DELETE FROM rooms WHERE number = ?').bind(number).run();
  
  return c.json({ message: `Pokój ${number} usunięty.` });
});

// 4. Get all active tickets (Maintenance + Housekeeping)
app.get('/api/admin/tickets', adminAuth, async (c) => {
  const maintenance = await c.env.DB.prepare('SELECT * FROM maintenance_tickets ORDER BY created_at DESC').all();
  const housekeeping = await c.env.DB.prepare('SELECT * FROM housekeeping_requests ORDER BY created_at DESC').all();
  
  return c.json({
    maintenance: maintenance.results,
    housekeeping: housekeeping.results
  });
});

// 5. Change ticket status manually
app.put('/api/admin/tickets/:type/:id', adminAuth, async (c) => {
  const type = c.req.param('type');
  const id = c.req.param('id');
  const { status } = await c.req.json();

  if (type === 'maintenance') {
    await c.env.DB.prepare('UPDATE maintenance_tickets SET status = ? WHERE id = ?').bind(status, id).run();
  } else if (type === 'housekeeping') {
    await c.env.DB.prepare('UPDATE housekeeping_requests SET status = ? WHERE id = ?').bind(status, id).run();
  } else {
    return c.json({ error: 'Invalid ticket type' }, 400);
  }

  return c.json({ message: 'Status zaktualizowany' });
});

export default app;
