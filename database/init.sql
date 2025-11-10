-- Nari’s Guild Quest System – Database Init
-- Engine: MariaDB 11.x
-- Charset: utf8mb4 for full emoji + symbols

-- Optional: only create DB if you run this outside of docker env vars
-- CREATE DATABASE IF NOT EXISTS `discord-bot-nari` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE `discord-bot-nari`;

-- Global defaults
SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- -----------------------------
-- Tables
-- -----------------------------

-- 1) Discord users (one per Discord account)
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  discord_user_id VARCHAR(32) NOT NULL,      -- Snowflake as string
  discord_guild_id VARCHAR(32) NULL,         -- Optional: per-guild linkage
  username VARCHAR(64) NULL,                 -- Snapshot username (not authoritative)
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_discord (discord_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) Player characters (exactly one per user in v1)
CREATE TABLE IF NOT EXISTS characters (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,          -- FK -> users.id
  name VARCHAR(50) NOT NULL,
  race VARCHAR(40) NULL,                     -- free text for now (Human/Elf/etc.)
  class VARCHAR(40) NULL,                    -- free text for now (Warrior/Mage/etc.)
  level INT UNSIGNED NOT NULL DEFAULT 1,
  xp BIGINT UNSIGNED NOT NULL DEFAULT 0,
  -- Simple core stats; expand later if needed
  stat_str TINYINT UNSIGNED NOT NULL DEFAULT 8,
  stat_dex TINYINT UNSIGNED NOT NULL DEFAULT 8,
  stat_int TINYINT UNSIGNED NOT NULL DEFAULT 8,
  stat_cha TINYINT UNSIGNED NOT NULL DEFAULT 8,
  hp_max INT UNSIGNED NOT NULL DEFAULT 10,
  hp_current INT UNSIGNED NOT NULL DEFAULT 10,
  coins_copper BIGINT UNSIGNED NOT NULL DEFAULT 0, -- use your custom currency math in app layer
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_characters_user (user_id),   -- one character per user (v1 rule)
  CONSTRAINT fk_characters_user FOREIGN KEY (user_id)
    REFERENCES users(id) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3) Quests posted on the board
CREATE TABLE IF NOT EXISTS quests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(80) NOT NULL,
  description TEXT NULL,
  difficulty TINYINT UNSIGNED NOT NULL DEFAULT 1,       -- 1..10 or your own scale
  required_level INT UNSIGNED NOT NULL DEFAULT 1,
  status ENUM('OPEN','LOCKED','RESOLVED','CANCELLED') NOT NULL DEFAULT 'OPEN',
  resolve_at DATETIME NULL,                              -- for daily/auto resolver
  posted_by_user_id BIGINT UNSIGNED NULL,                -- optional FK
  reward_xp INT UNSIGNED NOT NULL DEFAULT 0,
  reward_coins_copper INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_quests_status (status),
  KEY idx_quests_resolve_at (resolve_at),
  CONSTRAINT fk_quests_posted_by FOREIGN KEY (posted_by_user_id)
    REFERENCES users(id) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4) Participation (many-to-many between characters and quests)
CREATE TABLE IF NOT EXISTS quest_participants (
  quest_id BIGINT UNSIGNED NOT NULL,
  character_id BIGINT UNSIGNED NOT NULL,
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  result ENUM('PENDING','SUCCESS','FAILURE','CANCELLED') NOT NULL DEFAULT 'PENDING',
  xp_awarded INT UNSIGNED NOT NULL DEFAULT 0,
  coins_awarded_copper INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (quest_id, character_id),
  CONSTRAINT fk_qp_quest FOREIGN KEY (quest_id)
    REFERENCES quests(id) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_qp_character FOREIGN KEY (character_id)
    REFERENCES characters(id) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------
-- Seed (safe demo data)
-- -----------------------------
INSERT INTO users (discord_user_id, discord_guild_id, username)
VALUES
  ('000000000000000001', NULL, 'DemoUser')
ON DUPLICATE KEY UPDATE username = VALUES(username);

INSERT INTO characters (user_id, name, race, class, level, xp, stat_str, stat_dex, stat_int, stat_cha, hp_max, hp_current, coins_copper)
SELECT id, 'Cedhal', 'Human', 'Adventurer', 1, 0, 10, 10, 10, 10, 12, 12, 0
FROM users WHERE discord_user_id = '000000000000000001'
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO quests (title, description, difficulty, required_level, status, resolve_at, reward_xp, reward_coins_copper)
VALUES
  ('Rats in the Cellar', 'Help the tavern clear out a nest of oversized rats.', 1, 1, 'OPEN', NULL, 25, 120),
  ('Escort the Merchant', 'Protect a caravan through the forest road.', 2, 1, 'OPEN', NULL, 40, 300)
ON DUPLICATE KEY UPDATE description = VALUES(description);