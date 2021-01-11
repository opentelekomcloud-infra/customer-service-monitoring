#!/usr/bin/env bash
find ./playbooks/ -name "*.yml" -not -path "*/templates/*" -exec ansible-lint --nocolor {} +
