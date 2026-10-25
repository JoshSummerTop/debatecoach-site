#!/usr/bin/env bash
# Builds the site from one source: src/body.html is the page's content and style.
#   index.html   the live page (full document: lang, meta, social tags, favicon)
#   mockup.html  the same content for the review artifact (no document wrapper)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
FONTS='<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,700;12..96,800&family=Figtree:wght@400;500;600;700&family=JetBrains+Mono:wght@500;600&display=swap">'
TITLE='Debate Coach: practise debating with a coach who listens'
DESC='Argue out loud against an AI opponent. Your coach chairs the round, keeps the time, and tells you the one thing to change next time. Coming to iPhone and Android.'
{
  cat <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>$TITLE</title>
<meta name="description" content="$DESC">
<meta name="theme-color" content="#2a4bd7">
<link rel="canonical" href="https://debatecoach.app/">
<link rel="icon" href="favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<meta property="og:type" content="website">
<meta property="og:url" content="https://debatecoach.app/">
<meta property="og:title" content="Debate Coach">
<meta property="og:description" content="$DESC">
<meta property="og:image" content="https://debatecoach.app/og.png">
<meta name="twitter:card" content="summary_large_image">
$FONTS
</head>
<body>
EOF
  cat src/body.html
  printf '</body>\n</html>\n'
} > index.html
{
  echo '<title>Debate Coach Landing</title>'
  echo '<meta name="claude:viewport-fit-sides" content="cover">'
  echo "$FONTS"
  cat src/body.html
} > mockup.html
echo "built index.html ($(wc -c < index.html) bytes) and mockup.html"
