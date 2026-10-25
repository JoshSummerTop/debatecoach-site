#!/usr/bin/env bash
# Waits for GitHub Pages to issue the debatecoach.app certificate, then enforces HTTPS.
# Re-adds the custom domain once an hour in case the issuer stalled.
T=$(timeout 8 bash -c 'printf "protocol=https\nhost=github.com\n\n" | GIT_TERMINAL_PROMPT=0 git credential fill' 2>/dev/null | sed -n 's/^password=//p')
API=https://api.github.com/repos/JoshSummerTop/debatecoach-site/pages
H=(-H "Authorization: Bearer $T" -H "Accept: application/vnd.github+json")
for i in $(seq 1 240); do
  st=$(curl -s -m 15 "${H[@]}" $API | python3 -c "import sys,json; d=json.load(sys.stdin); c=d.get('https_certificate') or {}; print(c.get('state','none'))")
  echo "$(date +%T) cert: $st"
  if [ "$st" = "approved" ]; then
    curl -s -m 20 -X PUT "${H[@]}" $API -d '{"https_enforced":true}' -o /dev/null -w "https enforced %{http_code}\n"
    sleep 30
    curl -s -m 15 -o /dev/null -w "https://debatecoach.app %{http_code}\n" https://debatecoach.app/
    exit 0
  fi
  if [ $((i % 60)) -eq 0 ]; then
    curl -s -m 20 -X PUT "${H[@]}" $API -d '{"cname":"debatecoach.app","source":{"branch":"main","path":"/"}}' -o /dev/null -w "domain re-saved %{http_code}\n"
  fi
  sleep 60
done
echo "no certificate after 4 hours"
