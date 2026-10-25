-- EnDirect V1 backend schema for Supabase (PostgreSQL)
-- Run in Supabase SQL Editor only after creating a project.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null check (char_length(username) between 2 and 40),
  created_at timestamptz not null default now()
);
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 3 and 70),
  description text not null check (char_length(description) between 5 and 1000),
  category text not null check (category in ('Téléphones','Maison','Mode','Loisirs','Autre')),
  city text not null check (char_length(city) between 2 and 60),
  price_cents integer not null check (price_cents >= 0),
  contact_url text,
  live_url text,
  status text not null default 'active' check (status in ('active','sold','hidden','removed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists listings_active_created_idx on public.listings(status, created_at desc);
create index if not exists listings_seller_idx on public.listings(seller_id, created_at desc);

create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null references public.listings(id) on delete cascade,
  buyer_id uuid not null references auth.users(id) on delete cascade,
  amount_cents integer not null check (amount_cents >= 0),
  message text check (char_length(coalesce(message,'')) <= 1000),
  status text not null default 'pending' check (status in ('pending','accepted','rejected','withdrawn')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (listing_id, buyer_id, status)
);
create index if not exists offers_listing_idx on public.offers(listing_id, created_at desc);
create index if not exists offers_buyer_idx on public.offers(buyer_id, created_at desc);

create table if not exists public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  listing_id uuid not null references public.listings(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id, listing_id)
);
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references auth.users(id) on delete set null,
  listing_id uuid references public.listings(id) on delete set null,
  reason text not null check (char_length(reason) between 3 and 100),
  details text check (char_length(coalesce(details,'')) <= 2000),
  status text not null default 'new' check (status in ('new','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.listings enable row level security;
alter table public.offers enable row level security;
alter table public.favorites enable row level security;
alter table public.reports enable row level security;

-- Profiles are public only for display names; users can edit their own profile.
drop policy if exists "profiles readable" on public.profiles;
create policy "profiles readable" on public.profiles for select using (true);
drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

-- Public can see active listings; sellers manage only their own listings.
drop policy if exists "active listings public read" on public.listings;
create policy "active listings public read" on public.listings for select using (status = 'active' or auth.uid() = seller_id);
drop policy if exists "seller creates own listing" on public.listings;
create policy "seller creates own listing" on public.listings for insert with check (auth.uid() = seller_id);
drop policy if exists "seller updates own listing" on public.listings;
create policy "seller updates own listing" on public.listings for update using (auth.uid() = seller_id) with check (auth.uid() = seller_id);
drop policy if exists "seller deletes own listing" on public.listings;
create policy "seller deletes own listing" on public.listings for delete using (auth.uid() = seller_id);

-- Offers: buyer can create/read own offers; seller can read and update offers for their listings.
drop policy if exists "buyer reads own offers" on public.offers;
create policy "buyer reads own offers" on public.offers for select using (auth.uid() = buyer_id or exists(select 1 from public.listings l where l.id = listing_id and l.seller_id = auth.uid()));
drop policy if exists "buyer creates own offer" on public.offers;
create policy "buyer creates own offer" on public.offers for insert with check (auth.uid() = buyer_id and exists(select 1 from public.listings l where l.id = listing_id and l.status = 'active' and l.seller_id <> auth.uid()));
drop policy if exists "buyer withdraws own offer" on public.offers;
create policy "buyer withdraws own offer" on public.offers for update using (auth.uid() = buyer_id and status = 'pending') with check (auth.uid() = buyer_id and status = 'withdrawn');
drop policy if exists "seller responds to offers" on public.offers;
create policy "seller responds to offers" on public.offers for update using (exists(select 1 from public.listings l where l.id = listing_id and l.seller_id = auth.uid())) with check (exists(select 1 from public.listings l where l.id = listing_id and l.seller_id = auth.uid()));

drop policy if exists "user manages own favorites" on public.favorites;
create policy "user manages own favorites" on public.favorites for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Reports can be created by a logged-in user; report details are not public.
drop policy if exists "logged in submits report" on public.reports;
create policy "logged in submits report" on public.reports for insert with check (auth.uid() = reporter_id);
drop policy if exists "reporter sees own report" on public.reports;
create policy "reporter sees own report" on public.reports for select using (auth.uid() = reporter_id);

-- Create profile automatically at signup using metadata username if provided.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, username)
  values (new.id, coalesce(nullif(new.raw_user_meta_data ->> 'username',''), 'Utilisateur'))
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Restrict which offer fields authenticated users may change through the public API.
-- The row policies above still determine which offer rows are editable.
revoke update on public.offers from authenticated;
grant update (status, updated_at) on public.offers to authenticated;

-- Explicit API privileges; row-level security remains the primary access control.
grant select on public.profiles to anon, authenticated;
grant select on public.listings to anon, authenticated;
grant insert, update, delete on public.listings to authenticated;
grant select, insert on public.offers to authenticated;
grant select, insert, delete on public.favorites to authenticated;
grant insert, select on public.reports to authenticated;
