#!/usr/bin/env bash

DEMO_FAST=${DEMO_FAST:-0}
DEMO_NO_COLOR=${DEMO_NO_COLOR:-0}
DEMO_WIDTH=${DEMO_WIDTH:-100}

DEMO_PAUSE_SHORT=${DEMO_PAUSE_SHORT:-1}
DEMO_PAUSE_MEDIUM=${DEMO_PAUSE_MEDIUM:-2}
DEMO_PAUSE_LONG=${DEMO_PAUSE_LONG:-3}

DEMO_SPINNER_AUDIO=${DEMO_SPINNER_AUDIO:-4}
DEMO_SPINNER_TRANSCRIPT=${DEMO_SPINNER_TRANSCRIPT:-6}
DEMO_SPINNER_INDICATORS=${DEMO_SPINNER_INDICATORS:-10}
DEMO_SPINNER_MITRE=${DEMO_SPINNER_MITRE:-8}
DEMO_SPINNER_ASSESSMENT=${DEMO_SPINNER_ASSESSMENT:-10}

DEMO_TYPE_INTRO=${DEMO_TYPE_INTRO:-0.05}
DEMO_TYPE_TRANSCRIPT=${DEMO_TYPE_TRANSCRIPT:-0.035}
DEMO_TYPE_ANALYSIS=${DEMO_TYPE_ANALYSIS:-0.045}
DEMO_TYPE_CAVEAT=${DEMO_TYPE_CAVEAT:-0.035}

demo_ui_init() {
	while [[ $# -gt 0 ]]; do
		case "$1" in
			--fast)
				DEMO_FAST=1
				;;
			--no-color)
				DEMO_NO_COLOR=1
				;;
		esac
		shift
	done

	if [[ "$DEMO_NO_COLOR" == "1" ]] || [[ -z "${TERM:-}" ]] || [[ "${TERM:-}" == "dumb" ]] || ! command -v tput >/dev/null 2>&1; then
		bold=""
		reset=""
		red=""
		green=""
		yellow=""
		blue=""
		purple=""
		cyan=""
		white=""
	else
		bold=$(tput bold)
		reset=$(tput sgr0)
		red=$(tput setaf 1)
		green=$(tput setaf 2)
		yellow=$(tput setaf 3)
		blue=$(tput setaf 4)
		purple=$(tput setaf 5)
		cyan=$(tput setaf 6)
		white=$(tput setaf 7)
	fi

	boldred="${bold}${red}"
	boldgreen="${bold}${green}"
	boldyellow="${bold}${yellow}"
	boldblue="${bold}${blue}"
	boldpurple="${bold}${purple}"
	boldcyan="${bold}${cyan}"
	boldwhite="${bold}${white}"
	header="${bold}${cyan}"
	label="${bold}${white}"
}

demo_sleep() {
	local duration="$1"

	if [[ "$DEMO_FAST" == "1" ]]; then
		sleep 0.05
	else
		sleep "$duration"
	fi
}

demo_pause_short() {
	demo_sleep "$DEMO_PAUSE_SHORT"
}

demo_pause_medium() {
	demo_sleep "$DEMO_PAUSE_MEDIUM"
}

demo_pause_long() {
	demo_sleep "$DEMO_PAUSE_LONG"
}

demo_header() {
	local text="$1"

	printf "\n%s%s%s\n" "$header" "$text" "$reset"
	printf "%s\n\n" "============================================================"
}

demo_section() {
	local text="$1"

	printf "\n%s%s%s\n\n" "$boldcyan" "$text" "$reset"
}

demo_success() {
	printf "%s✓%s %s\n" "$boldgreen" "$reset" "$1"
}

demo_warn() {
	printf "%s!%s %s\n" "$boldyellow" "$reset" "$1"
}

demo_kv() {
	local key="$1"
	local value="$2"

	printf "%s%-18s%s %s\n" "$label" "$key:" "$reset" "$value"
}

demo_wrap() {
	echo -e "$*" | fold -s -w "$DEMO_WIDTH"
}

demo_ease_in_expo() {
	local t=$1

	if command -v bc >/dev/null 2>&1; then
		echo "scale=4; if ($t == 0) 0 else 1 * e(10 * ($t - 1))" | bc -l
	else
		printf "0.01"
	fi
}

