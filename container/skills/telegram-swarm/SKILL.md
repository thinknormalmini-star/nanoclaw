---
name: telegram-swarm
description: >-
  Send status updates and progress messages to the team Telegram channel
  (myteam_nano) as a specialist persona — Researcher, Coder, or Writer.
  Use this skill when you are performing multi-step work that benefits from
  showing the user which specialist role is active, or when you want to post
  a progress update, summary, or result notification to the team channel.
allowed-tools: Bash(/app/skills/telegram-swarm/send-as-specialist.sh:*)
---

# Telegram Swarm — Specialist Messaging

You can post messages to the team Telegram group (myteam_nano) as one of three
specialist personas, each with their own bot identity and avatar.

## Personas

| Role | Bot | Use when |
|---|---|---|
| `researcher` | my2m2_researcher_bot 🔍 | Reporting research findings, web lookups, analysis |
| `coder` | mya_coder_bot 💻 | Code changes, build results, test output |
| `writer` | mya_writer_bot ✍️ | Drafts, summaries, documentation updates |

## Quick start

```bash
# Send a message as Researcher
/app/skills/telegram-swarm/send-as-specialist.sh --role researcher --message "분석 완료: 결과를 정리 중입니다."

# Send as Coder
/app/skills/telegram-swarm/send-as-specialist.sh --role coder --message "빌드 성공 ✅ (3.2s)"

# Send as Writer
/app/skills/telegram-swarm/send-as-specialist.sh --role writer --message "초안 작성 완료. 검토 요청합니다."
```

## When to use

- Starting a multi-step task → post which role is taking over
- Completing a subtask → post a brief result
- Handoff between roles → post status before switching

## When NOT to use

- Asking the user for approvals or decisions → use the main bot (my2m2_bot)
- Reporting errors that need user action → use the main bot
- Routine short replies → just reply normally

## Token availability

If a pool bot token is not configured in `.env`, `send-as-specialist` will fall
back to posting from the main bot (my2m2_bot) with a role prefix in the text.
You do not need to check — the tool handles this automatically.
