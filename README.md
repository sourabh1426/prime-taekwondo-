# Prime Taekwondo website update

This package adds a visitor-facing photo gallery and an Admin editor for homepage content and gallery photos while keeping the existing Student/Parent portal link and Admin portal route.

## Files

- `index.html` — public academy homepage, contact/coach details, linked member cards, and gallery preview.
- `gallery.html` — public gallery with category filters.
- `admin-login.html` / `admin-dashboard.html` / `site-manager.html` — Supabase-authenticated Admin entry and editor.
- `student-parent-portal.html` — local browser demo portal, not production authentication.
- `supabase-config.js` / `supabase-setup.sql` — public browser configuration and database/storage policies.
- `SETUP-GUIDE-HINDI.md` — setup and upload steps.

## Hosting and data boundary

GitHub Pages hosts the static HTML. Supabase stores public homepage text/gallery records and photo files. Row-level security allows public reads for published content and limits writes to the Admin ID inserted into `site_admins`. Only a Supabase publishable key belongs in the browser. Never put a service-role/secret key in these files.

Student/Parent sample accounts and sample progress remain in that browser's local storage/session storage. The client-side parent-child filter is only a demonstration and can be altered by the browser user. It is not private, cross-device authentication or a production authorization boundary.

See `SETUP-GUIDE-HINDI.md` before deploying.
