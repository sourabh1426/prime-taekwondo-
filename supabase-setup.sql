-- Prime Taekwondo homepage and public gallery setup.
-- Create the public Storage bucket academy-gallery in the Supabase Dashboard first.

create extension if not exists pgcrypto;

create table if not exists public.site_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.site_admins enable row level security;
revoke all on table public.site_admins from anon, authenticated;

create or replace function public.is_site_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as 'select exists (select 1 from public.site_admins where user_id = (select auth.uid()))';
revoke all on function public.is_site_admin() from public, anon, authenticated;
grant execute on function public.is_site_admin() to authenticated;

create table if not exists public.site_content (
  id smallint primary key check (id = 1),
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.site_content enable row level security;
revoke all on table public.site_content from anon, authenticated;
grant select on table public.site_content to anon, authenticated;
grant insert, update, delete on table public.site_content to authenticated;

insert into public.site_content (id, content)
values (1, '{"heroTitle":"Train hard.\nThink strong.\nBecome better.","heroDescription":"Build fitness, discipline and confidence through focused Taekwondo training. Find the right program, strengthen your skills and take the next step in your journey.","coachName":"Siddhesh Godse","coachTitle":"Taekwondo Coach · National Referee · Maharashtra Coach · 1st Dan Black Belt","coachBio":"Coach Siddhesh brings four years of coaching experience, including training at Sansari and Vadner. He prepares students for school, district, state and national competitions while building fitness, discipline, confidence and sportsmanship. His students have earned state and national-level medals.","contactPhone":"9325586546","address":"Hanuman Mandir, Sansari Gaon, Sansari, Deolali Camp, Nashik, Maharashtra 422401"}'::jsonb)
on conflict (id) do nothing;

drop policy if exists "Public can read homepage content" on public.site_content;
create policy "Public can read homepage content" on public.site_content
for select to anon, authenticated using (true);
drop policy if exists "Admins can manage homepage content" on public.site_content;
create policy "Admins can manage homepage content" on public.site_content
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create table if not exists public.gallery_photos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  caption text not null default '',
  category text not null default 'Training' check (category in ('Training', 'Events', 'Awards', 'Classes')),
  image_path text not null unique,
  is_published boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
alter table public.gallery_photos enable row level security;
revoke all on table public.gallery_photos from anon, authenticated;
grant select on table public.gallery_photos to anon, authenticated;
grant insert, update, delete on table public.gallery_photos to authenticated;

drop policy if exists "Public can view published gallery photos" on public.gallery_photos;
create policy "Public can view published gallery photos" on public.gallery_photos
for select to anon, authenticated using (is_published = true);
drop policy if exists "Admins can manage gallery photos" on public.gallery_photos;
create policy "Admins can manage gallery photos" on public.gallery_photos
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

-- These policies assume a public bucket named academy-gallery already exists.
drop policy if exists "Admins can list gallery uploads" on storage.objects;
create policy "Admins can list gallery uploads" on storage.objects
for select to authenticated using (bucket_id = 'academy-gallery' and public.is_site_admin());
drop policy if exists "Admins can upload gallery photos" on storage.objects;
create policy "Admins can upload gallery photos" on storage.objects
for insert to authenticated with check (bucket_id = 'academy-gallery' and public.is_site_admin());
drop policy if exists "Admins can update gallery photos" on storage.objects;
create policy "Admins can update gallery photos" on storage.objects
for update to authenticated using (bucket_id = 'academy-gallery' and public.is_site_admin())
with check (bucket_id = 'academy-gallery' and public.is_site_admin());
drop policy if exists "Admins can delete gallery photos" on storage.objects;
create policy "Admins can delete gallery photos" on storage.objects
for delete to authenticated using (bucket_id = 'academy-gallery' and public.is_site_admin());

-- Academy management: student records, class progress, and approvals.
-- Safe to re-run; existing homepage/gallery records are preserved.
create table if not exists public.student_applications (
  id uuid primary key default gen_random_uuid(),
  applicant_name text not null check (length(btrim(applicant_name)) between 2 and 120),
  applicant_email text not null check (length(btrim(applicant_email)) <= 254),
  applicant_type text not null check (applicant_type in ('student', 'parent')),
  student_name text not null check (length(btrim(student_name)) between 2 and 120),
  student_email text not null check (length(btrim(student_email)) <= 254),
  parent_name text not null default '',
  parent_email text not null default '',
  phone text not null default '',
  message text not null default '',
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references auth.users(id) on delete set null
);
alter table public.student_applications enable row level security;
revoke all on table public.student_applications from anon, authenticated;
grant insert on table public.student_applications to anon, authenticated;
grant select, update, delete on table public.student_applications to authenticated;
drop policy if exists "Anyone can submit pending applications" on public.student_applications;
create policy "Anyone can submit pending applications" on public.student_applications
for insert to anon, authenticated with check (status = 'pending');
drop policy if exists "Admins can review applications" on public.student_applications;
create policy "Admins can review applications" on public.student_applications
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
drop policy if exists "Applicants can view their own application status" on public.student_applications;
create policy "Applicants can view their own application status" on public.student_applications
for select to authenticated using (lower(applicant_email) = lower((select auth.jwt() ->> 'email')));

create table if not exists public.academy_students (
  id uuid primary key default gen_random_uuid(),
  full_name text not null check (length(btrim(full_name)) between 2 and 120),
  student_email text not null default '',
  parent_email text not null default '',
  current_rank text not null default 'White Belt',
  status text not null default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);
alter table public.academy_students enable row level security;
revoke all on table public.academy_students from anon, authenticated;
grant select, insert, update, delete on table public.academy_students to authenticated;

create or replace function public.can_view_academy_student(p_student_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select public.is_site_admin() or exists (
    select 1 from public.academy_students s
    where s.id = p_student_id and s.status = 'active'
      and lower((select auth.jwt() ->> 'email')) in (lower(s.student_email), lower(s.parent_email))
  )
$$;
revoke all on function public.can_view_academy_student(uuid) from public, anon, authenticated;
grant execute on function public.can_view_academy_student(uuid) to authenticated;
create or replace function public.can_access_member_portal()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.academy_students s
    where s.status = 'active'
      and lower((select auth.jwt() ->> 'email')) in (lower(s.student_email), lower(s.parent_email))
  )
$$;
revoke all on function public.can_access_member_portal() from public, anon, authenticated;
grant execute on function public.can_access_member_portal() to authenticated;
drop policy if exists "Linked members can read student profiles" on public.academy_students;
create policy "Linked members can read student profiles" on public.academy_students
for select to authenticated using (
  public.is_site_admin() or (status = 'active' and lower((select auth.jwt() ->> 'email')) in (lower(student_email), lower(parent_email)))
);
drop policy if exists "Admins can manage student profiles" on public.academy_students;
create policy "Admins can manage student profiles" on public.academy_students
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create table if not exists public.academy_classes (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(btrim(title)) between 2 and 120),
  class_date date not null,
  start_time time not null default '17:30',
  location text not null default 'Main Dojang',
  details text not null default '',
  is_published boolean not null default true,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);
