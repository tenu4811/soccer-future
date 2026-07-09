# 管理器运行指令

> 你在 Claude Code 主会话中阅读此文件。你是编排器。
> 法国vs摩洛哥实战验证：17阶段，17次Agent调用，91.3分，87k字最终报告。

---

## 启动前检查

1. `config.yaml` 已填写：主客队名、FBref ID、TM ID、比赛日期/阶段/场地
2. outputs 目录已创建：`outputs/YYYY-MM-DD-主队vs客队/`
3. `scripts/check-all.sh` 可用

---

## 执行序列

### 阶段0：时间戳确认（主会话直接执行，不派Agent）

输出写入 `outputs/$MATCH_DIR/00-stage-0-timestamp.md`：
- 比赛基本信息表（日期/场地/容量/阶段/裁判/VAR）
- Q1-Q7 新鲜度检查表
- 赛程疲劳量化表（休息天数/旅行距离）
- Elo基线
- 字数底线：≥300字

### 阶段1a+1b：主客队数据采集（并行2个Agent）

```
Agent tool (general-purpose) → agents/stage-01a-team-home.md
  Playwright 直访 FBref/TM/WS
  输出：outputs/$MATCH_DIR/01a-team-[主队名].md

Agent tool (general-purpose) → agents/stage-01b-team-away.md
  Playwright 直访 FBref/TM/WS
  输出：outputs/$MATCH_DIR/01b-team-[客队名].md
```

等待两者完成。验证：每队阵容≥20人，YAML格式正确。

### 阶段1A：宏观统计画像（1个Agent）

```
Agent tool (general-purpose) → agents/stage-01a-statistical.md
  输入：阶段1a/1b YAML
  输出：outputs/$MATCH_DIR/01a-statistical-portrait.md（11项统计表+泊松校验）
```

完成后合并全部 YAML → ⛔ 门禁1

### ⛔ 门禁1（主会话 Bash）

```bash
bash scripts/check-d1-estimates.sh outputs/$MATCH_DIR/01a-statistical-portrait.md
bash scripts/check-d9-tags.sh outputs/$MATCH_DIR/01a-statistical-portrait.md
```
判定：D1≥4 且 D5≥4 且 D9≥4 → 通过。不通过则退回阶段1A补充。

### 阶段1.5-1.8：分析链（串行4个Agent，YAML链式传递）

```
Agent (general-purpose) → agents/stage-01.5-cross.md
  输入：1a/1b/1A YAML
  输出：outputs/$MATCH_DIR/01.5-cross-analysis.md

Agent (general-purpose) → agents/stage-01.6-poisson.md
  输入：1.5 YAML（含SCC量化值）
  输出：outputs/$MATCH_DIR/01.6-poisson-prediction.md

Agent (general-purpose) → agents/stage-01.7-bayesian.md
  输入：1.6 YAML（含泊松先验概率）
  输出：outputs/$MATCH_DIR/01.7-bayesian-update.md

Agent (general-purpose) → agents/stage-01.8-formation.md
  输入：1a/1b 阵型数据
  输出：outputs/$MATCH_DIR/01.8-formation-analysis.md
```

→ ⛔ 阶段1出口检查（主会话 Bash）：
```bash
# R1：否定性声称必须挂源标签
grep -Pn '(无|未|0|从不|尚未)' outputs/$MATCH_DIR/01.*.md | grep -v '\[FBref\]|\[TM\]|\[WS\]'
# R4：数值字段不能有"估/~/约"
grep -Pn '(估|~|约|大约)' outputs/$MATCH_DIR/01.*.md
```

### 阶段2-2.5（串行2个Agent）

```
Agent (general-purpose) → agents/stage-02-matchup.md
  输出：outputs/$MATCH_DIR/02-matchup.md

Agent (general-purpose) → agents/stage-02.5-interaction.md
  输出：outputs/$MATCH_DIR/02.5-interaction.md
```

### 阶段2a：数据验证+7步思维链（1个Agent）

