#!/bin/bash
# check-d4-cliches.sh — D4 模板套话检测
# 用法: bash scripts/check-d4-cliches.sh <文件路径>
# 2026-07-07 新增，教训来源：法国vs摩洛哥报告中"PSG前队友对决"被Agent自评漏过

if [ -z "$1" ]; then
  echo "用法: bash check-d4-cliches.sh <文件路径>"
  exit 1
fi

# 媒体叙事模板套话正则库（持续维护）
PATTERNS='(前队友对决|前队友效应|老对手|恩怨对决|宿命对决|火星撞地球|矛与盾的对决|最强之矛|最强之盾|巅峰对决|世纪之战|复仇之战|新老交替|青春风暴|黄金一代|无冕之王|黑马逆袭|逆转基因|大心脏|为荣誉而战|证明自己|正名之战|救赎之战|王者归来|史诗级|天王山|矛盾之争)'

MATCHES=$(grep -Pc "$PATTERNS" "$1")

echo "D4 模板套话检测:"
if [ "$MATCHES" -eq 0 ]; then
  echo "  ✅ 未发现模板套话"
else
  echo "  ⚠️ 发现 $MATCHES 处模板套话"
  grep -Pn "$PATTERNS" "$1" | head -30 | sed 's/^/    /'
fi
echo "D4_CLICHES=$MATCHES"
