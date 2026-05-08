#!/usr/bin/env bash
# uninstall.sh — 설치된 sermon skill을 제거
#
# 사용법:
#   bash scripts/uninstall.sh                       # ~/.claude/skills/sermon-* 제거
#   bash scripts/uninstall.sh --target ./.claude/skills

set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; RESET='\033[0m'
ok()   { echo -e "${GREEN}✓${RESET} $1"; }
info() { echo -e "${BLUE}ℹ${RESET} $1"; }
warn() { echo -e "${YELLOW}⚠${RESET} $1"; }
err()  { echo -e "${RED}✗${RESET} $1" >&2; }

TARGET="${HOME}/.claude/skills"
YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    -y|--yes) YES=1; shift ;;
    -h|--help)
      echo "Usage: bash scripts/uninstall.sh [--target <dir>] [-y]"; exit 0 ;;
    *) err "알 수 없는 옵션: $1"; exit 1 ;;
  esac
done

echo ""
echo -e "${BOLD}🗑  Uninstall sermon skills${RESET}"
info "Target: $TARGET"
echo ""

if [[ ! -d "$TARGET" ]]; then
  warn "디렉토리가 없습니다: $TARGET"
  exit 0
fi

# 제거할 sermon-* 항목 수집
mapfile -t TO_REMOVE < <(find "$TARGET" -maxdepth 1 -name 'sermon-*' \( -type d -o -type l \) 2>/dev/null)

if [[ ${#TO_REMOVE[@]} -eq 0 ]]; then
  info "제거할 sermon skill이 없습니다."
  exit 0
fi

echo "다음 ${#TO_REMOVE[@]}개 항목이 제거됩니다:"
for p in "${TO_REMOVE[@]}"; do
  echo "  - $(basename "$p")"
done
echo ""

if [[ $YES -eq 0 ]]; then
  read -r -p "계속하시겠습니까? [y/N] " response
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    info "취소되었습니다."
    exit 0
  fi
fi

REMOVED=0
for p in "${TO_REMOVE[@]}"; do
  if rm -rf "$p" 2>/dev/null; then
    ok "Removed: $(basename "$p")"
    REMOVED=$((REMOVED + 1))
  else
    err "실패: $(basename "$p")"
  fi
done

echo ""
ok "총 $REMOVED개 스킬 제거 완료."
