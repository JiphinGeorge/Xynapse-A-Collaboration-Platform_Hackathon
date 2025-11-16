# 🚀 Xynapse – A Collaborative Project Platform

A Flutter-based collaboration platform that allows users to create projects, join projects, explore public projects, and work together seamlessly.  
Built for the **Execute Event Hackathon (Theme: Collaborative Projects)**.

---

## 📌 Features

### 👤 User Features
- Create, edit, and delete personal projects  
- Join projects created by other users  
- Collaborate on joint projects  
- Explore public projects  
- User profile with avatar support  
- Real-time updates through SQLite queries  

### 🛡 Admin Features
- Admin dashboard with metrics  
- View all users  
- View all projects  
- Approve / reject submitted projects  
- View feedback  
- Delete projects / users  
- Live Metrics Page (auto-updates every 5 seconds)

---

## 🛠 Tech Stack

### **Frontend**
- **Flutter 3.x**
- **Dart**
- Google Fonts  
- Provider (State Management)

### **Backend / Local Database**
- **SQLite** (`sqflite` package)  
- Custom DBHelper with CRUD  

### **Other Tools**
- SharedPreferences  
- Image Picker  
- Custom animations & transitions  

---

## 🎯 Core Hackathon Requirements — Achieved ✔

| Requirement | Status |
|------------|--------|
| Home page displaying all projects | ✅ Completed |
| My Projects page (Add/Edit/Delete) | ✅ Completed |
| Collaboration page | ✅ Completed |
| Join existing projects | ✅ Completed |
| Create combined / joint projects | ✅ Completed |
| Multiple user simulation (5+ users) | ✅ Completed |
| Admin module | ✅ Completed |
| Live metrics dashboard | ✅ Completed |
| Clean UI & good UX | ✅ Completed |

---

## 📂 Folder Structure


lib/
│
├── db/
│   └── db_helper.dart
│
├── models/
│   ├── user_model.dart
│   ├── project_model.dart
│   ├── message_model.dart
│
├── providers/
│   └── project_provider.dart
│
├── screens/
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── admin_live_metrics.dart
│   │   ├── admin_project_details.dart
│   │   ├── admin_projects_screen.dart
│   │   ├── admin_users_screen.dart
│   │   └── admin_feedback_screen.dart
│   │
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── admin_login_screen.dart
│   │
│   ├── add_edit_project_screen.dart
│   ├── collaboration_screen.dart
│   ├── explore_projects_screen.dart
│   ├── main_wrapper.dart
│   ├── my_projects_screen.dart
│   ├── profile_screen.dart
│   ├── project_details_screen.dart
│   ├── project_search_filter.dart
│   ├── user_home_screen.dart
│   └── splash_screen.dart
│
├── services/
│   └── notification_service.dart
│
├── utils/
│   └── fade_route.dart
│
├── widgets/
│   ├── project_card.dart
│   └── user_avatar.dart
│
├── main.dart
└── app_router.dart


---

## 🗄 SQLite Database Overview

### **Tables**
1. **users**
   - id  
   - name  
   - email  
   - password  
   - created_at  
   - profile_image  

2. **projects**
   - id  
   - title  
   - description  
   - category  
   - creator_id  
   - is_public  
   - status (pending/approved/rejected)  
   - created_at  

3. **collaborators**
   - id  
   - project_id  
   - user_id  

4. **feedback**
   - id  
   - user_id  
   - message  
   - created_at  

5. **activity_log**
   - id  
   - action  
   - timestamp  

---

## ⚙️ Installation Guide

### **1. Clone the repository**
```bash
git clone https://github.com/JiphinGeorge/Xynapse-A-Collaboration-Platform_Hackathon.git
cd Xynapse-A-Collaboration-Platform_Hackathon
```
### **2. Install dependencies**

flutter pub get

### **3. Run the app**
flutter run

-----
###  **4. 🧪Test Users (Demo Data)**

| Email              | Password | Role  |
|--------------------|----------|-------|
| admin@xynapse.com  | admin123 | Admin |
| jiphin@example.com | 123456   | User  |
| merin@example.com  | 123456   | User  |
| ankith@example.com | 123456   | User  |


## 📸 Screenshots

### 🚀 Splash Screen
![Splash Screen]<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/ceb2a388-3a95-443b-aaef-c5ad07a69787" />


### 🔐 Login Screen
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/f05a4355-8fc9-4d9f-b7ef-874bef9c0be1" />

### 📝 User Registration
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/6dc9ccc1-21be-4b96-b46a-ff4f78ee6b86" />


### 🏠 User Home
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/4e82071b-d152-4123-bf0b-22e62006c1b1" />


### 📁 My Projects
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/9008d373-2de3-466d-8de7-621fcacaed60" />


### 🤝 Collaborations
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/ae2d6eff-f8d2-43da-a3e3-05eec88e3c23" />


### 👤 User Profile
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/1acf8d25-56e6-4666-9215-dadc090dc59e" />


### 🛡 Admin Login
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/f2018326-ed4f-4e68-9bd9-9b2d23a8ff5e" />

### 🛠 Admin Panel (Dashboard Overview)
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/6685ef04-ebf4-46d5-a1e5-9ed8d16fdd38" />


### 📝 Project Submitted / Project Details
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/205050e2-9510-4819-83fd-89cabc4aba81" />

### 📊 Live Metrics (Admin)
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/ae2096f9-8942-42a9-befa-2fd9f110edac" />


### 👥 Registered Users (Admin)
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/b6ddcd6c-a249-4330-8565-de89276889d7" />


### 💬 Feedback Messages (Admin)
<img width="720" height="1600" alt="image" src="https://github.com/user-attachments/assets/c27380d3-4fee-4285-ae44-92871feea212" />


---
## 🔮 Future Improvements

- Real-time collaboration using Firebase  
- Chat module for project members  
- Notifications for project updates  
- Cloud storage for images  
- Multi-role system (Mentor, Reviewer)  
- Analytics & charts using `fl_chart`  
- Dark/light theme switch  

---

## 📜 License

This project is licensed under the **MIT License**.

Copyright (c) 2025 Jiphin George 

Permission is hereby granted, free of charge, to any person obtaining a copy...

---

## 🏆 Credits

Developed by **Jiphin George**  
Built during **Execute Event Hackathon — 2025**

---

## ⭐ Support the Project

If you like this project, please consider **starring the GitHub repo**:

👉 **https://github.com/JiphinGeorge/Xynapse-A-Collaboration-Platform_Hackathon**
