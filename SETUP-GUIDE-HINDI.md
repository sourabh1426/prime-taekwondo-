# Prime Taekwondo: setup guide (simple Hindi)

Is package mein public homepage, public photo gallery aur Admin ke liye homepage/gallery editor hai. Admin changes sab visitors ke liye Supabase par save honge. Student/Parent portal abhi alag browser-demo hai; uska sample data real ya private student data nahi hai.

## Pehle Supabase project banayein

1. [supabase.com](https://supabase.com/) par account banakar **New project** choose karein. Project ka database password surakshit jagah likh kar rakhein.
2. Project khulne par **Storage → New bucket** kholein. Bucket name `academy-gallery` rakhein, **Public bucket** ON karein, maximum file size `8 MB` aur allowed MIME types `image/jpeg`, `image/png`, `image/webp` set karein. Create par click karein.
3. **SQL Editor → New query** kholein. Is folder ki `supabase-setup.sql` file ka poora text copy karke SQL Editor mein paste karein aur **Run** dabayein.
4. Supabase mein **Authentication → Users → Add user** se apna Admin email/password banayein. Agar email confirmation ka option aaye, demo setup ke liye user ko confirm/verified banayein.
5. `supabase-setup.sql` ke aakhri comments mein diye gaye chhote Admin query ko copy karein. `YOUR_ADMIN_EMAIL` ki jagah wahi email likhein jo step 4 mein use kiya. SQL Editor mein query Run karein. Isse isi account ko website Admin access milega.
6. **Project Settings → API Keys** se Project URL aur **publishable key** copy karein. `service_role` ya secret key ko kabhi website files mein paste/share na karein.
7. `supabase-config.js` file kholein. `https://YOUR_PROJECT_REF.supabase.co` ko apne Project URL se aur `YOUR_SUPABASE_PUBLISHABLE_KEY` ko publishable key se replace karke save karein.

## GitHub par files lagayein

1. ZIP download karke Windows mein right-click → **Extract All** karein.
2. Apne `prime-taekwondo-` GitHub repository ke **main** page par **Add file → Upload files** kholein.
3. Extracted folder ke andar ki **files** select karke upload karein (folder ke andar folder upload na karein). GitHub pooche to existing files replace hone dein. `index.html`, `admin-dashboard.html`, `admin-login.html`, `gallery.html`, `site-manager.html`, `student-parent-portal.html`, `logo.png`, `supabase-config.js`, `supabase-setup.sql` aur README/guide package mein hain.
4. Neeche jaakar **Commit changes** dabayein. Repository mein **Settings → Pages** par source `Deploy from a branch`, branch `main`, folder `/ (root)` hona chahiye.
5. Publish hone ke baad website par Admin card kholein, apne banaye Supabase email/password se sign in karein. Dashboard mein **Homepage updates** se text save karein aur **Public Gallery** se photo upload karein.

## Yaad rakhein

- Supabase publishable key browser file mein dikh sakti hai; database tables aur Storage policies ko writes sirf approved Admin tak rokne ke liye banaya hai. `service_role` key kabhi browser mein na daalein.
- Gallery public hai: upload ki gayi photos koi bhi dekh sakta hai. Sirf publish karne ki permission wale photos upload karein.
- Admin login/backend shared Supabase par hai. Student/Parent page ka sample login abhi `localStorage`/`sessionStorage` based demo hai. Is demo ko real student profile, password ya sensitive data ke liye use na karein; browser-only parent restriction production security nahi hai.
- Iske liye SQL/RLS aur admin verification Supabase par hain. Production use se pehle domain, account lifecycle, backups, privacy notice aur student/parent access ko trusted backend se configure karna chahiye.

## Agar Pages par 404 aaye

GitHub repository → **Settings → Pages** check karein. Source `Deploy from a branch`, branch `main`, folder `/ (root)` select karke Save karein. GitHub Pages ko publish karne mein thoda waqt lag sakta hai. Address project pages ke format mein hai: `https://sourabh1426.github.io/prime-taekwondo-/`.
