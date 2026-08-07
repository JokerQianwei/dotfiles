import { homedir } from "node:os";
import { isAbsolute, join, relative } from "node:path";
import type { Theme } from "@earendil-works/pi-coding-agent";
import type { Component } from "@earendil-works/pi-tui";
import {
  buildEditCallComponent,
  type EditRenderContext,
  type EditRenderState,
  getCallComponent,
  renderEditResultComponent,
  statusFromContext,
} from "../shared/render";
import type { KimiEditDetails, KimiEditInput } from "./edit";

/** Inlined from pi-harness `@harness/utils` to keep this extension standalone. */
function formatDisplayPath(path: string, cwd: string): string {
  if (!path) return path;
  const abs = isAbsolute(path) ? path : join(cwd, path);
  const rel = relative(cwd, abs);
  if (rel === "") return ".";
  if (!rel.startsWith("..") && !isAbsolute(rel)) return rel;
  const home = homedir();
  return home && abs.startsWith(home) ? `~${abs.slice(home.length)}` : abs;
}

export type KimiEditRenderState = EditRenderState;

export function renderKimiEditCall(
  args: KimiEditInput,
  theme: Theme,
  context: EditRenderContext<KimiEditInput>,
) {
  const component = getCallComponent(context.state, context.lastComponent);
  return buildEditCallComponent(
    component,
    "edit",
    formatDisplayPath(args.path, context.cwd),
    statusFromContext(context),
    theme,
  );
}

export function renderKimiEditResult(
  result: {
    content: Array<{ type: string; text?: string }>;
    details?: KimiEditDetails;
  },
  options: { expanded: boolean },
  theme: Theme,
  context: { isError: boolean; lastComponent?: Component },
) {
  return renderEditResultComponent(result, options, theme, context);
}
