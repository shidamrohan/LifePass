# LifePass Flutter Frontend - Complete Development Plan

**Objective:** Build a production-ready Flutter mobile app for patients to manage their emergency health profile.

**Methodology:** Step-by-step development with checkpoints after each phase. No jumping ahead!

---

## 🗺️ Frontend Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│              Flutter Mobile App                     │
│         (Patient Emergency Health App)              │
└─────────────────────────────────────────────────────┘
                        │
      ┌─────────────────┼─────────────────┐
      │                 │                 │
   ┌──▼──┐        ┌─────▼────┐       ┌───▼────┐
   │  UI │        │ Providers │       │ Models │
   │     │        │(State Mgmt)       │        │
   │     │        │           │       │        │
   └──┬──┘        └─────┬────┘       └───┬────┘
      │                 │                 │
      └─────────────────┼─────────────────┘
                        │
            ┌───────────▼──────────┐
            │   Services Layer     │
            │ (API, Storage, etc)  │
            └───────────┬──────────┘
                        │
         ┌──────────────┼──────────────┐
         │              │              │
      ┌──▼──┐      ┌────▼────┐   ┌───▼────┐
      │ API │      │  Local   │   │  QR    │
      │Serv │      │ Storage  │   │  Code  │
      └─────┘      └──────────┘   └────────┘
