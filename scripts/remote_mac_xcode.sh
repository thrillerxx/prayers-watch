#!/usr/bin/env bash
set -euo pipefail

# One-command Omarchy -> Mac workflow:
# - push selected branch to origin
# - sync Mac clone to that branch
# - run Xcode build + optional UI tests on Mac

MAC_HOST="${MAC_HOST:-thrillerx@thrillerxs-macbook-air}"
MAC_REPO_DIR="${MAC_REPO_DIR:-/Users/thrillerx/dev/prayers-watch}"
MAC_PROJECT_SUBDIR="${MAC_PROJECT_SUBDIR:-prayers}"
PROJECT_FILE="${PROJECT_FILE:-prayers.xcodeproj}"
BUILD_SCHEME="${BUILD_SCHEME:-prayers}"
TEST_SCHEME="${TEST_SCHEME:-prayers-watch-uitests}"
DESTINATION="${DESTINATION:-platform=watchOS Simulator,name=Apple Watch Series 11 (42mm)}"

RUN_TESTS="${RUN_TESTS:-1}"
PUSH_FIRST="${PUSH_FIRST:-1}"

LOCAL_ROOT="$(git rev-parse --show-toplevel)"
cd "$LOCAL_ROOT"

BRANCH="${1:-$(git rev-parse --abbrev-ref HEAD)}"
if [[ "$BRANCH" == "HEAD" ]]; then
  echo "Local repo is detached HEAD. Pass an explicit branch: scripts/remote_mac_xcode.sh <branch>" >&2
  exit 1
fi

LOCAL_REMOTE_URL="$(git remote get-url origin)"
if [[ -z "$LOCAL_REMOTE_URL" ]]; then
  echo "No origin remote found in local repo." >&2
  exit 1
fi

LOCAL_REMOTE_HTTPS="$LOCAL_REMOTE_URL"
if [[ "$LOCAL_REMOTE_URL" =~ ^git@github\.com:(.+)\.git$ ]]; then
  LOCAL_REMOTE_HTTPS="https://github.com/${BASH_REMATCH[1]}.git"
fi

LOCAL_DIRTY=0
if ! git diff --quiet || ! git diff --cached --quiet; then
  LOCAL_DIRTY=1
fi

LOCAL_HEAD="$(git rev-parse --short HEAD)"
echo "[local] repo: $LOCAL_ROOT"
echo "[local] branch: $BRANCH"
echo "[local] head: $LOCAL_HEAD"
if [[ "$LOCAL_DIRTY" == "1" ]]; then
  echo "[local] warning: working tree has uncommitted changes; remote Mac will build latest pushed commit only."
fi

if [[ "$PUSH_FIRST" == "1" ]]; then
  echo "[local] pushing branch to origin..."
  git push origin "$BRANCH"
fi

echo "[remote] syncing and building on $MAC_HOST"

ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new "$MAC_HOST" \
  "set -euo pipefail; \
   MAC_REPO_DIR='$MAC_REPO_DIR'; \
   MAC_PROJECT_SUBDIR='$MAC_PROJECT_SUBDIR'; \
   PROJECT_FILE='$PROJECT_FILE'; \
   BUILD_SCHEME='$BUILD_SCHEME'; \
   TEST_SCHEME='$TEST_SCHEME'; \
   DESTINATION='$DESTINATION'; \
   BRANCH='$BRANCH'; \
   RUN_TESTS='$RUN_TESTS'; \
   mkdir -p \"\$(dirname \"$MAC_REPO_DIR\")\"; \
   if [ ! -d \"$MAC_REPO_DIR/.git\" ]; then \
     echo '[remote] clone missing; cloning...'; \
     if ! git clone \"$LOCAL_REMOTE_URL\" \"$MAC_REPO_DIR\"; then \
       if [ \"$LOCAL_REMOTE_HTTPS\" != \"$LOCAL_REMOTE_URL\" ]; then \
         echo '[remote] primary clone URL failed; retrying fallback URL...'; \
         git clone \"$LOCAL_REMOTE_HTTPS\" \"$MAC_REPO_DIR\"; \
       else \
         echo '[remote] clone failed and no fallback URL available.'; \
         exit 1; \
       fi; \
     fi; \
   fi; \
   if ! git -C \"$MAC_REPO_DIR\" fetch --all --tags --prune; then \
     if [ \"$LOCAL_REMOTE_HTTPS\" != \"$LOCAL_REMOTE_URL\" ]; then \
       echo '[remote] fetch failed on current/primary remote; switching to fallback URL...'; \
       git -C \"$MAC_REPO_DIR\" remote set-url origin \"$LOCAL_REMOTE_HTTPS\"; \
       git -C \"$MAC_REPO_DIR\" fetch --all --tags --prune; \
     else \
       echo '[remote] fetch failed and no fallback URL available.'; \
       exit 1; \
     fi; \
   fi; \
   if git -C \"$MAC_REPO_DIR\" show-ref --verify --quiet \"refs/heads/$BRANCH\"; then \
     git -C \"$MAC_REPO_DIR\" switch \"$BRANCH\"; \
   else \
     git -C \"$MAC_REPO_DIR\" switch -c \"$BRANCH\" --track \"origin/$BRANCH\"; \
   fi; \
   git -C \"$MAC_REPO_DIR\" reset --hard \"origin/$BRANCH\"; \
   echo \"[remote] branch: \$(git -C \"$MAC_REPO_DIR\" rev-parse --abbrev-ref HEAD)\"; \
   echo \"[remote] head: \$(git -C \"$MAC_REPO_DIR\" rev-parse --short HEAD)\"; \
   cd \"$MAC_REPO_DIR/$MAC_PROJECT_SUBDIR\"; \
   echo '[remote] running xcodebuild build...'; \
   xcodebuild -project \"$PROJECT_FILE\" \
     -scheme \"$BUILD_SCHEME\" \
     -destination \"$DESTINATION\" \
     CODE_SIGNING_ALLOWED=NO \
     -configuration Debug \
     build; \
   if [ \"$RUN_TESTS\" = '1' ]; then \
     echo '[remote] running xcodebuild test...'; \
     xcodebuild test -project \"$PROJECT_FILE\" \
       -scheme \"$TEST_SCHEME\" \
       -destination \"$DESTINATION\" \
       CODE_SIGNING_ALLOWED=NO; \
   fi"

echo "[done] remote build workflow completed."
