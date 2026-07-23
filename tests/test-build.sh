#!/usr/bin/env bash
set -uo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$TEST_DIR/.." && pwd -P)"
BUILD="$REPO_ROOT/scripts/build.sh"
TEST_ROOT="$(mktemp -d)"
PASSED=0
FAILED=0

cleanup() { rm -rf -- "$TEST_ROOT"; }
trap cleanup EXIT

assert_file() { [[ -f "$1" ]] || { printf 'expected file: %s\n' "$1" >&2; return 1; }; }
assert_not_exists() { [[ ! -e "$1" ]] || { printf 'expected path to be absent: %s\n' "$1" >&2; return 1; }; }
assert_contains() { grep -Fq -- "$2" "$1" || { printf 'expected %s to contain %s\n' "$1" "$2" >&2; return 1; }; }
assert_json_module() { jq -e --arg id "$2" '.modules | index($id) != null' "$1" >/dev/null || { printf 'expected module %s in %s\n' "$2" "$1" >&2; return 1; }; }
assert_no_json_module() { jq -e --arg id "$2" '.modules | index($id) == null' "$1" >/dev/null || { printf 'unexpected module %s in %s\n' "$2" "$1" >&2; return 1; }; }

run_test() {
  local name="$1" function_name="$2"
  if "$function_name"; then
    printf 'PASS %s\n' "$name"
    ((PASSED += 1))
  else
    printf 'FAIL %s\n' "$name" >&2
    ((FAILED += 1))
  fi
}

test_nested_preset() {
  local target="$TEST_ROOT/nested-preset"
  mkdir -p "$target"
  "$BUILD" --target "$target" --preset cloud-service --no-detect >/dev/null || return 1
  local state="$target/.github/.ai-security-hub.json"
  assert_json_module "$state" core && assert_json_module "$state" iac-cloud &&
    [[ "$(jq '.modules | length' "$state")" == "$(jq '.modules | unique | length' "$state")" ]]
}

test_default_policy() {
  local target="$TEST_ROOT/default-policy"
  mkdir -p "$target"
  "$BUILD" --target "$target" >/dev/null || return 1
  local state="$target/.github/.ai-security-hub.json"
  local catalog_count
  catalog_count="$(jq '.modules | length' "$REPO_ROOT/catalog/catalog.json")"
  jq -e --argjson count "$catalog_count" \
    '.preset == "full" and .mode == "path-specific" and (.modules | length) == $count' "$state" >/dev/null &&
    assert_file "$target/.github/instructions/java-kotlin.instructions.md" &&
    assert_file "$target/.github/instructions/spring.instructions.md" &&
    assert_file "$target/.github/instructions/csharp-dotnet.instructions.md" &&
    assert_file "$target/.github/instructions/c-cpp.instructions.md" &&
    assert_file "$target/.github/instructions/wordpress-drupal.instructions.md"
}

test_detection() {
  local target="$TEST_ROOT/detection"
  mkdir -p "$target/src"
  printf '%s\n' 'export default function App() {}' > "$target/src/app.tsx"
  printf '%s\n' '{"dependencies":{"react":"1","express":"1"}}' > "$target/package.json"
  printf '%s\n' 'FROM scratch' > "$target/Dockerfile"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  local state="$target/.github/.ai-security-hub.json"
  assert_json_module "$state" javascript-typescript && assert_json_module "$state" next-react &&
    assert_json_module "$state" express-nest && assert_json_module "$state" containers
}

test_cross_technology_detection() {
  local target="$TEST_ROOT/cross-technology-detection"
  mkdir -p \
    "$target/src/main/java/com/company" \
    "$target/src/dotnet" \
    "$target/native" \
    "$target/cms/wp-content/plugins/example" \
    "$target/cms/modules/custom/example"
  printf '%s\n' 'package com.company; public class AccountController {}' > "$target/src/main/java/com/company/AccountController.java"
  printf '%s\n' '<project><dependencies><dependency><artifactId>spring-boot-starter-web</artifactId></dependency></dependencies></project>' > "$target/pom.xml"
  printf '%s\n' 'public sealed class ApiController {}' > "$target/src/dotnet/ApiController.cs"
  printf '%s\n' '<Project Sdk="Microsoft.NET.Sdk.Web"></Project>' > "$target/src/dotnet/Api.csproj"
  printf '%s\n' 'int main() { return 0; }' > "$target/native/main.cpp"
  printf '%s\n' '<?php define("WP_DEBUG", false);' > "$target/cms/wp-config.php"
  printf '%s\n' '<?php' > "$target/cms/wp-content/plugins/example/example.php"
  printf '%s\n' '<?php' > "$target/cms/modules/custom/example/example.module"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  local state="$target/.github/.ai-security-hub.json"
  local module_id
  for module_id in java-kotlin spring csharp-dotnet aspnet-core c-cpp php wordpress-drupal; do
    assert_json_module "$state" "$module_id" || return 1
    assert_file "$target/.github/instructions/$module_id.instructions.md" || return 1
  done
}