```

---

## 📊 Development Phases

### PHASE 1: PROJECT SETUP ⚙️ (30 min)
**Goal:** Organized Flutter project structure ready for development

**Tasks:**
1. Create Flutter project from existing template
2. Add dependencies to pubspec.yaml
3. Organize folder structure (lib/screens, lib/models, etc.)
4. Setup API configuration & constants

**Deliverables:**
- ✓ Project compiles without errors
- ✓ Folder structure organized
- ✓ All dependencies installed
- ✓ API base URL configured

**Checkpoint:** When complete, verify `flutter pub get` runs successfully

---

### PHASE 2: CORE INFRASTRUCTURE 🏗️ (1 hour)
**Goal:** Backend connectivity and state management setup

**Tasks:**
1. Create API service layer (HTTP client, request handling)
2. Setup Provider for state management
3. Setup local data persistence (SharedPreferences + Hive)
4. Create data models with JSON serialization

**Key Files to Create:**
- `services/api_service.dart`
- `providers/auth_provider.dart`
- `providers/user_provider.dart`
- `models/user_model.dart`
- `models/patient_model.dart`
- `config/api_config.dart`

**Deliverables:**
- ✓ Can make API calls to backend
- ✓ Auth provider stores JWT token
- ✓ User data persists locally
- ✓ Models serialize/deserialize correctly

**Checkpoint:** Test API connectivity with health endpoint

---

### PHASE 3: AUTHENTICATION SCREENS 🔐 (1.5 hours)
**Goal:** Users can register and login

**Screens to Build:**

#### 3.1 Splash Screen (START HERE!)
- Display LifePass logo
- Check if user is logged in (from local storage)
- Navigate to Home if logged in, else to Login
- Duration: ~2 seconds

**Files:**
- `screens/auth/splash_screen.dart`

**Before Starting:**
- ✓ Phase 1 complete
- ✓ Phase 2 complete

#### 3.2 Login Screen
- Email & password input fields
- Form validation
- Login button
- "Don't have account?" → Register link
- "Forgot password?" link
- Loading state during login
- Error message display

**Files:**
- `screens/auth/login_screen.dart`

#### 3.3 Registration Screen
- Name, Email, Password, Phone input
- Password confirmation
- Role selector (Patient/Doctor)
- Form validation
- Register button
- "Already have account?" → Login link
- Loading state
- Success/error messages

**Files:**
- `screens/auth/register_screen.dart`

#### 3.4 Forgot Password Screen
- Email input
- Send reset link button
- Confirmation message
- Back to login option

**Files:**
- `screens/auth/forgot_password_screen.dart`

**Deliverables:**
- ✓ User can register with all fields
- ✓ User can login with valid credentials
- ✓ Invalid credentials show error
- ✓ Token saved to local storage
- ✓ Navigation works correctly

**Checkpoint:** Complete full login/register flow end-to-end

---

### PHASE 4: PATIENT PROFILE SCREENS 👤 (1 hour)
**Goal:** Patients can create and manage their basic profile

**Screens to Build:**

#### 4.1 Create Profile Screen
- Date of Birth picker
- Gender dropdown (Male/Female/Other)
- Blood Group dropdown (O+, O-, A+, A-, B+, B-, AB+, AB-)
- Height input (cm)
- Weight input (kg)
- Emergency Contact name
- Emergency Contact phone
- Save button
- Validation for all fields

**Files:**
- `screens/profile/create_profile_screen.dart`

#### 4.2 View Profile Screen
- Display all profile data
- Edit button
- Formatted display (nice card layout)
- Read-only mode

**Files:**
- `screens/profile/view_profile_screen.dart`

#### 4.3 Edit Profile Screen
- Same as create but pre-filled
- Update button instead of Save
- Cancel option
- Show success/error message

**Files:**
- `screens/profile/edit_profile_screen.dart`

**Deliverables:**
- ✓ Can create patient profile
- ✓ Profile data displays correctly
- ✓ Can edit all fields
- ✓ Data persists after app restart
- ✓ Navigation flows smoothly

**Checkpoint:** Create profile → View → Edit → Verify data

---

### PHASE 5: MEDICAL HISTORY SCREENS 🏥 (1.5 hours)
**Goal:** Patients can manage medical conditions, allergies, and medicines

**Screens to Build:**

#### 5.1 Diseases Management Screen
- List of diseases (initially empty)
- Add disease button
- Each disease shows: name, diagnosed date
- Delete option per disease
- "Add Disease" dialog:
  - Disease name input
  - Diagnosed date picker
  - Add button

**Files:**
- `screens/medical/diseases_screen.dart`
- `widgets/disease_card.dart`

#### 5.2 Allergies Management Screen
- List of allergies
- Add allergy button
- Each allergy shows: name, severity badge
- Delete option per allergy
- "Add Allergy" dialog:
  - Allergy name input
  - Severity dropdown (Mild/Moderate/Severe)
  - Add button

**Files:**
- `screens/medical/allergies_screen.dart`
- `widgets/allergy_card.dart`

#### 5.3 Medicines Management Screen
- List of medicines
- Add medicine button
- Each medicine shows: name, dosage, frequency
- Delete option per medicine
- "Add Medicine" dialog:
  - Medicine name input
  - Dosage input (e.g., "500mg")
  - Frequency dropdown (e.g., "Twice daily")
  - Add button

**Files:**
- `screens/medical/medicines_screen.dart`
- `widgets/medicine_card.dart`

**Deliverables:**
- ✓ Can add diseases/allergies/medicines
- ✓ Can delete items
- ✓ Lists display correctly
- ✓ Data persists
- ✓ Proper validation

**Checkpoint:** Add 2 diseases, 2 allergies, 2 medicines → Verify all show

---

### PHASE 6: REPORTS & AI SCREENS 📄 (1.5 hours)
**Goal:** Users can upload medical reports and see AI analysis

**Screens to Build:**

#### 6.1 Report Upload Screen
- Report type dropdown (Prescription/Lab Report/Discharge Summary)
- Camera/Gallery picker
- File preview (PDF thumbnail or image)
- Upload button
- Loading state during upload
- Success message with extracted data

**Files:**
- `screens/reports/upload_report_screen.dart`
- `services/file_service.dart`

#### 6.2 Report History Screen
- List of all uploaded reports
- Each report shows: type, upload date, file name
- Thumbnail/preview
- Delete option
- Empty state message if no reports

**Files:**
- `screens/reports/report_history_screen.dart`
- `widgets/report_card.dart`

#### 6.3 AI Summary Screen
- Display AI-extracted data:
  - Blood group
  - Diseases found
  - Medications found
  - Allergies detected
  - Risk level (Low/Medium/High)
  - AI-generated summary text
- Last updated date
- Regenerate button

**Files:**
- `screens/reports/ai_summary_screen.dart`

**Deliverables:**
- ✓ Can pick file from camera/gallery
- ✓ File uploads to backend
- ✓ AI response displays correctly
- ✓ Report history shows all uploads
- ✓ Summary displays extracted data

**Checkpoint:** Upload 1 report → Verify extraction → Check history

---

### PHASE 7: EMERGENCY FEATURES 🆘 (1 hour)
**Goal:** Critical health data accessible in emergencies

**Screens to Build:**

#### 7.1 Emergency Profile Display Screen
- Display consolidated emergency data:
  - Blood Group (highlighted)
  - Chronic Diseases
  - Current Medications
  - Allergies (with severity)
  - Emergency Contact info
  - AI-generated summary
- Last updated timestamp
- Share button (share as PDF/screenshot)
- Regenerate summary button

**Files:**
- `screens/emergency/emergency_profile_screen.dart`
- `widgets/emergency_info_card.dart`

#### 7.2 QR Code Generation Screen
- Generate QR code button
- Display QR code as image
- Download QR button
- Print QR button
- Copy link button (if applicable)
- "Show this to doctor in emergency" instruction text

**Files:**
- `screens/emergency/qr_generation_screen.dart`
- `services/qr_service.dart`

#### 7.3 QR Scanner Screen (Optional - for testing)
- QR scanner UI
- Scan button
- Display scanned data
- Test with your own QR code

**Files:**
- `screens/emergency/qr_scanner_screen.dart` (optional)

**Deliverables:**
- ✓ Emergency profile shows all critical data
- ✓ QR code generates correctly
- ✓ QR code can be downloaded
- ✓ Shares/prints properly

**Checkpoint:** Generate QR → Download → Share successfully

---

### PHASE 8: ACCOUNT & SETTINGS ⚙️ (1 hour)
**Goal:** Account management and compliance features

**Screens to Build:**

#### 8.1 Account Settings Screen
- User profile summary (name, email, phone)
- Edit profile button
- Change password button
- Logout button
- Delete account button (with confirmation)

**Files:**
- `screens/settings/account_settings_screen.dart`

#### 8.2 Audit Logs Screen
- List of who accessed profile
- Shows: doctor name, access date, action
- Filter options (by date range)
- Empty state if no accesses

**Files:**
- `screens/settings/audit_logs_screen.dart`
- `widgets/audit_log_card.dart`

#### 8.3 Help & FAQ Screen
- FAQ accordion
- Contact support button
- App version info
- About LifePass section
- Privacy policy link
- Terms of service link

**Files:**
- `screens/settings/help_screen.dart`

**Deliverables:**
- ✓ Can logout
- ✓ Can view audit logs
- ✓ Help information displays
- ✓ All settings accessible

**Checkpoint:** Logout → Login → Verify token cleared → Can login again

---

### PHASE 9: WIDGETS & COMPONENTS 🎨 (1.5 hours)
**Goal:** Consistent, reusable UI components

**Widgets to Create:**

#### 9.1 Custom App Bar
- Logo/branding
- Title
- Back button (conditional)
- Action buttons (menu, notifications, etc.)

**Files:**
- `widgets/custom_app_bar.dart`

#### 9.2 Input Widgets
- Custom Text Field with validation
- Custom Date Picker
- Custom Dropdown
- Custom Phone Number Field
- All with consistent styling

**Files:**
- `widgets/custom_text_field.dart`
- `widgets/custom_date_picker.dart`
- `widgets/custom_dropdown.dart`

#### 9.3 Button Widgets
- Primary Button (solid background)
- Secondary Button (outline)
- Tertiary Button (text only)
- Loading state for all

**Files:**
- `widgets/custom_button.dart`

#### 9.4 Card Widgets
- Medical info card (rounded, shadow, padding)
- Report card (with thumbnail)
- Data card (for displaying key-value pairs)

**Files:**
- `widgets/info_card.dart`
- `widgets/report_card.dart`

#### 9.5 Dialog Widgets
- Confirmation dialog (Yes/No)
- Loading dialog (with spinner)
- Error dialog (with message)
- Success dialog (with checkmark)

**Files:**
- `widgets/custom_dialogs.dart`

**Deliverables:**
- ✓ All UI components unified
- ✓ Consistent styling across app
- ✓ Reusable components used in screens
- ✓ Loading states visual

**Checkpoint:** Verify all screens use consistent components

---

### PHASE 10: TESTING & POLISH ✨ (2 hours)
**Goal:** App is production-ready and polished

**Testing Tasks:**

#### 10.1 Manual Testing All Screens
```
Checklist:
- [ ] Splash screen works
- [ ] Login with valid credentials
- [ ] Login with invalid credentials (error shown)
- [ ] Register new account
- [ ] Create patient profile
- [ ] Edit patient profile
- [ ] Add diseases/allergies/medicines
- [ ] Delete items from lists
- [ ] Upload report (test with real file)
- [ ] View AI summary
- [ ] Generate QR code
- [ ] View emergency profile
- [ ] Check audit logs
- [ ] Change password
- [ ] Logout and verify
- [ ] Login again to verify persistence
```

#### 10.2 Debug & Fix Issues
- Fix any crashes
- Fix navigation issues
- Fix validation issues
- Fix API integration issues

#### 10.3 UI/UX Polish
- Add smooth transitions between screens
- Add loading animations
- Add success/error animations
- Add pull-to-refresh
- Add empty state illustrations
- Optimize colors and spacing

#### 10.4 Performance Optimization
- Check build size
- Optimize images
- Lazy load lists (pagination)
- Remove debug prints
- Optimize API calls (caching)

**Deliverables:**
- ✓ App is crash-free
- ✓ All flows work end-to-end
- ✓ Animations smooth
- ✓ Loading states clear
- ✓ Error messages helpful
- ✓ App is performant

**Checkpoint:** Full manual testing pass ✓

---

## 🎯 Success Criteria (For Each Phase)

### Phase 1: Project Setup ✓
- [ ] `flutter pub get` succeeds
- [ ] Project structure organized
- [ ] No compilation errors
- [ ] API config file created

### Phase 2: Infrastructure ✓
- [ ] API service can make requests
- [ ] Providers initialize correctly
- [ ] Local storage saves/reads data
- [ ] Models serialize correctly

### Phase 3: Authentication ✓
- [ ] Can register new user
- [ ] Can login with valid credentials
- [ ] Invalid login shows error
- [ ] Token persists locally
- [ ] Splash checks login state correctly

### Phase 4: Patient Profile ✓
- [ ] Can create profile
- [ ] Profile displays correctly
- [ ] Can edit profile
- [ ] Data persists after app restart

### Phase 5: Medical History ✓
- [ ] Can add/delete diseases
- [ ] Can add/delete allergies
- [ ] Can add/delete medicines
- [ ] Lists display correctly

### Phase 6: Reports & AI ✓
- [ ] Can pick and upload file
- [ ] AI extracts data correctly
- [ ] Can view report history
- [ ] AI summary displays all fields

### Phase 7: Emergency Features ✓
- [ ] Emergency profile shows all data
- [ ] QR code generates
- [ ] QR can be downloaded/shared

### Phase 8: Account & Settings ✓
- [ ] Can logout
- [ ] Can view audit logs
- [ ] Help content accessible
- [ ] Account deletion works

### Phase 9: Components ✓
- [ ] All screens use custom components
- [ ] Styling consistent
- [ ] Components reusable

### Phase 10: Testing & Polish ✓
- [ ] Zero crashes
- [ ] All flows work
- [ ] Smooth animations
- [ ] Helpful error messages

---

## 📱 Screen Map

```
Splash Screen
│
├─ User Logged In? No
│  └─ Login Screen
│     ├─ Register Link → Register Screen
│     └─ Forgot Password Link → Forgot Password
│
├─ User Logged In? Yes
│  └─ Home/Dashboard Screen (Tab Navigation)
│     ├─ Tab 1: Profile
│     │  ├─ View Profile
│     │  ├─ Edit Profile
│     │  └─ Medical History
│     │     ├─ Diseases
│     │     ├─ Allergies
│     │     └─ Medicines
│     │
│     ├─ Tab 2: Reports
│     │  ├─ Upload Report
│     │  ├─ Report History
│     │  └─ AI Summary
│     │
│     ├─ Tab 3: Emergency
│     │  ├─ Emergency Profile
│     │  └─ QR Code
│     │
│     └─ Tab 4: Settings
│        ├─ Account Settings
│        ├─ Audit Logs
│        ├─ Help & FAQ
│        └─ Logout
```

---

## 🔄 Workflow (FOR EACH PHASE)

```
1. PLAN Phase Thoroughly
   ↓
