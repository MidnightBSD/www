## 2025-02-23 - DOM-Based XSS via URL Parameter Parsing in html5gallery

**Vulnerability:** A third-party library (`html5gallery.js`) implemented a custom URL parameter parsing function (`getParams()`) that decoded parameters (`unescape()`) and placed them directly into a configuration object without sanitizing HTML-sensitive characters.
**Learning:** Third-party plugins that parse `window.location.search` manually often bypass modern framework protections (like React or Angular's automatic escaping) and might be missed by automated vulnerability scanners if the sink isn't directly `innerHTML` but rather a complex data flow culminating in DOM injection.
**Prevention:** Audit all manual implementations of URL parameter parsing within the application (especially within bundled or minified libraries). Ensure any value extracted from the URL and destined for the DOM undergoes proper HTML entity encoding immediately upon extraction.

## 2024-10-27 - Insecure script inclusion in old pages
**Vulnerability:** Found a hardcoded `http://` script inclusion for an executable JavaScript file (`show_ads.js`) in an older page (`notes/0.1.1/index.html`).
**Learning:** Older, seemingly static release notes pages might still contain active, third-party scripts loaded over insecure connections, creating a Man-in-the-Middle vulnerability.
**Prevention:** Regularly scan for `src="http:` tags across the entire codebase, including historical or archived pages, not just the active templates.
Learned to check and fix target='_blank' vulnerabilities by adding rel='noopener noreferrer' when linking to external resources. Fixed one such vulnerability in html5gallery.

## 2025-02-23 - DOM-Based XSS via innerHTML stripping in html5gallery
**Vulnerability:** A third-party library (`html5gallery.js`) implemented a custom HTML tag stripping function (`html2Text()`) that temporarily assigned untrusted input directly to `b.innerHTML = a;` in an effort to read back `b.innerText`.
**Learning:** Functions that attempt to "strip" HTML tags by assigning to `innerHTML` are highly dangerous and create an immediate DOM-based XSS execution vector (e.g., `<img src=x onerror=alert(1)>` executes immediately upon assignment to `innerHTML`, before `innerText` is even returned).
**Prevention:** Use `DOMParser().parseFromString(a, 'text/html').body.textContent` to securely extract text without executing scripts, or properly HTML-entity escape the input before assigning to `innerHTML`.
