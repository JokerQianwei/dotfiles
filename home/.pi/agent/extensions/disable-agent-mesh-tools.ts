import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const AGENT_MESH_TOOLS = new Set([
  "list_peers",
  "agent_send",
  "agent_request",
]);

export default function disableAgentMeshTools(pi: ExtensionAPI) {
  pi.on("session_start", () => {
    // 只隐藏 Agent 间通信工具；remote-pi 的手机桥接和 Relay 仍保持运行。
    pi.setActiveTools(
      pi.getActiveTools().filter((name) => !AGENT_MESH_TOOLS.has(name)),
    );
  });
}
