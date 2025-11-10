# Nari’s Guild Quest System 🧭
*A Discord RPG bot built with Java and JDA*

---

### 📖 Overview
**Nari’s Guild Quest System** is a Discord-based RPG experience where users can:
- Create their own adventurer profiles  
- Join quests posted on a guild quest board  
- Earn XP, level up, and develop stats  
- Interact through AI-driven flavor text from Nari

All gameplay logic runs locally on the bot and database — the AI is only used for narration and dialogue.

---

### ⚙️ Tech Stack
| Component | Technology |
|------------|-------------|
| **Bot** | Java 21 + [JDA 5](https://github.com/discord-jda/JDA) |
| **Database** | MariaDB (via JDBC) |
| **Backend Management** | Docker Compose |
| **Environment Config** | `.env` + [java-dotenv](https://github.com/cdimascio/java-dotenv) |
| **AI Flavor** | DeepSeek API (optional, text-only) |
| **Hosting** | Raspberry Pi 5 (8 GB RAM, SSD) |

---

### 🧩 Planned Features
| Phase | Feature | Description |
|:--:|--|--|
| **1** | Character Creation | `/nari create` – guided dialogue that builds a character profile |
| **2** | Character Viewer | `/nari character show` – display character info and stats |
| **3** | Quest Board | `/nari questboard` – view open quests and join them |
| **4** | Quest Join & Progress | `/nari joinquest <id>` and `/nari myquests` – handle joining and tracking |
| **5** | Daily Quest Resolution | Automatic daily resolver that calculates quest outcomes |
| **6** | XP & Leveling System | Stat-based experience and progression logic |
| **7** | Admin Tools | Commands for managing quests, characters, and debug |
| **8** | Optional AI Dialogue | Nari’s AI narration for quest flavor and player interaction |

---

### 🗺️ Milestone Roadmap
| Milestone | Target | Description |
|------------|---------|-------------|
| **M1 – Setup & Scaffolding** | ✅ Done | Repository, Maven project, and database Docker ready |
| **M2 – Core Data Layer** | WIP | Define database schema (`characters`, `quests`, `user_links`) and DAO classes |
| **M3 – JDA Integration** | ⏳ Next | Initialize bot, connect Discord, register `/nari` commands |
| **M4 – Character Creation Flow** | TBD | Handle user onboarding and persistent data storage |
| **M5 – Quest Board System** | TBD | Implement quest listing, joining, and XP system |
| **M6 – AI Flavor Module** | Later | Connect DeepSeek API for storytelling output |
| **M7 – Docker Deployment** | Later | Compose setup for bot + MariaDB on Raspberry Pi |

---

### 🧠 Developer Notes
- One player = one character per Discord account  
- All commands begin with `/nari`  
- Data stored locally in MariaDB (no external cloud)  
- Nari’s AI personality is for *flavor only*; game logic is deterministic  

---

### 🧰 Getting Started (w.i.p)
**Local run (Maven):**
```bash
mvn clean package
java -jar target/discord-bot-nari-1.0.0-all.jar
