-- =============================================================
-- CORATA — Schema inicial
-- Ejecutar en: Supabase Dashboard → SQL Editor
-- =============================================================

-- -------------------------------------------------------------
-- PROFILES
-- Extiende auth.users (que Supabase crea automáticamente).
-- Una fila por usuarix, creada vía trigger al registrarse.
-- -------------------------------------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  bio          text,
  avatar_url   text,
  role         text not null default 'candidate'
                 check (role in ('candidate', 'company', 'admin')),
  is_public    boolean not null default true,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- Trigger: crear perfil automáticamente cuando alguien se registra
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1))
  );
  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Trigger: actualizar updated_at automáticamente
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace trigger profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();


-- -------------------------------------------------------------
-- SKILLS (catálogo de habilidades — gestionado por admins)
-- -------------------------------------------------------------
create table if not exists public.skills (
  id         uuid primary key default gen_random_uuid(),
  slug       text unique not null,   -- ej: 'adaptacion-al-cambio'
  label      text not null,          -- ej: 'Adaptación al cambio'
  category   text not null,          -- ej: 'ejecucion', 'decision', 'estructura'
  created_at timestamptz not null default now()
);

-- Skills de seed (los que ya aparecen en la landing)
insert into public.skills (slug, label, category) values
  ('adaptacion-al-cambio',      'Adaptación al cambio',      'ejecucion'),
  ('razonamiento-estructural',  'Razonamiento estructural',  'estructura'),
  ('toma-de-decisiones',        'Toma de decisiones',        'decision'),
  ('autonomia',                 'Autonomía',                 'ejecucion'),
  ('gestion-bajo-presion',      'Gestión bajo presión',      'ejecucion'),
  ('fidelidad-a-instrucciones', 'Fidelidad a instrucciones', 'ejecucion')
on conflict (slug) do nothing;


-- -------------------------------------------------------------
-- PROFILE_SKILLS (habilidades verificadas de cada candidatx)
-- -------------------------------------------------------------
create table if not exists public.profile_skills (
  profile_id  uuid not null references public.profiles(id) on delete cascade,
  skill_id    uuid not null references public.skills(id) on delete cascade,
  score       integer check (score between 0 and 100),
  level       text check (level in ('beginner', 'mid', 'senior')),
  verified    boolean not null default false,
  updated_at  timestamptz not null default now(),
  primary key (profile_id, skill_id)
);

create or replace trigger profile_skills_updated_at
  before update on public.profile_skills
  for each row execute procedure public.set_updated_at();


-- -------------------------------------------------------------
-- CHALLENGES (retos — gestionado por admins)
-- -------------------------------------------------------------
create table if not exists public.challenges (
  id          uuid primary key default gen_random_uuid(),
  skill_id    uuid references public.skills(id) on delete set null,
  title       text not null,
  description text,
  difficulty  text not null check (difficulty in ('easy', 'medium', 'hard')),
  is_active   boolean not null default true,
  created_at  timestamptz not null default now()
);


-- -------------------------------------------------------------
-- CHALLENGE_ATTEMPTS (intentos de retos por usuarix)
-- -------------------------------------------------------------
create table if not exists public.challenge_attempts (
  id           uuid primary key default gen_random_uuid(),
  profile_id   uuid not null references public.profiles(id) on delete cascade,
  challenge_id uuid not null references public.challenges(id),
  status       text not null default 'pending'
                 check (status in ('pending', 'submitted', 'passed', 'failed')),
  score        integer check (score between 0 and 100),
  response     jsonb,          -- respuesta flexible según el tipo de reto
  time_ms      integer,        -- tiempo empleado en milisegundos
  submitted_at timestamptz,
  evaluated_at timestamptz,
  created_at   timestamptz not null default now()
);


-- =============================================================
-- ROW LEVEL SECURITY
-- Por defecto: nadie puede leer ni escribir nada.
-- Las políticas definen exactamente qué puede ver cada quien.
-- =============================================================

alter table public.profiles          enable row level security;
alter table public.profile_skills    enable row level security;
alter table public.challenges        enable row level security;
alter table public.challenge_attempts enable row level security;
-- skills es catálogo público, no necesita RLS restrictivo

-- Profiles: cualquiera puede ver los perfiles públicos
create policy "Ver perfiles públicos"
  on public.profiles for select
  using (is_public = true);

-- Profiles: cada usuarix puede ver y editar el suyo propio
create policy "Ver propio perfil (privado)"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Editar propio perfil"
  on public.profiles for update
  using (auth.uid() = id);

-- Profile skills: visibles si el perfil es público
create policy "Ver habilidades de perfiles públicos"
  on public.profile_skills for select
  using (
    exists (
      select 1 from public.profiles p
      where p.id = profile_id and p.is_public = true
    )
  );

create policy "Ver propias habilidades"
  on public.profile_skills for select
  using (auth.uid() = profile_id);

create policy "Gestionar propias habilidades"
  on public.profile_skills for all
  using (auth.uid() = profile_id);

-- Challenges: lectura pública para retos activos
create policy "Ver retos activos"
  on public.challenges for select
  using (is_active = true);

-- Attempts: solo el/la propix usuarix
create policy "Ver propios intentos"
  on public.challenge_attempts for select
  using (auth.uid() = profile_id);

create policy "Crear intentos propios"
  on public.challenge_attempts for insert
  with check (auth.uid() = profile_id);

create policy "Actualizar intentos propios"
  on public.challenge_attempts for update
  using (auth.uid() = profile_id);