test_hidden_workflow_detection() {
  local target="$TEST_ROOT/workflow"
  mkdir -p "$target/.github/workflows"
  printf '%s\n' 'name: build' > "$target/.github/workflows/build.yml"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  assert_json_module "$target/.github/.ai-security-hub.json" ci-cd
}

test_no_self_detection() {
  local target="$TEST_ROOT/no-self-detection"
  mkdir -p "$target/catalog/domains"
  printf '%s\n' 'payment guidance' > "$target/catalog/domains/payment-card.instructions.md"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  assert_no_json_module "$target/.github/.ai-security-hub.json" payment-card
}

test_path_specific_and_review_pack() {
  local target="$TEST_ROOT/path-specific"
  mkdir -p "$target"
  printf '%s\n' 'print("ok")' > "$target/main.py"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  assert_file "$target/.github/copilot-instructions.md" &&
    assert_file "$target/.github/instructions/python.instructions.md" &&
    assert_contains "$target/.github/instructions/python.instructions.md" 'applyTo:' &&
    assert_file "$target/.github/agents/secure-code-review.agent.md" &&
    assert_file "$target/.github/prompts/secure-code-review.prompt.md" &&
    assert_file "$target/.github/skills/secure-code-review-method/SKILL.md" &&
    jq -e '.reviewPack == true and (.modules | index("python") != null)' "$target/.github/.ai-security-hub.json" >/dev/null
}

test_universal_mode() {
  local target="$TEST_ROOT/universal"
  mkdir -p "$target"
  printf '%s\n' 'print("ok")' > "$target/main.py"
  "$BUILD" --target "$target" --preset baseline --mode universal >/dev/null || return 1
  assert_contains "$target/.github/copilot-instructions.md" '# Python secure coding' &&
    ! grep -Fq 'applyTo:' "$target/.github/copilot-instructions.md" &&
    assert_not_exists "$target/.github/instructions" &&
    assert_file "$target/.github/agents/secure-code-review.agent.md"
}

test_refuses_user_instruction() {
  local target="$TEST_ROOT/refuse"
  mkdir -p "$target/.github"
  printf '%s\n' 'my local rules' > "$target/.github/copilot-instructions.md"
  if "$BUILD" --target "$target" --preset baseline >/dev/null 2>&1; then return 1; fi
  [[ "$(cat "$target/.github/copilot-instructions.md")" == 'my local rules' ]]
}

test_local_instructions() {
  local target="$TEST_ROOT/local"
  mkdir -p "$target/.github"
  printf '%s\n' "Use the project's make verify command." > "$target/.github/ai-security-hub-local.md"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  assert_contains "$target/.github/copilot-instructions.md" "make verify" &&
    jq -e '.managedFiles | index(".github/ai-security-hub-local.md") == null' "$target/.github/.ai-security-hub.json" >/dev/null
}

test_unmanaged_instruction() {
  local target="$TEST_ROOT/unmanaged"
  mkdir -p "$target/.github/instructions"
  printf '%s\n' '---' 'applyTo: "**"' '---' '' 'Use the team build command.' > "$target/.github/instructions/team.instructions.md"
  local before
  before="$(sha256sum "$target/.github/instructions/team.instructions.md" | cut -d ' ' -f 1)"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  [[ "$before" == "$(sha256sum "$target/.github/instructions/team.instructions.md" | cut -d ' ' -f 1)" ]]
}

test_drift_check() {
  local target="$TEST_ROOT/drift"
  mkdir -p "$target"
  printf '%s\n' 'package main' > "$target/main.go"
  "$BUILD" --target "$target" --preset baseline --check >/dev/null 2>&1 && return 1
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  "$BUILD" --target "$target" --preset baseline --check >/dev/null
}

