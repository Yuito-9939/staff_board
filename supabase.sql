-- 運営スタッフ担当ボード用テーブル
-- Supabase ダッシュボード → SQL Editor に貼り付けて「Run」で実行する（1回だけ）
-- 共有プロジェクトの他のテーブルには影響しない

create table if not exists public.staff_board_signups (
  id   text primary key check (char_length(id) <= 120),
  p    text not null check (p ~ '^d[1-3]r[12]-[0-9]{4}$'),
  name text not null check (char_length(name) between 1 and 20),
  t    bigint not null default 0,
  c    text not null default '' check (char_length(c) <= 80)
);

alter table public.staff_board_signups enable row level security;

grant select, insert, update, delete on table public.staff_board_signups to anon;

-- ログインなしで誰でも閲覧・回答できる（ボードの仕様）。対象はこのテーブルだけ
drop policy if exists "staff_board read"   on public.staff_board_signups;
drop policy if exists "staff_board insert" on public.staff_board_signups;
drop policy if exists "staff_board update" on public.staff_board_signups;
drop policy if exists "staff_board delete" on public.staff_board_signups;
create policy "staff_board read"   on public.staff_board_signups for select to anon using (true);
create policy "staff_board insert" on public.staff_board_signups for insert to anon with check (true);
create policy "staff_board update" on public.staff_board_signups for update to anon using (true) with check (true);
create policy "staff_board delete" on public.staff_board_signups for delete to anon using (true);
