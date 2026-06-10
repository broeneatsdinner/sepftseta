#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/lib-demo-ui.sh"

usage() {
	cat <<-EOF
	Usage:
	  $0 <case-id> [--fast] [--no-color]

	Cases:
	  recruiter-voicemail
	  paypal-account-security-voicemail
	EOF
}

case_id=""
ui_args=()

while [[ $# -gt 0 ]]; do
	case "$1" in
		--fast|--no-color)
			ui_args+=("$1")
			;;
		-h|--help)
			usage
			exit 0
			;;
		--live-transcribe)
			echo "--live-transcribe is intentionally not implemented in this cached public demo." >&2
			exit 2
			;;
		-*)
			echo "Unknown option: $1" >&2
			usage >&2
			exit 2
			;;
		*)
			if [[ -n "$case_id" ]]; then
				echo "Unexpected argument: $1" >&2
				usage >&2
				exit 2
			fi
			case_id="$1"
			;;
	esac
	shift
done

if [[ -z "$case_id" ]]; then
	usage >&2
	exit 2
fi

if (( ${#ui_args[@]} )); then
	demo_ui_init "${ui_args[@]}"
else
	demo_ui_init
fi

CASE_DIR="$DEMO_ROOT/cases/$case_id"
METADATA_FILE="$CASE_DIR/metadata.env"

if [[ ! -d "$CASE_DIR" || ! -f "$METADATA_FILE" ]]; then
	echo "Unknown demo case: $case_id" >&2
	usage >&2
	exit 1
fi

source "$METADATA_FILE"

transcript_file="$CASE_DIR/transcript.presentation.verbose.txt"
raw_file="$CASE_DIR/transcript.raw.txt"
indicators_file="$CASE_DIR/indicators.txt"
ttp_file="$CASE_DIR/ttp-map.psv"
analysis_file="$CASE_DIR/analysis.txt"
notes_file="$CASE_DIR/analyst-notes.txt"

for required_file in "$transcript_file" "$raw_file" "$indicators_file" "$ttp_file" "$analysis_file" "$notes_file"; do
	if [[ ! -f "$required_file" ]]; then
		echo "Missing case artifact: $required_file" >&2
		exit 1
	fi
done

demo_header "SEPftSETA :: Controlled Voicemail Artifact"
demo_pause_short

demo_kv "Case" "$CASE_TITLE"
demo_kv "Case ID" "$CASE_ID"
demo_kv "Artifact" "$AUDIO_FILE"
demo_kv "Duration" "$DURATION"
demo_kv "Source" "$TRANSCRIPT_SOURCE"
demo_kv "Mode" "cached artifacts only"
echo
demo_type_wrap "$CASE_SUMMARY" "$DEMO_TYPE_INTRO"
demo_pause_medium

demo_spinner "$DEMO_SPINNER_AUDIO" "Preparing controlled audio artifact"
demo_spinner "$DEMO_SPINNER_TRANSCRIPT" "Processing cached Whisper transcript"
demo_section "Transcript and timestamps"
demo_reveal_file "$transcript_file" "$DEMO_TYPE_TRANSCRIPT" 0.20

demo_spinner "$DEMO_SPINNER_INDICATORS" "Extracting behavioral indicators"
demo_stage "Signal emerging..."
demo_pause_short
demo_section "Behavioral indicators"
demo_reveal_file "$indicators_file" "$DEMO_TYPE_ANALYSIS" 0.35

demo_spinner "$DEMO_SPINNER_MITRE" "Mapping indicators to MITRE ATT&CK"
demo_section "MITRE ATT&CK behavioral mapping"
demo_type_wrap "Actual MITRE ATT&CK technique IDs are used where applicable. Procedure rows are project-specific controlled-demo procedures, not attribution, proof of compromise, or evidence of malware activity." "$DEMO_TYPE_CAVEAT"
echo
demo_pause_medium
demo_mitre_table_file "$ttp_file"

demo_spinner "$DEMO_SPINNER_ASSESSMENT" "Rendering analyst-facing assessment"
demo_stage "Analyst view assembled."
demo_pause_short
demo_section "Analyst assessment"
demo_reveal_file "$analysis_file" "$DEMO_TYPE_ANALYSIS" 0.45

demo_pause_short
demo_section "Analyst notes"
demo_reveal_file "$notes_file" "$DEMO_TYPE_ANALYSIS" 0.30

echo
demo_success "Demo complete. Cached artifacts preserved; no network, API, Whisper, or model calls were made."
