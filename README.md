
# TeleNeuroAI – AI-Powered Remote Diagnosis Platform using Flutter & Firebase

A cross-platform Flutter application integrated with Firebase and deep learning (CNN ResNet-16) to facilitate **AI-assisted MRI diagnosis** of brain-related disorders. The app supports two user roles: **Patient** and **Doctor**. It allows patients to search for doctors, book appointments, upload MRI scans, and receive intelligent diagnosis reports in **PDF** format — all within a secure and easy-to-use interface.

---

## 🚀 Features

### 👨‍⚕️ **Doctor Module**

* Doctor registration and login
* View incoming appointment requests
* Access patient diagnostic reports
* Respond to and manage appointments

### 🧑‍🦱 **Patient Module**

* Sign up/login with secure Firebase Auth
* Update personal profile and medical history
* Search for doctors by specialty or name
* Book appointments with selected doctors
* Upload brain MRI scans for diagnosis
* Get automated diagnosis using AI (CNN - ResNet-16)
* Receive downloadable PDF reports
* Reports are automatically sent to the booked doctor

---

## 🧠 Supported Diagnoses (via AI)

The system uses a trained Convolutional Neural Network (ResNet-16) to classify uploaded MRI images into the following categories:

1. **Brain Tumor**
2. **Alzheimer’s Disease**
3. **Multiple Sclerosis**

All predictions are accompanied by a confidence score and included in a comprehensive PDF report.

---

## 🧬 AI Model – ResNet-16 (CNN)

* Trained on labeled MRI datasets for three neurological disorders
* Built using **TensorFlow/Keras**
* Integrated with the Flutter app via REST API or Firebase Functions
* Ensures real-time prediction with minimal latency

---

## 📱 Tech Stack

| Category    | Technology                                      |
| ----------- | ----------------------------------------------- |
| Frontend    | Flutter                                         |
| Backend     | Firebase (Auth, Firestore, Storage, Functions)  |
| AI/ML Model | Python, TensorFlow, ResNet-16 CNN               |
| Deployment  | Firebase Cloud Functions / Flask API (optional) |
| PDF Reports | ReportLab / custom generation in Python         |

---

## 📄 How It Works

### 🔁 Workflow

1. **User Authentication**

   * Patients and doctors sign in via Firebase Auth.

2. **Patient Flow**

   * Update profile → Search doctor → Book appointment
   * Upload MRI image → AI model processes it → PDF report generated → View or download report
   * PDF report is sent to the selected doctor automatically

3. **Doctor Flow**

   * Login → View scheduled appointments → Access patient diagnostic report
   * Review and recommend further treatment or tests

---

## 📦 Setup Instructions

### ✅ Prerequisites

* Flutter SDK installed
* Firebase account & project set up
* Python environment for AI model (TensorFlow)
* Firebase CLI installed

### 🔧 Flutter Setup

```bash
git clone https://github.com/yourusername/TeleNeuroAI.git
cd TeleNeuroAI
flutter pub get
flutter run
```

### ⚙️ Firebase Setup

* Create a Firebase project
* Enable **Authentication**, **Firestore**, and **Storage**
* Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### 🧠 AI Backend Setup (Optional)

* Host the AI model using Flask or Firebase Cloud Functions
* Example Python code for inference is in `ai_model/predict.py`

---

## 📄 Example Diagnosis Report (PDF)

The PDF includes:

* Patient Name and Date
* Uploaded MRI image
* Predicted Condition (e.g., Brain Tumor: 94.3% confidence)
* Description of the condition
* Recommendations

---

## 🔐 Security & Privacy

* All data is securely stored on Firebase
* MRI scans and reports are protected via Firebase Storage Rules
* Role-based access: doctors cannot edit reports, patients cannot view others' data

---

## 🤝 Contributing

Contributions are welcome!
If you’d like to fix a bug, add a feature, or improve the documentation, feel free to submit a pull request.

---

## 📧 Contact

For questions or collaboration:

* Email: [ansali194700@gmail.com)

---

## 🌟 Acknowledgements

* [TensorFlow](https://www.tensorflow.org/)
* [Flutter](https://flutter.dev/)
* [Firebase](https://firebase.google.com/)
* [Kaggle MRI Datasets](https://www.kaggle.com/)
* [ResNet Paper](https://arxiv.org/abs/1512.03385)

