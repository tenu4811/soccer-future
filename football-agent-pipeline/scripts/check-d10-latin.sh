#!/bin/bash
# check-d10-latin.sh — D10 拉丁文姓名检测
# 用法: bash scripts/check-d10-latin.sh <文件路径>

if [ -z "$1" ]; then
  echo "用法: bash check-d10-latin.sh <文件路径>"
  exit 1
fi

# 白名单：允许的拉丁文缩写
ALLOWED="UEFA|FIFA|VAR|PSG|FC|AC|FCB|RMA|MUFC|SS|WS|OD|TM|FBref|Opta|BBC|CNN|ESPN"

# 找出拉丁文姓名（首字母大写的连续两个单词）
MATCHES=$(grep -oP '\b[A-Z][a-z]+ [A-Z][a-z]+\b' "$1" | grep -vP "^($ALLOWED)$" | sort -u)

COUNT=$(echo "$MATCHES" | grep -c . || echo 0)

echo "D10 拉丁文姓名检测结果:"
if [ "$COUNT" -eq 0 ]; then
  echo "  ✅ 未发现违规拉丁文姓名"
else
  echo "  ❌ 发现 $COUNT 处拉丁文姓名:"
  echo "$MATCHES" | sed 's/^/    /'
fi
echo "D10_COUNT=$COUNT"
