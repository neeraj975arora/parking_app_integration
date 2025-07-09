# Monorepo Strategy for Parking App Integration

This monorepo contains the full-stack solution for the smart parking system, including the mobile app, backend services, and optional ML detection logic.

---

## Recommended Structure 

We follow a **monorepo strategy** with clearly separated folders for each major component:

```
parking_app_integration/
├── user_android_app/           # Android mobile app
│   ├── app/
│   ├── tests/                  # Appium / pytest
│   └── build.gradle

├── cloud_server/              # FastAPI/Flask backend
│   ├── src/
│   ├── Dockerfile
│   └── docker-compose.yml

├── parking_detection/         # Optional: ML microservice
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

### Explanation

- **user_android_app/**: Contains the Android mobile app source code and its tests.
- **cloud_server/**: Backend server (e.g., FastAPI/Flask) with its own Docker and compose files.
- **parking_detection/**: (Optional) ML microservice for parking detection.
- **shared/**: (Optional) Shared code, models, or API contracts between services.
- **.github/workflows/**: CI/CD pipelines for each component and full-stack E2E tests.
- **e2e-artifacts/**: Stores logs and results from E2E tests.
- **Makefile**: Top-level commands for building, testing, and running all components.

---

# GitHub Setup Instructions

## Scenario A: Changes in One Project (e.g., Backend)  

1. **Clone the Repository**
   ```bash
   git clone https://github.com/OWNER/REPO_NAME.git   # Download the repository to your local machine
   cd REPO_NAME                                       # Move into the project directory
   ```
   Replace `OWNER` and `REPO_NAME` with the actual GitHub username/organization and repository name.

2. **Set Upstream and Pull Latest Main**
   ```bash
   git checkout main           # Switch to the main branch
   git pull origin main        # Get the latest changes from the remote main branch
   ```

3. **Create a New Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name   # Create and switch to a new branch for your feature
   ```
   Use a descriptive branch name.

4. **Make Your Changes**
   Edit/add code in the relevant subfolder (e.g., `Backend/`).

5. **Stage and Commit Your Changes**
   ```bash
   git add Backend/    # Stage all changes in the Backend folder
   git commit -m "[Backend] Add feature: your feature description"   # Commit with a descriptive message
   ```

6. **Push Your Branch to GitHub**
   ```bash
   git push origin feature/your-feature-name   # Upload your branch and commits to GitHub
   ```

7. **Create a Pull Request (PR) on GitHub**
   - Go to the repository on GitHub.
   - You will see a prompt to create a Pull Request for your newly pushed branch.
   - Click "Compare & pull request".
   - Fill in the PR title and description, and select `main` as the base branch.
   - Submit the PR.

8. **Request Review and Wait for Approval**
   - Assign reviewers as per the repository's guidelines.
   - Wait for feedback and make any requested changes (repeat steps 4–6 as needed).

9. **PR Merged by Owner**
   - Only the repository owner or someone with write/merge permissions should merge the PR after approval.

**Note:**
If you are not a direct collaborator (i.e., you do not have push access), you would need to fork the repository and follow a fork-based workflow. See the note at the end of this section.

---

## Scenario B: Changes Across Two Projects (e.g., Vision-Parking and Backend)  

1. **Clone the Repository**
   ```bash
   git clone https://github.com/OWNER/REPO_NAME.git   # Download the repository to your local machine
   cd REPO_NAME                                       # Move into the project directory
   ```

2. **Set Upstream and Pull Latest Main**
   ```bash
   git checkout main           # Switch to the main branch
   git pull origin main        # Get the latest changes from the remote main branch
   ```

3. **Create a New Feature Branch**
   ```bash
   git checkout -b feature/cross-project-feature   # Create and switch to a new branch for your cross-project feature
   ```

4. **Make Changes in Both Relevant Folders**
   Edit/add code in both relevant subfolders (e.g., `Backend/` and `Vision-Parking/`).

5. **Stage and Commit All Changes**
   ```bash
   git add Backend/ Vision-Parking/   # Stage all changes in both folders
   git commit -m "[Cross-Project] Implement feature across Backend and Vision-Parking"   # Commit with a descriptive message
   ```

6. **Push Your Branch to GitHub**
   ```bash
   git push origin feature/cross-project-feature   # Upload your branch and commits to GitHub
   ```

7. **Create a Pull Request (PR) on GitHub**
   - Go to the repository on GitHub.
   - Click "Compare & pull request" for your branch.
   - Fill in the PR title and description, and select `main` as the base branch.
   - Submit the PR.

8. **Request Review and Wait for Approval**
   - Assign reviewers as per the repository's guidelines.
   - Wait for feedback and make any requested changes (repeat steps 4–6 as needed).

9. **PR Merged by Owner**
   - Only the repository owner or someone with write/merge permissions should merge the PR after approval.

---

## Scenario C: Initial Check-in of a New App (e.g., Admin React App)  

1. **Clone the Repository**
   ```bash
   git clone https://github.com/OWNER/REPO_NAME.git   # Download the repository to your local machine
   cd REPO_NAME                                       # Move into the project directory
   ```

2. **Ensure You Are on the Main Branch and Up to Date**
   ```bash
   git checkout main           # Switch to the main branch
   git pull origin main        # Get the latest changes from the remote main branch
   ```

3. **Add Your New App Folder (e.g., `admin_react_app/`)**
   Add the foundational codebase for the new app.

4. **Stage and Commit the Initial Codebase**
   ```bash
   git add admin_react_app/    # Stage all files in the new app folder
   git commit -m "Initial commit: Add admin React app base code"   # Commit with a descriptive message
   ```

5. **Push Directly to Main**
   ```bash
   git push origin main        # Upload your commit directly to the main branch
   ```

6. **For Future Feature Development, Use Branches as in Scenario A**

---

**Note for Fork-Based Workflow:**
If you do not have push access to the repository, fork the repository on GitHub, clone your fork, create a branch, push to your fork, and then create a Pull Request from your fork/branch to the original repository's `main` branch.

---
# Best Practices

- Always pull the latest `main` before starting new work.
- Use descriptive branch names (e.g., `feature/`, `bugfix/`, `hotfix/`).
- Keep PRs focused and small for easier review.
- Use PR templates and request reviews from relevant owners.
- Only owners should merge PRs to `main`. 

---
# Other approaches for Project Structure 

To mono repo (single GitHub repo for android, backend, ML(parking server), admin etc.) could have been using separate GitHub repos for each project e.g. android has its own repo, backend hosted in separate repo etc. The motivation for single repo is that CI/CD for android is using main latest codebase of backend as it is end to end scenarios. If we have opted for multi-repo approach, for end to end testing, one could have used docker image of backend (as opposed to building fresh docker image as in current approach)