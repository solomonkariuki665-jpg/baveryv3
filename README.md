# Bayver

**Your skill finally counts.**

Bayver is a free, fully online mobile eSports platform for Kenyan students. Players compete in eFootball and PUBG Mobile from their phones, build a permanent rank and reputation, and earn Bay Coins that can be spent at real shops and canteens near campus. No venue and no entry fee.

## Status

Early development.

| Area | State |
|---|---|
| App design (16 screens) | Done |
| Welcome screen | Done |
| Phone login with SMS code (Supabase Auth) | Done |
| User profiles in the database | Done |
| Home, matches, league, clans, shop, wallet, chat, clips | Designed, not built yet |

## Features (planned)

- **Player Passport:** a permanent profile with rank, wins, reputation, and badges
- **Find a match:** open challenges, quick match, and match requests
- **Campus League:** weekly leagues with promotion and relegation
- **Clan Wars:** clans fight for territory on a map of Kenya
- **Bay Coins:** earned by playing, spent in the Bay Shop or at partner shops. Never withdrawable, never stakeable
- **Bay Drop:** mystery rewards after wins
- **Clips and chat:** post brags, challenge players from a clip, and message other players
- **Pundit:** free predictions that earn reputation, never money
- **Sponsor dashboard:** partners see their reach and redemptions

## Tech stack

| Layer | Choice |
|---|---|
| Mobile app | Flutter (Dart) |
| Auth and database | Supabase (phone OTP login, PostgreSQL, Row Level Security) |
| Payments to partner shops (planned) | M-Pesa Daraja API |

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- A [Supabase](https://supabase.com) project
- An SMS provider account (Twilio, MessageBird, Vonage, or Textlocal), needed for real phone login

### 1. Install

```bash
git clone <your-repo-url>
cd bayver
flutter pub get
```

### 2. Set up Supabase

1. In your Supabase dashboard, open **Authentication, then Providers, then Phone** and enable it.
2. Add your SMS provider keys. While developing, add a test phone number with a fixed code so you do not pay for SMS.
3. Open the **SQL editor** and run the schema below.
4. Copy your **Project URL** and **anon key** from **Project Settings, then API**.

<details>
<summary>Database schema (SQL)</summary>

```sql
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  phone text,
  campus text,
  gamertag text unique,
  bay_coins integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users read own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Players may edit only these columns. bay_coins can never be changed from the app.
revoke update on public.profiles from authenticated;
grant update (gamertag, campus) on public.profiles to authenticated;

-- Create the profile automatically at sign-up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, phone, campus)
  values (new.id, new.phone, new.raw_user_meta_data->>'campus');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
```

</details>

### 3. Run the app

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

## How login works

1. The player enters a Kenyan phone number (07... or 01...) and picks a campus.
2. The app converts the number to `+254...` and asks Supabase to send a 6-digit SMS code.
3. The player enters the code. Supabase verifies it and starts a session.
4. A database trigger creates the player's profile. The app then shows the Home screen.
5. Existing players use **Sign in**, which sends a code to a number that is already registered.

## Project structure

```
lib/
  main.dart     App, theme, auth gate, Welcome, OTP, and Home screens
supabase/       (add your SQL files here as the database grows)
```

The app currently lives in a single `main.dart`. Split it into folders (`screens/`, `widgets/`, `services/`) once it grows.

## Security notes

- Use only the **anon key** in the app. Never put the `service_role` key in app code or in this repository.
- Row Level Security is on. Players can read and edit only their own profile.
- Bay Coins can only be changed by trusted server-side code, never by the app.
- Do not commit real keys. Pass them with `--dart-define` or a local, git-ignored config.

## Fair play

Bayver cannot see inside third-party games, so results are confirmed by people: both players submit a score and a screenshot, mismatches go to a dispute queue, and false reports lower reputation. Daily coin caps and phone verification limit coin farming.

## Rules that never change

- Entry is always free.
- Bay Coins can never be withdrawn as cash and can never be staked.
- Predictions are free and never involve money.
- Every Bay Coin in circulation must be covered by sponsor money.

## Roadmap

1. Launch tournament at MMU with a local sponsor prize
2. Player Passport, result reporting, and leaderboard
3. Find a match, chat, and the Bay Shop with 2 to 3 partner shops
4. Clans, territory map, Bay Drop, and clips feed
5. Campus vs campus across Nairobi, then Kenya, then East Africa

## Legal

- Legal advice is being sought on how Bay Coins and prize draws are treated under Kenyan law.
- Register with the Office of the Data Protection Commissioner before collecting player data at scale.
- Bayver is an independent community platform. It is not affiliated with Konami (eFootball) or Krafton (PUBG Mobile) and does not use their logos.

## Author

Built by Solomon, Multimedia University of Kenya (MMU), Nairobi.

## Contact

[add email / WhatsApp / Instagram handle here]

## License

[choose a license, or write "All rights reserved" for now]# baveryv3