demo_type_line() {
	local text="$1"
	local delay="${2:-0.04}"

	if [[ "$DEMO_FAST" == "1" ]]; then
		printf "%s\n" "$text"
		return
	fi

	for ((i = 0; i < ${#text}; i++)); do
		local progress
		progress=$(demo_ease_in_expo "$((i + 1)) / ${#text}")
		sleep "$(echo "$delay * $progress" | bc -l 2>/dev/null || printf "0.01")"
		printf "%s" "${text:$i:1}"
	done
	printf "\n"
}

demo_type_wrap() {
	local text="$1"
	local delay="${2:-0.04}"

	while IFS= read -r line; do
		demo_type_line "$line" "$delay"
	done < <(echo -e "$text" | fold -s -w "$DEMO_WIDTH")
}

demo_type_file() {
	local file="$1"
	local delay="${2:-0.025}"

	while IFS= read -r line || [[ -n "$line" ]]; do
		demo_type_line "$line" "$delay"
	done < "$file"
}

demo_reveal_file() {
	local file="$1"
	local delay="${2:-0.025}"
	local line_pause="${3:-0.2}"

	if [[ "$DEMO_FAST" == "1" ]]; then
		cat "$file"
		return
	fi

	while IFS= read -r line || [[ -n "$line" ]]; do
		demo_type_line "$line" "$delay"
		sleep "$line_pause"
	done < "$file"
}

demo_stage() {
	local text="$1"
	local delay="${2:-$DEMO_TYPE_ANALYSIS}"

	demo_type_line "$text" "$delay"
}

demo_print_file() {
	local file="$1"

	cat "$file"
}

demo_spinner() {
	local duration="$1"
	local message="${2:-Working}"
	local frames=(⣾ ⣽ ⣻ ⢿ ⡿ ⣟ ⣯ ⣷)
	local delay=0.1
	local end_time

	if [[ "$DEMO_FAST" == "1" ]]; then
		printf "%s... " "$message"
		demo_success "complete."
		return
	fi

	end_time=$((SECONDS + duration))
	if [[ "$DEMO_NO_COLOR" != "1" ]] && command -v tput >/dev/null 2>&1 && [[ -n "${TERM:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
		tput civis
	fi

	while (( SECONDS < end_time )); do
		for frame in "${frames[@]}"; do
			printf "\r%s%s%s %s..." "$boldcyan" "$frame" "$reset" "$message"
			sleep "$delay"
			(( SECONDS >= end_time )) && break
		done
	done

	if [[ "$DEMO_NO_COLOR" != "1" ]] && command -v tput >/dev/null 2>&1 && [[ -n "${TERM:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
		tput cnorm
	fi
	printf "\r"
	demo_success "${message} complete.           "
}

demo_table_file() {
	local file="$1"

	if command -v column >/dev/null 2>&1; then
		column -t -s '|' "$file"
	else
		cat "$file"
	fi
}

demo_mitre_table_file() {
	local file="$1"
	local current_block=""
	local block=""
	local level=""
	local id=""
	local name=""
	local description=""
	local rows=""
	local tactic_name=""

	_flush_mitre_rows() {
		[[ -z "$rows" ]] && return
		printf "\n=== %s: %s ===\n\n" "$current_block" "$tactic_name"
		if command -v column >/dev/null 2>&1; then
			printf "%b" "$rows" | column -t -s '|'
		else
			printf "%b" "$rows"
		fi
		rows=""
	}

	while IFS='|' read -r block level id name description || [[ -n "$block" ]]; do
		[[ "$block" == "Block" ]] && continue
		[[ -z "$block" ]] && continue

		if [[ "$block" != "$current_block" ]]; then
			_flush_mitre_rows
			current_block="$block"
			tactic_name="$name"
			rows="Level|ID|Name|Description\n"
			rows+="--------------|----------------------|--------------------------------|--------------------------------------------------------------\n"
		fi

		if [[ "$level" == "Tactic" ]]; then
			tactic_name="$name"
		fi

		rows+="${level}|${id}|${name}|${description}\n"
	done < "$file"

	_flush_mitre_rows
}