alter table public.academy_classes enable row level security;
revoke all on table public.academy_classes from anon, authenticated;
grant select, insert, update, delete on table public.academy_classes to authenticated;
drop policy if exists "Members can read published classes" on public.academy_classes;
create policy "Members can read published classes" on public.academy_classes
for select to authenticated using ((is_published and public.can_access_member_portal()) or public.is_site_admin());
drop policy if exists "Admins can manage classes" on public.academy_classes;
create policy "Admins can manage classes" on public.academy_classes
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create table if not exists public.academy_attendance (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academy_students(id) on delete cascade,
  class_id uuid not null references public.academy_classes(id) on delete cascade,
  status text not null check (status in ('present', 'absent', 'late', 'excused')),
  note text not null default '', recorded_at timestamptz not null default now(),
  recorded_by uuid references auth.users(id) on delete set null,
  unique (student_id, class_id)
);
alter table public.academy_attendance enable row level security;
revoke all on table public.academy_attendance from anon, authenticated;
grant select, insert, update, delete on table public.academy_attendance to authenticated;

create table if not exists public.academy_progress (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academy_students(id) on delete cascade,
  progress_date date not null default current_date,
  skill text not null check (length(btrim(skill)) between 2 and 120),
  score smallint check (score between 0 and 100),
  rank text not null default '', note text not null default '', next_goal text not null default '',
  recorded_at timestamptz not null default now(),
  recorded_by uuid references auth.users(id) on delete set null
);
alter table public.academy_progress enable row level security;
revoke all on table public.academy_progress from anon, authenticated;
grant select, insert, update, delete on table public.academy_progress to authenticated;

create table if not exists public.academy_activities (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academy_students(id) on delete cascade,
  title text not null check (length(btrim(title)) between 2 and 120),
  activity_date date not null default current_date,
  score smallint check (score between 0 and 100), details text not null default '',
  recorded_at timestamptz not null default now(),
  recorded_by uuid references auth.users(id) on delete set null
);
alter table public.academy_activities enable row level security;
revoke all on table public.academy_activities from anon, authenticated;
grant select, insert, update, delete on table public.academy_activities to authenticated;

create table if not exists public.academy_updates (
  id uuid primary key default gen_random_uuid(),
  student_id uuid references public.academy_students(id) on delete cascade,
  title text not null check (length(btrim(title)) between 2 and 120),
  message text not null check (length(btrim(message)) between 2 and 2000),
  update_date date not null default current_date, is_published boolean not null default true,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);
