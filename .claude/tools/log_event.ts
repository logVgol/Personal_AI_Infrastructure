#!/usr/bin/env bun
/**
 * Manual Event Logger for Gemini
 * Allows Gemini to log events to the PAI history system, enabling Dashboard visibility.
 * Usage: log_event.ts --type "ToolUse" --payload '{"tool_name": "...", ...}'
 */

import { appendFileSync, mkdirSync, existsSync, readFileSync } from 'fs';
import { join, resolve } from 'path';
import { homedir } from 'os';

// PAI_DIR Resolution (Copied from pai-paths.ts logic for standalone simplicity)
const PAI_DIR = process.env.PAI_DIR
  ? resolve(process.env.PAI_DIR)
  : resolve(homedir(), '.claude');

// Get PST timestamp
function getPSTTimestamp(): string {
  const date = new Date();
  const pstDate = new Date(date.toLocaleString('en-US', { timeZone: process.env.TIME_ZONE || 'America/Los_Angeles' }));

  const year = pstDate.getFullYear();
  const month = String(pstDate.getMonth() + 1).padStart(2, '0');
  const day = String(pstDate.getDate()).padStart(2, '0');
  const hours = String(pstDate.getHours()).padStart(2, '0');
  const minutes = String(pstDate.getMinutes()).padStart(2, '0');
  const seconds = String(pstDate.getSeconds()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds} PST`;
}

// Get current events file path
function getEventsFilePath(): string {
  const now = new Date();
  const pstDate = new Date(now.toLocaleString('en-US', { timeZone: process.env.TIME_ZONE || 'America/Los_Angeles' }));
  const year = pstDate.getFullYear();
  const month = String(pstDate.getMonth() + 1).padStart(2, '0');
  const day = String(pstDate.getDate()).padStart(2, '0');

  const monthDir = join(PAI_DIR, 'history', 'raw-outputs', `${year}-${month}`);

  // Ensure directory exists
  if (!existsSync(monthDir)) {
    mkdirSync(monthDir, { recursive: true });
  }

  return join(monthDir, `${year}-${month}-${day}_all-events.jsonl`);
}

function main() {
  const args = process.argv.slice(2);
  let eventType = 'Log';
  let payload = {};
  let agent = process.env.DA || 'PAI';

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--type' && args[i + 1]) {
      eventType = args[i + 1];
      i++;
    } else if (args[i] === '--payload' && args[i + 1]) {
      try {
        payload = JSON.parse(args[i + 1]);
      } catch (e) {
        console.error("Invalid JSON payload");
        process.exit(1);
      }
      i++;
    } else if (args[i] === '--agent' && args[i + 1]) {
      agent = args[i + 1];
      i++;
    }
  }

  const event = {
    source_app: agent,
    session_id: 'gemini-session', // Placeholder
    hook_event_type: eventType,
    payload: payload,
    timestamp: Date.now(),
    timestamp_pst: getPSTTimestamp()
  };

  try {
    const eventsFile = getEventsFilePath();
    appendFileSync(eventsFile, JSON.stringify(event) + '\n', 'utf-8');
    console.log("Event logged successfully.");
  } catch (error) {
    console.error("Failed to log event:", error);
    process.exit(1);
  }
}

main();
