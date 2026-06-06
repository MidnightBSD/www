## 2025-02-23 - DOM-Based XSS via URL Parameter Parsing in html5gallery

**Vulnerability:** A third-party library (`html5gallery.js`) implemented a custom URL parameter parsing function (`getParams()`) that decoded parameters (`unescape()`) and placed them directly into a configuration object without sanitizing HTML-sensitive characters.
**Learning:** Third-party plugins that parse `window.location.search` manually often bypass modern framework protections (like React or Angular's automatic escaping) and might be missed by automated vulnerability scanners if the sink isn't directly `innerHTML` but rather a complex data flow culminating in DOM injection.
**Prevention:** Audit all manual implementations of URL parameter parsing within the application (especially within bundled or minified libraries). Ensure any value extracted from the URL and destined for the DOM undergoes proper HTML entity encoding immediately upon extraction.
