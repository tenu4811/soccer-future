#!/bin/bash
# check-d8-charcount.sh — D8 字数统计
# 用法: bash scripts/check-d8-charcount.sh <文件路径>

if [ -z "$1" ]; then
  echo "用法: bash check-d8-charcount.sh <文件路径>"
  exit 1
fi

CHARS=$(wc -m < "$1")
echo "D8 字数统计: $CHARS"
if [ "$CHARS" -ge 15000 ]; then
  echo "D8 判定: ✅ 通过 (≥15,000)"
else
  echo "D8 判定: ❌ 不通过 (<15,000)"
fi
echo "D8_SCORE=$CHARS"
