/**
 * Swarm pool bot token passthrough — injects TELEGRAM_SWARM_*_TOKEN and
 * TELEGRAM_SWARM_GROUP_CHAT_ID into the Claude agent container so the
 * telegram-swarm container skill can call pool-bot Telegram APIs directly.
 *
 * Only injects keys that have non-empty values in .env (so a blank token
 * silently skips, keeping the container clean until the user configures it).
 *
 * Registers under the 'claude' provider slot (which has no host-side setup
 * by default — claude.ts is only imported when ANTHROPIC_BASE_URL is set).
 */
import { readEnvFile } from '../env.js';
import { registerProviderContainerConfig } from './provider-container-registry.js';

const SWARM_KEYS = [
  'TELEGRAM_SWARM_RESEARCHER_TOKEN',
  'TELEGRAM_SWARM_CODER_TOKEN',
  'TELEGRAM_SWARM_WRITER_TOKEN',
  'TELEGRAM_SWARM_GROUP_CHAT_ID',
] as const;

registerProviderContainerConfig('claude', () => {
  const dotenv = readEnvFile([...SWARM_KEYS]);
  const env: Record<string, string> = {};
  for (const key of SWARM_KEYS) {
    if (dotenv[key]) env[key] = dotenv[key];
  }
  return { env };
});
