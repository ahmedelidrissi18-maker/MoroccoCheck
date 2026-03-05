-- ============================================
-- MOROCCOCHECK - SEED DATA
-- Version: 1.0
-- Date: 2026-01-16
-- ============================================

-- Insert categories
INSERT INTO categories (name, name_ar, description, icon, color, display_order) VALUES
('Restaurant', 'مطعم', 'Restaurants et cafés', 'restaurant', '#FF5722', 1),
('Hotel', 'فندق', 'Hôtels et hébergements', 'hotel', '#2196F3', 2),
('Museum', 'متحف', 'Musées et galeries', 'museum', '#9C27B0', 3),
('Historical Site', 'موقع تاريخي', 'Sites historiques', 'historic', '#795548', 4),
('Beach', 'شاطئ', 'Plages', 'beach', '#00BCD4', 5),
('Park', 'حديقة', 'Parcs et jardins', 'park', '#4CAF50', 6),
('Shopping', 'تسوق', 'Centres commerciaux et marchés', 'shopping', '#FF9800', 7),
('Entertainment', 'ترفيه', 'Loisirs et divertissements', 'entertainment', '#E91E63', 8),
('Religious Site', 'موقع ديني', 'Mosquées et sites religieux', 'mosque', '#009688', 9),
('Natural Site', 'موقع طبيعي', 'Sites naturels', 'nature', '#8BC34A', 10);

-- Insert subcategories for Restaurant
INSERT INTO categories (name, name_ar, parent_id, display_order) 
SELECT 'Moroccan Cuisine', 'مطبخ مغربي', id, 1 FROM categories WHERE name = 'Restaurant';
INSERT INTO categories (name, name_ar, parent_id, display_order) 
SELECT 'Fast Food', 'وجبات سريعة', id, 2 FROM categories WHERE name = 'Restaurant';
INSERT INTO categories (name, name_ar, parent_id, display_order) 
SELECT 'Café', 'مقهى', id, 3 FROM categories WHERE name = 'Restaurant';

-- Insert admin user
INSERT INTO users (
    email, password_hash, first_name, last_name,
    role, status, is_email_verified,
    points, level, rank
) VALUES (
    'admin@moroccocheck.com',
    '$2b$10$XqJnXQJn.wKXq4H8KXq4H8KXq4H8KXq4H8KXq4H8KXq4H8KXq4H', -- password: admin123
    'Admin',
    'MoroccoCheck',
    'ADMIN',
    'ACTIVE',
    TRUE,
    10000,
    8,
    'PLATINUM'
);

-- Insert contributor user
INSERT INTO users (
    email, password_hash, first_name, last_name,
    role, status, is_email_verified,
    points, level, rank
) VALUES (
    'contributor@test.com',
    '$2b$10$XqJnXQJn.wKXq4H8KXq4H8KXq4H8KXq4H8KXq4H8KXq4H8KXq4H', -- password: test123
    'Ahmed',
    'Benali',
    'CONTRIBUTOR',
    'ACTIVE',
    TRUE,
    250,
    3,
    'BRONZE'
);

-- Insert professional user
INSERT INTO users (
    email, password_hash, first_name, last_name,
    role, status, is_email_verified,
    points, level, rank
) VALUES (
    'pro@test.com',
    '$2b$10$XqJnXQJn.wKXq4H8KXq4H8KXq4H8KXq4H8KXq4H8KXq4H8KXq4H', -- password: test123
    'Fatima',
    'Alami',
    'PROFESSIONAL',
    'ACTIVE',
    TRUE,
    1200,
    5,
    'GOLD'
);

-- Get category IDs
SET @cat_restaurant = (SELECT id FROM categories WHERE name = 'Restaurant' LIMIT 1);
SET @cat_hotel = (SELECT id FROM categories WHERE name = 'Hotel' LIMIT 1);
SET @cat_museum = (SELECT id FROM categories WHERE name = 'Museum' LIMIT 1);

-- Insert tourist sites
INSERT INTO tourist_sites (
    name, name_ar, description, category_id,
    latitude, longitude, address, city, region, country,
    phone_number, website,
    price_range, accepts_card_payment, has_wifi, has_parking,
    status, verification_status, is_active
) VALUES (
    'Rick\'s Café',
    'مقهى ريك',
    'Restaurant emblématique inspiré du film Casablanca',
    @cat_restaurant,
    33.5956, -7.6185,
    '248 Boulevard Sour Jdid, Place du Jardin Public',
    'Casablanca',
    'Casablanca-Settat',
    'MA',
    '+212 5 22 27 42 07',
    'https://rickscafe.ma',
    'EXPENSIVE',
    TRUE, TRUE, TRUE,
    'PUBLISHED', 'VERIFIED', TRUE
);

INSERT INTO tourist_sites (
    name, name_ar, description, category_id,
    latitude, longitude, address, city, region, country,
    phone_number,
    price_range, accepts_card_payment, has_wifi, has_parking,
    status, verification_status, is_active
) VALUES (
    'La Mamounia',
    'لا ماموني',
    'Hôtel de luxe 5 étoiles à Marrakech',
    @cat_hotel,
    31.6215, -7.9898,
    'Avenue Bab Jdid',
    'Marrakech',
    'Marrakech-Safi',
    'MA',
    '+212 5 24 38 86 00',
    'LUXURY',
    TRUE, TRUE, TRUE,
    'PUBLISHED', 'VERIFIED', TRUE
);

