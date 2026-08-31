-- ============================================================
-- Seed data — realistic hotel setup for workshops
-- ============================================================

-- Hotel settings
INSERT OR REPLACE INTO hotel_settings (key, value) VALUES
  ('hotel_name', 'Grand Hotel Warszawa'),
  ('hotel_address', 'ul. Marszałkowska 1, 00-001 Warszawa'),
  ('hotel_phone', '+48 22 123 4000'),
  ('hotel_email', 'recepcja@grandhotel.pl'),
  ('check_in_time', '15:00'),
  ('check_out_time', '11:00'),
  ('late_checkout_fee', '150'),
  ('late_checkout_max', '14:00'),
  ('currency', 'PLN'),
  ('breakfast_hours', '07:00-10:30'),
  ('pool_hours', '06:00-22:00'),
  ('spa_hours', '09:00-21:00'),
  ('gym_hours', '06:00-23:00'),
  ('restaurant_hours', '12:00-22:30'),
  ('bar_hours', '16:00-01:00'),
  ('parking_price_per_day', '80'),
  ('wifi_password', 'GrandHotel2026'),
  ('roomservice_hours', '06:00-23:00');

-- Rooms — 5 floors, mix of types
INSERT OR REPLACE INTO rooms (number, type, floor, price_per_night, status, amenities, description, max_guests, view) VALUES
  -- Floor 1 (ground)
  ('101', 'single', 1, 220, 'available', '["wifi","tv","minibar"]', 'Pokój jednoosobowy Standard', 1, 'city'),
  ('102', 'single', 1, 220, 'occupied', '["wifi","tv","minibar"]', 'Pokój jednoosobowy Standard', 1, 'city'),
  ('103', 'double', 1, 350, 'available', '["wifi","tv","minibar","safe"]', 'Pokój dwuosobowy Standard', 2, 'city'),
  ('104', 'double', 1, 350, 'available', '["wifi","tv","minibar","safe"]', 'Pokój dwuosobowy Standard', 2, 'garden'),
  ('105', 'family', 1, 520, 'reserved', '["wifi","tv","minibar","safe","crib"]', 'Pokój rodzinny z łóżeczkiem', 4, 'garden'),
  -- Floor 2
  ('201', 'single', 2, 250, 'available', '["wifi","tv","minibar","balcony"]', 'Pokój jednoosobowy z balkonem', 1, 'city'),
  ('202', 'double', 2, 380, 'occupied', '["wifi","tv","minibar","safe","balcony"]', 'Pokój dwuosobowy z balkonem', 2, 'city'),
  ('203', 'double', 2, 380, 'available', '["wifi","tv","minibar","safe","balcony"]', 'Pokój dwuosobowy z balkonem', 2, 'garden'),
  ('204', 'double_superior', 2, 450, 'available', '["wifi","tv","minibar","safe","balcony","bathrobe","slippers"]', 'Pokój Superior z widokiem na ogród', 2, 'garden'),
  ('205', 'double_superior', 2, 480, 'occupied', '["wifi","tv","minibar","safe","balcony","bathrobe","slippers"]', 'Pokój Superior z widokiem na morze', 2, 'sea'),
  -- Floor 3
  ('301', 'double', 3, 400, 'available', '["wifi","tv","minibar","safe","balcony"]', 'Pokój dwuosobowy Premium', 2, 'sea'),
  ('302', 'double_superior', 3, 480, 'cleaning', '["wifi","tv","minibar","safe","balcony","bathrobe","slippers","nespresso"]', 'Pokój Superior Premium', 2, 'sea'),
  ('303', 'suite', 3, 750, 'available', '["wifi","tv","minibar","safe","balcony","bathrobe","slippers","nespresso","jacuzzi"]', 'Apartament z jacuzzi', 2, 'sea'),
  ('304', 'family', 3, 580, 'available', '["wifi","tv","minibar","safe","balcony","crib","playarea"]', 'Pokój rodzinny Premium', 4, 'garden'),
  -- Floor 4
  ('401', 'suite', 4, 850, 'available', '["wifi","tv","minibar","safe","terrace","bathrobe","slippers","nespresso","jacuzzi","champagne"]', 'Apartament Deluxe z tarasem', 2, 'sea'),
  ('402', 'suite', 4, 850, 'reserved', '["wifi","tv","minibar","safe","terrace","bathrobe","slippers","nespresso","jacuzzi","champagne"]', 'Apartament Deluxe z tarasem', 2, 'sea'),
  -- Floor 5 (penthouse)
  ('501', 'penthouse', 5, 1500, 'available', '["wifi","tv","minibar","safe","terrace","bathrobe","slippers","nespresso","jacuzzi","champagne","sauna","butler"]', 'Penthouse z sauną i obsługą butlera', 4, 'sea');

-- Sample reservations
INSERT OR REPLACE INTO reservations (id, room_id, guest_name, guest_phone, check_in, check_out, guests, status, total_price, special_requests, created_by) VALUES
  ('RES-2026-0001', 2, 'Anna Nowak', '+48602111222', '2026-08-30', '2026-09-02', 1, 'checked_in', 880, 'Poduszka hipoalergiczna', 'admin'),
  ('RES-2026-0002', 7, 'Marek Wiśniewski', '+48603222333', '2026-08-31', '2026-09-03', 2, 'checked_in', 1140, NULL, 'admin'),
  ('RES-2026-0003', 10, 'Tomasz Kowalski', '+48604333444', '2026-08-29', '2026-09-01', 2, 'checked_in', 1920, 'Późny check-out jeśli możliwe', 'admin'),
  ('RES-2026-0004', 5, 'Katarzyna Zielińska', '+48605444555', '2026-09-01', '2026-09-05', 3, 'confirmed', 2080, 'Łóżeczko dziecięce przygotowane', 'admin'),
  ('RES-2026-0005', 16, 'James Smith', '+44770555666', '2026-09-02', '2026-09-04', 2, 'confirmed', 1700, 'Anniversary — champagne and flowers', 'admin');

