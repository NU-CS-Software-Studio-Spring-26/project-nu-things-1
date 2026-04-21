# Northwestern Lost and Found Board — wiki

## Problem we are solving

Northwestern’s large campus makes it easy to misplace everyday items (IDs, keys, bottles, laptops, jackets). Official lost-and-found processes vary by building, and students often do not know where to look first. This MVP gives the community a **single, simple website** to post what they lost or found, with clear contact details—so people can coordinate returns without building a heavy product in the first milestone.

## MVP description (Milestone 0)

- Two models: **LostItem** and **FoundItem** (no associations between them).  
- Full **create, read, update, delete** for each, with server-rendered **ERB** pages.  
- **Bootstrap** tables, buttons, forms, and badges; custom CSS for spacing and a Northwestern-inspired purple accent.  
- **Twenty seeded records** (10 + 10) for realistic demos.  
- **Automated tests** (models + request-style integration tests) and **GitHub Actions** CI.

Out of scope for MVP: logins, messaging, image uploads, search, maps, payments, verification of claims, and admin tooling.

## Design / OO diagram

- **Miro / OO design (placeholder):** `https://miro.com/app/board/REPLACE_ME`

Update this link when the team publishes the Milestone 0 board.

## Future features (not in MVP)

- User accounts and verified `@u.northwestern.edu` emails  
- In-app messaging instead of exposing raw email addresses  
- Photo uploads (Active Storage) and thumbnails  
- Search, filters, and map of “last seen near…”  
- Claim workflow with timestamps and optional staff review  
- Notifications (email or SMS) when a new listing matches a saved search  
- Mobile app or PWA polish beyond the basic manifest stub  

## Similar products / inspiration

- **Facebook / GroupMe “Lost & Found” groups** — community-driven, but noisy and hard to search.  
- **Reddit r/Northwestern** — occasional posts, not structured as listings.  
- **Tile / AirTag ecosystems** — hardware-first; we only solve lightweight **human-reported** listings.  
- **Campus-wide lost-and-found offices** — real-world analog; our app is a **directory-style supplement**, not a replacement.

## Notes for contributors

- **Routes:** [`config/routes.rb`](config/routes.rb) — `root`, `resources :lost_items`, `resources :found_items`.  
- **Controllers:** [`app/controllers/lost_items_controller.rb`](app/controllers/lost_items_controller.rb), [`app/controllers/found_items_controller.rb`](app/controllers/found_items_controller.rb), [`app/controllers/home_controller.rb`](app/controllers/home_controller.rb).  
- **Layouts & shared UI:** [`app/views/layouts/application.html.erb`](app/views/layouts/application.html.erb) (Bootstrap CDN + navbar), [`app/assets/stylesheets/application.css`](app/assets/stylesheets/application.css).  
- **Adding a field:** create a migration, update the model validations, whitelist the attribute in the controller’s `*_params` method, then update `_form`, `show`, and index table columns as needed.  
- **Status values:** `LostItem` uses `open` / `resolved`; `FoundItem` uses `unclaimed` / `claimed` (enforced in models and DB defaults).
