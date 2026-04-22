# Northwestern Lost and Found Board

A Milestone 0 MVP: a **server-rendered Ruby on Rails** app where Northwestern students and staff can post **lost** and **found** items, browse listings, view details, and update or delete posts. The UI uses **Bootstrap 5** (via CDN) plus a small amount of custom CSS with a subtle purple accent.

This project is for a class milestone: **no authentication**, messaging, payments, search, file uploads (only an optional `image_url` text field), or admin dashboards.

## Team members

- Rimen Jenhani
- Shayan Shabani
- Abem Girmai
- Gwendolyn Slaughter
- Nasser Issa

## Requirements

- **Ruby** version aligned with [`.ruby-version`](.ruby-version) (currently **4.0.2**; use the same patch level locally, or adjust the file if your instructor specifies another version).
- **Bundler** (`gem install bundler`).
- **SQLite 3** for local development and test (included on macOS/Linux; Windows users may need additional setup).
- **Node.js is not required** for this MVP (Bootstrap is loaded from a CDN).

## Local setup

```bash
git clone <YOUR_REPO_URL>
cd project-nu-things-1
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Open `http://localhost:3000`. Use the navbar to browse **Lost Items** and **Found Items**, or start a new report from **Report Lost Item** / **Report Found Item**.

## Database

### Run migrations

```bash
bin/rails db:migrate
```

### Seed sample data

Seeds create **10 lost items** and **10 found items** with Northwestern-themed descriptions and locations.

```bash
bin/rails db:seed
```

To reset the development database and reseed:

```bash
bin/rails db:reset
```

## Tests

Automated tests use Railsâ€™ default **Minitest** stack.

```bash
bin/rails db:test:prepare test
```

Short form:

```bash
bin/rails test
```

GitHub Actions runs the same checks on push and pull requests (see [`.github/workflows/ci.yml`](.github/workflows/ci.yml)).

## Deployment (Heroku)

**Production** uses **PostgreSQL** via the `pg` gem and `DATABASE_URL` (see [`config/database.yml`](config/database.yml)). Development and test stay on **SQLite** for simplicity.

### Live app URL

**Placeholder â€” replace after deploy:** `https://shielded-woodland-42404-a6be1ad4a07b.herokuapp.com`

### Deploy checklist

1. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) and log in.
2. `heroku create your-app-name`
3. `heroku addons:create heroku-postgresql:mini` (or another Postgres plan your team chooses).
4. `git push heroku main` (or `master`, depending on your default branch).
5. `heroku run rails db:migrate`
6. Optional: `heroku run rails db:seed` for demo data (only if you want seeded data in production).
7. Set **`RAILS_MASTER_KEY`** on Heroku to the value in `config/master.key` (share securely with teammates; do **not** commit `master.key` to a public repoâ€”this project lists it in `.gitignore`).

Solid Cache, Solid Queue, and Solid Cable are configured to use the **same** Postgres database as the primary app in production so the app does not rely on SQLite files on Herokuâ€™s ephemeral filesystem.

## Communication (team norms)

- **Primary channel:** *TBD â€” e.g. Slack workspace or Discord server (add link when created).*
- **Response times:** Aim to reply to messages within **24 hours** on weekdays; say if you are blocked sooner.
- **Decisions:** Product questions default to **simple majority** among the four members; if there is a tie, rotate a â€œdecider of the week.â€
- **Blockers:** Post in the primary channel with `@channel` or DM two teammates if urgent; escalate to the course staff **before** the deadline if the team cannot resolve an environment or merge issue within 48 hours.

## License / disclaimer

Course project for educational use. Not affiliated with Northwestern University.
