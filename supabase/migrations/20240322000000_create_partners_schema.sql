-- Create partnership types table
create table partnership_types (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create partners table
create table partners (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  logo_url text,
  partner_type text not null references partnership_types(name),
  website text,
  description text,
  location text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  is_active boolean default true,
  featured boolean default false,
  contact_email text,
  contact_phone text,
  social_media jsonb,
  created_by uuid references auth.users(id)
);

-- Create partner events table
create table partner_events (
  id uuid default gen_random_uuid() primary key,
  partner_id uuid references partners(id) on delete cascade,
  title text not null,
  description text,
  event_date timestamp with time zone not null,
  location text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create indexes
create index idx_partners_partner_type on partners(partner_type);
create index idx_partners_location on partners(location);
create index idx_partners_featured on partners(featured) where featured = true;
create index idx_partners_is_active on partners(is_active) where is_active = true;
create index idx_partnership_types_name on partnership_types(name);
create index idx_partner_events_partner_id on partner_events(partner_id);
create index idx_partner_events_event_date on partner_events(event_date);

-- Enable RLS
alter table partners enable row level security;
alter table partnership_types enable row level security;
alter table partner_events enable row level security;

-- Create RLS policies
create policy "Public can view active partners"
  on partners for select
  using (is_active = true);

create policy "Authenticated users can insert partners"
  on partners for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update their own partners"
  on partners for update
  to authenticated
  using (auth.uid() = created_by);

create policy "Public can view partnership types"
  on partnership_types for select
  to anon
  using (true);

create policy "Public can view partner events"
  on partner_events for select
  using (exists (
    select 1 from partners
    where partners.id = partner_events.partner_id
    and partners.is_active = true
  ));