test_mode_change() {
  local target="$TEST_ROOT/mode-change"
  mkdir -p "$target"
  printf '%s\n' 'print("ok")' > "$target/main.py"
  "$BUILD" --target "$target" --preset baseline >/dev/null || return 1
  assert_file "$target/.github/instructions/python.instructions.md" || return 1
  "$BUILD" --target "$target" --preset baseline --mode universal >/dev/null || return 1
  assert_not_exists "$target/.github/instructions/python.instructions.md" &&
    jq -e '.mode == "universal" and .generator == "AI Security Hub"' "$target/.github/.ai-security-hub.json" >/dev/null
}

test_selection_controls() {
  local target="$TEST_ROOT/selection-controls"
  mkdir -p "$target"
  printf '%s\n' 'print("ok")' > "$target/main.py"
  "$BUILD" --target "$target" --preset baseline --no-detect --include ai-ml --exclude browser-web >/dev/null || return 1
  local state="$target/.github/.ai-security-hub.json"
  assert_json_module "$state" core && assert_json_module "$state" ai-ml &&
    assert_no_json_module "$state" browser-web && assert_no_json_module "$state" python
}

test_cross_platform_parity() {
  local bash_target="$TEST_ROOT/parity-bash"
  local ps_target="$TEST_ROOT/parity-powershell"
  mkdir -p "$bash_target/src" "$ps_target/src"
  printf '%s\n' 'export const value = 1;' > "$bash_target/src/app.ts"
  printf '%s\n' '{"dependencies":{"express":"1"}}' > "$bash_target/package.json"
  cp -a "$bash_target/." "$ps_target/"
  "$BUILD" --target "$bash_target" --preset web-service >/dev/null || return 1
  if command -v pwsh >/dev/null 2>&1; then
    pwsh -NoProfile -File "$REPO_ROOT/scripts/build.ps1" -Target "$ps_target" -Preset web-service >/dev/null || return 1
  elif command -v powershell.exe >/dev/null 2>&1 && command -v wslpath >/dev/null 2>&1; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$REPO_ROOT/scripts/build.ps1")" \
      -Target "$(wslpath -w "$ps_target")" -Preset web-service >/dev/null || return 1
  else
    printf 'SKIP PowerShell parity (PowerShell unavailable)\n'
    return 0
  fi
  diff -ru "$bash_target/.github" "$ps_target/.github" >/dev/null

  local bash_universal="$TEST_ROOT/parity-universal-bash"
  local ps_universal="$TEST_ROOT/parity-universal-powershell"
  mkdir -p "$bash_universal" "$ps_universal"
  printf '%s\n' 'package main' > "$bash_universal/main.go"
  cp -a "$bash_universal/." "$ps_universal/"
  "$BUILD" --target "$bash_universal" --preset baseline --mode universal >/dev/null || return 1
  if command -v pwsh >/dev/null 2>&1; then
    pwsh -NoProfile -File "$REPO_ROOT/scripts/build.ps1" -Target "$ps_universal" -Preset baseline -Mode universal >/dev/null || return 1
  else
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(wslpath -w "$REPO_ROOT/scripts/build.ps1")" \
      -Target "$(wslpath -w "$ps_universal")" -Preset baseline -Mode universal >/dev/null || return 1
  fi
  diff -ru "$bash_universal/.github" "$ps_universal/.github" >/dev/null
}

run_test 'nested presets resolve without duplicates' test_nested_preset
run_test 'default policy selects full path-specific coverage' test_default_policy
run_test 'stack detection selects language, frameworks and containers' test_detection
run_test 'cross-technology detection selects Java, .NET, C/C++ and CMS modules' test_cross_technology_detection
run_test 'hidden GitHub workflows are detected' test_hidden_workflow_detection
run_test 'instruction documents do not self-detect payment code' test_no_self_detection
run_test 'path-specific output includes the review pack' test_path_specific_and_review_pack
run_test 'universal output remains valid and includes the review agent' test_universal_mode
run_test 'non-generated instructions are protected' test_refuses_user_instruction
run_test 'local repository instructions are preserved' test_local_instructions
run_test 'unmanaged path instructions remain untouched' test_unmanaged_instruction
run_test 'drift check fails then passes' test_drift_check
run_test 'mode changes remove stale generated files' test_mode_change
run_test 'include, exclude and no-detect selection controls work together' test_selection_controls
run_test 'Bash and PowerShell output is byte-equivalent' test_cross_platform_parity

printf '%s passed; %s failed.\n' "$PASSED" "$FAILED"
((FAILED == 0))
