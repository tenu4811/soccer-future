#!/bin/bash
# check-all.sh — 一键全跑所有质量检查
# 用法: bash scripts/check-all.sh <文件路径>
# 输出: 逐项打印 + outputs/latest/quality-report.json

if [ -z "$1" ]; then
  echo "用法: bash check-all.sh <文件路径>"
  exit 1
fi

FILE="$1"
OUTDIR=$(dirname "$FILE")
SCRIPT_DIR=$(dirname "$0")

echo "════════════════════════════════════════════"
echo "  足球分析质量自检报告"
echo "  文件: $FILE"
echo "════════════════════════════════════════════"
echo ""

RESULTS_FILE="$OUTDIR/quality-check-results.txt"
> "$RESULTS_FILE"

# D8 字数
bash "$SCRIPT_DIR/check-d8-charcount.sh" "$FILE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# D10 拉丁文
bash "$SCRIPT_DIR/check-d10-latin.sh" "$FILE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# D9 源标签
bash "$SCRIPT_DIR/check-d9-tags.sh" "$FILE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# D1 估算标记
bash "$SCRIPT_DIR/check-d1-estimates.sh" "$FILE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# D4 模板套话 [2026-07-07新增]
bash "$SCRIPT_DIR/check-d4-cliches.sh" "$FILE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# D11 YAML
bash "$SCRIPT_DIR/check-d11-yaml.sh" "$FILE" | tee -a "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# 从结果文件提取D8/D9/D10/D1/D4关键值
D8_VAL=$(grep -oP 'D8_SCORE=\K\d+' "$RESULTS_FILE")
D10_VAL=$(grep -oP 'D10_COUNT=\K\d+' "$RESULTS_FILE")
D9_VAL=$(grep -oP 'D9_COUNT=\K\d+' "$RESULTS_FILE")
D1_VAL=$(grep -oP 'D1_ESTIMATES=\K\d+' "$RESULTS_FILE")
D4_VAL=$(grep -oP 'D4_CLICHES=\K\d+' "$RESULTS_FILE")

echo "════════════════════════════════════════════" | tee -a "$RESULTS_FILE"
echo "  质量检查汇总" | tee -a "$RESULTS_FILE"
echo "  D8 字数: ${D8_VAL:-未检测}" | tee -a "$RESULTS_FILE"
echo "  D10 拉丁文: ${D10_VAL:-未检测} 处" | tee -a "$RESULTS_FILE"
echo "  D9 源标签: ${D9_VAL:-未检测} 种" | tee -a "$RESULTS_FILE"
echo "  D1 估算标记: ${D1_VAL:-未检测} 处" | tee -a "$RESULTS_FILE"
echo "  D4 模板套话: ${D4_VAL:-未检测} 处" | tee -a "$RESULTS_FILE"
echo "════════════════════════════════════════════" | tee -a "$RESULTS_FILE"
echo ""
echo "详细结果已保存: $RESULTS_FILE"
