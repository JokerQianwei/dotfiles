/**
 * Model-aware routing for the edit tool family.
 *
 * Pure predicates and a routing decision. All `pi.*` side effects live in
 * `index.ts`; this module only decides which edit interface a model should use
 * based on its provider / id.
 *
 * Ported from aliou/pi-harness `tools/edit/router.ts`; Codex detection is
 * extended to local providers and Kimi detection includes CodeBuddy Kimi K3.
 */

type ModelLike = { provider?: string; id?: string } | undefined;

/** Providers serving models post-trained on the V4A `apply_patch` format. */
const CODEX_PROVIDERS = new Set(["openai-codex", "tcodex"]);

/**
 * Codex / GPT-style models were post-trained on the V4A `apply_patch` format.
 *
 * Detection is primarily by provider. The `openai` provider serves the same
 * GPT-5 coding models under plain `gpt-*` ids, so those are matched by id
 * prefix; non-GPT ids under `openai` stay on the native `edit` tool.
 */
export function isCodexModel(model: ModelLike): boolean {
  if (model?.provider && CODEX_PROVIDERS.has(model.provider)) return true;
  return (
    model?.provider === "openai" &&
    (model.id?.toLowerCase().startsWith("gpt-") ?? false)
  );
}

/** Anthropic 直连模型及 tclaude 转发的 Opus 模型启用严格工具参数约束。 */
export function isAnthropicModel(model: ModelLike): boolean {
  if (model?.provider === "anthropic") return true;
  return (
    model?.provider === "tclaude" &&
    (model.id?.toLowerCase().startsWith("claude-opus") ?? false)
  );
}

/** Kimi models tuned for Moonshot's old_string/new_string edit shape. */
export function isKimiCodeModel(model: ModelLike): boolean {
  const id = model?.id?.toLowerCase();
  return (
    (model?.provider === "neuralwatt" && id === "kimi-k2.7-code") ||
    (model?.provider === "synthetic" && id === "hf:moonshotai/kimi-k2.7-code") ||
    (model?.provider === "codebuddy" && id === "kimi-k3-ioa")
  );
}

export type EditToolChoice = "apply_patch" | "edit" | "kimi_edit";

/** Which edit interface the active model should use. */
export function pickEditTool(model: ModelLike): EditToolChoice {
  if (isCodexModel(model)) return "apply_patch";
  if (isKimiCodeModel(model)) return "kimi_edit";
  return "edit";
}

/**
 * Compute the next active-tool set for an edit-interface swap.
 *
 * - `apply_patch` (Codex): drop `edit` and `write` (apply_patch's Add File
 *   covers creation), add `apply_patch`. `removedByUs` records what was dropped
 *   so it can be restored on exit.
 * - `edit` / `kimi_edit`: drop `apply_patch`, restore previously-removed
 *   tools, and ensure `edit` is present. The public tool name remains `edit`;
 *   `index.ts` swaps its registered definition for Kimi.
 *
 * Pure: `index.ts` owns the `currentChoice` / `removedByUs` state and the
 * `pi.setActiveTools` side effect.
 */
export function resolveActiveTools(
  active: string[],
  desired: EditToolChoice,
  removedByUs: string[],
): { active: string[]; removedByUs: string[] } {
  if (desired === "apply_patch") {
    const removed: string[] = [];
    const next = active.filter((t) => {
      if (t === "edit" || t === "write") {
        removed.push(t);
        return false;
      }
      return true;
    });
    const withPatch = next.includes("apply_patch")
      ? next
      : [...next, "apply_patch"];
    return { active: withPatch, removedByUs: removed };
  }

  let next = active.filter((t) => t !== "apply_patch");
  for (const t of removedByUs) {
    if (!next.includes(t)) next = [...next, t];
  }
  if (!next.includes("edit")) next = [...next, "edit"];
  return { active: next, removedByUs: [] };
}
