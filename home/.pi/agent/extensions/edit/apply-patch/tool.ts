/**
 * `apply_patch` tool definition for Codex / GPT-style models.
 *
 * GPT coding models were post-trained on a freeform text-patch interface (the
 * V4A format) rather than JSON edit tools. Grammar-capable OpenAI providers see
 * the same custom freeform + Lark tool shape as Codex CLI; Pi normalizes the
 * raw custom input into the internal `input` parameter before execution.
 *
 * The model-facing contract follows openai/codex
 * `codex-rs/core/src/tools/handlers/apply_patch_spec.rs` and
 * `apply_patch.lark`. Parsing and application remain local TypeScript.
 */

import {
  generateDiffString,
  type ToolDefinition,
} from "@earendil-works/pi-coding-agent";

import { applyHunks } from "./apply";
import { APPLY_PATCH_LARK_GRAMMAR } from "./grammar";
import { ApplyPatchParseError, parsePatch } from "./parser";
import {
  type ApplyPatchRenderState,
  renderApplyPatchCall,
  renderApplyPatchResult,
} from "./render";
import { APPLY_PATCH_SCHEMA, type ApplyPatchResult } from "./types";

const APPLY_PATCH_DESCRIPTION =
  "Use the `apply_patch` tool to edit files. This is a FREEFORM tool, so do not wrap the patch in JSON.";

const APPLY_PATCH_GUIDELINES = [
  "Use `apply_patch` for local file edits. Do not create or edit files with `cat` or other shell write tricks. Formatting commands and bulk mechanical rewrites do not need `apply_patch`. Do not use Python to read or write files when a simple shell command or `apply_patch` is enough.",
];

export interface ApplyPatchDetails {
  /** The original patch text that was applied. */
  patch: string;
  /** Git-style summary lines, e.g. "A path", "M path", "D path". */
  summary: string[];
  /** Per-file display diffs. */
  fileDiffs?: ApplyPatchFileDiff[];
  /** Display-oriented diff of the changes made. */
  diff: string;
}

export interface ApplyPatchFileDiff {
  status: "A" | "M" | "D";
  path: string;
  /** Present when the file contains binary content and its diff is suppressed. */
  isBinary?: true;
  diff: string;
}

export function createApplyPatchToolDefinition(
  cwd: string,
): ToolDefinition<
  typeof APPLY_PATCH_SCHEMA,
  ApplyPatchDetails | undefined,
  ApplyPatchRenderState
> {
  return {
    name: "apply_patch",
    label: "apply_patch",
    description: APPLY_PATCH_DESCRIPTION,
    promptSnippet:
      "Apply a V4A text patch to create, update, delete, or rename files",
    promptGuidelines: APPLY_PATCH_GUIDELINES,
    // Pi uses this single-string schema to normalize a custom tool's raw
    // freeform input into `{ input }` before calling execute(). It is not sent
    // as a function-tool schema when OpenAI grammar tools are supported.
    parameters: APPLY_PATCH_SCHEMA,
    constrainedSampling: {
      type: "grammar",
      variants: { openai_lark: APPLY_PATCH_LARK_GRAMMAR },
    },
    renderShell: "default",
    async execute(_toolCallId, params, signal, onUpdate, ctx) {
      const workdir = ctx?.cwd ?? cwd;
      const { hunks } = parsePatch(params.input);
      // Stream a partial result per committed hunk so the UI renders files as
      // they are edited/created, instead of only after the whole patch lands.
      const result = await applyHunks(
        hunks,
        workdir,
        (partial) => {
          onUpdate?.({
            content: [],
            details: buildApplyPatchDetails(params.input, partial),
          });
        },
        signal,
      );
      const details = buildApplyPatchDetails(params.input, result);
      return {
        content: [
          {
            type: "text",
            text:
              "Success. Updated the following files:\n" +
              result.summary.join("\n"),
          },
        ],
        details,
      };
    },
    renderCall: renderApplyPatchCall,
    renderResult: renderApplyPatchResult,
  };
}

function getFileChangeStatus(
  before: string,
  after: string,
): ApplyPatchFileDiff["status"] {
  if (!before) return "A";
  if (!after) return "D";
  return "M";
}

/**
 * Build the renderable `ApplyPatchDetails` (summary + per-file diffs) from a
 * (possibly partial) apply result. Shared by the final return and the
 * per-hunk `onUpdate` stream so the live view matches the settled view.
 */
function buildApplyPatchDetails(
  patch: string,
  result: ApplyPatchResult,
): ApplyPatchDetails {
  const fileDiffs = result.fileChanges
    .map((change): ApplyPatchFileDiff | undefined => {
      if (change.isBinary) {
        return {
          status: getFileChangeStatus(change.before, change.after),
          path: change.path,
          isBinary: true,
          diff: "",
        };
      }
      const diff = generateDiffString(change.before, change.after).diff;
      if (!diff) return undefined;
      return {
        status: getFileChangeStatus(change.before, change.after),
        path: change.path,
        diff,
      };
    })
    .filter((change): change is ApplyPatchFileDiff => change !== undefined);
  const diff = fileDiffs
    .map((change) => `${change.path}\n${change.diff}`)
    .join("\n\n");
  return {
    patch,
    summary: result.summary,
    fileDiffs,
    diff,
  };
}

// Re-export parse error type so callers (and tests) can distinguish parse
// failures from apply failures.
export { ApplyPatchParseError };
