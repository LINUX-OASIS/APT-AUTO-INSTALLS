#!/usr/bin/env bash
# set -euo pipefail

# DATE MADE & WORKING of [genymotion dynamic latest release fetcher w/parallelization]: DEC-7-2025

###############################################################################
# Genymotion Latest Version Locator — Hybrid Fast Scanner
#
# ── What this script does ────────────────────────────────────────────────────
#
# 1. Builds a list of potential Genymotion versions (MAJOR.MINOR.PATCH)
#    using descending ranges so newer versions are tested first.
#
# 2. For each generated version, it constructs the expected download URL:
#
#      https://dl.genymotion.com/releases/
#          genymotion-X.Y.Z/
#          genymotion-X.Y.Z-linux_x64.run
#
# 3. Uses HTTP HEAD requests (curl -I) to test whether each URL exists
#    without downloading the full file.
#
# 4. Runs checks in parallel (via xargs -P) to massively speed up detection
#    while keeping the version generation logic readable and maintainable.
#
# 5. Collects all valid versions, sorts them using semantic sort (sort -V),
#    and selects the highest (newest) version automatically.
#
# Result:
#   Prints the latest version number and its direct download URL.
#
# ── Why this approach? ──────────────────────────────────────────────────────
# • No API dependency
# • No reliance on Genymotion's website HTML structure
# • Works in CI/CD (GitHub Actions, etc.)
# • Easy to future-proof by adjusting version ranges
###############################################################################

DL_BASE="https://dl.genymotion.com/releases"
OS_FILE_SUFFIX="linux_x64.run"

# Informational banners
echo "🔎 Hybrid-fast Genymotion version probe..."
echo "🔎 Probing latest Genymotion version (fast mode)..."
echo "🔎 Hybrid-fast Genymotion version probe..."
echo "⚡ Ultra-fast Genymotion version probe..."

# ---------------------------------------------------------------------------
# Version range configuration (future-proofing)
# ---------------------------------------------------------------------------
# MAJOR versions to scan (space-separated, highest first)
_MAJOR="5 4 3"

# Descending ranges for minor/patch numbers
_MINORS=$(seq 25 -1 0)  # 25 → 0
_PATCHES=$(seq 25 -1 0) # 25 → 0

# Holds the final detected version
LATEST_FOUND=""

# ---------------------------------------------------------------------------
# Function: check_url
# Purpose : Test if a given version's download URL exists
# ---------------------------------------------------------------------------
check_url() {
	local ver="$1"
	local url="${DL_BASE}/genymotion-${ver}/genymotion-${ver}-${OS_FILE_SUFFIX}"

	# HTTP HEAD probe: success means the file exists
	if curl -fsI "$url" >/dev/null 2>&1; then
		echo "$ver"
	fi
}

# Export function + vars so xargs subprocesses can use them
export -f check_url
export DL_BASE OS_FILE_SUFFIX

# ---------------------------------------------------------------------------
# Build all version candidates in descending order
# (kept deliberately readable for future maintenance)
# ---------------------------------------------------------------------------
VERSION_LIST=$(
	for major in $_MAJOR; do
		for minor in $_MINORS; do
			for patch in $_PATCHES; do
				echo "${major}.${minor}.${patch}"
			done
		done
	done
)

# ---------------------------------------------------------------------------
# Parallel URL probing (network-bound, not CPU-bound)
# TLDR → "Run check_url on every input line, N at a time, using only built-in tools
#
# This block uses `xargs -P` to run multiple HTTP HEAD checks in parallel.
# Each worker effectively runs:  curl -I https://...
#
# This workload is NETWORK-BOUND:
#   • Most time is spent waiting on the network
#   • CPU usage is minimal
#   • Performance depends more on latency than core count
#
# Moderate parallelism (8–16 workers) gives the best balance.
# Too many workers can reduce performance due to TCP/socket overhead.
#
# Core execution pattern:
#
#   xargs -P8 -I{} bash -c 'check_url "$@"' _ {}
#
# Component breakdown:
#
#   xargs        → Reads lines from stdin
#   -P8          → Runs up to 8 parallel workers
#   -I{}         → Replaces {} with each input line
#   bash -c      → Spawns a shell to run the command
#   'check_url'  → Function executed per URL
#   _            → Dummy $0 (required by bash -c)
#   {}           → Becomes $1 / $@ inside bash
#
# Example expansion:
#
#   Input:  https://example.com
#   Runs:   bash -c 'check_url "$@"' _ https://example.com
#
# Inside bash:
#   $0 = _
#   $1 = https://example.com
#   $@ = https://example.com
#
# Final executed command:
#   check_url https://example.com
#
# Portable, fast, dependency-free parallelism.
# ●─────────────────────────────────────────────────────────────────────────●
# ●─────────────────────────────────────────────────────────────────────────●
# ●─────────────────────────────────────────────────────────────────────────●
# Even nicer alternative: GNU Parallel (when available)
# ─────────────────────────────────────────────────────
#   cat urls.txt        | parallel -j8 check_url
#   parallel -j8 check_url ::: "${url_array[@]}"
#
# Much more readable, handles quoting perfectly, many extra features.
# But xargs -P works everywhere (Linux, macOS, minimal systems) with zero dependencies.
# ---------------------------------------------------------------------------

FOUND_VERSIONS=$(
	echo "$VERSION_LIST" |
		xargs -P8 -I{} bash -c 'check_url "$@"' _ {}
	# xargs -P16 -I{} bash -c 'check_url "$@"' _ {}
)

# ---------------------------------------------------------------------------
# Pick the highest (latest) version using semantic version sorting
# ---------------------------------------------------------------------------
LATEST_FOUND=$(echo "$FOUND_VERSIONS" | sort -V | tail -n1)

# Safety check
if [[ -z "$LATEST_FOUND" ]]; then
	echo "❌ No valid versions found"
	exit 1
fi

# ---------------------------------------------------------------------------
# Construct final download URL
# ---------------------------------------------------------------------------
FINAL_URL_GENYMOTION="${DL_BASE}/genymotion-${LATEST_FOUND}/genymotion-${LATEST_FOUND}-${OS_FILE_SUFFIX}"

# ---------------------------------------------------------------------------
# Output result
# ---------------------------------------------------------------------------
echo "✅ Latest version: $LATEST_FOUND"
echo "📦 $FINAL_URL_GENYMOTION"
