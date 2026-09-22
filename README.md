# Sahyog 🤝

### Smart Civic Collaboration Platform

> **Sahyog** is a civic collaboration platform that connects **Citizens, Government, Universities, and Industries** to report, manage, track, and collaboratively resolve civic issues.

---

## 📌 Overview

Sahyog aims to transform traditional civic issue reporting into a transparent and collaborative digital workflow.

Citizens can report problems such as road damage, garbage, drainage, water leakage, street-light issues, and other civic concerns. Government authorities can review and manage these reports, while universities and industries can contribute technical expertise, resources, and solutions.

### Core Workflow

```text
Citizen
   ↓
Report Civic Issue
   ↓
Image + Description + Location
   ↓
AI-Based Classification
   ↓
Government Verification
   ↓
Assignment to University / Industry
   ↓
Action / Solution
   ↓
Status Updates
   ↓
Citizen Tracks Progress
```

---

## 🎯 Objectives

- Provide a simple digital platform for reporting civic issues.
- Enable transparent tracking of submitted reports.
- Improve communication between citizens and authorities.
- Connect government departments with universities and industries.
- Support collaborative problem solving.
- Provide centralized digital records of civic reports.
- Use AI-assisted classification to improve issue categorization.
- Create a scalable foundation for smart-city applications.

---

## 👥 User Roles

| Role | Responsibilities |
|---|---|
| 👤 **Citizen** | Register, report issues, upload images, provide location, track reports, view report history |
| 🏛️ **Government** | Review reports, verify issues, assign challenges, update progress and status |
| 🎓 **University** | Participate in assigned civic challenges and provide technical solutions |
| 🏢 **Industry** | Contribute expertise, resources, technology, and implementation support |

---

## ✨ Key Features

### 🔐 Authentication & Authorization
- User registration and login
- Role-based access
- Secure Supabase authentication
- Session persistence
- Protected application workflows

### 📝 Civic Issue Reporting
- Create civic issue reports
- Add title and description
- Upload supporting images
- Capture or provide location information
- Track report status

### 📊 Dashboards
Dedicated dashboards for:
- Citizens
- Government
- Universities
- Industries

### 🔄 Report Assignment
Government users can assign verified reports/challenges to participating universities or industries and track the assignment lifecycle.

### 📍 Location Support
The application can use location services to associate civic reports with their relevant geographic location.

### 🤖 AI-Assisted Classification
The planned AI component analyzes issue images and helps identify categories such as:
- Road damage
- Garbage/waste
- Drainage
- Water leakage
- Street-light issues
- Public infrastructure
- Other civic issues

### 📈 Report Tracking
Citizens can follow the progress of their reports through structured status updates.

### 🔔 Notifications
The architecture supports notification integration for important report and assignment updates.

### 💬 Communication
The project is designed to support automated communication through services such as the WhatsApp Cloud API.

---

## 🏗️ System Architecture

```text
┌─────────────────────────────────────────────┐
│                  USERS                      │
│ Citizen | Government | University | Industry│
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│             Flutter Application             │
│     Login | Reports | Dashboards | Profile  │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│                 Supabase                    │
│ Authentication | PostgreSQL | Storage | RLS │
└─────────────────────┬───────────────────────┘
                      │
          ┌───────────┼────────────┐
          ▼           ▼            ▼
        AI/ML       Maps       Notifications
          │           │            │
          └───────────┼────────────┘
                      ▼
┌─────────────────────────────────────────────┐
│       Government–University–Industry        │
│              Collaboration                  │
└─────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

### Frontend
- **Flutter**
- **Dart**
- Material UI

### Backend & Database
- **Supabase**
- **PostgreSQL**
- Supabase Authentication
- Supabase Storage
- Row Level Security (RLS)

### APIs & Services
- REST APIs
- Location/GPS services
- Google Maps integration
- Firebase Cloud Messaging
- WhatsApp Cloud API

### AI
- AI/ML-based civic issue image classification

### DevOps
- **Docker**
- Git
- GitHub

---

## 🗄️ Database Structure

The application uses Supabase/PostgreSQL for centralized data management.

### Profiles

```text
profiles
├── id
├── full_name
├── email
├── role
└── created_at
```

Supported roles:

```text
Citizen
University
Industry
Government
```

### Reports

```text
reports
├── report_id
├── citizen_id
├── title
├── description
├── category
├── location
├── image
├── status
└── created_at
```

### Report Assignments

```text
report_assignments
├── assignment_id
├── report_id
├── assigned_to
├── assigned_role
├── status
└── created_at
```

### Report Updates

```text
report_updates
├── report_id
├── title
├── description
├── completed
└── created_at
```

> The exact database schema may evolve as new application modules are implemented.

---

## 🔒 Security

Sahyog is designed with application and database security in mind:

- Supabase Authentication
- Role-based authorization
- PostgreSQL Row Level Security (RLS)
- Protected database operations
- Authenticated API requests
- Secure session management
- Environment variables for sensitive configuration
- Controlled access to uploaded files

---

## 📁 Project Structure

A typical Flutter structure for Sahyog:

```text
sahyog/
│
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
│
├── lib/
│   ├── main.dart
│   │
│   ├── pages/
│   │   ├── landing_page.dart
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── report_issue_page.dart
│   │   ├── success_page.dart
│   │   └── profile_page.dart
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── location_service.dart
│   │   ├── report_store.dart
│   │   ├── report_assignment_store.dart
│   │   ├── challenge_store.dart
│   │   └── team_store.dart
│   │
│   ├── widgets/
│   │   ├── bottom_nav_bar.dart
│   │   ├── profile_button.dart
│   │   ├── profile_menu.dart
│   │   └── reset_button.dart
│   │
│   └── ...
│
├── test/
├── pubspec.yaml
├── pubspec.lock
├── Dockerfile
├── firebase.json
├── analysis_options.yaml
└── README.md
```

> File names and folders may change as the project evolves.

---

## 🚀 Getting Started

### Prerequisites

Install the following:

- Flutter SDK
- Dart SDK
- Android Studio / Android SDK
- VS Code or Android Studio
- Git
- A Supabase project

Verify Flutter:

```bash
flutter doctor
```

---

### 1. Clone the Repository

```bash
git clone https://github.com/abhi-ram-2007/Sahyog.git
cd Sahyog
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