-- Menu items
INSERT OR REPLACE INTO menu_items (id, name, category, description, price, allergens) VALUES
  -- Breakfast
  ('B01', 'Śniadanie kontynentalne', 'breakfast', 'Pieczywo, wędliny, sery, warzywa, kawa/herbata', 45, '["gluten","dairy"]'),
  ('B02', 'Śniadanie angielskie', 'breakfast', 'Jajka, bekon, kiełbaski, fasola, tosty', 55, '["gluten","eggs"]'),
  ('B03', 'Pancakes z owocami', 'breakfast', 'Puszyste naleśniki z owocami sezonowymi i syropem klonowym', 38, '["gluten","eggs","dairy"]'),
  ('B04', 'Owsianka z owocami', 'breakfast', 'Owsianka na mleku z miodem i sezonowymi owocami', 32, '["dairy","gluten"]'),
  -- Lunch/Dinner
  ('D01', 'Krem z pomidorów', 'dinner', 'Kremowa zupa pomidorowa z grzankami i bazylią', 28, '["gluten","dairy"]'),
  ('D02', 'Rosół z makaronem', 'dinner', 'Tradycyjny rosół z domowym makaronem', 25, '["gluten"]'),
  ('D03', 'Żurek w chlebku', 'dinner', 'Żurek z jajkiem i białą kiełbasą podany w chlebku', 32, '["gluten","eggs"]'),
  ('D10', 'Stek wołowy 300g', 'dinner', 'Stek z polędwicy wołowej z frytkami truflowymi i masłem czosnkowym', 89, '["dairy"]'),
  ('D11', 'Łosoś grillowany', 'dinner', 'Filet z łososia z warzywami grillowanymi i sosem holenderskim', 72, '["fish","dairy","eggs"]'),
  ('D12', 'Risotto z grzybami', 'dinner', 'Risotto z borowikami i parmezanem', 55, '["dairy"]'),
  ('D13', 'Pierogi ruskie', 'dinner', 'Pierogi z serem i ziemniakami, podane ze śmietaną i cebulką', 38, '["gluten","dairy"]'),
  ('D14', 'Kaczka z jabłkami', 'dinner', 'Pieczona kaczka z karmelizowanymi jabłkami i modrą kapustą', 78, '[]'),
  ('D15', 'Burger Grand Hotel', 'dinner', 'Burger wołowy 200g z serem cheddar, bekonem i frytkami', 48, '["gluten","dairy"]'),
  -- Drinks
  ('K01', 'Kawa czarna / Espresso', 'drinks', 'Lavazza Premium', 15, '[]'),
  ('K02', 'Cappuccino / Latte', 'drinks', 'Kawa z mlekiem', 18, '["dairy"]'),
  ('K03', 'Herbata (wybór)', 'drinks', 'Zielona, czarna, owocowa, miętowa', 12, '[]'),
  ('K04', 'Sok pomarańczowy', 'drinks', 'Świeżo wyciskany sok z pomarańczy', 16, '[]'),
  ('K05', 'Woda mineralna 0.5L', 'drinks', 'Gazowana lub niegazowana', 8, '[]'),
  ('K06', 'Piwo Tyskie 0.5L', 'drinks', 'Piwo jasne pełne', 18, '[]'),
  ('K07', 'Wino kieliszek', 'drinks', 'Białe/czerwone/różowe — zapytaj o kartę win', 28, '[]'),
  -- Desserts
  ('S01', 'Sernik nowojorski', 'desserts', 'Klasyczny sernik z sosem malinowym', 32, '["gluten","dairy","eggs"]'),
  ('S02', 'Lody 3 gałki', 'desserts', 'Wanilia, czekolada, truskawka', 24, '["dairy"]'),
  ('S03', 'Tiramisu', 'desserts', 'Klasyczne włoskie tiramisu', 34, '["dairy","eggs","gluten"]');

-- Workshop participants (example — to be configured per workshop)
INSERT OR REPLACE INTO participants (id, name, api_key, is_active) VALUES
  ('P01', 'Participant 01', 'wk-participant-01-a1b2c3', 1),
  ('P02', 'Participant 02', 'wk-participant-02-d4e5f6', 1),
  ('P03', 'Participant 03', 'wk-participant-03-g7h8i9', 1),
  ('P04', 'Participant 04', 'wk-participant-04-j0k1l2', 1),
  ('P05', 'Participant 05', 'wk-participant-05-m3n4o5', 1),
  ('P06', 'Participant 06', 'wk-participant-06-p6q7r8', 1),
  ('P07', 'Participant 07', 'wk-participant-07-s9t0u1', 1),
  ('P08', 'Participant 08', 'wk-participant-08-v2w3x4', 1),
  ('P09', 'Participant 09', 'wk-participant-09-y5z6a7', 1),
  ('P10', 'Participant 10', 'wk-participant-10-b8c9d0', 1);
