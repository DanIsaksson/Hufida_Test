# HUFIDA Partners Database Schema

## Partners Table
```sql
create table partners (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  logo_url text,
  partner_type text not null,
  website text,
  description text,
  location text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  is_active boolean default true,
  featured boolean default false,
  contact_email text,
  contact_phone text,
  social_media jsonb
);

-- Create indexes for common queries
create index idx_partners_partner_type on partners(partner_type);
create index idx_partners_location on partners(location);
create index idx_partners_featured on partners(featured) where featured = true;
create index idx_partners_is_active on partners(is_active) where is_active = true;

-- Add RLS policies
alter table partners enable row level security;

-- Allow public read access to active partners
create policy "Public can view active partners"
  on partners for select
  using (is_active = true);

-- Allow authenticated users to insert partners
create policy "Authenticated users can insert partners"
  on partners for insert
  to authenticated
  with check (true);

-- Allow authenticated users to update their own partners
create policy "Authenticated users can update their own partners"
  on partners for update
  to authenticated
  using (auth.uid() = created_by);
```

## Social Media Type
```sql
create type social_media_type as (
  linkedin text,
  twitter text,
  facebook text,
  instagram text
);
```

## Partnership Types Table
```sql
create table partnership_types (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  description text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create index for name lookups
create index idx_partnership_types_name on partnership_types(name);
```

## Partner Events Table (Optional)
```sql
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

-- Create indexes for common queries
create index idx_partner_events_partner_id on partner_events(partner_id);
create index idx_partner_events_event_date on partner_events(event_date);
```

## Features and Considerations

1. **UUID Primary Keys**: Using UUIDs for better security and distribution
2. **Timestamps**: Automatic tracking of creation and update times
3. **Soft Deletion**: Using is_active flag instead of hard deletes
4. **Rich Content**: Support for social media links and contact information
5. **Indexing**: Optimized for common query patterns
6. **Row Level Security**: Basic policies for public/authenticated access
7. **Relationships**: Optional events table for partner activities
8. **Type Safety**: Custom types for structured data like social media links

## Example Queries

### Get Active Partners with Type
```sql
select p.*, pt.name as partnership_type_name
from partners p
join partnership_types pt on p.partner_type = pt.name
where p.is_active = true
order by p.created_at desc;
```

### Get Featured Partners
```sql
select *
from partners
where is_active = true
  and featured = true
order by created_at desc;
```

### Get Partner Events
```sql
select p.name as partner_name, e.*
from partner_events e
join partners p on e.partner_id = p.id
where e.event_date >= now()
order by e.event_date asc;
```