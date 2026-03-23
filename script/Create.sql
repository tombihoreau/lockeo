-- =========================================================
-- DATABASE: lockeo
-- =========================================================
CREATE DATABASE IF NOT EXISTS lockeo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lockeo;

-- =========================================================
-- TABLE: Users
-- =========================================================
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    last_name VARCHAR(150),
    first_name VARCHAR(150),
    email VARCHAR(150) UNIQUE NOT NULL,
    login VARCHAR(100) UNIQUE,
    phone_number VARCHAR(50),
    longitude DECIMAL(10,6),
    latitude DECIMAL(10,6),
    city VARCHAR(150),
    postal_code VARCHAR(20),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: NotificationPreferences
-- =========================================================
CREATE TABLE NotificationPreferences (
    notification_preference_id INT AUTO_INCREMENT PRIMARY KEY,
    allowed BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: NotificationTemplates
-- =========================================================
CREATE TABLE NotificationTemplates (
    template_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50),
    title VARCHAR(150),
    content TEXT
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: UserNotifications
-- =========================================================
CREATE TABLE UserNotifications (
    user_notification_id INT AUTO_INCREMENT PRIMARY KEY,
    destination_user_id INT NOT NULL,
    template_id INT,
    status VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (destination_user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES NotificationTemplates(template_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: MessageTemplates
-- =========================================================
CREATE TABLE MessageTemplates (
    message_template_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50),
    title VARCHAR(150),
    content TEXT
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Conversations
-- =========================================================
CREATE TABLE Conversations (
    conversation_id INT AUTO_INCREMENT PRIMARY KEY,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Messages
-- =========================================================
CREATE TABLE Messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    conversation_id INT NOT NULL,
    sender_id INT NOT NULL,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (conversation_id) REFERENCES Conversations(conversation_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES Users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Products
-- =========================================================
CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    price_estimate DECIMAL(10,2),
    state VARCHAR(50),
    longitude DECIMAL(10,6),
    latitude DECIMAL(10,6),
    city VARCHAR(150),
    postal_code VARCHAR(20),
    is_available BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Images
-- =========================================================
CREATE TABLE Images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    uri VARCHAR(255),
    position_image INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Categories
-- =========================================================
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    label VARCHAR(100) NOT NULL,
    parent_id INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: ProductsHasCategories
-- =========================================================
CREATE TABLE ProductsHasCategories (
    product_has_category_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: ProductUnavailabilities
-- =========================================================
CREATE TABLE ProductUnavailabilities (
    unavailability_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    start_date_time DATETIME,
    end_date_time DATETIME,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Offers
-- =========================================================
CREATE TABLE Offers (
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    product_id INT NOT NULL,
    status VARCHAR(50),
    amount DECIMAL(10,2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Reservations
-- =========================================================
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    offer_id INT NOT NULL,
    start_date DATETIME,
    end_date DATETIME,
    status VARCHAR(50),
    final_price DECIMAL(10,2),
    verification_code VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (offer_id) REFERENCES Offers(offer_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Reviews
-- =========================================================
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Favorites
-- =========================================================
CREATE TABLE Favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========================================================
-- TABLE: Conversations ownership
-- =========================================================
ALTER TABLE Conversations
    ADD COLUMN renter_id INT,
    ADD COLUMN owner_id INT,
    ADD FOREIGN KEY (renter_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    ADD FOREIGN KEY (owner_id) REFERENCES Users(user_id) ON DELETE CASCADE;

-- =========================================================
-- INDEXES FOR PERFORMANCE
-- =========================================================

-- USERS
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_users_city ON Users(city);
CREATE INDEX idx_users_postal_code ON Users(postal_code);
CREATE INDEX idx_users_is_verified ON Users(is_verified);

-- PRODUCTS
CREATE INDEX idx_products_name ON Products(name);
CREATE INDEX idx_products_city ON Products(city);
CREATE INDEX idx_products_is_available ON Products(is_available);
CREATE INDEX idx_products_created_at ON Products(created_at);

-- OFFERS
CREATE INDEX idx_offers_status ON Offers(status);
CREATE INDEX idx_offers_created_at ON Offers(created_at);

-- RESERVATIONS
CREATE INDEX idx_reservations_status ON Reservations(status);
CREATE INDEX idx_reservations_offer_id ON Reservations(offer_id);
CREATE INDEX idx_reservations_created_at ON Reservations(created_at);

-- REVIEWS
CREATE INDEX idx_reviews_rating ON Reviews(rating);

-- FAVORITES
CREATE INDEX idx_favorites_user_id ON Favorites(user_id);
CREATE INDEX idx_favorites_product_id ON Favorites(product_id);

-- MESSAGES & CONVERSATIONS
CREATE INDEX idx_messages_conversation_id ON Messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON Messages(sender_id);
CREATE INDEX idx_conversations_created_at ON Conversations(created_at);

-- NOTIFICATIONS
CREATE INDEX idx_user_notifications_status ON UserNotifications(status);
CREATE INDEX idx_user_notifications_user_id ON UserNotifications(destination_user_id);

-- PRODUCT AVAILABILITIES
CREATE INDEX idx_product_unavailabilities_product_id ON ProductUnavailabilities(product_id);

-- CATEGORIES
CREATE INDEX idx_categories_label ON Categories(label);
CREATE INDEX idx_categories_parent_id ON Categories(parent_id);
