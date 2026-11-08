// Pi agent -> tmux window-tab notifier. Pi's counterpart to the Claude Code hooks in
// ~/.claude/settings.json: same script, same pane flag, same tab colours.
// Symlinked into ~/.pi/agent/extensions/ by setup.sh.
import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const script = join(homedir(), ".config/tmux/claude-notify.sh");

// stdio must be "ignore": the script reads stdin to EOF on stop/notify, and an open
// pipe would hang it. /dev/null gives it an immediate EOF.
function run(command: string, args: string[]): Promise<void> {
	return new Promise((resolve) => {
		const child = spawn(command, args, { stdio: "ignore" });
		child.on("close", () => resolve());
		child.on("error", () => resolve());
	});
}

function tab(action: string, event: string): Promise<void> {
	return run("bash", [script, action, event]);
}

// Pi is a node process, so tmux can only tell it apart through this pane marker,
// which automatic-rename-format in tmux.conf turns into the tab name "Pi".
function markPane(on: boolean): Promise<void> {
	const pane = process.env.TMUX_PANE;
	if (!pane) return Promise.resolve();
	return run(
		"tmux",
		on ? ["set-option", "-p", "-t", pane, "@pi_pane", "1"] : ["set-option", "-p", "-u", "-t", pane, "@pi_pane"],
	);
}

export default function (pi: ExtensionAPI) {
	// Extensions can open prompts while idle; only a live run may go back to green.
	let running = false;

	pi.on("agent_start", async () => {
		running = true;
		await tab("start", "agent_start");
	});
	// Not agent_end: Pi may still retry, compact, or run queued messages after it.
	pi.on("agent_settled", async () => {
		running = false;
		await tab("stop", "agent_settled");
	});
	pi.on("ui_prompt_start", async () => {
		if (running) await tab("notify", "ui_prompt_start");
	});
	pi.on("ui_prompt_end", async () => {
		if (running) await tab("start", "ui_prompt_end");
	});
	pi.on("session_start", async () => {
		await markPane(true);
	});
	pi.on("session_shutdown", async () => {
		await Promise.all([tab("end", "session_shutdown"), markPane(false)]);
	});
}