```
Agent (general-purpose) → agents/stage-02a-chain.md
  输入：全部前序 YAML
  输出：outputs/$MATCH_DIR/02a-chain-validation.md
```

→ ⛔ 门禁2预评（主会话 Bash）：
```bash
# 博弈点指向性检查
grep -cP '(if.*then|若.*则|触发条件|因果链)' outputs/$MATCH_DIR/02a-chain-validation.md
# 反指标完整性检查
grep -cP '(错误|失败信号|逆向)' outputs/$MATCH_DIR/02a-chain-validation.md
```
判定：D2≥4 且 D3≥4 且 D7≥4 → 通过。

### 阶段2b-2g（串行6个Agent）

```
Agent (general-purpose) → agents/stage-02b-macro.md
  输出：outputs/$MATCH_DIR/02b-macro-variables.md

Agent (general-purpose) → agents/stage-02c-lineup.md
  输出：outputs/$MATCH_DIR/02c-lineup-prediction.md

Agent (general-purpose) → agents/stage-02d-spatial.md
  输出：outputs/$MATCH_DIR/02d-spatial-matchup.md

Agent (general-purpose) → agents/stage-02e-supplementary.md
  输出：outputs/$MATCH_DIR/02e-supplementary.md

Agent (general-purpose) → agents/stage-02f-prediction.md
  输出：outputs/$MATCH_DIR/02f-prediction.md

Agent (general-purpose) → agents/stage-02g-ratings.md
  输出：outputs/$MATCH_DIR/02g-ratings.md
```

→ ⛔ 阶段2出口检查（主会话 Bash）：
```bash
grep -Pn '(估|~|约|大约)' outputs/$MATCH_DIR/02*.md
```

### 阶段3：写作+速查卡（1个Agent）

```
Agent (general-purpose) → agents/stage-03-writing.md
  输入：全部前序 YAML + 阶段2g评分数据
  输出：outputs/$MATCH_DIR/03-final-report.md
```

→ ⛔ 阶段3出口检查（主会话 Bash）：
```bash
bash scripts/check-d10-latin.sh outputs/$MATCH_DIR/03-final-report.md
```
拉丁文命中 = 0（白名单除外）→ 通过。>0 → 修正后重跑。

### 阶段4：数据验证（1个Agent）

```
Agent (general-purpose) → agents/stage-04-validation.md
  输入：阶段3完整报告 + 全部前序 YAML
  输出：outputs/$MATCH_DIR/04-validation.md
```

任务：数据供应链追溯、十种骗局防范检查、来源标注率统计、修正建议。

要求：标注率 ≥ 95%、10/10骗局检查通过。

### 阶段5：质量评分+门禁3（主会话 Bash）

```bash
bash scripts/check-all.sh outputs/$MATCH_DIR/03-final-report.md
```

脚本自动执行：D8(字数) / D10(拉丁文) / D9(源标签) / D1(估算标记) / D4(模板套话) / D11(YAML) → 输出汇总。

→ ⛔ 门禁3：D8≥15000 ✓ 且 D10<3 ✓ 且 总分≥88 ✓ → ✅ 可交付

总分 < 88 → 输出 `⚠️ 质量未达标：当前XX分，需补充：[最低分维度]`，退回对应阶段补充。**禁止在总分<88时说"报告已交付"。**

### 装配最终报告

手动汇总 to `outputs/$MATCH_DIR/quality-report.json`：
- machine_checks 字段：从 check-all.sh 输出提取实际数值
- scoring_detail 字段：10维加权计算
- gates 字段：三门禁判定结果
- lessons_learned 字段：本次发现的新问题

---

## Agent 调用模板

```
Agent tool:
  subagent_type: "general-purpose"
  prompt: |
    读取 agents/stage-XX-name.md，执行其中的任务。
    
    ## 上游 YAML 数据
    [sed 提取的前置阶段 YAML 摘要]
    
    ## 输出
    将完整结果写入 outputs/YYYY-MM-DD-主队vs客队/XX-stage-name.md
    
    必须输出：
    1. 完成信号：✅ 阶段XX完成 [具体要求]
    2. YAML数据摘要（```yaml 代码块）
    3. 正文
