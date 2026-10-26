#!/usr/bin/env bash
# Builds the site from one source: src/body.html is the page's content and style.
#   index.html   the live page (full document: lang, meta, social tags, favicon)
#   mockup.html  the same content for the review artifact (no document wrapper)
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
FONTS='<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,700;12..96,800&family=Instrument+Sans:wght@400;500;600;700&family=Spline+Sans+Mono:wght@500;600&display=swap">'
TITLE='Debate Coach: speak like a debater, three minutes a day'
DESC='Your coach listens to every word. Say your point out loud, and the moment you stop, you hear what worked and the one thing to change. Coming to iPhone and Android.'
{
  cat <<EOF
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title>$TITLE</title>
<meta name="description" content="$DESC">
<meta name="theme-color" content="#0e7a70">
<link rel="canonical" href="https://debatecoach.app/">
<link rel="icon" href="favicon.ico" sizes="any">
<link rel="icon" href="favicon.svg" type="image/svg+xml">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<link rel="manifest" href="site.webmanifest">
<meta property="og:type" content="website">
<meta property="og:url" content="https://debatecoach.app/">
<meta property="og:title" content="Debate Coach: speak like a debater, three minutes a day">
<meta property="og:image:alt" content="Debate Coach. Speak like a debater, three minutes a day.">
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
