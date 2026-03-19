USE lockeo;

START TRANSACTION;

-- ---------------------------------------------------------
-- 1) UTILISATEURS
-- ---------------------------------------------------------
INSERT INTO Users (user_id, last_name, first_name, email, login, phone_number, longitude, latitude, city, postal_code, is_verified, created_at)
VALUES
(1, 'Martin',  'Léa',   'lea.martin@example.com',   'lea',    '+33601010101', -1.68002, 48.111338, 'Rennes',  '35000', 1, NOW()),
(2, 'Dubois',  'Hugo',  'hugo.dubois@example.com',  'hugo',   '+33602020202', 2.352222, 48.856614, 'Paris',   '75010', 1, NOW()),
(3, 'Durand',  'Nina',  'nina.durand@example.com',  'nina',   '+33603030303', 5.369780, 43.296482, 'Marseille','13001', 1, NOW()),
(4, 'Bernard', 'Yanis', 'yanis.bernard@example.com','yanis',  '+33604040404', -0.57918, 44.837789, 'Bordeaux','33000', 0, NOW()),
(5, 'Leroy',   'Chloé', 'chloe.leroy@example.com',  'chloe',  '+33605050505', 4.835659, 45.764043, 'Lyon',    '69002', 1, NOW());

-- ---------------------------------------------------------
-- 2) PREFERENCES / TEMPLATES NOTIFS & MESSAGES
-- ---------------------------------------------------------
INSERT INTO NotificationPreferences (notification_preference_id, allowed) VALUES
(1, TRUE),(2, TRUE),(3, TRUE);

INSERT INTO NotificationTemplates (template_id, code, title, content) VALUES
(1, 'RES_CREATED', 'Réservation créée', 'Votre réservation a bien été créée.'),
(2, 'RES_CONFIRMED','Réservation confirmée','Votre réservation a été confirmée.');

INSERT INTO MessageTemplates (message_template_id, code, title, content) VALUES
(1, 'WELCOME', 'Bienvenue', 'Bienvenue sur Lockeo !'),
(2, 'REMIND_PAY', 'Rappel de paiement', 'Merci de finaliser votre paiement.');

-- ---------------------------------------------------------
-- 3) CATEGORIES
-- ---------------------------------------------------------
INSERT INTO Categories (category_id, label, parent_id) VALUES
(1, 'Bricolage', 0),
(2, 'Maison', 0),
(3, 'Sport', 0),
(4, 'Informatique', 0),
(5, 'Jardin', 0),
(6, 'Perceuse', 1),
(7, 'Nettoyage', 2),
(8, 'Vélo', 3),
(9, 'Camping', 3),
(10, 'Randonnée', 3),
(11, 'Ordinateur', 4),
(12, 'Tondeuse', 5),
(13, 'Taille-haie', 5);

-- ---------------------------------------------------------
-- 4) PRODUCTS
-- ---------------------------------------------------------
INSERT INTO Products (product_id, name, description, price, price_estimate, state, longitude, latitude, city, postal_code, is_available, created_at, updated_at)
VALUES
(1, 'Perceuse Bosch',       'Perceuse à percussion 18V',              12.00,  80.00,  'Bon',   -1.6800, 48.1113, 'Rennes',   '35000', 1, NOW(), NOW()),
(2, 'Tondeuse électrique',  'Tondeuse 1600W coupe 38cm',              18.00, 160.00,  'Très bon', 4.8357, 45.7640, 'Lyon',     '69002', 1, NOW(), NOW()),
(3, 'Vélo route Triban',    'Vélo route alu, taille M',               25.00, 600.00,  'Bon',    2.3522, 48.8566, 'Paris',    '75010', 1, NOW(), NOW()),
(4, 'PC portable 15"',      'i5 / 16Go / 512Go SSD',                  30.00, 900.00,  'Très bon',-0.5792,44.8378, 'Bordeaux', '33000', 1, NOW(), NOW()),
(5, 'Nettoyeur haute pression','Kärcher K4',                          20.00, 220.00,  'Bon',    5.3698, 43.2965, 'Marseille','13001', 1, NOW(), NOW()),
(6, 'Tente 3 places',       'Tente de camping légère',                10.00, 120.00,  'Bon',    2.3522, 48.8566, 'Paris',    '75010', 0, NOW(), NOW());

-- ---------------------------------------------------------
-- 5) IMAGES PRODUITS
-- ---------------------------------------------------------
INSERT INTO Images (image_id, product_id, uri, position_image, created_at) VALUES
(1, 1, 'https://pics.example.com/perceuse1.jpg', 1, NOW()),
(2, 1, 'https://pics.example.com/perceuse2.jpg', 2, NOW()),
(3, 2, 'https://pics.example.com/tondeuse1.jpg', 1, NOW()),
(4, 3, 'https://pics.example.com/velo1.jpg',     1, NOW()),
(5, 4, 'https://pics.example.com/pc1.jpg',       1, NOW()),
(6, 5, 'https://pics.example.com/karcher1.jpg',  1, NOW());

