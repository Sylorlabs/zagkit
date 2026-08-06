#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$root"

fail() {
    printf 'contract check: FAIL: %s\n' "$1" >&2
    exit 1
}

require_file() {
    [ -f "$1" ] || fail "missing required file: $1"
}

require_json() {
    require_file "$1"
    jq -e . "$1" >/dev/null || fail "invalid JSON: $1"
}

command -v jq >/dev/null 2>&1 || fail "jq is required to validate repository contracts"

for path in \
    LICENSE README.md GOAL.md CHANGELOG.md CONTRIBUTING.md GOVERNANCE.md VERSIONING.md \
    SUPPORT.md SECURITY.md DEPENDENCIES.md ROADMAP.md zag.mod \
    docs/design/visual-direction.md docs/quality/release-gates.md \
    docs/automation/talkback.md \
    docs/architecture/README.md docs/milestones/0000-product-contract.md \
    benchmarks/README.md; do
    require_file "$path"
done

for path in \
    docs/rfcs/0000-rfc-process.md \
    docs/rfcs/0001-product-and-platform-contract.md \
    docs/rfcs/0002-declarative-core-and-rendering.md \
    docs/rfcs/0003-text-semantics-and-input.md \
    docs/rfcs/0004-platform-seams-and-backend-truth.md \
    docs/rfcs/0005-quality-and-release-contract.md \
    docs/rfcs/0006-flex-talkback-visual-fidelity-and-prismstudio.md; do
    require_file "$path"
    grep -q 'Status: Accepted' "$path" || fail "$path is not accepted"
done

grep -q 'Goal status: \*\*Active\*\*' GOAL.md || fail "master goal is not active"
checkbox_count=$(grep -Ec '^- \[[ x]\] `[A-Z0-9][A-Z0-9-]+` ' GOAL.md || true)
[ "$checkbox_count" -ge 80 ] || fail "master goal checklist lost required coverage"
checklist_ids=$(grep -E '^- \[[ x]\] `[A-Z0-9][A-Z0-9-]+` ' GOAL.md | sed -E 's/^- \[[ x]\] `([^`]+)`.*/\1/')
unique_checklist_ids=$(printf '%s\n' "$checklist_ids" | sort -u | wc -l | tr -d ' ')
[ "$unique_checklist_ids" -eq "$checkbox_count" ] || fail "master goal checklist IDs are not unique"
if grep -E '^- \[x\] ' GOAL.md | grep -vq ' — Evidence: '; then
    fail "checked goal item is missing Evidence"
fi
if grep -E '^- \[ \] ' GOAL.md | grep -vq ' — Exit: '; then
    fail "unchecked goal item is missing an Exit condition"
fi
for id in G1-SOURCE-FIRST G2-FLEX G3-FONTS G3-SVG G3-PNG G3-GLASS \
    G4-TALKBACK-IDS G4-TALKBACK-PIXELS G5-LINUX-POLISH G6-SHELL \
    G6-SCREENSHOTS G6-POLISH G7-ONE-POINT-ZERO; do
    printf '%s\n' "$checklist_ids" | grep -qx "$id" || fail "master goal is missing $id"
done

for path in contracts/toolchain.json contracts/platforms.json \
    contracts/upstream-zag.json contracts/components.json \
    contracts/benchmark-scenes.json contracts/talkback-protocol.json; do
    require_json "$path"
done

manifest_version=$(awk -F '"' '/^[[:space:]]*version[[:space:]]*=/{print $2; exit}' zag.mod)
manifest_edition=$(awk -F '"' '/^[[:space:]]*edition[[:space:]]*=/{print $2; exit}' zag.mod)
contract_version=$(jq -r '.zagkit_version' contracts/toolchain.json)
platform_version=$(jq -r '.generated_for' contracts/platforms.json)
component_version=$(jq -r '.generated_for' contracts/components.json)
benchmark_version=$(jq -r '.generated_for' contracts/benchmark-scenes.json)

[ -n "$manifest_version" ] || fail "zag.mod has no version"
printf '%s\n' "$manifest_version" | grep -Eq '^0\.[0-9]+\.[0-9]+-(experimental|alpha|beta)\.[0-9]+$' \
    || fail "pre-1.0 version must carry an experimental, alpha, or beta prerelease"
