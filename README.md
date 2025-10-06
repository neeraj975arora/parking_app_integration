<!-- 
# 🛠️ Monorepo Strategy for Parking App Integration

This monorepo contains the full-stack solution for the smart parking system, including the mobile app, backend services, and optional ML detection logic.

---

## ✅ Recommended Structure

We follow a **monorepo strategy** with clearly separated folders for each major component:

```
parking_app_integration/
├── vision-parking(user_android_app)/           # Android mobile app
│   ├── app/
│   ├── tests/                  # Appium / pytest
│   └── build.gradle

├── Backend(cloud_server)/              # Flask/Django/FastAPI backend
│   ├── src/
│   ├── Dockerfile
│   └── docker-compose.yml

├── Parking-Server(parking_detection system)/         # ML service   Flask/FastAPI
│   ├── models/
│   └── Dockerfile

├── shared/                    # Optional: common models/config
│   ├── api_contracts/
│   └── utils/

├── .github/
│   └── workflows/
│       ├── android-e2e.yml        # Android E2E Tests with Backend
│       ├── backend-ci.yml         # Backend CI
│       └── admin-app-ci.yml       # Admin react app CI
│       ├── ml.yml                 # ML service CI
│       └── e2e.yml                # Full stack E2E tests

├── e2e-artifacts/             # Stores test logs/results
├── README.md
└── Makefile                   # CLI to build/run/test all components
```

---

## 🤖 GitHub Actions Setup

### 🎯 1. Trigger Workflows Conditionally with Path Filters

Only run workflows when relevant folders change:

**Example: `.github/workflows/backend-ci.yml`**
```yaml
on:
  push:
    paths:
      - 'Backend/**'
  pull_request:
    paths:
      - 'Backend/**'
```

### 🧪 2. Full E2E Integration Test Workflow

Triggered when **any major service** changes:

```yaml
# .github/workflows/android-e2e.yml
on:
  push:
    paths:
      - 'Backend/**'
      - 'Vision-Parking/**'
      - 'Parking-Server/**'
  pull_request:
    paths:
      - 'Backend/**'
      - 'Vision-Parking/**'
      - 'Parking-Server/**'

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Start Backend + Detection
        run: docker-compose -f Backend/docker-compose.yml up -d

      - name: Run Android E2E Tests
        run: ./Vision-Parking/tests/run_e2e.sh
```

### 🧩 3. Optional Manual Dispatch

Allow manual full-stack test runs:

```yaml
on:
  workflow_dispatch:
```

---

## 🔁 Summary of Workflow Triggers

| Component           | Workflow File                 | Trigger Path                     |
|---------------------|-------------------------------|----------------------------------|
| Backend Server      | `.github/workflows/backend-ci.yml`   | `Backend/**`                |
| ML Detection        | `.github/workflows/ml.yml`      | `Parking-Server/**`           |
| E2E Integration     | `.github/workflows/android-e2e.yml`     | Any of the above folders         |

---

## 💡 Tips for Scaling

- Add a root `Makefile` with targets like `make test`, `make build`, `make e2e`
- Use `.env` files to manage shared environment configs
- Add `.github/CODEOWNERS` for reviewer auto-assignment
- Consider tools like Nx or Bazel if the repo grows significantly

---

# Contributing to Parking App Integration

