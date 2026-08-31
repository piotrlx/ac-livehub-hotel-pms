-- ============================================================
-- LiveHub Hotel Workshop Portal — D1 Database Schema
-- ============================================================

-- Rooms (Now representing a Workshop Participant's Domain)
CREATE TABLE IF NOT EXISTS rooms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number TEXT NOT NULL UNIQUE,          -- 4-digit room number, e.g., '1001'
  phone_number TEXT UNIQUE,             -- E.164 format, e.g., '+48111222333'
  participant_email TEXT,               -- E-mail of the workshop participant
  participant_name TEXT,                -- Name of the participant
  access_token TEXT UNIQUE,             -- API Key & Login Token for the participant
  
  -- Physical room details
  type TEXT NOT NULL DEFAULT 'double',
  price_per_night REAL DEFAULT 350.0,
  currency TEXT DEFAULT 'PLN',
  status TEXT DEFAULT 'available' CHECK(status IN ('available','occupied','reserved','cleaning','maintenance','out_of_order')),
  amenities TEXT DEFAULT '["wifi","tv","minibar","ac"]', -- JSON array
  description TEXT,
  
  created_at TEXT DEFAULT (datetime('now'))
);

-- Reservations
CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL REFERENCES rooms(number),
  guest_name TEXT NOT NULL,
  guest_phone TEXT,
  check_in TEXT NOT NULL,
  check_out TEXT NOT NULL,
  guests INTEGER DEFAULT 1,
  status TEXT DEFAULT 'confirmed' CHECK(status IN ('pending','confirmed','checked_in','checked_out','cancelled')),
  total_price REAL,
  currency TEXT DEFAULT 'PLN',
  created_at TEXT DEFAULT (datetime('now'))
);

-- Housekeeping requests
CREATE TABLE IF NOT EXISTS housekeeping_requests (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL REFERENCES rooms(number),
  items TEXT NOT NULL,                  -- JSON array of requested items
  status TEXT DEFAULT 'pending' CHECK(status IN ('pending','in_progress','completed','cancelled')),
  eta_minutes INTEGER DEFAULT 15,
  created_at TEXT DEFAULT (datetime('now')),
  completed_at TEXT
);

-- Maintenance tickets
CREATE TABLE IF NOT EXISTS maintenance_tickets (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL REFERENCES rooms(number),
  category TEXT NOT NULL CHECK(category IN ('hvac','plumbing','electrical','other')),
  description TEXT NOT NULL,
  status TEXT DEFAULT 'open' CHECK(status IN ('open','in_progress','resolved')),
  technician TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  resolved_at TEXT
);

-- Room service orders
CREATE TABLE IF NOT EXISTS roomservice_orders (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL REFERENCES rooms(number),
  items TEXT NOT NULL,                  -- JSON array of ordered items
  total_price REAL NOT NULL,
  status TEXT DEFAULT 'received' CHECK(status IN ('received','preparing','delivered')),
  created_at TEXT DEFAULT (datetime('now'))
);

-- API call log (for dashboard to show real-time agent activity)
CREATE TABLE IF NOT EXISTS api_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT DEFAULT (datetime('now')),
  room_number TEXT,
  method TEXT NOT NULL,
  path TEXT NOT NULL,
  request_body TEXT,
  response_body TEXT,
  status_code INTEGER
);

-- Post-call records (Webhooks)
CREATE TABLE IF NOT EXISTS call_records (
  id TEXT PRIMARY KEY,
  room_number TEXT,
  conversation_id TEXT UNIQUE,
  summary TEXT,
  extracted_data TEXT,                   -- JSON
  transcript TEXT,                       -- JSON
  received_at TEXT DEFAULT (datetime('now'))
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_rooms_token ON rooms(access_token);
CREATE INDEX IF NOT EXISTS idx_reservations_room ON reservations(room_number);
CREATE INDEX IF NOT EXISTS idx_housekeeping_room ON housekeeping_requests(room_number);
CREATE INDEX IF NOT EXISTS idx_maintenance_room ON maintenance_tickets(room_number);
CREATE INDEX IF NOT EXISTS idx_api_logs_room ON api_logs(room_number);
