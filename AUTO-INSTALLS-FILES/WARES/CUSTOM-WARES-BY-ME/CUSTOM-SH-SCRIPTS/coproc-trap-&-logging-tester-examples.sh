#!/bin/bash
# ✨ Magical Bash Girl Team™ – Async Bash Adventure 🐱💻🌈
# Featuring: coproc-chan 💫, trap-chan ⚠️, and &-kun 💨

####==========================================================================================================
####==========================================================================================================

#  coproc — UwU Asynchronous Cutie Co-Processes
# coproc = "co-process" — it's like spawning a cute little helper Bash terminal that can run alongside your main script~! ✨
# It’s cleaner and more elegant than &, and gives you input/output pipes too!

# This launches a background process with built-in I/O:
# my_helper_process[0] = output from the coproc (like stdout)
# my_helper_process[1] = input to the coproc (like stdin)

# 🎀 Basic Usage:
# coproc fetch_data {

#     echo "📡 Fetching data in the background..."
#     sleep 30
#     echo "✨ Background task complete nya~!"
# }

# echo "⏳ Main script continues... while fetch_data runs~"

# # Read coproc output line by line~ uwu
# while read -r line <&"${fetch_data[0]}"; do
#     echo "🐾 Coproc says: $line"
# done

# echo "🌈 All done~!"
####==========================================================================================================
####==========================================================================================================

# The $! variable is a special shell variable that stores the PID of the most recently executed background process.
# A background process, also known as a background job, allows us to continue using the command line interface for other tasks
#        _kun_pid=$!

set -euo pipefail

# 🪄 Globals
WAIFU_TEMP="/tmp/waifu_tempfile"
LOG_FILE="/tmp/magical_battle.log"
coproc_pid=""

# ✨ trap-chan: protects the script with magic shield!
handle_exit() {
    echo "⚠️ trap-chan: Emergency cleanup spell activated~!"
    [[ -f "$WAIFU_TEMP" ]] && rm -f "$WAIFU_TEMP" && echo "🧼 Removed waifu temp file!"
    [[ -n "$coproc_pid" ]] && kill "$coproc_pid" 2>/dev/null && echo "🌙 Terminated coproc-chan!"
    echo "🎀 Bye bye, magical shell~!" >>"$LOG_FILE"
    exit
}
trap handle_exit INT TERM EXIT

# 💨 &-kun: quick background helper!
launch_background_spell() {
    echo "💨 &-kun: Starting silent sparkle logger in background~"
    {
        while true; do
            echo -e "🌟 &-kun: Still watching the cosmos... \n🌙" >>"$LOG_FILE"
            sleep 2
        done
    } &
}

# 💫 coproc-chan: async magical dialogue handler!
launch_coproc_waifu() {
    echo "💫 coproc-chan: Preparing async task with magical IO~"
    coproc waifu_talk {
        echo "💬 coproc-chan: Hello senpai~! I'm working hard... nya~"
        sleep 3
        for i in {1..30}; do
            echo "💖 coproc-chan: Sending magical message #$i~"
            sleep 1
            HEARTS+=$(printf '💖%.0s' " ")
            echo $HEARTS
        done
        echo "💬 coproc-chan: All done desu~ 💖"
    }

    coproc_pid=$!

    echo "⏳ Main script continues... while fetch_data runs~"
    echo "🔮 Main script: Waiting for coproc-chan to finish her spell..."
    while read -r line <&"${waifu_talk[0]}"; do
        echo "📩 From coproc-chan: $line"
    done
}

# 🧼 Setup Phase
echo "📝 Creating waifu_temp at $WAIFU_TEMP"
touch "$WAIFU_TEMP"
echo "🌈 Welcome to the Magical Bash Girl Adventure~!" >"$LOG_FILE"

# 🧪 Phase 1: Launch &-kun
launch_background_spell

# 🔮 Phase 2: Summon coproc-chan
launch_coproc_waifu

# 💤 Phase 3: Main script still doing things~
echo "💤 Main script: Taking a nap while my girls do the work~"
sleep 5

# 🌟 Done
echo "🎉 All async magical girls finished their missions~!"
echo "🌈 All done~!"
echo "🔚 Script end! Check logs at: $LOG_FILE"

# | Feature  | Purpose                        | UwU Bonus                              |
# | -------- | ------------------------------ | -------------------------------------- |
# | `coproc` | Structured async task w/ I/O   | Elegant subprocess with pipe access 🌸 |
# | `&`      | Fire-and-forget async task     | Simple helper in background 💨         |
# | `trap`   | Catch signals or clean on exit | Graceful waifu-tier error handling ⚠️✨ |
