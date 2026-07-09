#!/bin/bash
# check-d11-yaml.sh — D11 YAML数据块完整性检查
# 用法: bash scripts/check-d11-yaml.sh <文件路径>

if [ -z "$1" ]; then
  echo "用法: bash check-d11-yaml.sh <文件路径>"
  exit 1
fi

BLOCKS=$(grep -c "stage:" "$1" 2>/dev/null || echo 0)
COMPLETE=$(grep -c "status: complete" "$1" 2>/dev/null || echo 0)

echo "D11 YAML数据块检查:"
echo "  stage: 标记数 = $BLOCKS"
echo "  status: complete 标记数 = $COMPLETE"

if [ "$BLOCKS" -ge 10 ]; then
  echo "D11 判定: ✅ 通过 (≥10)"
else
  echo "D11 判定: ⚠️ 不足10个"
fi
echo "D11_BLOCKS=$BLOCKS"
echo "D11_COMPLETE=$COMPLETE"
