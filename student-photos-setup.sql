-- Prime Taekwondo: private student profile photos
-- Run once in Supabase SQL Editor after the main supabase-setup.sql.
-- Photos are private: only Admins and the linked active student/parent can view them.

begin;

alter table public.academy_students
  add column if not exists photo_path text not null default '';

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'academy-student-photos',
  'academy-student-photos',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Admins manage student profile photos" on storage.objects;
create policy "Admins manage student profile photos"
on storage.objects
for all to authenticated
using (
  bucket_id = 'academy-student-photos'
  and public.is_site_admin()
)
with check (
  bucket_id = 'academy-student-photos'
  and public.is_site_admin()
);

drop policy if exists "Linked members can view their student photos" on storage.objects;
create policy "Linked members can view their student photos"
on storage.objects
for select to authenticated
using (
  bucket_id = 'academy-student-photos'
  and exists (
    select 1
    from public.academy_students s
    where s.id::text = (storage.foldername(name))[1]
      and s.status = 'active'
      and lower((select auth.jwt() ->> 'email'))
        in (lower(s.student_email), lower(s.parent_email))
  )
);

commit;
