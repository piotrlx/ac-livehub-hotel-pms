-- ============================================================
-- LiveHub Hotel Workshop Portal — D1 Database Schema
-- ============================================================

-- Participants (workshop attendees)
CREATE TABLE IF NOT EXISTS participants (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  api_key TEXT NOT NULL UNIQUE,
  created_at TEXT DEFAULT (datetime('now')),
  is_active INTEGER DEFAULT 1
);

-- Rooms
CREATE TABLE IF NOT EXISTS rooms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL CHECK(type IN ('single','double','double_superior','suite','family','penthouse')),
  floor INTEGER NOT NULL,
  price_per_night REAL NOT NULL,
  currency TEXT DEFAULT 'PLN',
  status TEXT DEFAULT 'available' CHECK(status IN ('available','occupied','reserved','cleaning','maintenance','out_of_order')),
  amenities TEXT DEFAULT '[]',         -- JSON array
  description TEXT,
  max_guests INTEGER DEFAULT 2,
  view TEXT DEFAULT 'city'             -- city, sea, garden, pool
);

-- Reservations
CREATE TABLE IF NOT EXISTS reservations (
  id TEXT PRIMARY KEY,
  room_id INTEGER NOT NULL REFERENCES rooms(id),
  guest_name TEXT NOT NULL,
  guest_phone TEXT,
  guest_email TEXT,
  check_in TEXT NOT NULL,
  check_out TEXT NOT NULL,
  guests INTEGER DEFAULT 1,
  status TEXT DEFAULT 'confirmed' CHECK(status IN ('pending','confirmed','checked_in','checked_out','cancelled','no_show')),
  total_price REAL,
  currency TEXT DEFAULT 'PLN',
  special_requests TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  created_by TEXT,                      -- participant api_key or 'admin'
  FOREIGN KEY (room_id) REFERENCES rooms(id)
);

-- Housekeeping requests
CREATE TABLE IF NOT EXISTS housekeeping_requests (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL,
  items TEXT NOT NULL,                  -- JSON array of requested items
  priority TEXT DEFAULT 'normal' CHECK(priority IN ('low','normal','high','urgent')),
  status TEXT DEFAULT 'pending' CHECK(status IN ('pending','in_progress','completed','cancelled')),
  eta_minutes INTEGER,
  assigned_to TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  completed_at TEXT,
  created_by TEXT
);

-- Maintenance tickets
CREATE TABLE IF NOT EXISTS maintenance_tickets (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL,
  category TEXT NOT NULL CHECK(category IN ('hvac','plumbing','electrical','furniture','tv','internet','door_lock','other')),
  description TEXT NOT NULL,
  priority TEXT DEFAULT 'normal' CHECK(priority IN ('low','normal','high','urgent')),
  status TEXT DEFAULT 'open' CHECK(status IN ('open','assigned','in_progress','resolved','closed')),
  technician TEXT,
  eta_minutes INTEGER,
  created_at TEXT DEFAULT (datetime('now')),
  resolved_at TEXT,
  created_by TEXT
);

-- Room service orders
CREATE TABLE IF NOT EXISTS roomservice_orders (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL,
  items TEXT NOT NULL,                  -- JSON array of ordered items
  total_price REAL NOT NULL,
  currency TEXT DEFAULT 'PLN',
  status TEXT DEFAULT 'received' CHECK(status IN ('received','preparing','delivering','delivered','cancelled')),
  delivery_eta_minutes INTEGER,
  special_instructions TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  delivered_at TEXT,
  created_by TEXT
);

-- Room service menu
CREATE TABLE IF NOT EXISTS menu_items (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK(category IN ('breakfast','lunch','dinner','drinks','snacks','desserts')),
  description TEXT,
  price REAL NOT NULL,
  currency TEXT DEFAULT 'PLN',
  available INTEGER DEFAULT 1,
  allergens TEXT DEFAULT '[]'           -- JSON array
);

-- Wake-up calls
CREATE TABLE IF NOT EXISTS wakeup_calls (
  id TEXT PRIMARY KEY,
  room_number TEXT NOT NULL,
  scheduled_time TEXT NOT NULL,
  status TEXT DEFAULT 'scheduled' CHECK(status IN ('scheduled','calling','answered','no_answer','cancelled')),
  conversation_id TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  created_by TEXT
);

-- API call log (for dashboard)
CREATE TABLE IF NOT EXISTS api_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT DEFAULT (datetime('now')),
  participant_id TEXT,
  method TEXT NOT NULL,
  path TEXT NOT NULL,
  status_code INTEGER,
  request_body TEXT,
  response_body TEXT,
  duration_ms INTEGER,
  source TEXT DEFAULT 'rest_tool'       -- rest_tool, webhook, manual, dialout
);

-- Post-call analysis records (from webhook)
CREATE TABLE IF NOT EXISTS call_records (
  id TEXT PRIMARY KEY,
  conversation_id TEXT UNIQUE,
  call_id TEXT,
  caller TEXT,
  callee TEXT,
  start_time TEXT,
  end_time TEXT,
  duration_seconds INTEGER,
  summary TEXT,
  extracted_data TEXT,                   -- JSON
  insights TEXT,                         -- JSON array
  transcript TEXT,                       -- JSON array
  received_at TEXT DEFAULT (datetime('now')),
  participant_id TEXT
);

-- In-call events log (from webhook)
CREATE TABLE IF NOT EXISTS call_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  conversation_id TEXT NOT NULL,
  event_name TEXT NOT NULL,
  event_data TEXT,                       -- JSON
  timestamp TEXT NOT NULL,
  received_at TEXT DEFAULT (datetime('now'))
);

-- Hotel settings
CREATE TABLE IF NOT EXISTS hotel_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_reservations_dates ON reservations(check_in, check_out);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_rooms_status ON rooms(status);
CREATE INDEX IF NOT EXISTS idx_api_logs_timestamp ON api_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_api_logs_participant ON api_logs(participant_id);
CREATE INDEX IF NOT EXISTS idx_call_events_conversation ON call_events(conversation_id);
CREATE INDEX IF NOT EXISTS idx_housekeeping_status ON housekeeping_requests(status);
CREATE INDEX IF NOT EXISTS idx_maintenance_status ON maintenance_tickets(status);
