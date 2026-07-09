#!/bin/bash
# check-d1-estimates.sh — D1 估算标记检测
# 用法: bash scripts/check-d1-estimates.sh <文件路径>

if [ -z "$1" ]; then
  echo "用法: bash check-d1-estimates.sh <文件路径>"
  exit 1
fi

# 搜索估算/模糊标记
MATCHES=$(grep -cP '(估|~|约|大约|待补充|暂缺|\b大概\b)' "$1")

echo "D1 估算标记检测:"
if [ "$MATCHES" -eq 0 ]; then
  echo "  ✅ 未发现估算标记"
else
  echo "  ⚠️ 发现 $MATCHES 处估算标记"
  grep -nP '(估|~|约|大约|待补充|暂缺|\b大概\b)' "$1" | head -20 | sed 's/^/    /'
fi
echo "D1_ESTIMATES=$MATCHES"