INSERT INTO tourist_sites (
    name, name_ar, description, category_id,
    latitude, longitude, address, city, region, country,
    status, verification_status, is_active
) VALUES (
    'Musée Mohammed VI d\'Art Moderne et Contemporain',
    'متحف محمد السادس',
    'Musée d\'art moderne et contemporain',
    @cat_museum,
    34.0078, -6.8333,
    'Avenue Allal Ben Abdellah',
    'Rabat',
    'Rabat-Salé-Kénitra',
    'MA',
    'PUBLISHED', 'VERIFIED', TRUE
);

-- Insert badges
INSERT INTO badges (
    name, name_ar, description, icon, color,
    type, category, rarity,
    required_checkins, points_reward
) VALUES
('First Steps', 'الخطوات الأولى', 'Complete your first check-in', 'star', '#FFD700', 
 'CHECKIN_MILESTONE', 'CONTRIBUTION', 'COMMON', 1, 10),
('Explorer', 'المستكشف', 'Complete 10 check-ins', 'explore', '#4CAF50', 
 'CHECKIN_MILESTONE', 'EXPLORATION', 'UNCOMMON', 10, 50),
('Traveler', 'المسافر', 'Complete 50 check-ins', 'travel', '#2196F3', 
 'CHECKIN_MILESTONE', 'EXPLORATION', 'RARE', 50, 100),
('Adventurer', 'المغامر', 'Complete 100 check-ins', 'adventure', '#9C27B0', 
 'CHECKIN_MILESTONE', 'EXPLORATION', 'EPIC', 100, 250),
('Legend', 'الأسطورة', 'Complete 500 check-ins', 'legend', '#FF5722', 
 'CHECKIN_MILESTONE', 'EXPLORATION', 'LEGENDARY', 500, 500);

INSERT INTO badges (
    name, name_ar, description, icon, color,
    type, category, rarity,
    required_reviews, points_reward
) VALUES
('Critic', 'الناقد', 'Write your first review', 'review', '#FFC107', 
 'REVIEW_MILESTONE', 'CONTRIBUTION', 'COMMON', 1, 15),
('Reviewer', 'المراجع', 'Write 10 reviews', 'reviews', '#FF9800', 
 'REVIEW_MILESTONE', 'CONTRIBUTION', 'UNCOMMON', 10, 75),
('Expert Critic', 'الناقد الخبير', 'Write 50 reviews', 'expert', '#F44336', 
 'REVIEW_MILESTONE', 'EXPERTISE', 'RARE', 50, 150);

INSERT INTO badges (
    name, name_ar, description, icon, color,
    type, category, rarity,
    required_level, points_reward
) VALUES
('Bronze Member', 'عضو برونزي', 'Reach level 3', 'bronze', '#CD7F32', 
 'LEVEL_ACHIEVEMENT', 'ACHIEVEMENT', 'COMMON', 3, 25),
('Silver Member', 'عضو فضي', 'Reach level 5', 'silver', '#C0C0C0', 
 'LEVEL_ACHIEVEMENT', 'ACHIEVEMENT', 'UNCOMMON', 5, 50),
('Gold Member', 'عضو ذهبي', 'Reach level 7', 'gold', '#FFD700', 
 'LEVEL_ACHIEVEMENT', 'ACHIEVEMENT', 'RARE', 7, 100);

-- Insert check-in
SET @user_id = (SELECT id FROM users WHERE email = 'contributor@test.com');
SET @site_id = (SELECT id FROM tourist_sites WHERE name = 'Rick\'s Café');

INSERT INTO checkins (
    user_id, site_id, status, comment,
    latitude, longitude, accuracy, distance,
    has_photo, points_earned, validation_status
) VALUES (
    @user_id, @site_id, 'OPEN', 
    'Great atmosphere, highly recommended!',
    33.5956, -7.6185, 10.5, 5.2,
    TRUE, 15, 'APPROVED'
);

-- Insert review
INSERT INTO reviews (
    user_id, site_id,
    overall_rating, service_rating, cleanliness_rating, value_rating, location_rating,
    title, content, visit_date, visit_type,
    helpful_count, status, moderation_status, points_earned
) VALUES (
    @user_id, @site_id,
    4.5, 5.0, 4.5, 4.0, 5.0,
    'Excellent experience',
    'The ambiance is incredible, exactly like in the movie. Food is delicious and service is top-notch. A must-visit in Casablanca!',
    '2026-01-10', 'COUPLE',
    5, 'PUBLISHED', 'APPROVED', 15
);

-- Insert opening hours for Rick's Café
INSERT INTO opening_hours (site_id, day_of_week, opens_at, closes_at, is_closed)
VALUES 
(@site_id, 'MONDAY', '08:00:00', '23:00:00', FALSE),
(@site_id, 'TUESDAY', '08:00:00', '23:00:00', FALSE),
(@site_id, 'WEDNESDAY', '08:00:00', '23:00:00', FALSE),
(@site_id, 'THURSDAY', '08:00:00', '23:00:00', FALSE),
(@site_id, 'FRIDAY', '08:00:00', '23:00:00', FALSE),
(@site_id, 'SATURDAY', '08:00:00', '23:00:00', FALSE),
(@site_id, 'SUNDAY', '08:00:00', '23:00:00', FALSE);

-- Insert favorite
INSERT INTO favorites (user_id, site_id)
VALUES (@user_id, @site_id);

-- Update user stats
UPDATE users SET 
    checkins_count = 1,
    reviews_count = 1,
    photos_count = 1
WHERE id = @user_id;

-- Update site stats
UPDATE tourist_sites SET 
    total_reviews = 1,
    average_rating = 4.5,
    favorites_count = 1
WHERE id = @site_id;