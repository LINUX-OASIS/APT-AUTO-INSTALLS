#!/usr/bin/env bash
# set -euo pipefail

# DATE MADE & WORKING (BUT SLOWWWWW): DEC-7-2025

###############################################################################
# Genymotion Latest Version Locator — Simple Sequential Scanner
#
# ── What this script does ────────────────────────────────────────────────────
#
# 1. Iterates over possible Genymotion version numbers in descending order
#    (MAJOR.MINOR.PATCH).
#
# 2. For each version, constructs the expected direct download URL:
#
#      https://dl.genymotion.com/releases/
#          genymotion-X.Y.Z/
#          genymotion-X.Y.Z-linux_x64.run
#
# 3. Uses an HTTP HEAD request (curl -I) to test whether the file exists
#    on the Genymotion servers.
#
# 4. Stops immediately when the first valid version is found, assuming
#    that higher versions are checked first and therefore the newest
#    release will be discovered first.
#
# ── Why this version exists ─────────────────────────────────────────────────
# • Maximum readability
# • Easy to reason about at a glance
# • Minimal Bash “magic”
# • Highly maintainable and easy to extend in the future
#
# Trade-off:
#   This version is intentionally sequential (slow but simple).
###############################################################################

DL_BASE="https://dl.genymotion.com/releases"
OS_FILE_SUFFIX="linux_x64.run"

# User-facing banners
echo "🔎 Simple Genymotion version probe..."
echo "⚡ Sequential scan (readable + maintainable mode)"

# ---------------------------------------------------------------------------
# Version range configuration
# ---------------------------------------------------------------------------
# MAJOR versions to test (space-separated, highest first)
_MAJOR="4 3"

# Descending ranges for minor and patch versions
_MINORS=$(seq 25 -1 0)  # 25 → 0
_PATCHES=$(seq 25 -1 0) # 25 → 0

# Holds the most recent detected version
LATEST_FOUND=""

# ---------------------------------------------------------------------------
# Sequential scan from highest → lowest version
# ---------------------------------------------------------------------------
for major in $_MAJOR; do
	for minor in $_MINORS; do
		for patch in $_PATCHES; do
			VER="${major}.${minor}.${patch}"
			URL="${DL_BASE}/genymotion-${VER}/genymotion-${VER}-${OS_FILE_SUFFIX}"

			# Test existence of the download using HTTP HEAD
			if curl -fsI "$URL" >/dev/null 2>&1; then
				LATEST_FOUND="$VER"
				echo "✅ Found latest: $LATEST_FOUND"

				# Break out of all three loops immediately
				break 3
			fi
		done
	done
done

# ---------------------------------------------------------------------------
# Safety check
# ---------------------------------------------------------------------------
if [[ -z "$LATEST_FOUND" ]]; then
	echo "❌ No valid versions found"
fi

# ---------------------------------------------------------------------------
# Construct final download URL
# ---------------------------------------------------------------------------
FINAL_URL="${DL_BASE}/genymotion-${LATEST_FOUND}/genymotion-${LATEST_FOUND}-${OS_FILE_SUFFIX}"

# ---------------------------------------------------------------------------
# Output result
# ---------------------------------------------------------------------------
echo
echo "📦 Download URL:"
echo "$FINAL_URL"
