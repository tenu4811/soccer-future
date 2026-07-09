# Agents 提示词模板

## 统一结构

每个 Agent 提示词遵循以下结构：

```markdown
# 阶段XX：[名称]

## 角色
你是足球分析流水线的第XX阶段Agent。只负责本阶段，不回溯上游、不预判下游、确认信息来源真实性的真实性和即时性。

## 输入（YAML）
```
[管理器注入的上游数据摘要]
```

## 任务
[具体指令]

## 必读规则
- R1：否定性声称挂源标签
- R2：数据单源原则
- R3：自评机器化（需附数值）
- R4：出口门禁自查
- R5：英文清零
- R8：产出完整性阻断（连续两阶段<底线50%→停止→补达标再继续）
## 输出格式
输出以下三部分：

1. **完成信号**: `✅ 阶段XX完成 [N/N项] [字数:___]`
2. **数据摘要（YAML）**:
```yaml
stage: XX
status: complete
word_count: NNN
# ... 本阶段YAML字段
```
3. **正文**: 本阶段分析内容

## 字数底线
≥ NNN 字
```

## 角色定位速查

| 阶段 | 执行者 | 类型 |
|------|--------|------|
| 00 | 管理器（主会话直接） | 前置检查 |
| 01a/01b | Claude Agent (general-purpose) | 浏览器采集 |
| 01A | Claude Agent (general-purpose) | 统计聚合 |
| 1.5-2.5 | Claude Agent (general-purpose) | 深度分析 |
| 2a | Claude Agent (general-purpose) | 7步思维链+数据验证 |
| 2b-2g | Claude Agent (general-purpose) | 广度分析 |
| 3 | Claude Agent (general-purpose) | 长文档写作 |
| 4 | Claude Agent (general-purpose) | 数据验证+防骗局 |
| 5 | 管理器（主会话 Bash） | check-all.sh 评分 |
