# TODO — Rune Forge

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

### Photo Confirmation (Rare Runes)
- [ ] Integrate camera access
- [ ] Add image classification model (on-device)
- [ ] Map natural object shapes to rune types
- [ ] Add photo gallery for captured objects
- [ ] Privacy policy update for camera usage

### Online Features (Future)
- [ ] Cloud sync with Firebase/Supabase
- [ ] Leaderboards
- [ ] Friend system
- [ ] Rune trading
- [ ] Global events / challenges

### Widget (iOS)
- [ ] Home screen widget showing current runes
- [ ] Lock screen widget for daily streak
- [ ] Tower progress widget

### Color Scheme
- [ ] Replace placeholder colors in `app_colors.dart` with final scheme
- [ ] Update `additional info/color_scheme.css` with final colors
- [ ] Test all screens with new colors

### Localization
- [ ] All UI text is in English (done)
- [ ] Prepare for future localization (l10n setup)
- [ ] Extract all strings to ARB files

### Accessibility
- [ ] VoiceOver labels for all interactive elements
- [ ] Dynamic type support
- [ ] Reduced motion support

### Performance
- [ ] Profile animations on older devices
- [ ] Optimize particle systems
- [ ] Lazy load rune images/icons
- [ ] Database optimization for large rune collections

### App Store
- [ ] App Store screenshots
- [ ] App Store description
- [ ] Privacy policy
- [ ] Terms of service
- [ ] App review notes
