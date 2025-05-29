# 🚑 Smart Pillbox – Your Intelligent Medication Assistant

> **Empowering Health. Preventing Missed Doses. Enhancing Lives.**

Smart Pillbox is a next-generation AI & IoT-powered health companion designed to help patients and caregivers manage medications with zero stress. It goes beyond traditional reminders by using intelligent computer vision, real-time caregiver alerts, prescription scanning, and a rotating pill dispensing mechanism – making it your all-in-one medicine management system.

---

## 🌟 Why Smart Pillbox?

- 🧠 **AI Vision for Pill Detection**
- 🔔 **Offline & Online Smart Reminders**
- 📷 **Scan Prescriptions in Seconds (OCR + Gemini)**
- 💬 **24/7 AI Health Chatbot for Medical Guidance**
- 🧑‍⚕️ **Caregiver Access & Real-Time Notifications**
- 🗂️ **Auto-Generated Monthly Reports**
- 🏥 **Nearby Pharmacy Locator + Digital Prescription Sharing**
- 🔐 **Secure Local Storage + Firebase Syncing**
- 🌍 **Multilingual Support (Hindi, Gujarati, Marathi)**
- ⚡ **Smart Wi-Fi Configuration (No coding needed!)**

---

## 🧪 How It Works

1. **Prescription Upload**: Scan or upload a medical prescription using the in-app OCR + Gemini AI.
2. **Automatic Pill Scheduling**: App auto-fills schedules based on your prescription.
3. **Timed Dispensing**: Motorized mechanism rotates the correct pill to the front.
4. **Camera Check**: ESP32-CAM verifies pill intake using real-time ML model.
5. **Alerts**: Notifications, LCD display + buzzer notify users at exact times.
6. **Caregiver Dashboard**: Family or doctors receive missed-dose alerts & monthly adherence reports.

---

## 🧰 Tech Stack

| Layer        | Technology                                     |
| ------------ | ---------------------------------------------- |
| Frontend     | Flutter (Dart) + Kotlin (for native alarms)    |
| Backend      | Firebase (Firestore, FCM, Auth)                |
| Hardware     | ESP32-CAM, Stepper Motor, ULN2003, LCD, Buzzer |
| AI/ML        | Gemini, TensorFlow Lite                        |
| OCR & Vision | Google ML Kit + Custom Pill Detection Model    |
| Connectivity | Wi-Fi (SmartConfig), I2C, Bluetooth (planned)  |

---

## 📱 App Modules

- 🏠 Home Dashboard
- 📸 Scan Prescription
- 💊 Medicine List & Schedule Editor
- 🤖 Chat with HealthBot (Gemini)
- 🔔 Reminder Logs & Alerts
- 📍 Locate Nearby Pharmacies
- 📊 Monthly Compliance Reports
- 🛠️ Smart Diagnosis
- 👨‍👩‍👧 Caregiver Portal

---

## 🔧 Hardware Setup

- 🔌 **ESP32-CAM**: Detects pill presence + sends data to Firebase
- 🔄 **28BYJ-48 Stepper + ULN2003**: Rotates the pillbox
- 📺 **16x2 LCD (I2C)**: Shows dosage info
- 📣 **TMB12A24 Buzzer**: Alerts user
- 🔋 **18650 Li-Ion Battery + TP4056**: Portable and rechargeable

---

## 🛠️ Getting Started

```bash
# Clone the repository
https://github.com/yourusername/smart-pillbox.git
cd smart-pillbox
flutter pub get
```

- Add `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
- Flash ESP32 firmware using Arduino IDE
- Set up Firebase project and Firestore rules
- Launch app: `flutter run`

---

## 📁 Folder Structure

```
lib/
├── screens/           # UI screens
├── services/          # Firebase, OCR, AI integrations
├── widgets/           # Reusable UI components
├── models/            # Data models
├── utils/             # Helpers, constants
├── main.dart          # App entry
ESP32/
├── firmware/          # Embedded code for pillbox hardware
```

---

## 🔮 Future Roadmap

- 🎙️ Voice Command Support
- ⌚ Smartwatch Sync for Alerts
- 🧬 Personalized AI Suggestions via Health Trends
- 🛒 One-Click Prescription Refill
- 📦 Medicine Stock Tracker
- 📡 GSM Integration for SMS Alerts in low-connectivity areas

---

## 👨‍💻 Developed By

- Samyak Chheda (B008)
- Parth Dave (B011)
- Rishi Vejani (B057)

**Mentor:** Mrs. Sharyu Kadam
**Institution:** Shri Bhagubhai Mafatlal Polytechnic, Computer Engineering Dept.

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 🌈 Experience a Smarter Way to Stay Healthy

With Smart Pillbox, missing a dose is a thing of the past. Designed with empathy. Built with precision. Powered by AI.

🎯 _Try it. Love it. Rely on it._
