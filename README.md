
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

├── Backend(cloud_server)/              # FastAPI/Flask backend
│   ├── src/
│   ├── Dockerfile
│   └── docker-compose.yml

├── Parking-Server(parking_detection system)/         # Optional: ML microservice
│   ├── models/
│   └── Dockerfile

├── shared/                    # Optional: common models/config
│   ├── api_contracts/
│   └── utils/

├── .github/
│   └── workflows/
│       ├── android.yml        # Android app CI
│       ├── cloud.yml          # Backend CI
│       ├── ml.yml             # ML service CI
│       └── e2e.yml            # Full stack E2E tests

├── e2e-artifacts/             # Stores test logs/results
├── README.md
└── Makefile                   # CLI to build/run/test all components
```

---

## 🤖 GitHub Actions Setup

### 🎯 1. Trigger Workflows Conditionally with Path Filters

Only run workflows when relevant folders change:

**Example: `.github/workflows/cloud.yml`**
```yaml
on:
  push:
    paths:
      - 'cloud_server/**'
  pull_request:
    paths:
      - 'cloud_server/**'
```

### 🧪 2. Full E2E Integration Test Workflow

Triggered when **any major service** changes:

```yaml
# .github/workflows/e2e.yml
on:
  push:
    paths:
      - 'cloud_server/**'
      - 'user_android_app/**'
      - 'parking_detection/**'
  pull_request:
    paths:
      - 'cloud_server/**'
      - 'user_android_app/**'
      - 'parking_detection/**'

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Start Backend + Detection
        run: docker-compose -f cloud_server/docker-compose.yml up -d

      - name: Run Android E2E Tests
        run: ./user_android_app/tests/run_e2e.sh
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
| Android App         | `.github/workflows/android.yml` | `user_android_app/**`            |
| Backend Server      | `.github/workflows/cloud.yml`   | `cloud_server/**`                |
| ML Detection        | `.github/workflows/ml.yml`      | `parking_detection/**`           |
| E2E Integration     | `.github/workflows/e2e.yml`     | Any of the above folders         |

---

## 💡 Tips for Scaling

- Add a root `Makefile` with targets like `make test`, `make build`, `make e2e`
- Use `.env` files to manage shared environment configs
- Add `.github/CODEOWNERS` for reviewer auto-assignment
- Consider tools like Nx or Bazel if the repo grows significantly

---


