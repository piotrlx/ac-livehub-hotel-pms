-- ============================================================
-- Seed data — Workshop Rooms
-- ============================================================

-- Create 5 sample participant rooms
INSERT OR REPLACE INTO rooms (number, phone_number, participant_email, participant_name, access_token, type, status) VALUES
  ('1001', '+48111222001', 'jan.kowalski@example.com', 'Jan Kowalski', 'wk-1001-a1b2c3', 'double', 'occupied'),
  ('1002', '+48111222002', 'anna.nowak@example.com', 'Anna Nowak', 'wk-1002-d4e5f6', 'double_superior', 'occupied'),
  ('1003', '+48111222003', 'piotr.wisniewski@example.com', 'Piotr Wiśniewski', 'wk-1003-g7h8i9', 'suite', 'available'),
  ('1004', '+48111222004', 'maria.wojcik@example.com', 'Maria Wójcik', 'wk-1004-j0k1l2', 'double', 'occupied'),
  ('1005', '+48111222005', 'tomasz.kaminski@example.com', 'Tomasz Kamiński', 'wk-1005-m3n4o5', 'single', 'available');

-- Sample Reservation for Room 1001
INSERT OR REPLACE INTO reservations (id, room_number, guest_name, check_in, check_out, status, total_price) VALUES
  ('RES-2026-1001', '1001', 'Jan Kowalski (Gość)', '2026-08-30', '2026-09-02', 'checked_in', 1050);

-- Pre-existing Maintenance Ticket (To simulate global HVAC issue)
INSERT OR REPLACE INTO maintenance_tickets (id, room_number, category, description, status, technician) VALUES
  ('MNT-1002-01', '1002', 'hvac', 'Klimatyzacja nie chłodzi', 'in_progress', 'Marek K.');
