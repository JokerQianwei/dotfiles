export type BtwRoute =
	| { kind: "open"; split?: "down" }
	| { kind: "ask"; question: string; split?: "down" }
	| { kind: "config"; args: string }
	| { kind: "merge"; text: string }
	| { kind: "help" };

export const HELP_TEXT = `/btw usage:
/btw                        open an empty side pane
/btw <question...>          open a side pane with a draft question
/btw --down [question...]   open this side pane below without changing config
/btw ask <question...>      explicit form for questions starting with a reserved word
/btw config [...]           show or change defaults (auto-submit, model, thinking, tools, split, reset)
/btw merge <prompt...>      fold this side thread into the parent and continue with the prompt
/btw help                   show this grammar`;

/**
 * Exact first-word routing. Only the reserved words `ask`, `config`, `merge`,
 * and `help` are subcommands; any other first word keeps the whole input as a
 * question. `/btw ask ...` is the escape hatch for questions that begin with a
 * reserved word.
 */
export function parseBtwCommand(input: string): BtwRoute {
	const trimmed = input.trim();
	if (!trimmed) return { kind: "open" };

	const spaceIndex = trimmed.search(/\s/);
	const first = spaceIndex === -1 ? trimmed : trimmed.slice(0, spaceIndex);
	const rest = spaceIndex === -1 ? "" : trimmed.slice(spaceIndex).trim();

	switch (first) {
		case "--down":
			return rest
				? { kind: "ask", question: rest, split: "down" }
				: { kind: "open", split: "down" };
		case "ask":
			return rest ? { kind: "ask", question: rest } : { kind: "open" };
		case "config":
			return { kind: "config", args: rest };
		case "merge":
			return { kind: "merge", text: rest };
		case "help":
			return { kind: "help" };
		default:
			return { kind: "ask", question: trimmed };
	}
}
