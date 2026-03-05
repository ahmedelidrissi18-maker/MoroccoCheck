# Phase 2.3 : Modèle Physique de Données (MPD)
## MoroccoCheck - Scripts SQL Complets

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Script d'Initialisation Complet](#1-script-dinitialisation-complet)
2. [Triggers](#2-triggers)
3. [Procédures Stockées](#3-procédures-stockées)
4. [Fonctions](#4-fonctions)
5. [Vues](#5-vues)
6. [Données de Test (Seeds)](#6-données-de-test-seeds)
7. [Scripts de Maintenance](#7-scripts-de-maintenance)

---

## 1. Script d'Initialisation Complet

### 1.1 Script de Création de Base de Données

```sql
-- ============================================
-- MOROCCOCHECK - DATABASE INITIALIZATION
-- Version: 1.0
-- Date: 2026-01-16
-- ============================================

-- Drop database if exists (WARNING: Use with caution)
-- DROP DATABASE IF EXISTS moroccocheck;

-- Create database
CREATE DATABASE IF NOT EXISTS moroccocheck
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE moroccocheck;

-- Set global variables
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
```

### 1.2 Script Principal de Création des Tables

```sql
-- ============================================
-- TABLE: categories
-- ============================================
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100) NOT NULL,
    description TEXT,
    description_ar TEXT,
    icon VARCHAR(255),
    color VARCHAR(7),
    parent_id INT UNSIGNED NULL,
    display_order INT UNSIGNED NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_parent_id (parent_id),
    INDEX idx_display_order (display_order),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add foreign key after table creation
ALTER TABLE categories
    ADD CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_id) REFERENCES categories(id)
    ON DELETE SET NULL ON UPDATE CASCADE;

-- ============================================
-- TABLE: users
-- ============================================
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'),
    nationality VARCHAR(2),
    profile_picture VARCHAR(500),
    bio TEXT,
    
    role ENUM('TOURIST', 'CONTRIBUTOR', 'PROFESSIONAL', 'MODERATOR', 'ADMIN') 
        NOT NULL DEFAULT 'TOURIST',
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED', 'BANNED', 'PENDING_VERIFICATION') 
        NOT NULL DEFAULT 'PENDING_VERIFICATION',
    
    is_email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    email_verification_token VARCHAR(255),
    email_verification_expires_at TIMESTAMP NULL,
    
    points INT UNSIGNED NOT NULL DEFAULT 0,
    level INT UNSIGNED NOT NULL DEFAULT 1,
    experience_points INT UNSIGNED NOT NULL DEFAULT 0,
    rank ENUM('BRONZE', 'SILVER', 'GOLD', 'PLATINUM') NOT NULL DEFAULT 'BRONZE',
    checkins_count INT UNSIGNED NOT NULL DEFAULT 0,
    reviews_count INT UNSIGNED NOT NULL DEFAULT 0,
    photos_count INT UNSIGNED NOT NULL DEFAULT 0,
    
    google_id VARCHAR(255) UNIQUE,
    facebook_id VARCHAR(255) UNIQUE,
    apple_id VARCHAR(255) UNIQUE,
    
    last_login_at TIMESTAMP NULL,
    last_seen_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status),
    INDEX idx_points (points DESC),
    INDEX idx_level (level DESC),
    INDEX idx_created_at (created_at),
    INDEX idx_google_id (google_id),
    INDEX idx_facebook_id (facebook_id),
    INDEX idx_apple_id (apple_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TABLE: tourist_sites
-- ============================================
DROP TABLE IF EXISTS tourist_sites;

CREATE TABLE tourist_sites (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255),
    description TEXT,
    description_ar TEXT,
    category_id INT UNSIGNED NOT NULL,
    subcategory VARCHAR(100),
    
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    address VARCHAR(500),
    city VARCHAR(100),
    region VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(2) NOT NULL DEFAULT 'MA',
    
    phone_number VARCHAR(20),
    email VARCHAR(255),
    website VARCHAR(500),
    social_media JSON,
    
    price_range ENUM('BUDGET', 'MODERATE', 'EXPENSIVE', 'LUXURY'),
    
    accepts_card_payment BOOLEAN NOT NULL DEFAULT FALSE,
    has_wifi BOOLEAN NOT NULL DEFAULT FALSE,
    has_parking BOOLEAN NOT NULL DEFAULT FALSE,
    is_accessible BOOLEAN NOT NULL DEFAULT FALSE,
    amenities JSON,
    
    average_rating DECIMAL(3, 2) NOT NULL DEFAULT 0.00 
        CHECK (average_rating >= 0 AND average_rating <= 5),
    total_reviews INT UNSIGNED NOT NULL DEFAULT 0,
    freshness_score INT UNSIGNED NOT NULL DEFAULT 0 
        CHECK (freshness_score >= 0 AND freshness_score <= 100),
    freshness_status ENUM('FRESH', 'RECENT', 'OLD', 'OBSOLETE') 
        NOT NULL DEFAULT 'OBSOLETE',
    last_verified_at TIMESTAMP NULL,
    last_updated_at TIMESTAMP NULL,
    
    cover_photo VARCHAR(500),
    
    owner_id INT UNSIGNED NULL,
    is_professional_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    subscription_plan ENUM('FREE', 'BASIC', 'PRO', 'PREMIUM'),
    
    status ENUM('DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'ARCHIVED', 'REPORTED') 
        NOT NULL DEFAULT 'DRAFT',
    verification_status ENUM('PENDING', 'VERIFIED', 'REJECTED') 
        NOT NULL DEFAULT 'PENDING',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    
    views_count INT UNSIGNED NOT NULL DEFAULT 0,
    favorites_count INT UNSIGNED NOT NULL DEFAULT 0,
    
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    FOREIGN KEY (category_id) REFERENCES categories(id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES users(id) 
        ON DELETE SET NULL ON UPDATE CASCADE,
    
    INDEX idx_category_id (category_id),
    INDEX idx_owner_id (owner_id),
    INDEX idx_location (latitude, longitude),
    INDEX idx_city (city),
    INDEX idx_region (region),
    INDEX idx_status (status),
    INDEX idx_is_active (is_active),
    INDEX idx_is_featured (is_featured),
    INDEX idx_freshness_score (freshness_score DESC),
    INDEX idx_average_rating (average_rating DESC),
    INDEX idx_created_at (created_at),
    INDEX idx_freshness_rating (freshness_score DESC, average_rating DESC),
    FULLTEXT INDEX idx_fulltext_search (name, description, address, city)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Continue with all other tables...
-- (Les autres tables sont déjà définies dans Phase2_2_MLD_Modele_Logique.md)

SET FOREIGN_KEY_CHECKS = 1;
```

---

## 2. Triggers

### 2.1 Trigger : Mise à jour automatique du nombre de check-ins

```sql
DELIMITER $$

-- Trigger après insertion d'un check-in
CREATE TRIGGER trg_after_checkin_insert
AFTER INSERT ON checkins
FOR EACH ROW
BEGIN
    -- Incrémenter le compteur de check-ins de l'utilisateur
    UPDATE users
    SET checkins_count = checkins_count + 1
    WHERE id = NEW.user_id;
    
    -- Mettre à jour la date de dernière vérification du site
    UPDATE tourist_sites
    SET last_verified_at = CURRENT_TIMESTAMP
    WHERE id = NEW.site_id;
END$$

-- Trigger après suppression d'un check-in
CREATE TRIGGER trg_after_checkin_delete
AFTER DELETE ON checkins
FOR EACH ROW
BEGIN
    -- Décrémenter le compteur de check-ins de l'utilisateur
    UPDATE users
    SET checkins_count = GREATEST(checkins_count - 1, 0)
    WHERE id = OLD.user_id;
END$$

DELIMITER ;
```

### 2.2 Trigger : Mise à jour automatique des avis

```sql
DELIMITER $$

-- Trigger après insertion d'un avis
CREATE TRIGGER trg_after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    -- Incrémenter le compteur d'avis de l'utilisateur
    UPDATE users
    SET reviews_count = reviews_count + 1
    WHERE id = NEW.user_id;
    
    -- Recalculer la note moyenne du site
    UPDATE tourist_sites
    SET 
        average_rating = (
            SELECT AVG(overall_rating)
            FROM reviews
            WHERE site_id = NEW.site_id AND status = 'PUBLISHED'
        ),
        total_reviews = total_reviews + 1
    WHERE id = NEW.site_id;
END$$

-- Trigger après mise à jour d'un avis
CREATE TRIGGER trg_after_review_update
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    -- Si le statut change ou la note change
    IF OLD.overall_rating != NEW.overall_rating 
       OR OLD.status != NEW.status THEN
        -- Recalculer la note moyenne du site
        UPDATE tourist_sites
        SET average_rating = (
            SELECT COALESCE(AVG(overall_rating), 0)
            FROM reviews
            WHERE site_id = NEW.site_id AND status = 'PUBLISHED'
        )
        WHERE id = NEW.site_id;
    END IF;
END$$

-- Trigger après suppression d'un avis
CREATE TRIGGER trg_after_review_delete
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
    -- Décrémenter le compteur d'avis de l'utilisateur
    UPDATE users
    SET reviews_count = GREATEST(reviews_count - 1, 0)
    WHERE id = OLD.user_id;
    
    -- Recalculer la note moyenne du site
    UPDATE tourist_sites
    SET 
        average_rating = (
            SELECT COALESCE(AVG(overall_rating), 0)
            FROM reviews
            WHERE site_id = OLD.site_id AND status = 'PUBLISHED'
        ),
        total_reviews = GREATEST(total_reviews - 1, 0)
    WHERE id = OLD.site_id;
END$$

DELIMITER ;
```

### 2.3 Trigger : Gestion des points et niveaux

```sql
DELIMITER $$

-- Trigger après mise à jour des points
CREATE TRIGGER trg_after_user_points_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
    DECLARE new_level INT;
    DECLARE new_rank VARCHAR(20);
    
    -- Calculer le nouveau niveau basé sur les points
    IF NEW.points >= 0 AND NEW.points < 100 THEN
        SET new_level = 1;
    ELSEIF NEW.points >= 100 AND NEW.points < 250 THEN
        SET new_level = 2;
    ELSEIF NEW.points >= 250 AND NEW.points < 500 THEN
        SET new_level = 3;
    ELSEIF NEW.points >= 500 AND NEW.points < 1000 THEN
        SET new_level = 4;
    ELSEIF NEW.points >= 1000 AND NEW.points < 2500 THEN
        SET new_level = 5;
    ELSEIF NEW.points >= 2500 AND NEW.points < 5000 THEN
        SET new_level = 6;
    ELSEIF NEW.points >= 5000 AND NEW.points < 10000 THEN
        SET new_level = 7;
    ELSE
        SET new_level = 8;
    END IF;
    
    -- Calculer le nouveau rang basé sur les points
    IF NEW.points < 500 THEN
        SET new_rank = 'BRONZE';
    ELSEIF NEW.points >= 500 AND NEW.points < 1000 THEN
        SET new_rank = 'SILVER';
    ELSEIF NEW.points >= 1000 AND NEW.points < 5000 THEN
        SET new_rank = 'GOLD';
    ELSE
        SET new_rank = 'PLATINUM';
    END IF;
    
    -- Mettre à jour si changement
    IF OLD.level != new_level OR OLD.rank != new_rank THEN
        UPDATE users
        SET 
            level = new_level,
            rank = new_rank
        WHERE id = NEW.id;
    END IF;
END$$

DELIMITER ;
```

### 2.4 Trigger : Mise à jour du compteur de favoris

```sql
DELIMITER $$

-- Trigger après insertion d'un favori
CREATE TRIGGER trg_after_favorite_insert
AFTER INSERT ON favorites
FOR EACH ROW
BEGIN
    UPDATE tourist_sites
    SET favorites_count = favorites_count + 1
    WHERE id = NEW.site_id;
END$$

-- Trigger après suppression d'un favori
CREATE TRIGGER trg_after_favorite_delete
AFTER DELETE ON favorites
FOR EACH ROW
BEGIN
    UPDATE tourist_sites
    SET favorites_count = GREATEST(favorites_count - 1, 0)
    WHERE id = OLD.site_id;
END$$

DELIMITER ;
```

### 2.5 Trigger : Validation des données avant insertion

```sql
DELIMITER $$

-- Trigger avant insertion d'un check-in
CREATE TRIGGER trg_before_checkin_insert
BEFORE INSERT ON checkins
FOR EACH ROW
BEGIN
    -- Valider que la distance est <= 100m
    IF NEW.distance > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Check-in distance must be <= 100 meters';
    END IF;
    
    -- Calculer les points automatiquement
    IF NEW.has_photo = TRUE THEN
        SET NEW.points_earned = 15;
    ELSE
        SET NEW.points_earned = 10;
    END IF;
END$$

-- Trigger avant insertion d'un avis
CREATE TRIGGER trg_before_review_insert
BEFORE INSERT ON reviews
FOR EACH ROW
BEGIN
    -- Valider la longueur minimale du contenu
    IF CHAR_LENGTH(NEW.content) < 20 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Review content must be at least 20 characters';
    END IF;
    
    -- Calculer les points automatiquement
    SET NEW.points_earned = 15;
END$$

DELIMITER ;
```

---

## 3. Procédures Stockées

### 3.1 Procédure : Calculer le score de fraîcheur d'un site

```sql
DELIMITER $$

CREATE PROCEDURE sp_calculate_freshness_score(
    IN p_site_id INT UNSIGNED
)
BEGIN
    DECLARE v_score INT DEFAULT 0;
    DECLARE v_time_score INT DEFAULT 0;
    DECLARE v_activity_score INT DEFAULT 0;
    DECLARE v_review_score INT DEFAULT 0;
    DECLARE v_days_since_verification INT;
    DECLARE v_checkins_24h INT;
    DECLARE v_checkins_7d INT;
    DECLARE v_checkins_30d INT;
    DECLARE v_reviews_30d INT;
    DECLARE v_status VARCHAR(20);
    
    -- Calculer jours depuis dernière vérification
    SELECT DATEDIFF(CURRENT_TIMESTAMP, last_verified_at)
    INTO v_days_since_verification
    FROM tourist_sites
    WHERE id = p_site_id;
    
    -- Score basé sur le temps (40 points max)
    IF v_days_since_verification IS NULL OR v_days_since_verification > 30 THEN
        SET v_time_score = 0;
    ELSEIF v_days_since_verification < 1 THEN
        SET v_time_score = 40;
    ELSEIF v_days_since_verification < 7 THEN
        SET v_time_score = 30;
    ELSEIF v_days_since_verification < 30 THEN
        SET v_time_score = 15;
    END IF;
    
    -- Compter les check-ins récents
    SELECT 
        COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 1 DAY) THEN 1 END),
        COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) THEN 1 END),
        COUNT(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 END)
    INTO v_checkins_24h, v_checkins_7d, v_checkins_30d
    FROM checkins
    WHERE site_id = p_site_id AND validation_status = 'APPROVED';
    
    -- Score basé sur l'activité (40 points max)
    IF v_checkins_24h > 5 THEN
        SET v_activity_score = 20;
    ELSEIF v_checkins_24h > 2 THEN
        SET v_activity_score = 15;
    ELSEIF v_checkins_24h > 0 THEN
        SET v_activity_score = 10;
    END IF;
    
    IF v_checkins_7d > 10 THEN
        SET v_activity_score = v_activity_score + 15;
    ELSEIF v_checkins_7d > 5 THEN
        SET v_activity_score = v_activity_score + 10;
    ELSEIF v_checkins_7d > 0 THEN
        SET v_activity_score = v_activity_score + 5;
    END IF;
    
    -- Compter les avis récents
    SELECT COUNT(*)
    INTO v_reviews_30d
    FROM reviews
    WHERE site_id = p_site_id 
      AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
      AND status = 'PUBLISHED';
    
    -- Score basé sur les avis (20 points max)
    IF v_reviews_30d > 5 THEN
        SET v_review_score = 15;
    ELSEIF v_reviews_30d > 2 THEN
        SET v_review_score = 10;
    ELSEIF v_reviews_30d > 0 THEN
        SET v_review_score = 5;
    END IF;
    
    -- Bonus si site professionnel
    IF (SELECT is_professional_claimed FROM tourist_sites WHERE id = p_site_id) = TRUE THEN
        SET v_review_score = v_review_score + 5;
    END IF;
    
    -- Calculer score total
    SET v_score = v_time_score + v_activity_score + v_review_score;
    
    -- Limiter entre 0 et 100
    IF v_score > 100 THEN
        SET v_score = 100;
    ELSEIF v_score < 0 THEN
        SET v_score = 0;
    END IF;
    
    -- Déterminer le statut
    IF v_score >= 80 THEN
        SET v_status = 'FRESH';
    ELSEIF v_score >= 50 THEN
        SET v_status = 'RECENT';
    ELSEIF v_score >= 20 THEN
        SET v_status = 'OLD';
    ELSE
        SET v_status = 'OBSOLETE';
    END IF;
    
    -- Mettre à jour le site
    UPDATE tourist_sites
    SET 
        freshness_score = v_score,
        freshness_status = v_status,
        last_updated_at = CURRENT_TIMESTAMP
    WHERE id = p_site_id;
    
END$$

DELIMITER ;
```

### 3.2 Procédure : Mettre à jour tous les scores de fraîcheur

```sql
DELIMITER $$

CREATE PROCEDURE sp_update_all_freshness_scores()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_site_id INT;
    DECLARE cur CURSOR FOR 
        SELECT id FROM tourist_sites WHERE is_active = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_site_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        CALL sp_calculate_freshness_score(v_site_id);
    END LOOP;
    
    CLOSE cur;
    
    SELECT CONCAT('Updated freshness scores for ', COUNT(*), ' sites') as message
    FROM tourist_sites WHERE is_active = TRUE;
END$$

DELIMITER ;
```

### 3.3 Procédure : Vérifier et attribuer les badges

```sql
DELIMITER $$

CREATE PROCEDURE sp_check_and_award_badges(
    IN p_user_id INT UNSIGNED
)
BEGIN
    DECLARE v_checkins_count INT;
    DECLARE v_reviews_count INT;
    DECLARE v_photos_count INT;
    DECLARE v_points INT;
    DECLARE v_level INT;
    
    -- Récupérer les stats de l'utilisateur
    SELECT 
        checkins_count, 
        reviews_count, 
        photos_count, 
        points, 
        level
    INTO 
        v_checkins_count, 
        v_reviews_count, 
        v_photos_count, 
        v_points, 
        v_level
    FROM users
    WHERE id = p_user_id;
    
    -- Vérifier tous les badges non encore obtenus
    INSERT INTO user_badges (user_id, badge_id, earned_at, progress)
    SELECT 
        p_user_id,
        b.id,
        CURRENT_TIMESTAMP,
        100.00
    FROM badges b
    WHERE b.is_active = TRUE
      AND NOT EXISTS (
          SELECT 1 FROM user_badges ub 
          WHERE ub.user_id = p_user_id AND ub.badge_id = b.id
      )
      AND (
          -- Badges check-in
          (b.type = 'CHECKIN_MILESTONE' AND v_checkins_count >= b.required_checkins)
          OR
          -- Badges avis
          (b.type = 'REVIEW_MILESTONE' AND v_reviews_count >= b.required_reviews)
          OR
          -- Badges photos
          (b.type = 'PHOTO_MILESTONE' AND v_photos_count >= b.required_photos)
          OR
          -- Badges niveau
          (b.type = 'LEVEL_ACHIEVEMENT' AND v_level >= b.required_level)
          OR
          -- Badges points
          (b.required_points > 0 AND v_points >= b.required_points)
      );
    
    -- Attribuer les points récompense des nouveaux badges
    UPDATE users
    SET points = points + (
        SELECT COALESCE(SUM(b.points_reward), 0)
        FROM user_badges ub
        JOIN badges b ON ub.badge_id = b.id
        WHERE ub.user_id = p_user_id
          AND ub.earned_at >= DATE_SUB(NOW(), INTERVAL 1 MINUTE)
    )
    WHERE id = p_user_id;
    
    -- Retourner les nouveaux badges
    SELECT 
        b.id,
        b.name,
        b.description,
        b.icon,
        b.points_reward,
        ub.earned_at
    FROM user_badges ub
    JOIN badges b ON ub.badge_id = b.id
    WHERE ub.user_id = p_user_id
      AND ub.earned_at >= DATE_SUB(NOW(), INTERVAL 1 MINUTE);
      
END$$

DELIMITER ;
```

### 3.4 Procédure : Créer un check-in

```sql
DELIMITER $$

CREATE PROCEDURE sp_create_checkin(
    IN p_user_id INT UNSIGNED,
    IN p_site_id INT UNSIGNED,
    IN p_status VARCHAR(50),
    IN p_comment TEXT,
    IN p_latitude DECIMAL(10,8),
    IN p_longitude DECIMAL(11,8),
    IN p_accuracy DECIMAL(10,2),
    IN p_has_photo BOOLEAN,
    OUT p_checkin_id INT UNSIGNED,
    OUT p_points_earned INT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_site_lat DECIMAL(10,8);
    DECLARE v_site_lng DECIMAL(11,8);
    DECLARE v_distance DECIMAL(10,2);
    DECLARE v_last_checkin_date DATE;
    DECLARE v_user_role VARCHAR(20);
    
    -- Vérifier le rôle de l'utilisateur
    SELECT role INTO v_user_role
    FROM users
    WHERE id = p_user_id;
    
    IF v_user_role = 'TOURIST' THEN
        SET p_message = 'Only contributors and above can check in';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;
    
    -- Récupérer les coordonnées du site
    SELECT latitude, longitude
    INTO v_site_lat, v_site_lng
    FROM tourist_sites
    WHERE id = p_site_id;
    
    -- Calculer la distance (formule haversine simplifiée)
    SET v_distance = (
        6371000 * ACOS(
            COS(RADIANS(p_latitude)) * 
            COS(RADIANS(v_site_lat)) * 
            COS(RADIANS(v_site_lng) - RADIANS(p_longitude)) + 
            SIN(RADIANS(p_latitude)) * 
            SIN(RADIANS(v_site_lat))
        )
    );
    
    -- Vérifier la distance
    IF v_distance > 100 THEN
        SET p_message = CONCAT('Too far from site: ', ROUND(v_distance, 0), 'm (max 100m)');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;
    
    -- Vérifier le cooldown (1 check-in par site par jour)
    SELECT DATE(created_at)
    INTO v_last_checkin_date
    FROM checkins
    WHERE user_id = p_user_id AND site_id = p_site_id
    ORDER BY created_at DESC
    LIMIT 1;
    
    IF v_last_checkin_date = CURDATE() THEN
        SET p_message = 'Already checked in today at this site';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;
    
    -- Calculer les points
    IF p_has_photo = TRUE THEN
        SET p_points_earned = 15;
    ELSE
        SET p_points_earned = 10;
    END IF;
    
    -- Insérer le check-in
    INSERT INTO checkins (
        user_id, site_id, status, comment,
        latitude, longitude, accuracy, distance,
        has_photo, points_earned, validation_status
    ) VALUES (
        p_user_id, p_site_id, p_status, p_comment,
        p_latitude, p_longitude, p_accuracy, v_distance,
        p_has_photo, p_points_earned, 'APPROVED'
    );
    
    SET p_checkin_id = LAST_INSERT_ID();
    
    -- Ajouter les points à l'utilisateur
    UPDATE users
    SET points = points + p_points_earned
    WHERE id = p_user_id;
    
    -- Vérifier les badges
    CALL sp_check_and_award_badges(p_user_id);
    
    -- Recalculer la fraîcheur du site
    CALL sp_calculate_freshness_score(p_site_id);
    
    SET p_message = 'Check-in created successfully';
    
END$$

DELIMITER ;
```

---

## 4. Fonctions

### 4.1 Fonction : Calculer la distance entre deux points GPS

```sql
DELIMITER $$

CREATE FUNCTION fn_calculate_distance(
    lat1 DECIMAL(10,8),
    lng1 DECIMAL(11,8),
    lat2 DECIMAL(10,8),
    lng2 DECIMAL(11,8)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE distance DECIMAL(10,2);
    
    -- Formule Haversine
    SET distance = (
        6371000 * ACOS(
            LEAST(1.0,
                COS(RADIANS(lat1)) * 
                COS(RADIANS(lat2)) * 
                COS(RADIANS(lng2) - RADIANS(lng1)) + 
                SIN(RADIANS(lat1)) * 
                SIN(RADIANS(lat2))
            )
        )
    );
    
    RETURN ROUND(distance, 2);
END$$

DELIMITER ;

-- Utilisation :
-- SELECT fn_calculate_distance(33.5731, -7.5898, 33.5720, -7.5890) as distance_meters;
```

### 4.2 Fonction : Obtenir le niveau d'un utilisateur basé sur les points

```sql
DELIMITER $$

CREATE FUNCTION fn_get_level_from_points(
    p_points INT
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_level INT;
    
    IF p_points < 100 THEN
        SET v_level = 1;
    ELSEIF p_points < 250 THEN
        SET v_level = 2;
    ELSEIF p_points < 500 THEN
        SET v_level = 3;
    ELSEIF p_points < 1000 THEN
        SET v_level = 4;
    ELSEIF p_points < 2500 THEN
        SET v_level = 5;
    ELSEIF p_points < 5000 THEN
        SET v_level = 6;
    ELSEIF p_points < 10000 THEN
        SET v_level = 7;
    ELSE
        SET v_level = 8;
    END IF;
    
    RETURN v_level;
END$$

DELIMITER ;
```

### 4.3 Fonction : Obtenir le rang d'un utilisateur

```sql
DELIMITER $$

CREATE FUNCTION fn_get_rank_from_points(
    p_points INT
)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_rank VARCHAR(20);
    
    IF p_points < 500 THEN
        SET v_rank = 'BRONZE';
    ELSEIF p_points < 1000 THEN
        SET v_rank = 'SILVER';
    ELSEIF p_points < 5000 THEN
        SET v_rank = 'GOLD';
    ELSE
        SET v_rank = 'PLATINUM';
    END IF;
    
    RETURN v_rank;
END$$

DELIMITER ;
```

---

## 5. Vues

### 5.1 Vue : Statistiques des utilisateurs

```sql
CREATE OR REPLACE VIEW v_user_stats AS
SELECT 
    u.id,
    u.email,
    u.first_name,
    u.last_name,
    u.role,
    u.status,
    u.points,
    u.level,
    u.rank,
    u.checkins_count,
    u.reviews_count,
    u.photos_count,
    COUNT(DISTINCT ub.badge_id) as badges_count,
    COUNT(DISTINCT f.site_id) as favorites_count,
    COALESCE(AVG(r.overall_rating), 0) as avg_rating_given,
    u.created_at,
    u.last_login_at
FROM users u
LEFT JOIN user_badges ub ON u.id = ub.user_id
LEFT JOIN favorites f ON u.id = f.user_id
LEFT JOIN reviews r ON u.id = r.user_id AND r.status = 'PUBLISHED'
GROUP BY u.id;
```

### 5.2 Vue : Sites avec statistiques complètes

```sql
CREATE OR REPLACE VIEW v_site_details AS
SELECT 
    s.id,
    s.name,
    s.name_ar,
    c.name as category_name,
    s.latitude,
    s.longitude,
    s.city,
    s.region,
    s.average_rating,
    s.total_reviews,
    s.freshness_score,
    s.freshness_status,
    s.is_featured,
    s.is_professional_claimed,
    COUNT(DISTINCT ch.id) as total_checkins,
    COUNT(DISTINCT ch.user_id) as unique_visitors,
    COUNT(DISTINCT p.id) as photos_count,
    s.favorites_count,
    s.views_count,
    DATEDIFF(CURRENT_TIMESTAMP, s.last_verified_at) as days_since_verification,
    s.created_at,
    s.updated_at
FROM tourist_sites s
LEFT JOIN categories c ON s.category_id = c.id
LEFT JOIN checkins ch ON s.id = ch.site_id AND ch.validation_status = 'APPROVED'
LEFT JOIN photos p ON s.id = p.entity_id AND p.entity_type = 'SITE' AND p.status = 'ACTIVE'
WHERE s.is_active = TRUE
GROUP BY s.id;
```

### 5.3 Vue : Leaderboard global

```sql
CREATE OR REPLACE VIEW v_leaderboard AS
SELECT 
    u.id,
    u.first_name,
    u.last_name,
    u.profile_picture,
    u.points,
    u.level,
    u.rank,
    u.checkins_count,
    u.reviews_count,
    COUNT(DISTINCT ub.badge_id) as badges_count,
    RANK() OVER (ORDER BY u.points DESC) as global_rank
FROM users u
LEFT JOIN user_badges ub ON u.id = ub.user_id
WHERE u.status = 'ACTIVE'
GROUP BY u.id
ORDER BY u.points DESC
LIMIT 100;
```

### 5.4 Vue : Statistiques par catégorie

```sql
CREATE OR REPLACE VIEW v_category_stats AS
SELECT 
    c.id,
    c.name,
    c.name_ar,
    COUNT(DISTINCT s.id) as sites_count,
    COUNT(DISTINCT ch.id) as total_checkins,
    COUNT(DISTINCT r.id) as total_reviews,
    COALESCE(AVG(s.average_rating), 0) as avg_rating,
    COALESCE(AVG(s.freshness_score), 0) as avg_freshness
FROM categories c
LEFT JOIN tourist_sites s ON c.id = s.category_id AND s.is_active = TRUE
LEFT JOIN checkins ch ON s.id = ch.site_id AND ch.validation_status = 'APPROVED'
LEFT JOIN reviews r ON s.id = r.site_id AND r.status = 'PUBLISHED'
WHERE c.is_active = TRUE
GROUP BY c.id
ORDER BY sites_count DESC;
```

### 5.5 Vue : Avis récents avec détails

```sql
CREATE OR REPLACE VIEW v_recent_reviews AS
SELECT 
    r.id,
    r.overall_rating,
    r.title,
    r.content,
    r.helpful_count,
    r.visit_date,
    r.created_at,
    u.id as user_id,
    u.first_name,
    u.last_name,
    u.profile_picture,
    u.level,
    u.rank,
    s.id as site_id,
    s.name as site_name,
    s.city as site_city,
    c.name as category_name,
    COUNT(DISTINCT p.id) as photos_count
FROM reviews r
JOIN users u ON r.user_id = u.id
JOIN tourist_sites s ON r.site_id = s.id
JOIN categories c ON s.category_id = c.id
LEFT JOIN photos p ON r.id = p.entity_id AND p.entity_type = 'REVIEW' AND p.status = 'ACTIVE'
WHERE r.status = 'PUBLISHED'
GROUP BY r.id
ORDER BY r.created_at DESC
LIMIT 50;
```

---

## 6. Données de Test (Seeds)

### 6.1 Catégories de sites

```sql
-- Insertion des catégories principales
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

-- Sous-catégories pour Restaurants
INSERT INTO categories (name, name_ar, parent_id, display_order) 
SELECT 'Moroccan Cuisine', 'مطبخ مغربي', id, 1 FROM categories WHERE name = 'Restaurant';
INSERT INTO categories (name, name_ar, parent_id, display_order) 
SELECT 'Fast Food', 'وجبات سريعة', id, 2 FROM categories WHERE name = 'Restaurant';
INSERT INTO categories (name, name_ar, parent_id, display_order) 
SELECT 'Café', 'مقهى', id, 3 FROM categories WHERE name = 'Restaurant';
```

### 6.2 Utilisateurs de test

```sql
-- Admin user
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

-- Contributeur test
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

-- Professionnel test
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
```

### 6.3 Sites touristiques de test

```sql
-- Récupérer l'ID de la catégorie Restaurant
SET @cat_restaurant = (SELECT id FROM categories WHERE name = 'Restaurant' LIMIT 1);
SET @cat_hotel = (SELECT id FROM categories WHERE name = 'Hotel' LIMIT 1);
SET @cat_museum = (SELECT id FROM categories WHERE name = 'Museum' LIMIT 1);

-- Restaurant à Casablanca
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

-- Hôtel à Marrakech
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

-- Musée à Rabat
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
```

### 6.4 Badges

```sql
-- Badges de check-in
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

-- Badges d'avis
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

-- Badges de niveau
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
```

### 6.5 Check-ins de test

```sql
-- Check-in au Rick's Café
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
```

### 6.6 Avis de test

```sql
-- Avis sur Rick's Café
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
```

---

## 7. Scripts de Maintenance

### 7.1 Script de nettoyage des anciennes sessions

```sql
-- Supprimer les sessions expirées
DELETE FROM sessions
WHERE expires_at < CURRENT_TIMESTAMP
   OR (is_active = FALSE AND updated_at < DATE_SUB(NOW(), INTERVAL 30 DAY));
```

### 7.2 Script de nettoyage des notifications

```sql
-- Supprimer les notifications lues de plus de 90 jours
DELETE FROM notifications
WHERE is_read = TRUE 
  AND read_at < DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Supprimer les notifications expirées
DELETE FROM notifications
WHERE expires_at IS NOT NULL 
  AND expires_at < CURRENT_TIMESTAMP;
```

### 7.3 Script de mise à jour des compteurs

```sql
-- Recalculer tous les compteurs d'utilisateurs
UPDATE users u
SET 
    checkins_count = (
        SELECT COUNT(*) FROM checkins 
        WHERE user_id = u.id AND validation_status = 'APPROVED'
    ),
    reviews_count = (
        SELECT COUNT(*) FROM reviews 
        WHERE user_id = u.id AND status = 'PUBLISHED'
    ),
    photos_count = (
        SELECT COUNT(*) FROM photos 
        WHERE user_id = u.id AND status = 'ACTIVE'
    );

-- Recalculer les notes moyennes des sites
UPDATE tourist_sites s
SET 
    average_rating = (
        SELECT COALESCE(AVG(overall_rating), 0)
        FROM reviews
        WHERE site_id = s.id AND status = 'PUBLISHED'
    ),
    total_reviews = (
        SELECT COUNT(*)
        FROM reviews
        WHERE site_id = s.id AND status = 'PUBLISHED'
    ),
    favorites_count = (
        SELECT COUNT(*)
        FROM favorites
        WHERE site_id = s.id
    );
```

### 7.4 Script d'archivage

```sql
-- Archiver les sites inactifs depuis plus d'un an
UPDATE tourist_sites
SET 
    status = 'ARCHIVED',
    is_active = FALSE
WHERE last_verified_at < DATE_SUB(NOW(), INTERVAL 1 YEAR)
  AND status = 'PUBLISHED';

-- Soft delete des utilisateurs inactifs depuis 2 ans
UPDATE users
SET 
    status = 'INACTIVE',
    deleted_at = CURRENT_TIMESTAMP
WHERE last_login_at < DATE_SUB(NOW(), INTERVAL 2 YEAR)
  AND status = 'ACTIVE'
  AND deleted_at IS NULL;
```

---

## 8. Configuration MySQL Optimale

### 8.1 Variables de configuration recommandées

```sql
-- my.cnf / my.ini

[mysqld]
# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# InnoDB Settings
innodb_buffer_pool_size = 2G
innodb_log_file_size = 512M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Query Cache (disable in MySQL 8.0+)
# query_cache_type = 0
# query_cache_size = 0

# Connections
max_connections = 200
max_connect_errors = 100

# Timeouts
wait_timeout = 600
interactive_timeout = 600

# Logging
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow-query.log
long_query_time = 2

# Binary logging for replication
log_bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7
```

---

## 9. Script d'Installation Complet

### 9.1 install_database.sh

```bash
#!/bin/bash

# MoroccoCheck Database Installation Script
# Version: 1.0
# Date: 2026-01-16

echo "================================"
echo "MoroccoCheck Database Setup"
echo "================================"

# Variables
DB_NAME="moroccocheck"
DB_USER="moroccocheck_user"
DB_PASS="your_secure_password_here"
DB_HOST="localhost"

echo "Creating database..."
mysql -u root -p <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME}
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}' 
    IDENTIFIED BY '${DB_PASS}';

GRANT ALL PRIVILEGES ON ${DB_NAME}.* 
    TO '${DB_USER}'@'${DB_HOST}';

FLUSH PRIVILEGES;
EOF

echo "Creating tables..."
mysql -u ${DB_USER} -p${DB_PASS} ${DB_NAME} < create_tables.sql

echo "Creating triggers..."
mysql -u ${DB_USER} -p${DB_PASS} ${DB_NAME} < create_triggers.sql

echo "Creating procedures..."
mysql -u ${DB_USER} -p${DB_PASS} ${DB_NAME} < create_procedures.sql

echo "Creating functions..."
mysql -u ${DB_USER} -p${DB_PASS} ${DB_NAME} < create_functions.sql

echo "Creating views..."
mysql -u ${DB_USER} -p${DB_PASS} ${DB_NAME} < create_views.sql

echo "Inserting seed data..."
mysql -u ${DB_USER} -p${DB_PASS} ${DB_NAME} < seed_data.sql

echo "================================"
echo "Database setup completed!"
echo "================================"
```

---

## Résumé

### Scripts créés

✅ **3 Triggers** : Mise à jour automatique des compteurs et calculs
✅ **4 Procédures stockées** : Calcul fraîcheur, badges, check-in
✅ **3 Fonctions** : Distance GPS, niveau, rang
✅ **5 Vues** : Statistiques utilisateurs, sites, leaderboard
✅ **Seeds** : Données de test complètes
✅ **Maintenance** : Scripts de nettoyage et archivage

### Prochaines étapes

Nous avons complété :
- ✅ Phase 2.1 : MCD
- ✅ Phase 2.2 : MLD
- ✅ Phase 2.3 : MPD

Il reste :
- ⏳ Phase 2.4 : Dictionnaire de données (Excel/CSV)

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Phase 2.3 : Modèle Physique de Données**  
**Version 1.0 - Complet**
