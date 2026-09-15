#!/bin/bash
printf "lines\tbytes\tscriptlet\texpr\tdirective\tinclude\ttaglib\tel\tscript_tag\tjsfunc\tform\tinput\ttable\tajax\tpath\n"
find sourceCode -name "*.jsp" | while read f; do
  t=$(iconv -f BIG5 -t UTF-8 "$f" 2>/dev/null || cat "$f")
  [ -z "$t" ] && t=$(cat "$f")
  lines=$(printf '%s' "$t" | wc -l | tr -d ' ')
  bytes=$(wc -c < "$f" | tr -d ' ')
  sc=$(printf '%s' "$t" | grep -o '<%[^@=-]' | wc -l | tr -d ' ')
  ex=$(printf '%s' "$t" | grep -o '<%=' | wc -l | tr -d ' ')
  di=$(printf '%s' "$t" | grep -o '<%@' | wc -l | tr -d ' ')
  inc=$(printf '%s' "$t" | grep -oE '(<%@[[:space:]]*include|<jsp:include)' | wc -l | tr -d ' ')
  tl=$(printf '%s' "$t" | grep -oE '<(c|fmt|logic|bean|html|fn|sql|s|form):' | wc -l | tr -d ' ')
  el=$(printf '%s' "$t" | grep -o '\${' | wc -l | tr -d ' ')
  st=$(printf '%s' "$t" | grep -oic '<script' | tr -d ' ')
  jf=$(printf '%s' "$t" | grep -oE 'function[[:space:]]+[A-Za-z_$]' | wc -l | tr -d ' ')
  fm=$(printf '%s' "$t" | grep -oic '<form' | tr -d ' ')
  ip=$(printf '%s' "$t" | grep -oicE '<(input|select|textarea)' | tr -d ' ')
  tb=$(printf '%s' "$t" | grep -oic '<table' | tr -d ' ')
  aj=$(printf '%s' "$t" | grep -oicE '(XMLHttpRequest|\.ajax\(|CSRUtil|doPost|sendRequest)' | tr -d ' ')
  printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" "$lines" "$bytes" "$sc" "$ex" "$di" "$inc" "$tl" "$el" "$st" "$jf" "$fm" "$ip" "$tb" "$aj" "$f"
done
