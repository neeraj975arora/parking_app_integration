# 🚀 GitHub Workflow Guide - Parking App Integration

This comprehensive guide covers all Git and GitHub commands for managing the Parking App Integration monorepo, including branching, merging, pull requests, and collaboration workflows.

## 📋 Table of Contents

- [Repository Overview](#repository-overview)
- [Initial Setup](#initial-setup)
- [Basic Git Commands](#basic-git-commands)
- [Branching Strategy](#branching-strategy)
- [Feature Development Workflows](#feature-development-workflows)
- [Pull Request Management](#pull-request-management)
- [Code Review Process](#code-review-process)
- [Merging Strategies](#merging-strategies)
- [Collaboration Guidelines](#collaboration-guidelines)
- [Troubleshooting](#troubleshooting)

## 🏗️ Repository Overview

### Monorepo Structure
```
parking_app_integration/
├── admin_react_app/           # React Admin Dashboard
├── Backend/                   # Flask API Server
├── Vision-Parking/            # Android Mobile App
├── Parking-Server/            # Computer Vision Server
├── REST_API_Specs/            # API Documentation
└── README.md                  # Project documentation
```

### Repository URL
```bash
https://github.com/neeraj975arora/parking_app_integration.git
```

## 🚀 Initial Setup

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/neeraj975arora/parking_app_integration.git
cd parking_app_integration

# Verify you're on main branch
git branch

# Pull latest changes
git pull origin main
```

### 2. Configure Git (First Time Setup)

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Verify configuration
git config --list
```

## 📚 Basic Git Commands

### Essential Commands

```bash
# Check status
git status

# View commit history
git log --oneline
git log --graph --oneline --all

# View changes
git diff
git diff --staged

# Add files to staging
git add .
git add filename.txt
git add Backend/

# Commit changes
git commit -m "Your commit message"
git commit -am "Add and commit all changes"

# Push to remote
git push origin branch-name

# Pull latest changes
git pull origin main
git pull origin branch-name

# Fetch latest changes without merging
git fetch origin
```

### File Management

```bash
# Remove file from Git tracking
git rm filename.txt
git rm --cached filename.txt  # Keep local file

# Rename file
git mv oldname.txt newname.txt

# Undo changes
git checkout -- filename.txt
git reset HEAD filename.txt

# Stash changes
git stash
git stash pop
git stash list
git stash apply stash@{0}
```

## 🌿 Branching Strategy

### Branch Naming Conventions

```bash
# Feature branches
feature/feature-name
feature/reactapp-integration
feature/backend-auth-fix

# Bug fix branches
bugfix/issue-description
bugfix/login-validation-error

# Hotfix branches
hotfix/critical-security-patch

# Release branches
release/v1.0.0
release/v2.0.0
```

### Branch Management Commands

```bash
# Create and switch to new branch
git checkout -b feature/your-feature-name
git switch -c feature/your-feature-name

# Switch between branches
git checkout main
git checkout feature/your-feature-name
git switch main
git switch feature/your-feature-name

# List all branches
git branch                    # Local branches
git branch -r                 # Remote branches
git branch -a                 # All branches

# Delete branches
git branch -d feature/old-feature    # Delete local branch
git push origin --delete feature/old-feature  # Delete remote branch

# Rename branch
git branch -m old-name new-name
```

## 🔄 Feature Development Workflows

### Scenario A: Single Project Changes (e.g., Backend Only)

```bash
# 1. Ensure you're on main and up to date
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/backend-auth-improvement

# 3. Make your changes in Backend/
# Edit files in Backend/ directory

# 4. Stage and commit changes
git add Backend/
git commit -m "[Backend] Add feature: improved authentication system"

# 5. Push branch to GitHub
git push origin feature/backend-auth-improvement

# 6. Create Pull Request on GitHub
# Go to GitHub → Click "Compare & pull request"
# Fill PR details and submit

# 7. After PR approval, merge (if you have permissions)
git checkout main
git pull origin main
git merge feature/backend-auth-improvement
git push origin main

# 8. Clean up
git branch -d feature/backend-auth-improvement
git push origin --delete feature/backend-auth-improvement
```

### Scenario B: Cross-Project Changes (e.g., Backend + Android)

```bash
# 1. Ensure you're on main and up to date
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/cross-project-integration

# 3. Make changes in multiple projects
# Edit files in Backend/ and Vision-Parking/

# 4. Stage and commit all changes
git add Backend/ Vision-Parking/
git commit -m "[Cross-Project] Implement feature across Backend and Vision-Parking"

# 5. Push branch to GitHub
git push origin feature/cross-project-integration

# 6. Create Pull Request
# Follow same PR process as Scenario A
```

### Scenario C: Initial App Check-in (New Project)

```bash
# 1. Ensure you're on main and up to date
git checkout main
git pull origin main

# 2. Add new app folder (e.g., admin_react_app/)
# Add your new project files

# 3. Stage and commit initial codebase
git add admin_react_app/
git commit -m "Initial commit: Add admin React app base code"

# 4. Push directly to main
git push origin main

# 5. For future development, use feature branches
git checkout -b feature/react-app-features
```

## 🔀 Pull Request Management

### Creating Pull Requests

```bash
# 1. Push your feature branch
git push origin feature/your-feature-name

# 2. Go to GitHub repository
# 3. Click "Compare & pull request" button
# 4. Fill in PR details:
#    - Title: Clear, descriptive title
#    - Description: Detailed explanation of changes
#    - Assignees: Assign reviewers
#    - Labels: Add appropriate labels
#    - Milestone: Link to project milestone
```

### PR Best Practices

```bash
# Good PR titles
"[Backend] Add user authentication endpoints"
"[Android] Implement parking slot booking feature"
"[Cross-Project] Integrate payment gateway across platforms"

# Good commit messages
git commit -m "[Backend] Add feature: JWT token validation"
git commit -m "[Android] Fix bug: login screen validation"
git commit -m "[Docs] Update API documentation for v2.0"
```

### PR Management Commands

```bash
# Update PR with new commits
git add .
git commit -m "Address review feedback"
git push origin feature/your-feature-name

# Squash commits before merging
git rebase -i HEAD~3  # Interactive rebase last 3 commits
git push --force-with-lease origin feature/your-feature-name

# Merge main into feature branch
git checkout feature/your-feature-name
git merge main
git push origin feature/your-feature-name
```

## 👥 Code Review Process

### For Reviewers

```bash
# Checkout PR branch locally
git fetch origin
git checkout feature/pr-branch-name

# Review changes
git diff main..feature/pr-branch-name

# Test the changes
# Run tests, check functionality

# Provide feedback on GitHub
# Use GitHub's review interface
```

### For Authors

```bash
# Address review feedback
git add .
git commit -m "Address review feedback: fix validation logic"
git push origin feature/your-feature-name

# Respond to comments
# Use GitHub's comment system
```

## 🔀 Merging Strategies

### Merge Commit (Default)

```bash
# Merge feature branch into main
git checkout main
git pull origin main
git merge feature/your-feature-name
git push origin main
```

### Squash and Merge

```bash
# Squash all commits into one
git checkout main
git pull origin main
git merge --squash feature/your-feature-name
git commit -m "Complete feature: your feature description"
git push origin main
```

### Rebase and Merge

```bash
# Rebase feature branch onto main
git checkout feature/your-feature-name
git rebase main
git checkout main
git merge feature/your-feature-name
git push origin main
```

## 🤝 Collaboration Guidelines

### Working with Multiple Developers

```bash
# Sync with team changes
git fetch origin
git checkout main
git pull origin main

# Rebase your feature branch on latest main
git checkout feature/your-feature-name
git rebase main

# Resolve conflicts if any
git add .
git rebase --continue

# Push updated branch
git push --force-with-lease origin feature/your-feature-name
```

### Handling Merge Conflicts

```bash
# When conflicts occur during merge
git status  # See conflicted files
# Edit conflicted files manually
git add resolved-file.txt
git commit -m "Resolve merge conflicts"

# When conflicts occur during rebase
git status
# Edit conflicted files
git add resolved-file.txt
git rebase --continue
```

### Fork-Based Workflow (For External Contributors)

```bash
# 1. Fork repository on GitHub
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/parking_app_integration.git
cd parking_app_integration

# 3. Add upstream remote
git remote add upstream https://github.com/neeraj975arora/parking_app_integration.git

# 4. Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# 5. Create feature branch
git checkout -b feature/your-contribution

# 6. Make changes and commit
git add .
git commit -m "Your contribution description"
git push origin feature/your-contribution

# 7. Create PR from your fork to upstream main
```

## 🛠️ Advanced Git Commands

### History and Logging

```bash
# View detailed commit history
git log --oneline --graph --decorate --all

# View changes in specific file
git log --follow filename.txt

# View commits by author
git log --author="Author Name"

# View commits in date range
git log --since="2024-01-01" --until="2024-12-31"

# View commit statistics
git log --stat
```

### Undoing Changes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo specific commit
git revert commit-hash

# Reset to specific commit
git reset --hard commit-hash
```

### Tagging and Releases

```bash
# Create tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# List tags
git tag
git tag -l "v1.*"

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

## 🚨 Troubleshooting

### Common Issues and Solutions

```bash
# Accidentally committed to main
git checkout main
git reset --hard HEAD~1
git checkout feature/your-branch
git cherry-pick commit-hash

# Lost commits
git reflog
git checkout commit-hash
git checkout -b recovery-branch

# Wrong branch
git stash
git checkout correct-branch
git stash pop

# Unwanted files
git rm --cached filename.txt
echo "filename.txt" >> .gitignore
git add .gitignore
git commit -m "Add filename.txt to .gitignore"
```

### Repository Maintenance

```bash
# Clean up merged branches
git branch --merged main | grep -v main | xargs -n 1 git branch -d

# Prune remote references
git remote prune origin

# Garbage collection
git gc --prune=now

# Check repository size
du -sh .git
```

## 📝 Quick Reference

### Daily Workflow Commands

| Command | Description |
|---------|-------------|
| `git status` | Check current status |
| `git add .` | Stage all changes |
| `git commit -m "message"` | Commit changes |
| `git push origin branch-name` | Push to remote |
| `git pull origin main` | Pull latest changes |
| `git checkout -b feature/name` | Create feature branch |
| `git checkout main` | Switch to main |
| `git merge feature/name` | Merge feature branch |

### Emergency Commands

| Command | Description |
|---------|-------------|
| `git stash` | Save uncommitted changes |
| `git stash pop` | Restore stashed changes |
| `git reset --hard HEAD` | Discard all changes |
| `git checkout -- filename` | Discard file changes |
| `git revert commit-hash` | Undo specific commit |

---

## 🎯 Best Practices

1. **Always pull latest main before starting new work**
2. **Use descriptive branch and commit names**
3. **Keep PRs focused and small**
4. **Write clear commit messages**
5. **Test your changes before pushing**
6. **Use .gitignore to exclude unnecessary files**
7. **Regularly sync with upstream changes**
8. **Clean up merged branches regularly**

---

**Repository**: `https://github.com/neeraj975arora/parking_app_integration.git`  
**Main Branch**: `main`  
**Default Workflow**: Feature Branch → Pull Request → Review → Merge
