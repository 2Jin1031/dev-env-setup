#!/usr/bin/env bash
# 작업 폴더(git 레포)에 pre-commit 훅을 깐다.
# 훅: 커밋 직전에 레포 안의 gradlew로 test를 돌리고, 실패하면 커밋을 막는다.
# 사용: 작업 폴더 안에서 bash <dev-env-setup 경로>/setup-hooks.sh
set -euo pipefail

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "git 레포가 아니다. 작업 폴더 안에서 실행하거나 먼저 git init 한다." >&2
  exit 1
fi

hooks_dir="$(git rev-parse --git-path hooks)"
mkdir -p "$hooks_dir"
hook="$hooks_dir/pre-commit"

if [ -e "$hook" ]; then
  backup="$hook.bak.$(date +%Y%m%d%H%M%S)"
  cp "$hook" "$backup"
  echo "기존 훅 백업: $backup"
fi

cat > "$hook" <<'EOF'
#!/usr/bin/env bash
# pre-commit: 커밋 전에 테스트를 돌리고, 실패하면 커밋을 막는다. (dev-env-setup/setup-hooks.sh가 설치)
[ -f "$HOME/.jdk-env" ] && . "$HOME/.jdk-env"
cd "$(git rev-parse --show-toplevel)" || exit 1

found=0
while IFS= read -r w; do
  found=1
  dir="$(dirname "$w")"
  echo "pre-commit: $dir 에서 gradlew test"
  log="$(mktemp)"
  if ! (cd "$dir" && sh ./gradlew test --console=plain) >"$log" 2>&1; then
    tail -n 40 "$log" >&2
    rm -f "$log"
    echo "pre-commit: 테스트 실패로 커밋을 막음. 고치고 다시 커밋한다. --no-verify로 건너뛰지 않는다." >&2
    exit 1
  fi
  rm -f "$log"
done < <(find . -maxdepth 3 -name gradlew -type f -not -path '*/build/*' -not -path '*/node_modules/*' | sort)

if [ "$found" -eq 0 ]; then
  echo "pre-commit: gradlew가 없어 테스트를 건너뜀"
  exit 0
fi
echo "pre-commit: 테스트 통과"
EOF

chmod +x "$hook"
echo "설치 완료: $hook"
echo "확인: 테스트가 실패하는 상태에서 git commit 하면 막혀야 한다."
