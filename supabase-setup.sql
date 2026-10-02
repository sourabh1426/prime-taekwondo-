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

-- After creating the Admin user in Authentication, replace the email and run:
-- insert into public.site_admins (user_id)
-- select id from auth.users where email = 'YOUR_ADMIN_EMAIL'
-- on conflict (user_id) do nothing;
