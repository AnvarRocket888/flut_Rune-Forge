# Rune Forge — App Analysis

## Concept Summary
Rune Forge is a gamified productivity app where users collect virtual runes, each providing passive bonuses (productivity boosts, water reminders, mood tracking). Runes can be combined into "spells" — automated routines. Runes drop randomly every hour and can be upgraded using "energy" that regenerates with sleep. Rare runes require photo confirmation of natural objects.

## Tower Integration
The app is themed around building a **Rune Tower** — a mystical tower the user constructs floor by floor. Each floor unlocks as the user progresses, representing different rune categories. The tower serves as the central visual metaphor for progress.

## Screen Map

### 1. Welcome Screen (Splash)
- Shows on every launch, auto-dismiss after 5 seconds or tap
- Fade-out animation
- App logo, tower silhouette, tagline

### 2. Home Screen
- Greeting with user name
- Tower progress preview (mini tower)
- Daily streak, total runes, XP stats
- Current level & XP bar
- Active spells summary
- Recent rune drops
- Motivational quote
- Energy bar

### 3. Rune Collection Screen
- Grid/list of all collected runes
- Filter by element/category
- Search functionality
- Rune detail cards with stats & bonuses
- Upgrade button (spend energy)
- Rune rarity indicators (Common, Rare, Epic, Legendary)

### 4. Forge Screen (Spell Crafting)
- Combine 2+ runes into a spell
- Visual crafting animation
- Active spells list
- Spell effects description
- Deactivate/edit spells

### 5. Tower Screen
- Visual tower with floors
- Each floor = rune category
- Animated tower building
- Floor details on tap
- Progress indicators per floor

### 6. Profile Screen
- Username & avatar
- Level & XP bar
- Statistics grid (total runes, streak, spells, etc.)
- Achievements preview
- Trophies preview
- Dream Moods / Rune distribution chart

### 7. Achievements Screen (Full)
- All achievements with locked/unlocked state
- Progress bars for in-progress achievements
- Categories: Collection, Forging, Tower, Streaks, Special

### 8. Trophies Screen (Full)
- Trophy showcase
- Rare trophy display
- Trophy history / timeline

### 9. Settings Screen
- Profile edit
- Notification preferences (stub)
- Theme selection (stub)
- Data export
- About / Credits

## Gamification Elements
1. **XP & Levels** — Earn XP for every action, level up with titles
2. **Daily Streaks** — Consecutive days of rune collection
3. **Achievements** — 20+ achievements across categories
4. **Trophies** — Special rare trophies for milestones
5. **Rune Rarity System** — Common/Rare/Epic/Legendary
6. **Energy System** — Resource management for upgrades
7. **Tower Building** — Visual progression
8. **Spell Crafting** — Combining runes
9. **Daily Rune Drops** — Hourly random drops
10. **Photo Confirmation** — AR-lite feature for rare runes (stub)

## Color Scheme (Reference-based)
- Background: Deep navy/dark purple gradient
- Primary accent: Golden yellow (#FFD700 area)
- Cards: Dark blue-gray with subtle borders
- Text: White/cream primary, yellow for highlights
- Success: Emerald green
- Rarity colors: Gray, Blue, Purple, Gold
- Navigation: Dark with golden active state
- Particles: Small yellow/golden dots floating

## Unique Features (Added)
1. **Rune Tower Visualization** — 3D-like tower that grows
2. **Elemental Categories** — Fire, Water, Earth, Air, Spirit
3. **Spell Recipe Book** — Discoverable combinations
4. **Energy Recovery Timer** — Real-time countdown
5. **Rune Lore** — Each rune has backstory text
6. **Daily Challenges** — Special tasks for bonus rewards
7. **Rune Fusion Animations** — Particle effects during forging