Create a Supabase project and configure:

- Authentication
- PostgreSQL database
- Storage
- Row Level Security policies

Add the required Supabase project URL and publishable/anonymous key through the application's configuration.

**Do not expose the Supabase service-role key in the Flutter client.**

### 4. Run the Application

For Chrome:

```bash
flutter run -d chrome
```

For Android:

```bash
flutter run
```

To check available devices:

```bash
flutter devices
```

---

## 🐳 Docker

Docker can be used to package and deploy supporting application/backend services in a consistent environment.

Typical workflow:

```bash
docker build -t sahyog .
```

Run the container:

```bash
docker run -p 8080:8080 sahyog
```

> Docker configuration should match the actual deployment target and the services included in the current version of the project.

---

## 🔄 Development Workflow

```text
Requirement Analysis
        ↓
UI/UX Design
        ↓
Flutter Development
        ↓
Supabase Integration
        ↓
Authentication & RLS
        ↓
Feature Development
        ↓
Testing & Debugging
        ↓
Docker / Deployment
        ↓
Continuous Improvement
```

The project follows an iterative development approach where features are implemented, tested, refined, and integrated progressively.

---

## 🌟 Expected Impact

### Social
- Encourages citizen participation.
- Improves transparency in civic issue handling.
- Promotes collaboration among stakeholders.

### Economic
- Reduces repetitive manual complaint-management work.
- Helps organizations contribute existing technical resources.
- Encourages industry and university participation.

### Environmental
- Supports faster reporting of waste, drainage, water, and infrastructure issues.
- Provides structured civic data that can support future planning.

### Operational
- Centralized report management.
- Role-based workflows.
- Digital status tracking.
- Better coordination between participating organizations.

---

## 🔮 Future Scope

- Advanced AI image classification
- AI chatbot for citizen assistance
- Predictive civic issue analysis
- Real-time GPS-based tracking
- Multilingual support
- Advanced government analytics
- IoT-based smart-city integration
- Automated WhatsApp communication
- Government API integrations
- Scalable cloud deployment
- Advanced notification and escalation workflows

---

## 📸 Application Modules

The prototype includes or is designed around the following modules:

```text
Landing Page
     ↓
Authentication
     ↓
Role Selection
     ↓
┌────────────┬────────────┬────────────┬────────────┐
│  Citizen   │ Government │ University │  Industry  │
└────────────┴────────────┴────────────┴────────────┘
     ↓
Report / Challenge Management
     ↓
Assignment & Collaboration
     ↓
Progress Tracking
```

---

## 🎓 Project Information

**Project Name:** Sahyog  
**Project Type:** Civic Collaboration Platform / Hackathon Prototype  
**Domain:** Smart City / Civic Technology  
**Frontend:** Flutter & Dart  
**Backend:** Supabase  
**Database:** PostgreSQL  
**Development:** Git & GitHub  
**Deployment/DevOps:** Docker  
**Target Users:** Citizens, Government, Universities, Industries  

---

## 👨‍💻 Team

Developed as a collaborative project for academic/hackathon purposes.

### Team Members

- Tejaswi — Team Leader
- Sruthi
- Jithin
- Sharvani
- Lahari
- Abhiram

**Institution:** Niat X Annamacharya University

---

## 📄 Project Status

**Current Stage:** Prototype / Active Development

The core application architecture, authentication, role-based dashboards, report management, Supabase integration, and assignment workflow are being developed incrementally. Some advanced features such as AI classification, automated WhatsApp communication, and expanded deployment infrastructure are planned for subsequent development stages.

---

## 🤝 Contributing

Contributions and suggestions are welcome.

1. Fork the repository.
2. Create a feature branch.

```bash
git checkout -b feature/your-feature
```

3. Make your changes.
4. Commit your changes.

```bash
git add .
git commit -m "Add your feature"
```

5. Push the branch.

```bash
git push origin feature/your-feature
```

6. Open a Pull Request.

---

## 📜 License

This project is currently developed as an academic/hackathon prototype.

License terms can be added when the project is prepared for public distribution.

---

## 💡 Vision

> **Sahyog aims to create a connected civic ecosystem where reporting a problem is only the beginning—government, universities, industries, and citizens work together toward solving it.**

**Sahyog — Connect. Collaborate. Solve.**
