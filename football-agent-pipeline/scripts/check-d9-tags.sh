#!/bin/bash
# check-d9-tags.sh — D9 源标签种类统计
# 用法: bash scripts/check-d9-tags.sh <文件路径>

if [ -z "$1" ]; then
  echo "用法: bash check-d9-tags.sh <文件路径>"
  exit 1
fi

TAGS=$(grep -oP '\b(FBref|TM|WhoScored|SS|SofaScore|Opta|Bet365|Betfair|Oddspedia|FIFA|UEFA|WorldReferee|EloRatings|Polymarket|OD|WR|RACING)\b' "$1" | sort -u)
TAG_COUNT=$(echo "$TAGS" | grep -c . || echo 0)

echo "D9 源标签种类:"
echo "  种类数: $TAG_COUNT"
echo "  标签列表:"
echo "$TAGS" | sed 's/^/    - /'

if [ "$TAG_COUNT" -ge 5 ]; then
  echo "D9 判定: ✅ 通过 (≥5)"
else
  echo "D9 判定: ⚠️ 不足5种"
fi
echo "D9_COUNT=$TAG_COUNT"
