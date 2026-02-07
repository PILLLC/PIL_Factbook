#!/usr/bin/env bash
set -euo pipefail

# Add cross-entity relationship sections for gold-standard countries:
# - countries/usa/context.adoc
# - countries/japan/context.adoc
# - countries/ukraine/context.adoc
# And (recommended):
# - orgs/nato/context.adoc
#
# Usage:
#   ./scripts/add_relationships_gold_countries.sh
#   ./scripts/add_relationships_gold_countries.sh --force   # overwrite data/relationships.yml (rare)

FORCE=0
if [[ "${1:-}" == "--force" ]]; then
  FORCE=1
fi

relfile="data/relationships.yml"

usa_ctx="countries/usa/context.adoc"
jpn_ctx="countries/japan/context.adoc"
ukr_ctx="countries/ukraine/context.adoc"
nato_ctx="orgs/nato/context.adoc"

mkdir -p data scripts

write_relationships_yml() {
  if [[ -f "$relfile" && "$FORCE" -eq 0 ]]; then
    echo "SKIP (exists): $relfile"
    return
  fi

  cat > "$relfile" <<'YAML'
schema_version: 0.1
last_updated: "2026-02-07"

relationships:

  - id: rel-usa-nato-member-001
    from: country:usa
    to: org:nato
    relationship_type: member
    label: "NATO member"
    status: active
    since: "1949-04-04"
    sources:
      - id: nato-member-countries
        title: "NATO member countries (official list)"
        url: "TBD"
        accessed: "2026-02-07"

  - id: rel-jpn-nato-partner-001
    from: country:japan
    to: org:nato
    relationship_type: partner
    label: "NATO partner (non-member cooperation)"
    status: active
    summary: >
      Japan is not a NATO member. NATO and Japan maintain cooperation as partners,
      including political dialogue and practical collaboration.
    since: "TBD"
    sources:
      - id: nato-relations-japan
        title: "NATO relations with Japan (official overview)"
        url: "TBD"
        accessed: "2026-02-07"

  - id: rel-ukr-nato-partnership-001
    from: country:ukraine
    to: org:nato
    relationship_type: partnership
    label: "Ukraine–NATO partnership"
    status: active
    summary: >
      Ukraine is not a NATO member. NATO and Ukraine maintain a formal partnership
      framework and ongoing political and practical cooperation.
    since: "1991"
    sources:
      - id: nato-relations-ukraine
        title: "NATO Relations with Ukraine (official overview)"
        url: "TBD"
        accessed: "2026-02-07"
      - id: nato-ukr-nato-commission
        title: "NATO–Ukraine Commission / partnership mechanisms (official)"
        url: "TBD"
        accessed: "2026-02-07"
YAML

  echo "WRITE: $relfile"
}

ensure_file_exists() {
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "ERROR: expected file not found: $f"
    exit 1
  fi
}

append_if_missing() {
  local f="$1"
  local marker="$2"
  local block="$3"

  if grep -qF "$marker" "$f"; then
    echo "SKIP (already updated): $f"
    return
  fi

  printf "\n%s\n" "$block" >> "$f"
  echo "UPDATE: $f"
}

# --- main ---
write_relationships_yml

ensure_file_exists "$usa_ctx"
ensure_file_exists "$jpn_ctx"
ensure_file_exists "$ukr_ctx"
ensure_file_exists "$nato_ctx"

USA_BLOCK=$(cat <<'ADOC'

== Relationships

Relationships are maintained in `data/relationships.yml` for auditability.

[cols="1,1,3",options="header"]
|===
| Relationship ID | Type | Summary
| rel-usa-nato-member-001 | member | The United States is a NATO member.
|===
ADOC
)

JPN_BLOCK=$(cat <<'ADOC'

== Relationships

Relationships are maintained in `data/relationships.yml` for auditability.

[cols="1,1,3",options="header"]
|===
| Relationship ID | Type | Summary
| rel-jpn-nato-partner-001 | partner | Japan is not a NATO member. NATO and Japan maintain cooperation as partners.
|===
ADOC
)

UKR_BLOCK=$(cat <<'ADOC'

== Relationships

Relationships are maintained in `data/relationships.yml` for auditability.

[cols="1,1,3",options="header"]
|===
| Relationship ID | Type | Summary
| rel-ukr-nato-partnership-001 | partnership | Ukraine is not a NATO member. NATO and Ukraine maintain a formal partnership framework and ongoing political and practical cooperation.
|===
ADOC
)

NATO_BLOCK=$(cat <<'ADOC'

== Relationships

Relationships are maintained in `data/relationships.yml` for auditability.

[cols="1,1,3",options="header"]
|===
| Relationship ID | Type | Summary
| rel-usa-nato-member-001 | member | The United States is a NATO member.
| rel-jpn-nato-partner-001 | partner | Japan is not a NATO member. NATO and Japan maintain cooperation as partners.
| rel-ukr-nato-partnership-001 | partnership | Ukraine is not a NATO member. NATO and Ukraine maintain a formal partnership framework and ongoing political and practical cooperation.
|===
ADOC
)

append_if_missing "$usa_ctx" "rel-usa-nato-member-001" "$USA_BLOCK"
append_if_missing "$jpn_ctx" "rel-jpn-nato-partner-001" "$JPN_BLOCK"
append_if_missing "$ukr_ctx" "rel-ukr-nato-partnership-001" "$UKR_BLOCK"
append_if_missing "$nato_ctx" "rel-usa-nato-member-001" "$NATO_BLOCK"

echo
echo "Done. Review changes with:"
echo "  git diff"
echo "Then commit/push:"
echo "  git add -A && git commit -m \"Add NATO relationships for gold-standard countries\" && git push"