```

## YAML 传递

每阶段完成后提取 YAML 供下游使用：
```bash
sed -n '/^```yaml/,/^```/p' outputs/$MATCH_DIR/XX-stage-name.md | grep -v '^```'
```

---

## 实战教训（法国vs摩洛哥，91.3分）

### 已知坑位

| 坑 | 现象 | 对策 |
|----|------|------|
| **Agent崩溃** | 阶段1.6系统崩溃，文件未写入 | 用 SendMessage 恢复Agent，传入关键数据摘要 |
| **Agent不结束** | 阶段2f跑25分钟、阶段3文件写完但挂起 | `ls -la` 确认文件存在且大小正常 → 跳过等待 |
| **D4自评盲区** | Agent自评5.0，用户发现"PSG前队友对决"模板 | 已新增 `check-d4-cliches.sh` 机器grep，Agent自评不可信 |
| **FBref H2H被拦** | Playwright返回Cloudflare 1020 | Firecrawl三源交叉验证（11v11/AiScore/Flashscore） |
| **Oddspedia未上架** | 比赛赔率尚未列出 | 降级为DraftKings+Polymarket+bet365 |
| **SS雷达无实测** | SofaScore五维无法直接采集 | 标注[SS估算]，基于WS数据推算 |
| **裁判单源错误** | Playwright直访WorldReferee"已确认"的裁判实际是预测/泄露数据 | 裁判必须≥2独立源交叉验证，以FIFA官方公告为准；-48h前标注"待官方确认" |

### 门禁不可跳过

法国vs摩洛哥实战中，门禁1和门禁2的grep检查**均由主会话执行**，不依赖Agent自评。门禁3的check-all.sh输出真实机器数值。D4自评5.0被用户纠正为3.5的教训说明：**任何Agent自评维度都应有对应机器grep校验。**

### 否定性声称规则

任何"无/未/0/从不/尚未"类表述，必须挂数据源标签（[FBref]/[TM]/[WhoScored]等），否则视为未验证，不得写入报告。葡萄牙vs克罗地亚审计中H2H漏报的教训——不知道≠不存在。

---

## 阶段文件清单（对齐法国vs摩洛哥实战）

| 文件 | 阶段 | 方式 | 字数底线 |
|------|:----:|:----:|:----:|
| 00-stage-0-timestamp.md | 0 | 主会话直接 | 300 |
| 01a-team-[主队].md | 1a | Agent（并行） | 500 |
| 01b-team-[客队].md | 1b | Agent（并行） | 500 |
| 01a-statistical-portrait.md | 1A | Agent | 600 |
| 01.5-cross-analysis.md | 1.5 | Agent | 400 |
| 01.6-poisson-prediction.md | 1.6 | Agent | 500 |
| 01.7-bayesian-update.md | 1.7 | Agent | 400 |
| 01.8-formation-analysis.md | 1.8 | Agent | 500 |
| 02-matchup.md | 2 | Agent | 200 |
| 02.5-interaction.md | 2.5 | Agent | 400 |
| 02a-chain-validation.md | 2a | Agent | 500 |
| 02b-macro-variables.md | 2b | Agent | 750 |
| 02c-lineup-prediction.md | 2c | Agent | 500 |
| 02d-spatial-matchup.md | 2d | Agent | 1500 |
| 02e-supplementary.md | 2e | Agent | 600 |
| 02f-prediction.md | 2f | Agent | 800 |
| 02g-ratings.md | 2g | Agent | 500 |
| 03-final-report.md | 3 | Agent | 85000 |
| 04-validation.md | 4 | Agent | 400 |
| quality-report.json | 5 | Bash | — |

**共19阶段产物，18次Agent调用，3次主会话Bash。**
