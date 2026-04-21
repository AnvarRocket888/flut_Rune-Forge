# TODO — OveRune Forging

## Future Integrations

### AppsFlyer Analytics
- [ ] Replace `AnalyticsStub` calls with actual AppsFlyer SDK
- [ ] Add AppsFlyer SDK dependency to `pubspec.yaml`
- [ ] Configure AppsFlyer dev key and app ID
- [ ] Set up conversion data handling
- [ ] Map all stub events to AppsFlyer event names
- [ ] Events to track:
  - `app_open` — app launched
  - `rune_collected` — user received a rune
  - `rune_upgraded` — user upgraded a rune
  - `spell_created` — user forged a new spell
  - `spell_activated` — user activated a spell
  - `level_up` — user leveled up
  - `achievement_unlocked` — achievement earned
  - `trophy_earned` — trophy earned
  - `tower_floor_unlocked` — new tower floor built
  - `energy_spent` — energy used for upgrade
  - `photo_confirmation` — photo taken for rare rune (future)
  - `settings_changed` — any settings modification
  - `profile_updated` — name/avatar changed

### Push Notifications
- [ ] Add local notification support for rune drops
- [ ] Daily reminder notifications
- [ ] Streak at risk notifications
- [ ] Energy fully recovered notifications
- [ ] Achievement unlocked notifications

### App Store
- [ ] App Store screenshots
- [ ] App Store description
- [ ] Privacy policy
- [ ] Terms of service
- [ ] App review notes
