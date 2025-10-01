
# 🛠️ Monorepo Strategy for Parking App Integration

This monorepo contains the full-stack solution for the smart parking system, including the mobile app, backend services, and optional ML detection logic.

---

## ✅ Recommended Structure

We follow a **monorepo strategy** with clearly separated folders for each major component:

## Repository Structure
```
parking_app_integration/
├── admin_react_app/           # React Admin Dashboard (Frontend)
│   ├── src/                   # Source code
│   ├── public/                # Static assets
│   ├── tests/                 # Test files
│   └── package.json           # Dependencies
├── Backend/                   # Flask API Server
│   ├── app/                   # Application code
│   ├── tests/                 # Test files
│   ├── nginx/                 # Nginx configuration
│   └── docker-compose.yml     # Docker setup
├── Vision-Parking/            # Android Mobile App
│   ├── app/                   # Android source
│   ├── tests/                 # Test files
│   └── build.gradle.kts       # Build configuration
├── Parking-Server/            # Computer Vision Server
│   ├── model/                 # ML models
│   ├── static/                # Static files
│   └── templates/             # HTML templates
├── REST_API_Specs/            # API Documentation
└── README.md                  # Project documentation
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

This ensures consistency and avoids duplication of ignore patterns across subfolders.
