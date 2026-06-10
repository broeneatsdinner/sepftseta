# SEPftSETA Terminal Demo

This directory contains the sanitized, case-driven terminal demonstration for SEPftSETA.

The demo is designed for repeatable public presentation recording. By default, it uses cached, sanitized transcript artifacts rather than live transcription or external services.

## Run the demo

    ./assets/demo/bin/demo.sh paypal-account-security-voicemail
    ./assets/demo/bin/demo.sh recruiter-voicemail

Fast test mode:

    ./assets/demo/bin/demo.sh paypal-account-security-voicemail --fast --no-color
    ./assets/demo/bin/demo.sh recruiter-voicemail --fast --no-color

## Demo flow

    controlled voicemail artifact
    → cached Whisper-style transcript
    → behavioral indicators
    → MITRE ATT&CK behavioral mapping
    → analyst assessment

Actual MITRE ATT&CK technique IDs are used where applicable. Procedure rows are project-specific controlled-demo procedures, not attribution, proof of compromise, or evidence of malware activity.

## Directory layout

    bin/
      demo.sh
      lib-demo-ui.sh

    cases/
      paypal-account-security-voicemail/
      recruiter-voicemail/

    source-scripts/
      Original sanitized voicemail scripts.

    transcript-artifacts/
      Cached verbose and presentation-formatted transcript artifacts.

## Audio files

Demo audio files are intentionally not committed by default because repository-level ignore rules exclude MP3 files.
The public terminal demo does not require audio files to run. It uses cached transcript artifacts committed under `cases/` and `transcript-artifacts/`.

If audio is needed for local regeneration, place synthetic/controlled demo audio files under:

    assets/demo/audio/

## Safety boundary

This demo does not include private infrastructure details, real phone numbers, credentials, raw private evidence, or live external API calls.
