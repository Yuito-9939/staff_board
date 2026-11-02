-- 運営スタッフ担当ボード（staff_board）: Supabase スキーマ
-- Supabase ダッシュボード → SQL Editor に貼り付けて「Run」で実行する
-- 実行後、Project Settings → Data API → Exposed schemas に staff_board を「追加」する（既存の名前は消さない）
--
-- 共有プロジェクトのルールに従い、このシステム専用のスキーマ staff_board に置く。
-- 他スキーマへの外部キーは張らない。ログインなしで使うボードなので anon に読み書きを許可する。

create schema if not exists staff_board;

grant usage on schema staff_board to anon, authenticated, service_role;

create table if not exists staff_board.signups (
  id   text primary key check (char_length(id) <= 120),
  p    text not null check (p ~ '^d[1-3]r[12]-[0-9]{4}$'),
  name text not null check (char_length(name) between 1 and 20),
  t    bigint not null default 0,
  c    text not null default '' check (char_length(c) <= 80)
);

alter table staff_board.signups enable row level security;

grant select, insert, update, delete on table staff_board.signups to anon;
grant all on table staff_board.signups to service_role;

-- 再実行してもエラーにならないよう、同名のポリシーを消してから作り直す（このテーブルのポリシーだけが対象）
drop policy if exists "signups_read"   on staff_board.signups;
drop policy if exists "signups_insert" on staff_board.signups;
drop policy if exists "signups_update" on staff_board.signups;
drop policy if exists "signups_delete" on staff_board.signups;
create policy "signups_read"   on staff_board.signups for select to anon using (true);
create policy "signups_insert" on staff_board.signups for insert to anon with check (true);
create policy "signups_update" on staff_board.signups for update to anon using (true) with check (true);
create policy "signups_delete" on staff_board.signups for delete to anon using (true);

-- 旧テーブル（public.staff_board_signups）からの移行: 回答をコピーしてから旧テーブルを削除する
do $$
begin
  if to_regclass('public.staff_board_signups') is not null then
    insert into staff_board.signups (id, p, name, t, c)
      select id, p, name, t, c from public.staff_board_signups
      on conflict (id) do nothing;
    drop table public.staff_board_signups;
  end if;
end $$;

-- 共有プロジェクトの管理台帳に登録（台帳がある場合のみ。Storage バケットは使わないが列が必須のため同名で予約）
do $$
begin
  if to_regclass('public.systems') is not null then
    insert into public.systems (schema_name, bucket_name, display_name, repo_url, status)
    values ('staff_board', 'staff_board', '会場担当 回答ボード', 'https://github.com/Yuito-9939/staff_board', 'active')
    on conflict (schema_name) do nothing;
  end if;
end $$;

select count(*) as "移行した回答数" from staff_board.signups;