[ "$contract_version" = "$manifest_version" ] || fail "toolchain version does not match zag.mod"
[ "$platform_version" = "$manifest_version" ] || fail "platform version does not match zag.mod"
[ "$component_version" = "$manifest_version" ] || fail "component version does not match zag.mod"
[ "$benchmark_version" = "$manifest_version" ] || fail "benchmark version does not match zag.mod"
[ "$manifest_edition" = "$(jq -r '.zag.edition' contracts/toolchain.json)" ] \
    || fail "Zag edition does not match zag.mod"

compiler_commit=$(jq -r '.zag.commit' contracts/toolchain.json)
printf '%s\n' "$compiler_commit" | grep -Eq '^[0-9a-f]{40}$' \
    || fail "toolchain commit is not an exact lowercase Git SHA"
jq -e '.zag.repository == "https://github.com/Sylorlabs/zag" and
       (.zag.resolved_ref | startswith("refs/heads/")) and
       (.zag.compiler_version | length > 0) and
       (.audited_on | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$")) and
       (.evidence | length >= 3)' contracts/toolchain.json >/dev/null \
    || fail "toolchain record is incomplete"

expected_platforms='android ios linux macos windows'
actual_platforms=$(jq -r '.platforms[].id' contracts/platforms.json | sort | tr '\n' ' ' | sed 's/ $//')
required_platforms=$(jq -r '.one_point_zero.required_platforms[]' contracts/platforms.json | sort | tr '\n' ' ' | sed 's/ $//')
[ "$actual_platforms" = "$expected_platforms" ] || fail "platform matrix must contain exactly the five required families"
[ "$required_platforms" = "$expected_platforms" ] || fail "1.0 gate must require exactly the five platform families"

jq -e '
  .status_vocabulary == ["supported", "experimental", "unavailable"] and
  (.required_capabilities | sort) as $required |
  all(.platforms[];
    (.public_channel | IN("experimental", "alpha", "beta", "stable")) and
    ((.capabilities | map(.id) | sort) == $required) and
    ((.capabilities | map(.id) | unique | length) == ($required | length)) and
    all(.capabilities[];
      (.state | IN("supported", "experimental", "unavailable")) and
      (.reason | type == "string" and length > 0) and
      (.evidence | type == "array") and
      (if .state == "unavailable" then true else (.evidence | length > 0) end)
    )
  ) and
  (.one_point_zero.blocked == true) and
  all(.platforms[].capabilities[]; .state == "unavailable")
' contracts/platforms.json >/dev/null || fail "platform capability truth is incomplete or inflated"

ledger_commit=$(jq -r '.audited_commit' contracts/upstream-zag.json)
[ "$ledger_commit" = "$compiler_commit" ] || fail "upstream ledger and toolchain pin audit different Zag commits"
jq -e '
  (.entries | length >= 15) and
  ((.entries | map(.id) | unique | length) == (.entries | length)) and
  all(.entries[];
    (.state | IN("available", "partial", "missing")) and
    (.category | type == "string" and length > 0) and
    (.needed_by | type == "array" and length > 0) and
    all(.needed_by[]; . >= 2 and . <= 7) and
    (.evidence | type == "string" and length > 20) and
    (.exit_gate | type == "string" and length > 20)
  )
' contracts/upstream-zag.json >/dev/null || fail "upstream prerequisite ledger is incomplete"

for id in \
    target-linux-arm64 target-darwin-macho target-windows-pe-coff \
    target-ios-arm64 target-android-arm64 abi-objective-c abi-com abi-jni \
    abi-callbacks abi-aggregates resource-embedding dynamic-platform-loading \
    main-loop-and-workers package-resolution incremental-and-reload-hooks; do
    jq -e --arg id "$id" 'any(.entries[]; .id == $id)' contracts/upstream-zag.json >/dev/null \
        || fail "upstream prerequisite is missing: $id"
done

jq -e '
  (.visual_direction_gate.state == "blocked") and
  (.components | length >= 40) and
  ((.components | map(.id) | unique | length) == (.components | length)) and
  all(.components[];
    (.status == "planned") and
    (.milestone >= 2 and .milestone <= 4) and
    (.semantic_roles | type == "array" and length > 0) and
    (.inputs | type == "array") and
    (.adaptive | type == "array" and length > 0)
  )
' contracts/components.json >/dev/null || fail "component inventory or visual production gate is incomplete"

jq -e '
  (.result_state == "specifications-only") and
  (.scenes | length >= 10) and
  ((.scenes | map(.id) | unique | length) == (.scenes | length)) and
  all(.scenes[];
    (.status == "specification") and
    (.milestone >= 2 and .milestone <= 4) and
    (.canonical_interaction | type == "string" and length > 20) and
    (.stresses | length >= 3) and
    (.assertions | length >= 4)
  ) and
  (.variant_matrix.scale_factors | length >= 5) and
  (.variant_matrix.themes == ["light", "dark"]) and
  (.variant_matrix.contrast | length == 2) and
  (.variant_matrix.directions | sort == ["ltr", "rtl"]) and
  (.variant_matrix.text_scales | length >= 3) and
  (.variant_matrix.motion | length == 2) and
  (.variant_matrix.locales | length >= 7) and
  (.global_performance_contract.frame_deadline_p99_fraction_max == 1.0) and
  (.global_performance_contract.scroll_refresh_hz_on_supported_reference_hardware == 120) and
  (.global_performance_contract.idle_layouts_per_second_max == 0) and
  (.global_performance_contract.idle_paints_per_second_max == 0) and
  (.global_performance_contract.unexplained_two_frame_stalls_per_ten_minutes_max == 0) and
  (.global_performance_contract.regression_without_reviewed_waiver_percent_max == 5.0)
' contracts/benchmark-scenes.json >/dev/null || fail "benchmark scene contract is incomplete"

jq -e '
  .name == "Zagkit Talkback" and
  .android_assistive_technology == "Android TalkBack" and
  (.version | test("^[0-9]+\\.[0-9]+\\.[0-9]+-experimental$")) and
  .targeting.primary == "semantic-id" and
  .targeting.pixel_fallback.capability_gated == true and
  .targeting.pixel_fallback.record_coordinates == true and
  .targeting.pixel_fallback.record_scale == true and
  .targeting.pixel_fallback.may_report_as_id_target == false and
  (.commands | length == 16) and
  ((.commands | unique | length) == (.commands | length)) and
  (.statuses | length >= 9) and
  ((.statuses | unique | length) == (.statuses | length)) and
  (.request_fields | index("target-kind") != null) and
  (.request_fields | index("semantics-revision") != null) and
  (.response_fields | index("event-sequence") != null) and
  (.response_fields | index("emitted-action") != null) and
  .event_contract.ordered == true and
  .event_contract.records_accepted_and_rejected == true and
  .current_runtime_truth."native-transport" == "unavailable"
' contracts/talkback-protocol.json >/dev/null || fail "Zagkit Talkback protocol contract is incomplete"

if [ -d ../zag/.git ]; then
    git -C ../zag cat-file -e "$compiler_commit^{commit}" 2>/dev/null \
        || fail "neighboring Zag repository does not contain the pinned commit"
    printf 'contract check: verified pinned Zag commit in neighboring checkout\n'
else
    printf 'contract check: neighboring Zag checkout absent; exact SHA format validated only\n'
fi

for source_root in src packages platform; do
    if [ -d "$source_root" ] && find "$source_root" -type f \
        \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.cxx' \
           -o -name '*.zig' -o -name '*.rs' \) -print -quit | grep -q .; then
        fail "foreign implementation source found under $source_root"
    fi
done

find . -path './.git' -prune -o -name '*.md' -type f -print | sort |
while IFS= read -r markdown_file; do
    markdown_base=$(dirname "$markdown_file")
    grep -oE '\]\([^)]+\)' "$markdown_file" |
    sed -e 's/^](//' -e 's/)$//' |
    while IFS= read -r target; do
        case "$target" in
            ''|'#'*|http://*|https://*|mailto:*) continue ;;
        esac
        link_path=${target%%#*}
        [ -e "$markdown_base/$link_path" ] \
            || fail "broken Markdown link in $markdown_file: $target"
    done
done

printf 'contract check: PASS (%s, Zag %s)\n' "$manifest_version" "$compiler_commit"
