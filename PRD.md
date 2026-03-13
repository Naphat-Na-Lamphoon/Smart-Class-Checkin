# Product Requirement Document (PRD)
## Smart Class Check-in & Learning Reflection App

## 1) Problem Statement
Instructors need a lightweight way to confirm student attendance and engagement in class sessions. Traditional roll call confirms only presence, but does not capture participation or reflection. This product provides a two-step class workflow (before and after class) with GPS + QR proof and learning reflection fields.

## 2) Target User
- Primary user: University students enrolled in a class
- Secondary stakeholder: Instructor (reviews attendance and reflections)

## 3) Goals & Success Criteria
- Ensure students check in from a valid location around class time
- Ensure students actively reflect before and after class
- Store records reliably for later review/export

Success indicators (MVP):
- Students can complete check-in and finish-class flows without errors
- Each submission stores timestamp, GPS, QR, and required form fields
- Data persists locally between app sessions

## 4) Scope (MVP)
### In Scope
1. Home screen with navigation to two flows
2. Check-in flow (before class)
   - Capture GPS + timestamp
   - Scan QR
   - Input previous topic, expected topic, mood (1-5)
3. Finish class flow (after class)
   - Scan QR again
   - Capture GPS
   - Input learned today + feedback
4. Local storage persistence using SharedPreferences (JSON list)
5. Firebase Hosting deployment for one web component (landing page)

### Out of Scope (for MVP)
- Authentication
- Instructor dashboard
- Geofence validation rules
- Real-time sync to Firestore

## 5) User Flow
1. Student opens app and sees Home screen
2. Student chooses "Check-in (Before Class)"
3. Student captures GPS/timestamp, scans class QR, fills required fields, submits
4. Student returns to Home and can see recent records
5. At class end, student chooses "Finish Class (After Class)"
6. Student captures GPS, scans QR, fills reflection + feedback, submits

## 6) Data Fields
### Check-in Record
- id (string)
- type = check_in
- timestampIso (ISO8601)
- latitude (double)
- longitude (double)
- qrContent (string)
- previousTopic (string)
- expectedTopic (string)
- moodScore (int: 1-5)

### Finish Class Record
- id (string)
- type = finish
- timestampIso (ISO8601)
- latitude (double)
- longitude (double)
- qrContent (string)
- learnedToday (string)
- feedback (string)

## 7) Validation Rules
- GPS must be captured before submit
- QR content must exist before submit
- Required text fields cannot be empty
- Mood score must be selected for check-in

## 8) Tech Stack
- Flutter (Dart, Material 3)
- Packages:
  - geolocator (GPS + permission)
  - mobile_scanner (QR scanning)
  - shared_preferences (MVP local persistence)
- Firebase Hosting (for deployable component)

## 9) Risks & Mitigation
- Camera/location permission denied -> show clear error and re-request path
- QR unreadable -> allow rescan
- No network for deployment/testing -> keep app fully local for core features

## 10) Future Enhancements
- Firebase Auth + Firestore sync
- Instructor view and analytics dashboard
- Geofence and session time-window policy
- Export attendance report (CSV)