Repo: [parking_app_integration](https://github.com/neeraj975arora/parking_app_integration.git)

This repository uses a **monorepo strategy** where all components live together:

- `react_admin_app/` → React-based Admin Web App  

- `Backend/` → Flask/Django/FastAPI Backend  

- `vision-parking/` → Android User App  

- `Parking-Server/` → ML Detection Service  

- `shared/` → Common contracts/utilities

---

## 🚀 General Guidelines

1\. **Clone and work from the monorepo root** --- all `git` commands (branching, committing, pushing) happen at the root level.  

2\. **Branch per feature/fix** --- never commit directly to `main` or `develop`.  

3\. **Commit messages and branch names must be prefixed** with the subproject you are working on.  

4\. **Stage changes carefully** --- prefer `git add <path>` instead of `git add .` to avoid unintended commits.  

5\. Run **local tests/lints** before pushing changes.

---

## 🌱 Branch Naming Convention

When creating a branch, prefix it with the subproject:

- **React Admin App**

  - `react_admin_app/fix-login-validation`

  - `react_admin_app/feature-user-roles`

- **Backend**

  - `backend/add-parking-endpoint`

  - `backend/fix-db-connection`

- **Android User App**

  - `android_user_app/update-ui-theme`

  - `android_user_app/fix-parking-booking`

- **ML Service**

  - `ml/improve-detection-model`

---

## 📝 Commit Message Convention

Each commit message must start with the subproject name:

- **React Admin App**  

  `react_admin_app: fix login validation bug`

- **Backend**  

  `backend: add /parking/available endpoint`

- **Android User App**  

  `android_user_app: update home screen UI`

- **ML Service**  

  `ml: update YOLOv5 detection config`

---

## 🔧 Working on a Subproject

### Example 1: Fixing a Bug in React Admin App

```bash

git checkout -b react_admin_app/fix-login

cd react_admin_app

# make changes

cd ..

git add react_admin_app/src/components/Login.js

git commit -m "react_admin_app: fix login validation bug"

git push origin react_admin_app/fix-login
```

### Example 2: Adding an API Endpoint in Backend

```bash

Copy code

git checkout -b backend/add-parking-endpoint

cd Backend

# edit src/routes/parking.py

cd ..

git add Backend/src/routes/parking.py Backend/tests/test_parking.py

git commit -m "backend: add /parking/available endpoint"

git push origin backend/add-parking-endpoint
```

### Example 3: Updating UI in Android User App

```bash

git checkout -b android_user_app/update-ui

cd vision-parking

# edit layout files

cd ..

git add vision-parking/app/src/main/res/layout/main.xml

git commit -m "android_user_app: update home screen UI"

git push origin android_user_app/update-ui
```



## 📂 .gitignore Strategy

We maintain one single .gitignore at the repo root:

parking_app_integration/.gitignore

This file contains ignore rules for all subprojects (React, Backend, Android, ML, shared).

This ensures consistency and avoids duplication of ignore patterns across subfolders. -->
# 🛠️ Monorepo Strategy for Parking App Integration

This monorepo contains the full-stack solution for the **Smart Parking System**, including the **Admin Web App**, **Backend Services**, **Android User App**, and **ML-based Parking Detection Service** — all integrated under a single repository.

---

## ✅ Recommended Structure

We follow a **monorepo strategy** with clearly separated folders for each major component:

```
parking_app_integration/
├── react_admin_app/                       # Admin Web Dashboard (React)
│   ├── src/
│   ├── public/
│   ├── package.json
│   ├── README.md       <-- Setup and run instructions for admin web app
│
├── Backend/                               # Flask/Django/FastAPI backend
│   ├── src/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── README.md       <-- API endpoints, DB setup, and environment config
│
├── vision-parking/                        # Android User App (Mobile)
│   ├── app/
│   ├── tests/
│   ├── build.gradle
│   ├── README.md       <-- Android Studio setup, emulator testing, E2E guide
│
├── Parking-Server/                        # ML-based Parking Detection Service
│   ├── models/
│   ├── inference/
│   ├── Dockerfile
│   ├── README.md       <-- YOLO setup, model deployment, and API usage
│
├── shared/                                # Common models/config
│   ├── api_contracts/
│   ├── utils/
│   ├── README.md       <-- Shared API specs and reusable modules
│
├── .github/
│   └── workflows/
│       ├── android-e2e.yml
│       ├── backend-ci.yml
│       ├── admin-app-ci.yml
│       ├── ml.yml
│       └── e2e.yml
│
├── e2e-artifacts/                         # Stores test logs/results
├── Makefile                               # CLI to build/run/test all components
└── README.md                              # (This file)
```

Each subproject contains its own `README.md` with detailed setup, environment, and deployment steps.

---

## 📚 Subproject Documentation

### 🖥️ [React Admin App](react_admin_app/README.md)
- **Purpose:** Admin dashboard for viewing parking status, payments, reports, and analytics.  
- **Tech Stack:** React + Tailwind + Recharts + shadcn/ui  
- **Setup:**  
  ```bash
  cd react_admin_app
  npm install
  npm start
  ```
- Refer to the [React Admin App README](react_admin_app/README.md) for details on environment setup, build commands, and CI workflow.

---

### ⚙️ [Backend (Cloud Server)](Backend/README.md)
- **Purpose:** Core business logic, REST APIs, and database operations.  
- **Tech Stack:** Flask + SQLAlchemy + PostgreSQL + JWT Auth  
- **Setup:**  
  ```bash
  cd Backend
  python -m venv venv
  source venv/bin/activate
  pip install -r requirements.txt
  flask run
  ```
- Includes Docker setup (`docker-compose.yml`), seed data, and CI/CD workflow.  
- See the [Backend README](Backend/README.md) for API endpoints, migrations, and DB setup.

---

### 📱 [Vision Parking (Android User App)](vision-parking/README.md)
- **Purpose:** User-facing Android application for booking and managing parking.  
- **Tech Stack:** Kotlin + Retrofit + Jetpack Compose  
- **Setup:**  
  - Open in **Android Studio**  
  - Connect to emulator or real device  
  - Sync Gradle and Run  
- Automated E2E tests (Appium/Pytest) integrated via `.github/workflows/android-e2e.yml`  
- More details in [Vision Parking README](vision-parking/README.md).

---

### 🤖 [Parking Detection Server (ML Service)](Parking-Server/README.md)
- **Purpose:** Detects vehicles, vacant slots, or fights using YOLO-based models.  
- **Tech Stack:** Python + FastAPI + YOLOv8 + OpenCV  
- **Setup:**  
  ```bash
  cd Parking-Server
  pip install -r requirements.txt
  python app.py
  ```
- Model weights are stored in `models/` and served via REST endpoints.  
- For full setup and model retraining, see [ML Service README](Parking-Server/README.md).

---

### 🧩 [Shared Components](shared/README.md)
- **Purpose:** Centralized contracts, common utilities, and reusable components.  
- **Includes:**  
  - `api_contracts/` → Shared request/response schemas  
  - `utils/` → Logger, config parser, constants  
- More info: [Shared README](shared/README.md)

---

## 🤖 GitHub Actions Setup

### 🎯 Conditional Workflow Triggers

Workflows execute **only when relevant folders change** (for performance and clarity).

Example: `.github/workflows/backend-ci.yml`
```yaml
on:
  push:
    paths:
      - 'Backend/**'
  pull_request:
    paths:
      - 'Backend/**'
```

---

### 🧪 Full E2E Integration Tests

Triggered automatically when **any of the major components** (Backend, Android App, or ML Service) are updated.

```yaml
# .github/workflows/android-e2e.yml
on:
  push:
    paths:
      - 'Backend/**'
      - 'vision-parking/**'
      - 'Parking-Server/**'
  pull_request:
    paths:
      - 'Backend/**'
      - 'vision-parking/**'
      - 'Parking-Server/**'

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Start Backend + Detection Services
        run: docker-compose -f Backend/docker-compose.yml up -d
      - name: Run Android E2E Tests
        run: ./vision-parking/tests/run_e2e.sh
```

---

## 🔁 Summary of Workflow Triggers

| Component | Workflow File | Trigger Path |
|------------|----------------|---------------|
| Backend Server | `.github/workflows/backend-ci.yml` | `Backend/**` |
| ML Detection | `.github/workflows/ml.yml` | `Parking-Server/**` |
| React Admin App | `.github/workflows/admin-app-ci.yml` | `react_admin_app/**` |
| Android App | `.github/workflows/android-e2e.yml` | `vision-parking/**` |
| Full E2E Tests | `.github/workflows/e2e.yml` | Any of the above folders |

---

## 💡 Tips for Scaling

- Maintain a **root Makefile** with unified commands (`make build`, `make test`, `make e2e`)  
- Use `.env` files for environment configuration  
- Configure `.github/CODEOWNERS` for automatic reviewers  
- Use caching and parallel jobs to speed up CI  
- Consider **Nx**, **Bazel**, or **Turborepo** for advanced dependency management if the monorepo expands further

---

# 🧭 Contributing to Parking App Integration

Repo: [parking_app_integration](https://github.com/neeraj975arora/parking_app_integration.git)

This repository uses a **monorepo strategy**, with each component tracked independently but integrated through shared contracts and CI workflows.

### Subprojects:
- `react_admin_app/` → Admin Web App (React)  
- `Backend/` → Flask/Django/FastAPI Backend  
- `vision-parking/` → Android User App  
- `Parking-Server/` → ML Detection Service  
- `shared/` → Common contracts/utilities  

---

## 🚀 General Contribution Guidelines

1. **Work from the monorepo root** — all git commands (branching, committing, pushing) are done at the root.  
2. **Use one branch per feature/fix** — never commit directly to `main` or `develop`.  
3. **Prefix branches and commits** with the subproject name.  
4. **Stage carefully** — use `git add <path>` instead of `git add .` to avoid unrelated commits.  
5. **Run tests and linters** before pushing.

---

## 🌱 Branch Naming Convention

| Subproject | Example Branch |
|-------------|----------------|
| React Admin App | `react_admin_app/feature-user-roles` |
| Backend | `backend/add-parking-endpoint` |
| Android User App | `android_user_app/update-ui-theme` |
| ML Service | `ml/improve-detection-model` |

---

## 📝 Commit Message Convention

| Subproject | Example Commit Message |
|-------------|------------------------|
| React Admin App | `react_admin_app: fix login validation bug` |
| Backend | `backend: add /parking/available endpoint` |
| Android User App | `android_user_app: update home screen UI` |
| ML Service | `ml: improve detection model accuracy` |

---

## 📂 .gitignore Strategy

A single `.gitignore` is maintained at the root (`parking_app_integration/.gitignore`) to handle ignores for all subprojects (React, Backend, Android, ML, Shared).