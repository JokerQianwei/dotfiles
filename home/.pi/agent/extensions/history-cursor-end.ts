import {
  CustomEditor,
  type ExtensionAPI,
  type KeybindingsManager,
} from "@earendil-works/pi-coding-agent";

type EditorInternals = {
  historyIndex: number;
  preferredVisualCol: number | null;
  snappedFromCursorCol: number | null;
  state: {
    lines: string[];
    cursorLine: number;
    cursorCol: number;
  };
};

type HistoryEditor = {
  addToHistory?(text: string): void;
  handleInput(data: string): void;
};

const HISTORY_STORE_KEY = "__piHistoryCursorEndHistory";
const globalState = globalThis as typeof globalThis & {
  [HISTORY_STORE_KEY]?: string[];
};
const historyStore = globalState[HISTORY_STORE_KEY] ??= [];

function rememberHistory(text: string): void {
  const trimmed = text.trim();
  if (!trimmed || historyStore[0] === trimmed) return;
  historyStore.unshift(trimmed);
  if (historyStore.length > 100) historyStore.pop();
}

function rememberSessionHistory(entries: readonly unknown[]): void {
  for (const entry of entries) {
    if (!entry || typeof entry !== "object") continue;
    const message = (entry as { message?: unknown }).message;
    if (!message || typeof message !== "object") continue;

    const { role, content } = message as {
      role?: unknown;
      content?: unknown;
    };
    if (role !== "user") continue;

    if (typeof content === "string") {
      rememberHistory(content);
      continue;
    }
    if (!Array.isArray(content)) continue;

    const text = content
      .filter(
        (part): part is { type: "text"; text: string } =>
          part !== null
          && typeof part === "object"
          && (part as { type?: unknown }).type === "text"
          && typeof (part as { text?: unknown }).text === "string",
      )
      .map((part) => part.text)
      .join("");
    rememberHistory(text);
  }
}

function getInternals(editor: HistoryEditor): EditorInternals | undefined {
  const candidate = editor as Partial<EditorInternals>;
  if (typeof candidate.historyIndex !== "number") return undefined;
  if (!candidate.state || !Array.isArray(candidate.state.lines)) return undefined;
  return candidate as EditorInternals;
}

function enhanceEditor<T extends HistoryEditor>(
  editor: T,
  keybindings: KeybindingsManager,
): T {
  const addToHistory = editor.addToHistory?.bind(editor);
  if (addToHistory) {
    // Pi 重载扩展时不会复制 Editor.history；进程内保留同一份历史。
    for (const entry of [...historyStore].reverse()) addToHistory(entry);
    editor.addToHistory = (text) => {
      addToHistory(text);
      rememberHistory(text);
    };
  }

  const handleInput = editor.handleInput.bind(editor);
  editor.handleInput = (data) => {
    const previousHistoryIndex = getInternals(editor)?.historyIndex;

    handleInput(data);

    // 只调整 ↑ 成功调出的历史项；其他按键和普通光标移动保持原样。
    if (!keybindings.matches(data, "tui.editor.cursorUp")) return;
    const internals = getInternals(editor);
    if (!internals || internals.historyIndex < 0) return;
    if (internals.historyIndex === previousHistoryIndex) return;

    const lastLine = internals.state.lines.length - 1;
    internals.state.cursorLine = lastLine;
    internals.state.cursorCol = internals.state.lines[lastLine]?.length ?? 0;
    internals.preferredVisualCol = null;
    internals.snappedFromCursorCol = null;
  };

  return editor;
}

export default function historyCursorEnd(pi: ExtensionAPI): void {
  pi.on("session_start", (event, ctx) => {
    if (ctx.mode !== "tui") return;

    // 会话切换会在扩展绑定前把目标历史写入默认 Editor，需从会话补入共享历史。
    if (event.reason !== "startup" && event.reason !== "reload") {
      rememberSessionHistory(ctx.sessionManager.buildContextEntries());
    }

    const previous = ctx.ui.getEditorComponent();
    ctx.ui.setEditorComponent((tui, theme, keybindings) => {
      const editor = previous?.(tui, theme, keybindings)
        ?? new CustomEditor(tui, theme, keybindings);
      return enhanceEditor(editor, keybindings);
    });
  });
}
