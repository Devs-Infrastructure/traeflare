#!/usr/bin/env bash

set -euo pipefail

initial_version="${INITIAL_VERSION:-1.0.0}"
bootstrap_sha="${BOOTSTRAP_SHA:-0e23b2fcd1cb0bf677443da1c4022eda5e907148}"
latest_tag=""

while IFS= read -r candidate; do
  if [[ "$candidate" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    latest_tag="$candidate"
    break
  fi
done < <(git tag --list 'v*' --sort=-version:refname)

if [[ -n "$latest_tag" ]]; then
  current_version="${latest_tag#v}"
  commit_range="${latest_tag}..HEAD"
else
  current_version="$initial_version"
  commit_range="${bootstrap_sha}..HEAD"
fi

if ! [[ "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
  echo "Invalid current version: $current_version" >&2
  exit 1
fi

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"

if [[ "$(git rev-list --count "$commit_range")" -eq 0 ]]; then
  echo "No commits found in $commit_range" >&2
  exit 1
fi

messages="$(git log "$commit_range" --format='%B')"

if grep -Eq '^[[:alpha:]][[:alnum:]_-]*(\([^)]*\))?!:' <<<"$messages" || \
   grep -Eq '^BREAKING[ -]CHANGE:' <<<"$messages"; then
  major=$((major + 1))
  minor=0
  patch=0
elif grep -Eq '^feat(\([^)]*\))?:' <<<"$messages"; then
  minor=$((minor + 1))
  patch=0
else
  patch=$((patch + 1))
fi

printf 'v%s.%s.%s\n' "$major" "$minor" "$patch"
