---
name: knowledge-memory
description: 通过 TokenHub MCP 使用用户长期记忆和 Agent Skill。用户要求记住/查找历史约定/继续先前偏好，或需要复用可执行流程时使用。
version: 2026.09.09.2
source: https://github.com/TencentCloud/TencentDB-Agent-Memory
---

# TokenHub Long-term Memory

这个 Skill 配合 TokenHub MCP Server `knowledge-base` 使用。客户端只需要支持 MCP；
身份由 TokenHub Gateway 在 `/mcp/knowledge-base` 请求中注入，Agent 或用户不要伪造
`x-tokenhub-user`，也不要让一个 Agent 操作其他人的记忆。

## 何时检索

在回答或执行前调用 `memory_recall`，重点场景包括：

- 用户说“继续刚才 / 按之前的约定 / 我偏好 / 我们项目里”。
- 当前任务涉及部署约束、权限边界、命名规则、沟通偏好或稳定决策。
- 用户要求查找以前说过的结论，或答案依赖历史上下文。

调用时传入当前客户端的真实 `query`；需要原始对话时设置
`include_conversations=true`。没有命中的记忆必须明说“没有找到”，不要虚构。

## 何时写入

只有两类内容调用 `memory_capture`：

1. 用户明确要求记住。
2. 对话包含长期价值：稳定偏好、项目约束、关键决策、复用结论。

不要保存临时调试过程、密码、Token、私钥、手机号、身份证等敏感数据。
如果用户要求保存凭据，先建议改用平台的凭据存储；拒绝后也不要写入记忆。

已确认的规则、约束或工作流用 `memory_scene_write` 写入稳定路径：

- `project/<topic>.md`：项目部署、架构、权限、发版规则。
- `preferences/<topic>.md`：沟通和协作偏好。

路径必须相对且稳定，例如 `project/deploy.md`，不要使用临时会话路径。

## 何时沉淀 Skill

完成一段可复用流程，或用户明确说“沉淀为 Skill / 保存工作流”时，调用
`skill_extract`。提交的 `messages` 必须包含至少两条有效消息，优先保留用户目标、
关键决策、工具调用、成功结果和注意事项。

需要复用已有流程时先调用 `skill_search`，找到后用 `skill_get` 读取全文，再执行。

## 隔离与可删除性

- `agent_id` 默认是 `default`；Codex、Claude、OpenCode 等客户端可传入不同值，
  用同一 TokenHub 用户下的独立记忆空间。
- 用户可在 Console「知识库与记忆 → 记忆」查看、搜索和删除记忆与 Skill。
- 删除前应向用户确认；删除是不可恢复的数据面操作。
