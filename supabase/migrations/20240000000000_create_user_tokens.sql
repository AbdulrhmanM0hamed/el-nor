-- Create user_tokens table
create table if not exists public.user_tokens (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references auth.users(id) not null,
    fcm_token text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    unique(user_id, fcm_token)
);

-- Enable RLS
alter table public.user_tokens enable row level security;

-- Create insert policy
create policy "Users can insert their own tokens"
    on public.user_tokens
    for insert
    with check (auth.uid() = user_id);

-- Create update policy
create policy "Users can update their own tokens"
    on public.user_tokens
    for update
    using (auth.uid() = user_id);

-- Create select policy
create policy "Users can view their own tokens"
    on public.user_tokens
    for select
    using (auth.uid() = user_id);

-- Create delete policy
create policy "Users can delete their own tokens"
    on public.user_tokens
    for delete
    using (auth.uid() = user_id);

-- Grant access to authenticated users
grant usage on schema public to authenticated;
grant all on public.user_tokens to authenticated;

-- Create function to clean up old tokens
create or replace function clean_old_tokens()
returns trigger as $$
begin
    -- Delete tokens older than 30 days
    delete from public.user_tokens
    where updated_at < now() - interval '30 days';
    return new;
end;
$$ language plpgsql;

-- Create trigger to clean up old tokens
create trigger clean_old_tokens_trigger
    after insert on public.user_tokens
    execute function clean_old_tokens(); 