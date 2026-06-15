#!/usr/bin/env bash
# send-as-specialist — Telegram pool-bot sender
#
# Usage:
#   send-as-specialist --role researcher|coder|writer --message "TEXT" [--chat-id CHAT_ID]
#
# Env vars (injected by NanoClaw swarm-passthrough provider):
#   TELEGRAM_SWARM_RESEARCHER_TOKEN
#   TELEGRAM_SWARM_CODER_TOKEN
#   TELEGRAM_SWARM_WRITER_TOKEN
#   TELEGRAM_SWARM_GROUP_CHAT_ID
#   TELEGRAM_BOT_TOKEN   (main bot — fallback if pool token not set)
#
# Exit codes:
#   0  message delivered
#   1  missing required argument or Telegram API error

set -euo pipefail

# ── Arg parsing ──────────────────────────────────────────────────────────────

ROLE=""
MESSAGE=""
CHAT_ID="${TELEGRAM_SWARM_GROUP_CHAT_ID:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --role)     ROLE="$2";    shift 2 ;;
    --message)  MESSAGE="$2"; shift 2 ;;
    --chat-id)  CHAT_ID="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$ROLE" ]]; then
  echo "Error: --role is required (researcher|coder|writer)" >&2
  exit 1
fi
if [[ -z "$MESSAGE" ]]; then
  echo "Error: --message is required" >&2
  exit 1
fi
if [[ -z "$CHAT_ID" ]]; then
  echo "Error: --chat-id or TELEGRAM_SWARM_GROUP_CHAT_ID env var required" >&2
  exit 1
fi

# ── Token resolution ─────────────────────────────────────────────────────────

TOKEN=""
ICON=""

ROLE_LOWER=$(echo "$ROLE" | tr '[:upper:]' '[:lower:]')
case "$ROLE_LOWER" in
  researcher)
    TOKEN="${TELEGRAM_SWARM_RESEARCHER_TOKEN:-}"
    ICON="🔍"
    ;;
  coder)
    TOKEN="${TELEGRAM_SWARM_CODER_TOKEN:-}"
    ICON="💻"
    ;;
  writer)
    TOKEN="${TELEGRAM_SWARM_WRITER_TOKEN:-}"
    ICON="✍️"
    ;;
  *)
    echo "Error: unknown role '${ROLE_LOWER}'. Must be researcher, coder, or writer." >&2
    exit 1
    ;;
esac

# Fallback to main bot with a role prefix if pool token is not configured
if [[ -z "$TOKEN" ]]; then
  MAIN_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
  if [[ -z "$MAIN_TOKEN" ]]; then
    echo "Error: no pool token or main TELEGRAM_BOT_TOKEN available" >&2
    exit 1
  fi
  TOKEN="$MAIN_TOKEN"
  ROLE_CAP=$(echo "$ROLE_LOWER" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
  MESSAGE="${ICON} [${ROLE_CAP}] ${MESSAGE}"
fi

# ── Send via Telegram Bot API ─────────────────────────────────────────────────

TELEGRAM_API="https://api.telegram.org/bot${TOKEN}/sendMessage"

RESPONSE=$(curl -s -X POST "$TELEGRAM_API" \
  --header "Content-Type: application/json" \
  --data "$(printf '{"chat_id":"%s","text":"%s","parse_mode":"HTML"}' \
    "$CHAT_ID" \
    "$(echo "$MESSAGE" | sed 's/"/\\"/g; s/\n/\\n/g')")")

OK=$(echo "$RESPONSE" | grep -o '"ok":true' || true)

if [[ -n "$OK" ]]; then
  echo "Sent as ${ROLE}: ${MESSAGE}" | head -c 120
  exit 0
else
  echo "Telegram API error: ${RESPONSE}" >&2
  exit 1
fi
