# Prime Taekwondo — updated setup (Hindi)

Is update mein current homepage editor aur public gallery **bani rahengi**. Admin mein applications/approvals, students, classes, attendance, student progress, activities, family updates, awards, ranks aur reports bhi jud rahe hain. Student/Parent portal ab browser demo ki jagah Supabase account use karta hai.

## 1. Supabase mein updated SQL chalayein

1. Supabase project kholein → **SQL Editor** → **New query**.
2. Is folder ki updated `supabase-setup.sql` file ka poora content paste karke **Run** dabayein.
3. Aap pehle setup SQL chala chuke hain, phir bhi **updated file dobara run karni hogi**. Yeh safe/idempotent hai: existing Admin, homepage content aur gallery records ko delete nahi karegi; naye tables aur access rules add karegi.
4. Agar Admin pehle se sign in kar pa raha tha to Admin banane wali purani query dobara chalane ki zarurat nahi.

## 2. Public login requests on karein

1. Supabase mein **Authentication → Sign In / Providers → Email** kholein aur email sign-up enabled rakhein.
2. **Authentication → URL Configuration** mein Site URL `https://sourabh1426.github.io/prime-taekwondo-/` set karein. Redirect URLs mein bhi yahi address add karein.
3. Agar email confirmation on hai, naya user apna confirmation email kholkar account confirm kare. Confirmation ke baad Admin approval bhi zaroori hai.

## 3. GitHub Pages files update karein

1. Neeche diye ZIP ko download karke right-click → **Extract All** karein.
2. GitHub repository `prime-taekwondo-` kholein → **Add file → Upload files**.
3. Extracted folder ke andar ki files select karke upload karein; GitHub existing files replace karne de. Nayi `academy-admin.html` file bhi upload honi chahiye.
4. Neeche **Commit changes** dabayein. GitHub Pages deployment complete hone ke baad website refresh karein.

## 4. Login request se student portal tak

1. Website ke **Member Portal / Request Access** link par koi bhi visitor jaakar Student ya Parent/Guardian access request bhej sakta hai. Form Supabase login account bhi banata hai.
2. Admin **Admin Portal** mein sign in kare. Naya Academy Dashboard khulega. **Approvals** se request approve ya reject karein.
3. Approve karne par student roster profile banegi. Student email aur parent/guardian email profile se match hone chahiye.
4. Admin **Classes** mein class schedule, **Attendance** mein hazri, **Student Progress** mein skill/score/coach note, aur baki tabs mein activities, updates, awards aur belt promotions record kare.
5. Student/Parent usi email se Member Portal mein sign in kare. Approved aur active profile ke linked records hi dikhte hain. Approval se pehle ya inactive karne ke baad training records nahi dikhte.

## Website aur Gallery abhi bhi kahaan hain?

Academy Dashboard ke left menu mein **Homepage editor** aur **Gallery manager** links hain. Wahi pehle wala homepage text/coach details aur public photos edit karte hain.

## Zaroori baat

- `supabase-config.js` mein keval Project URL aur **publishable key** hoti hai. `service_role` ya secret key website mein kabhi na rakhein.
- Naye user account ka password user khud banata hai. Password SQL mein set/share na karein.
- Request approve karne se login-account signup pehle se ho chuka hota hai; approval unke student/parent records ko unlock karti hai.
- Existing demo `localStorage` data ko naye secure database mein import nahi kiya gaya. Real progress admin dashboard mein dobara enter karni hogi.
- GitHub Pages deployment complete hone mein kuch waqt lag sakta hai. Site URL: `https://sourabh1426.github.io/prime-taekwondo-/`.
