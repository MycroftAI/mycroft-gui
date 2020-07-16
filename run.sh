#!/usr/bin/env bash
set -Ee

# Build
bash dev_setup.sh

# Sync with remote
bash sync_skills.sh

# And run!
mycroft-gui-app
