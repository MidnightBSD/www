## 2024-10-27 - Insecure script inclusion in old pages
**Vulnerability:** Found a hardcoded `http://` script inclusion for an executable JavaScript file (`show_ads.js`) in an older page (`notes/0.1.1/index.html`).
**Learning:** Older, seemingly static release notes pages might still contain active, third-party scripts loaded over insecure connections, creating a Man-in-the-Middle vulnerability.
**Prevention:** Regularly scan for `src="http:` tags across the entire codebase, including historical or archived pages, not just the active templates.
