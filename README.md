# Prime Taekwondo website and academy portal

This package keeps the Supabase-backed public homepage editor and photo gallery, and restores the academy management areas: application approvals, student roster, class schedule, attendance, student progress, activity notes, family updates, awards, ranks and reports.

## Main files

- `index.html`, `gallery.html`, `logo.png`, `coach.jpeg` — public website, gallery and coach image.
- `admin-login.html`, `admin-dashboard.html`, `academy-admin.html` — protected Admin access and academy dashboard.
- `site-manager.html` — existing homepage and public gallery editor.
- `student-parent-portal.html` — Supabase sign-in, public access request, and approved member records.
- `supabase-config.js`, `supabase-setup.sql` — browser configuration and database/RLS setup.
- `SETUP-GUIDE-HINDI.md` — SQL, sign-up, upload and approval steps.

## Access and privacy

Public visitors can request a Student or Parent/Guardian account from the Member Portal. Sign-up creates a Supabase Auth account and a pending application. Admin approval creates an active student profile; until then, RLS policies prevent the account from reading student records. Student/Parent record access is linked by the profile's student and parent email fields. Only Admin accounts can edit academy records.

Run the updated `supabase-setup.sql` in the existing project's SQL Editor. It is idempotent and preserves current homepage/gallery data. The static site uses the Supabase publishable key only; never put a service-role/secret key in browser files.