alter table public.academy_updates enable row level security;
revoke all on table public.academy_updates from anon, authenticated;
grant select, insert, update, delete on table public.academy_updates to authenticated;

create table if not exists public.academy_awards (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academy_students(id) on delete cascade,
  title text not null check (length(btrim(title)) between 2 and 120),
  description text not null default '', award_date date not null default current_date,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);
alter table public.academy_awards enable row level security;
revoke all on table public.academy_awards from anon, authenticated;
grant select, insert, update, delete on table public.academy_awards to authenticated;

create table if not exists public.academy_rank_history (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.academy_students(id) on delete cascade,
  rank text not null check (length(btrim(rank)) between 2 and 80),
  promotion_date date not null default current_date, note text not null default '',
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);
alter table public.academy_rank_history enable row level security;
revoke all on table public.academy_rank_history from anon, authenticated;
grant select, insert, update, delete on table public.academy_rank_history to authenticated;

-- Read-only policies for members are separate from Admin write policies.
drop policy if exists "Admins manage attendance and members read linked records" on public.academy_attendance;
drop policy if exists "Members can read linked attendance" on public.academy_attendance;
create policy "Members can read linked attendance" on public.academy_attendance
for select to authenticated using (public.is_site_admin() or public.can_view_academy_student(student_id));
drop policy if exists "Admins can manage attendance" on public.academy_attendance;
create policy "Admins can manage attendance" on public.academy_attendance
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
drop policy if exists "Admins manage progress and members read linked records" on public.academy_progress;
drop policy if exists "Members can read linked progress" on public.academy_progress;
create policy "Members can read linked progress" on public.academy_progress
for select to authenticated using (public.is_site_admin() or public.can_view_academy_student(student_id));
drop policy if exists "Admins can manage progress" on public.academy_progress;
create policy "Admins can manage progress" on public.academy_progress
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
drop policy if exists "Admins manage activities and members read linked records" on public.academy_activities;
drop policy if exists "Members can read linked activities" on public.academy_activities;
create policy "Members can read linked activities" on public.academy_activities
for select to authenticated using (public.is_site_admin() or public.can_view_academy_student(student_id));
drop policy if exists "Admins can manage activities" on public.academy_activities;
create policy "Admins can manage activities" on public.academy_activities
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
drop policy if exists "Admins manage updates and members read linked records" on public.academy_updates;
drop policy if exists "Members can read linked updates" on public.academy_updates;
create policy "Members can read linked updates" on public.academy_updates
for select to authenticated using (
  public.is_site_admin() or (student_id is null and is_published and public.can_access_member_portal())
  or (student_id is not null and public.can_view_academy_student(student_id))
);
drop policy if exists "Admins can manage updates" on public.academy_updates;
create policy "Admins can manage updates" on public.academy_updates
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
drop policy if exists "Admins manage awards and members read linked records" on public.academy_awards;
drop policy if exists "Members can read linked awards" on public.academy_awards;
create policy "Members can read linked awards" on public.academy_awards
for select to authenticated using (public.is_site_admin() or public.can_view_academy_student(student_id));
drop policy if exists "Admins can manage awards" on public.academy_awards;
create policy "Admins can manage awards" on public.academy_awards
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());
drop policy if exists "Admins manage ranks and members read linked records" on public.academy_rank_history;
drop policy if exists "Members can read linked ranks" on public.academy_rank_history;
create policy "Members can read linked ranks" on public.academy_rank_history
for select to authenticated using (public.is_site_admin() or public.can_view_academy_student(student_id));
drop policy if exists "Admins can manage ranks" on public.academy_rank_history;
create policy "Admins can manage ranks" on public.academy_rank_history
for all to authenticated using (public.is_site_admin()) with check (public.is_site_admin());

create index if not exists student_applications_status_date_idx on public.student_applications (status, submitted_at desc);
create index if not exists academy_students_student_email_idx on public.academy_students (lower(student_email));
create index if not exists academy_students_parent_email_idx on public.academy_students (lower(parent_email));
create index if not exists academy_attendance_student_date_idx on public.academy_attendance (student_id, recorded_at desc);
create index if not exists academy_progress_student_date_idx on public.academy_progress (student_id, progress_date desc);
create index if not exists academy_activities_student_date_idx on public.academy_activities (student_id, activity_date desc);
create index if not exists academy_updates_student_date_idx on public.academy_updates (student_id, update_date desc);

-- After creating the Admin user in Authentication, replace the email and run:
-- insert into public.site_admins (user_id)
-- select id from auth.users where email = 'YOUR_ADMIN_EMAIL'
-- on conflict (user_id) do nothing;