-- ---------------------------------------------------------
-- 6) PRODUITS x CATEGORIES
-- ---------------------------------------------------------
INSERT INTO ProductsHasCategories (product_has_category_id, product_id, category_id) VALUES
(1, 1, 1),  -- Perceuse -> Bricolage
(2, 1, 6),  -- Perceuse -> Perceuse
(3, 2, 5),  -- Tondeuse -> Jardin
(4, 2, 12), -- Tondeuse -> Tondeuse
(5, 3, 3),  -- Vélo -> Sport
(6, 3, 8),  -- Vélo -> Vélo
(7, 4, 4),  -- PC -> Informatique
(8, 4, 11), -- PC -> Ordinateur
(9, 5, 2),  -- Kärcher -> Maison
(10, 5, 7), -- Kärcher -> Nettoyage
(11, 6, 3), -- Tente -> Sport
(12, 6, 9); -- Tente -> Camping

-- ---------------------------------------------------------
-- 7) INDISPONIBILITÉS PRODUIT
-- ---------------------------------------------------------
INSERT INTO ProductUnavailabilities (unavailability_id, product_id, start_date_time, end_date_time) VALUES
(1, 1, '2025-07-01 08:00:00', '2025-07-03 20:00:00'),
(2, 3, '2025-07-10 09:00:00', '2025-07-12 18:00:00');

-- ---------------------------------------------------------
-- 8) OFFRES (proposées par des propriétaires sur des produits)
--   owner_id = utilisateur propriétaire de l’offre
-- ---------------------------------------------------------
INSERT INTO Offers (offer_id, owner_id, product_id, status, amount, created_at) VALUES
(1, 1, 1, 'active',     12.00, NOW()),   -- Léa loue sa perceuse
(2, 2, 3, 'active',     25.00, NOW()),   -- Hugo loue son vélo
(3, 4, 4, 'inactive',   30.00, NOW()),   -- Yanis loue son PC (inactif)
(4, 3, 5, 'active',     20.00, NOW());   -- Nina loue son Kärcher

-- ---------------------------------------------------------
-- 9) RÉSERVATIONS (liées à une offre)
-- ---------------------------------------------------------
INSERT INTO Reservations (reservation_id, offer_id, start_date, end_date, status, final_price, verification_code, created_at, updated_at) VALUES
(1, 1, '2025-07-02 09:00:00', '2025-07-02 18:00:00', 'completed', 12.00, 'ABC123', NOW(), NOW()),
(2, 2, '2025-07-05 10:00:00', '2025-07-06 10:00:00', 'confirmed', 50.00, 'VLO789', NOW(), NOW()),
(3, 4, '2025-07-08 14:00:00', '2025-07-08 18:00:00', 'canceled',  0.00,  'KAR555', NOW(), NOW());

-- ---------------------------------------------------------
-- 10) AVIS (sur réservations terminées)
-- ---------------------------------------------------------
INSERT INTO Reviews (review_id, reservation_id, rating, comment, created_at) VALUES
(1, 1, 5, 'Perceuse au top, RAS.', NOW());

-- ---------------------------------------------------------
-- 11) FAVORIS (utilisateur ↔ produit)
-- ---------------------------------------------------------
INSERT INTO Favorites (favorite_id, user_id, product_id) VALUES
(1, 2, 1),  -- Hugo aime la perceuse
(2, 5, 3),  -- Chloé aime le vélo
(3, 3, 4);  -- Nina aime le PC

-- ---------------------------------------------------------
-- 12) CONVERSATIONS (renter_id = locataire, owner_id = propriétaire)
-- ---------------------------------------------------------
INSERT INTO Conversations (conversation_id, created_at, renter_id, owner_id) VALUES
(1, NOW(), 2, 1),  -- Hugo (locataire) ↔ Léa (proprio) pour la perceuse
(2, NOW(), 5, 2),  -- Chloé ↔ Hugo pour le vélo
(3, NOW(), 3, 4);  -- Nina ↔ Yanis pour le PC

-- ---------------------------------------------------------
-- 13) MESSAGES
-- ---------------------------------------------------------
INSERT INTO Messages (message_id, conversation_id, sender_id, content, created_at) VALUES
(1, 1, 2, 'Bonjour, la perceuse est-elle dispo demain ?', NOW()),
(2, 1, 1, 'Oui, je peux vous la remettre à 9h.', NOW()),
(3, 2, 5, 'Bonjour, intéressée par le vélo pour ce week-end.', NOW()),
(4, 2, 2, 'Parfait, je suis dispo samedi matin.', NOW()),
(5, 3, 3, 'Le PC a-t-il un port HDMI ?', NOW()),
(6, 3, 4, 'Oui, et un USB-C aussi.', NOW());

-- ---------------------------------------------------------
-- 14) NOTIFICATIONS UTILISATEURS
-- ---------------------------------------------------------
INSERT INTO UserNotifications (user_notification_id, destination_user_id, template_id, status, created_at) VALUES
(1, 1, 1, 'sent',    NOW()),   -- Léa informée qu’une résa est créée
(2, 2, 2, 'queued',  NOW());   -- Hugo informé que sa résa est confirmée

COMMIT;