2. CREATE All Files
   ↓
3. IMPLEMENT Code
   ↓
4. TEST Thoroughly
   ↓
5. VERIFY Checkpoint is met
   ↓
6. MOVE TO NEXT PHASE
   
   ⚠️  DO NOT SKIP AHEAD!
```

---

## 📝 Notes

- **No Skipping:** Complete phases in order. Don't jump to Phase 5 while Phase 3 is incomplete.
- **Test After Each Phase:** Don't wait until the end to test.
- **Create Checkpoints:** Verify each phase works before moving forward.
- **Document Issues:** If something doesn't work, document it and fix before moving on.
- **Commit to Git:** After each phase, commit changes with descriptive messages.

---

## ⏱️ Estimated Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| 1: Setup | 30 min | ⏳ Pending |
| 2: Infrastructure | 1 hour | ⏳ Pending |
| 3: Authentication | 1.5 hours | ⏳ Pending |
| 4: Patient Profile | 1 hour | ⏳ Pending |
| 5: Medical History | 1.5 hours | ⏳ Pending |
| 6: Reports & AI | 1.5 hours | ⏳ Pending |
| 7: Emergency Features | 1 hour | ⏳ Pending |
| 8: Account & Settings | 1 hour | ⏳ Pending |
| 9: Components | 1.5 hours | ⏳ Pending |
| 10: Testing & Polish | 2 hours | ⏳ Pending |
| **TOTAL** | **~12 hours** | |

---

## 🚀 Ready to Start?

**Next Step:** Begin with **PHASE 1: PROJECT SETUP**

Once you're ready, I'll guide you through creating the Flutter project structure step by step.

Type: "Start Phase 1" and we'll begin! 🎯

---

**Status:** 📋 Planning Complete  
**Date:** August 4, 2026  
**Version:** 1.0
