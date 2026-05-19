#!/usr/bin/env sh
# auto-bump.sh — bump patch version on every main push that hasn't been bumped.
#
# Short-circuits if HEAD contains [skip bump] or [skip ci], or if the code
# version is already higher than the published version on rubygems.org.
# Otherwise: gem bump --no-commit → commit → tag v<new> → push to Forgejo origin.
#
# Required env:
#   FORGEJO_PUSH_TOKEN   PAT with write scope on this repo (secret: forgejo_push_token)

set -eu

HEAD_MSG=$(git log -1 --pretty=%B)
case "$HEAD_MSG" in
  *"[skip bump]"*|*"[skip ci]"*)
    echo "auto-bump: HEAD commit opts out (found '[skip bump]' or '[skip ci]') — leaving version alone"
    exit 0
    ;;
esac

CURRENT_VERSION=$(ruby -e "load 'lib/rate_limited_jira/version.rb'; puts RateLimitedJira::VERSION")
PUBLISHED_VERSION=$(curl -sf "https://rubygems.org/api/v1/gems/rate-limited-jira-ruby.json" \
  | ruby -rjson -e "puts JSON.parse(\$stdin.read)['version']" 2>/dev/null || echo "0.0.0")

echo "auto-bump: current=${CURRENT_VERSION}  published=${PUBLISHED_VERSION}"

HIGHER=$(ruby -rrubygems -e "
  c = Gem::Version.new(ARGV[0])
  p = Gem::Version.new(ARGV[1])
  puts(c > p ? 'yes' : 'no')
" "$CURRENT_VERSION" "$PUBLISHED_VERSION")

if [ "$HIGHER" = "yes" ]; then
  echo "auto-bump: developer already bumped to ${CURRENT_VERSION} and not yet published — no action"
  exit 0
fi

# Reset any workspace changes from preceding test step so gem-release's
# dirty-tree check does not abort.
git checkout -- .

echo "auto-bump: bumping patch version"
bundle exec gem bump --version patch \
  --file lib/rate_limited_jira/version.rb \
  --no-commit

NEW_VERSION=$(ruby -e "load 'lib/rate_limited_jira/version.rb'; puts RateLimitedJira::VERSION")
echo "auto-bump: bumped to ${NEW_VERSION}"

if [ "${NEW_VERSION}" = "${CURRENT_VERSION}" ]; then
  echo "auto-bump: version did not change — aborting" >&2
  exit 1
fi

REMOTE_URL=$(git remote get-url origin)
AUTH_URL=$(echo "$REMOTE_URL" | sed "s#https://#https://x-access-token:${FORGEJO_PUSH_TOKEN}@#")

GIT_AUTHOR='-c user.email=ci@cbp-org.internal -c user.name=CBP-Org-CI'

# shellcheck disable=SC2086
git $GIT_AUTHOR add lib/rate_limited_jira/version.rb
# shellcheck disable=SC2086
git $GIT_AUTHOR commit -m "chore: auto-bump version to ${NEW_VERSION} [skip ci]"
git tag "v${NEW_VERSION}"
git push "$AUTH_URL" HEAD:main --tags

echo "auto-bump: pushed v${NEW_VERSION} to origin/main"
