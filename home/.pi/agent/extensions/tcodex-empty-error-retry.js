/**
 * Mark tcodex/copilot empty upstream failures as retryable so pi's existing
 * auto-retry (settings.retry) kicks in.
 *
 * Upstream sometimes returns SSE:
 *   event: response.failed
 *   data: { response: { status: "failed", error: null } }
 * pi maps that to: "Unknown error (no error details in response)"
 * which is not in pi-ai's default retryable pattern list.
 *
 * ESM exports are read-only, so we patch AgentSession.prototype._isRetryableError
 * on the same class instance pi uses (via virtualModules).
 */
import { AgentSession } from "@earendil-works/pi-coding-agent";

const RETRYABLE_EMPTY_UPSTREAM_ERROR =
	/no error details in response|Unknown error \(no error details in response\)/i;

const PATCH_FLAG = "__piTcodexEmptyErrorRetryPatched";

function shouldRetryEmptyUpstreamError(message) {
	const text = message?.errorMessage;
	return typeof text === "string" && RETRYABLE_EMPTY_UPSTREAM_ERROR.test(text);
}

function installPatch() {
	const proto = AgentSession?.prototype;
	if (!proto || typeof proto._isRetryableError !== "function") {
		return false;
	}
	if (proto._isRetryableError[PATCH_FLAG]) {
		return true;
	}

	const original = proto._isRetryableError;
	function patchedIsRetryableError(message) {
		if (shouldRetryEmptyUpstreamError(message)) {
			return true;
		}
		return original.call(this, message);
	}
	patchedIsRetryableError[PATCH_FLAG] = true;
	proto._isRetryableError = patchedIsRetryableError;
	return true;
}

const installed = installPatch();

export default function tcodexEmptyErrorRetryExtension(_pi) {
	// Patch is applied at module load. Keep a no-op factory so the loader is happy.
	if (!installed) {
		// Fail soft: don't block pi startup if the internal API moves.
		console.error(
			"[tcodex-empty-error-retry] AgentSession._isRetryableError patch failed; empty upstream errors will not auto-retry",
		);
	}
}
