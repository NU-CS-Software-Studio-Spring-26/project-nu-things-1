# Northwestern-themed sample data for development and demos.
# Run: bin/rails db:seed

# SQLite (and Postgres) enforce FKs: remove rows that reference users before users.
# Skip tables that are not migrated yet (e.g. older Heroku DBs).
conn = ApplicationRecord.connection
%w[claims login_tokens].each do |table|
  next unless conn.table_exists?(table)
  conn.execute("DELETE FROM #{conn.quote_table_name(table)}")
end

LostItem.destroy_all
FoundItem.destroy_all
User.destroy_all

lost_seed = [
  {
    title: "Purple Northwestern lanyard with student ID",
    description: "Wildcat card in a clear plastic holder on a purple lanyard. Name starts with A.",
    category: "IDs & cards",
    location_lost: "Norris University Center — ground floor seating",
    date_lost: Date.new(2026, 4, 18),
    contact_name: "Jordan Lee",
    contact_email: "jordan.lee@u.northwestern.edu",
    status: "open",
    image_url: "https://picsum.photos/seed/nu-lost-id/600/400",
    reward: "Coffee at Norris",
    color: "Purple",
    brand: "Northwestern"
  },
  {
    title: "Key ring with three keys and small Wildcat charm",
    description: "Silver ring with two brass keys and one silver key; small purple charm.",
    category: "Keys",
    location_lost: "Technological Institute — south lobby benches",
    date_lost: Date.new(2026, 4, 17),
    contact_name: "Sam Rivera",
    contact_email: "sam.rivera@u.northwestern.edu",
    status: "open",
    color: "Silver",
    brand: nil
  },
  {
    title: "32oz insulated water bottle (stickers)",
    description: "White bottle covered in STEM club stickers; dent near base.",
    category: "Drinkware",
    location_lost: "Main Library — 3rd floor study carrels",
    date_lost: Date.new(2026, 4, 16),
    contact_name: "Priya Shah",
    contact_email: "priya.shah@u.northwestern.edu",
    status: "resolved",
    image_url: "https://picsum.photos/seed/nu-lost-bottle/600/400",
    reward: nil,
    color: "White",
    brand: "Hydro Flask"
  },
  {
    title: "Black commuter backpack",
    description: "Slim black backpack with laptop sleeve; zipper pull on front pocket is broken.",
    category: "Bags",
    location_lost: "University Library — ground floor cafe line",
    date_lost: Date.new(2026, 4, 15),
    contact_name: "Alex Kim",
    contact_email: "alex.kim@u.northwestern.edu",
    status: "open",
    color: "Black",
    brand: "The North Face"
  },
  {
    title: "AirPods Pro charging case only",
    description: "White case with tiny scratch on hinge; no earbuds inside case.",
    category: "Electronics",
    location_lost: "Deering Library — reading room entrance",
    date_lost: Date.new(2026, 4, 14),
    contact_name: "Taylor Brooks",
    contact_email: "taylor.brooks@u.northwestern.edu",
    status: "open",
    reward: "$20",
    color: "White",
    brand: "Apple"
  },
  {
    title: "Green puffer jacket (size M)",
    description: "Olive green jacket left on hook; Northwestern patch on sleeve.",
    category: "Clothing",
    location_lost: "Foster-Walker (Plex) — dining hall coat rack",
    date_lost: Date.new(2026, 4, 12),
    contact_name: "Morgan Ellis",
    contact_email: "morgan.ellis@u.northwestern.edu",
    status: "open",
    color: "Olive",
    brand: "Patagonia"
  },
  {
    title: "Five-subject spiral notebook (Chem notes)",
    description: "Blue cover, first page says CHEM 151 — lots of pencil marginalia.",
    category: "School supplies",
    location_lost: "Tech LG51 lecture hall — left side seats",
    date_lost: Date.new(2026, 4, 11),
    contact_name: "Riley Chen",
    contact_email: "riley.chen@u.northwestern.edu",
    status: "resolved",
    color: "Blue",
    brand: "Five Star"
  },
  {
    title: "USB-C laptop charger (65W)",
    description: "Compact brick with long USB-C cable wrapped with blue velcro strap.",
    category: "Electronics",
    location_lost: "Norris — second floor study nook outlets",
    date_lost: Date.new(2026, 4, 10),
    contact_name: "Casey Nguyen",
    contact_email: "casey.nguyen@u.northwestern.edu",
    status: "open",
    color: "Black",
    brand: "Anker"
  },
  {
    title: "TI-84 Plus calculator",
    description: "Gray calculator with initials etched on back cover.",
    category: "Electronics",
    location_lost: "Tech bridge hallway — window ledge",
    date_lost: Date.new(2026, 4, 9),
    contact_name: "Jamie Ortiz",
    contact_email: "jamie.ortiz@u.northwestern.edu",
    status: "open",
    color: "Gray",
    brand: "Texas Instruments"
  },
  {
    title: "Brown leather wallet",
    description: "Slim bifold; contains Wildcat Cash card (will cancel) but no cash.",
    category: "Wallets",
    location_lost: "Campus shuttle stop — Sheridan & Church",
    date_lost: Date.new(2026, 4, 8),
    contact_name: "Drew Patel",
    contact_email: "drew.patel@u.northwestern.edu",
    status: "open",
    image_url: "https://picsum.photos/seed/nu-lost-wallet/600/400",
    color: "Brown",
    brand: nil
  },
  {
    title: "Beats Studio Buds case (empty)",
    description: "Black oval charging case only; no earbuds. Small crack on hinge.",
    category: "Electronics",
    location_lost: "SPAC — women's locker room bench",
    date_lost: Date.new(2026, 4, 22),
    contact_name: "Nina Okonkwo",
    contact_email: "nina.okonkwo@u.northwestern.edu",
    status: "open",
    reward: "$15",
    color: "Black",
    brand: "Beats"
  },
  {
    title: "Medill lanyard + press pass holder",
    description: "Black retractable badge reel with Medill sticker; no ID inside.",
    category: "IDs & cards",
    location_lost: "Fisk Hall — basement print lab",
    date_lost: Date.new(2026, 4, 21),
    contact_name: "Chris Alvarez",
    contact_email: "chris.alvarez@u.northwestern.edu",
    status: "open",
    color: "Black",
    brand: nil
  },
  {
    title: "Graphing calculator (TI-84 CE)",
    description: "Color screen model; name on masking tape on battery door.",
    category: "Electronics",
    location_lost: "Tech M152 — back row under seat",
    date_lost: Date.new(2026, 4, 20),
    contact_name: "Hannah Park",
    contact_email: "hannah.park@u.northwestern.edu",
    status: "open",
    color: "Black",
    brand: "Texas Instruments"
  },
  {
    title: "Northwestern quarter-zip (purple, size L)",
    description: "NU bookstore quarter-zip; left on bleachers after intramural game.",
    category: "Clothing",
    location_lost: "Henry Crown Sports Pavilion — court 2 bleachers",
    date_lost: Date.new(2026, 4, 19),
    contact_name: "Ethan Morales",
    contact_email: "ethan.morales@u.northwestern.edu",
    status: "open",
    image_url: "https://picsum.photos/seed/nu-lost-zip/600/400",
    color: "Purple",
    brand: "Nike"
  },
  {
    title: "Violin bow (carbon fiber)",
    description: "Slim black carbon bow in soft case; forgot after orchestra rehearsal.",
    category: "Other",
    location_lost: "Pick-Staiger Concert Hall — practice room hallway",
    date_lost: Date.new(2026, 4, 7),
    contact_name: "Sophie Lin",
    contact_email: "sophie.lin@u.northwestern.edu",
    status: "open",
    reward: "Dinner at Fran's",
    color: "Black",
    brand: "CodaBow"
  },
  {
    title: "Surface Pen (Microsoft)",
    description: "Slim silver pen; tip slightly worn; pairs with Surface Pro.",
    category: "Electronics",
    location_lost: "Annenberg Hall — seminar table by windows",
    date_lost: Date.new(2026, 4, 6),
    contact_name: "Imani Washington",
    contact_email: "imani.washington@u.northwestern.edu",
    status: "resolved",
    color: "Silver",
    brand: "Microsoft"
  },
  {
    title: "Red North Face beanie",
    description: "Knit beanie with small pom; name tag sewn inside (faded).",
    category: "Clothing",
    location_lost: "Lakefill — stone bench near sailing center",
    date_lost: Date.new(2026, 4, 5),
    contact_name: "Lucas Meyer",
    contact_email: "lucas.meyer@u.northwestern.edu",
    status: "open",
    color: "Red",
    brand: "The North Face"
  },
  {
    title: "Bike U-lock (Kryptonite) with key",
    description: "Mini U-lock; single key on small carabiner; scratched paint from rack.",
    category: "Other",
    location_lost: "Garage bike cage — Sheridan side",
    date_lost: Date.new(2026, 4, 4),
    contact_name: "Zoe Nakamura",
    contact_email: "zoe.nakamura@u.northwestern.edu",
    status: "open",
    color: "Black",
    brand: "Kryptonite"
  }
]

lost_seed.each { |attrs| LostItem.create!(attrs) }

found_seed = [
  {
    title: "Wildcat student ID on blue lanyard",
    description: "Found on a bench near the food court; turned in with card facing down.",
    category: "IDs & cards",
    location_found: "Norris University Center — near Starbucks seating",
    date_found: Date.new(2026, 4, 19),
    contact_name: "Riley Adams",
    contact_email: "riley.adams@u.northwestern.edu",
    status: "unclaimed",
    storage_location: "Norris information desk drawer #2",
    image_url: "https://picsum.photos/seed/nu-found-id/600/400",
    color: "Blue",
    brand: nil
  },
  {
    title: "Single brass dorm key on purple wrist coil",
    description: "Key has small 'B' etched on it; wrist coil is fabric-covered.",
    category: "Keys",
    location_found: "Allison dining hall — tray return",
    date_found: Date.new(2026, 4, 18),
    contact_name: "Sam Johnson",
    contact_email: "sam.johnson@u.northwestern.edu",
    status: "unclaimed",
    storage_location: "Allison front desk lost & found bin",
    color: "Purple",
    brand: nil
  },
  {
    title: "Metal water bottle with math department sticker",
    description: "Dented silver bottle; sticker shows π day event.",
    category: "Drinkware",
    location_found: "Technological Institute — A wing water fountain",
    date_found: Date.new(2026, 4, 17),
    contact_name: "Alex Morgan",
    contact_email: "alex.morgan@u.northwestern.edu",
    status: "claimed",
    storage_location: "Tech main office shelf",
    color: "Silver",
    brand: "Takeya"
  },
  {
    title: "Gray backpack with patch from CAESAR outage week",
    description: "Medium hiking-style pack; patch is iron-on and slightly peeling.",
    category: "Bags",
    location_found: "Main Library — lockers corridor",
    date_found: Date.new(2026, 4, 16),
    contact_name: "Jordan Smith",
    contact_email: "jordan.smith@u.northwestern.edu",
    status: "unclaimed",
    color: "Gray",
    brand: "Osprey"
  },
  {
    title: "Single AirPod (right) found near bike rack",
    description: "Right AirPod only; slight scuff on microphone mesh.",
    category: "Electronics",
    location_found: "University Library — east bike racks",
    date_found: Date.new(2026, 4, 15),
    contact_name: "Taylor Reed",
    contact_email: "taylor.reed@u.northwestern.edu",
    status: "unclaimed",
    color: "White",
    brand: "Apple"
  },
  {
    title: "Black North Face rain jacket (women's S)",
    description: "Lightweight shell; name written on tag inside collar (faded).",
    category: "Clothing",
    location_found: "Deering Library — coat hooks by seminar rooms",
    date_found: Date.new(2026, 4, 14),
    contact_name: "Morgan Lee",
    contact_email: "morgan.lee@u.northwestern.edu",
    status: "claimed",
    storage_location: "Deering circulation desk",
    color: "Black",
    brand: "The North Face"
  },
  {
    title: "Composition notebook — Econ 201 doodles on cover",
    description: "Marble cover; first page has supply/demand sketches.",
    category: "School supplies",
    location_found: "Foster-Walker (Plex) — TV lounge table",
    date_found: Date.new(2026, 4, 13),
    contact_name: "Casey Brown",
    contact_email: "casey.brown@u.northwestern.edu",
    status: "unclaimed",
    color: "Black and white",
    brand: nil
  },
  {
    title: "MacBook USB-C charger (Apple 61W)",
    description: "Official Apple brick; cable has small fray near connector (electrical tape).",
    category: "Electronics",
    location_found: "Tech study lounge — power strip under window",
    date_found: Date.new(2026, 4, 12),
    contact_name: "Jamie Wu",
    contact_email: "jamie.wu@u.northwestern.edu",
    status: "unclaimed",
    storage_location: "Tech EECS main office",
    color: "White",
    brand: "Apple"
  },
  {
    title: "Scientific calculator (Casio)",
    description: "Casio fx-991; initials in sharpie on battery cover.",
    category: "Electronics",
    location_found: "Sheridan shuttle stop — shelter bench",
    date_found: Date.new(2026, 4, 11),
    contact_name: "Drew Garcia",
    contact_email: "drew.garcia@u.northwestern.edu",
    status: "unclaimed",
    color: "Gray",
    brand: "Casio"
  },
  {
    title: "Canvas wallet with purple stitching",
    description: "Slim wallet; NU bookstore receipt still inside.",
    category: "Wallets",
    location_found: "Elder dining hall — booth corner",
    date_found: Date.new(2026, 4, 10),
    contact_name: "Rimen Jenhani",
    contact_email: "rimen.jenhani@u.northwestern.edu",
    status: "unclaimed",
    image_url: "https://picsum.photos/seed/nu-found-wallet/600/400",
    color: "Gray",
    brand: nil
  },
  {
    title: "Northwestern knit scarf (purple and white stripes)",
    description: "Hand-knit style scarf; no tags; slight grass stain on one end.",
    category: "Clothing",
    location_found: "Ryan Field — section 112 aisle after spring game",
    date_found: Date.new(2026, 4, 22),
    contact_name: "Pat O'Neill",
    contact_email: "pat.oneill@u.northwestern.edu",
    status: "unclaimed",
    storage_location: "Athletics guest services cage",
    image_url: "https://picsum.photos/seed/nu-found-scarf/600/400",
    color: "Purple",
    brand: nil
  },
  {
    title: "iPad mini in folio case",
    description: "Space gray iPad mini in navy folio; passcode locked — will hold for owner verification.",
    category: "Electronics",
    location_found: "University Hall — lecture hall 101, front row",
    date_found: Date.new(2026, 4, 21),
    contact_name: "Prof. desk (turned in by student)",
    contact_email: "lostfound@northwestern.edu",
    status: "unclaimed",
    storage_location: "University Hall department office",
    color: "Space gray",
    brand: "Apple"
  },
  {
    title: "Clarinet in black hard case",
    description: "Yamaha student model; case has Bienen practice room sticker.",
    category: "Other",
    location_found: "Regenstein Hall — basement locker corridor",
    date_found: Date.new(2026, 4, 20),
    contact_name: "Facilities night staff",
    contact_email: "music.facilities@northwestern.edu",
    status: "unclaimed",
    storage_location: "Regenstein main office locked closet",
    color: "Black",
    brand: "Yamaha"
  },
  {
    title: "Prescription glasses (round frames)",
    description: "Thin gold wire frames; lenses in case; found in restroom.",
    category: "Other",
    location_found: "Norris — second floor restroom counter",
    date_found: Date.new(2026, 4, 9),
    contact_name: "Norris building manager",
    contact_email: "norris.info@northwestern.edu",
    status: "unclaimed",
    storage_location: "Norris information desk",
    color: "Gold",
    brand: nil
  },
  {
    title: "Wildcat foam finger",
    description: "Purple #1 foam finger; minor tear at seam.",
    category: "Other",
    location_found: "Welsh-Ryan Arena — concourse under seat",
    date_found: Date.new(2026, 4, 8),
    contact_name: "Event staff",
    contact_email: "nusports.facilities@northwestern.edu",
    status: "claimed",
    storage_location: "Arena operations office",
    color: "Purple",
    brand: nil
  },
  {
    title: "Stanley tumbler (40oz, cream)",
    description: "Handle intact; sticker that says 'Go 'Cats' on side.",
    category: "Drinkware",
    location_found: "The Arch — picnic tables south side",
    date_found: Date.new(2026, 4, 7),
    contact_name: "Tour guide staff",
    contact_email: "admissions.visit@northwestern.edu",
    status: "unclaimed",
    color: "Cream",
    brand: "Stanley"
  },
  {
    title: "Mechanical keyboard (75%, white)",
    description: "Gasket-mount board; white keycaps; USB-C coiled cable attached.",
    category: "Electronics",
    location_found: "Mudd Library — basement computer lab desk 14",
    date_found: Date.new(2026, 4, 6),
    contact_name: "Library circulation",
    contact_email: "library-help@northwestern.edu",
    status: "unclaimed",
    storage_location: "Mudd circulation lost shelf",
    image_url: "https://picsum.photos/seed/nu-found-kb/600/400",
    color: "White",
    brand: "Keychron"
  },
  {
    title: "Dorm desk lamp (gooseneck LED)",
    description: "Black base; USB port on base; works — left after move-out weekend.",
    category: "Other",
    location_found: "1835 Hinman — move-out donation pile (sorted to lost & found)",
    date_found: Date.new(2026, 4, 5),
    contact_name: "Residential Services",
    contact_email: "residential@northwestern.edu",
    status: "unclaimed",
    storage_location: "1835 Hinman service desk",
    color: "Black",
    brand: "IKEA"
  }
]

found_seed.each { |attrs| FoundItem.create!(attrs) }

Booking.destroy_all if ApplicationRecord.connection.table_exists?("bookings")
RentalItem.destroy_all

rental_seed = [
  {
    title: "4-Person Camping Tent",
    description: "REI Co-op dome tent in excellent condition. Used only 3 times. Comes with rainfly, stakes, and storage bag. Fits easily in a car.",
    category: "Camping Gear",
    rental_price: 20,
    rental_period: "per_day",
    condition: "Like New",
    location: "Tech building (pickup/dropoff)",
    available_from: Date.new(2026, 5, 1),
    available_to: Date.new(2026, 8, 31),
    image_url: "https://picsum.photos/seed/tent/600/400",
    owner_name: "Alex Chen",
    owner_email: "alex.chen@u.northwestern.edu",
    owner_phone: "(555) 123-4567",
    deposit_required: 50,
    status: "available"
  },
  {
    title: "Mountain Bike - Trek Marlin",
    description: "Trek Marlin 5 hardtail mountain bike. 29-inch wheels. Great for trails around Chicago. Well-maintained, recently serviced.",
    category: "Sports Equipment",
    rental_price: 25,
    rental_period: "per_day",
    condition: "Good",
    location: "Campus near Lakefront",
    available_from: Date.new(2026, 5, 1),
    available_to: Date.new(2026, 9, 30),
    image_url: "https://picsum.photos/seed/bike/600/400",
    owner_name: "Jordan Smith",
    owner_email: "jordan.smith@u.northwestern.edu",
    owner_phone: "(555) 234-5678",
    deposit_required: 75,
    status: "available"
  },
  {
    title: "Power Drill & Tool Set",
    description: "DeWalt 20V cordless drill/driver with complete bit set plus hammer, level, and measuring tape. Includes 2 batteries and charger.",
    category: "Tools",
    rental_price: 15,
    rental_period: "per_day",
    condition: "Good",
    location: "Evanston near NU",
    available_from: Date.new(2026, 5, 5),
    available_to: Date.new(2026, 9, 15),
    owner_name: "Taylor Brown",
    owner_email: "taylor.brown@u.northwestern.edu",
    owner_phone: "(555) 345-6789",
    deposit_required: 40,
    status: "available"
  },
  {
    title: "Textbook: Organic Chemistry (8th Edition)",
    description: "Brown & Iverson Organic Chemistry textbook. Hardcover, minimal highlighting. Also includes practice problem book.",
    category: "Books",
    rental_price: 8,
    rental_period: "per_week",
    condition: "Good",
    location: "Library",
    available_from: Date.new(2026, 5, 1),
    available_to: Date.new(2026, 12, 31),
    owner_name: "Sam Patel",
    owner_email: "sam.patel@u.northwestern.edu",
    deposit_required: 0,
    status: "available"
  },
  {
    title: "Ikea Futon Sofa Bed",
    description: "Comfortable futon from Ikea. Can be used as couch or bed. Dark gray fabric. Minimal stains. Needs pickup/return.",
    category: "Furniture",
    rental_price: 40,
    rental_period: "per_week",
    condition: "Fair",
    location: "Evanston (1st floor, easy access)",
    available_from: Date.new(2026, 5, 10),
    available_to: Date.new(2026, 8, 20),
    image_url: "https://picsum.photos/seed/couch/600/400",
    owner_name: "Casey Lee",
    owner_email: "casey.lee@u.northwestern.edu",
    owner_phone: "(555) 456-7890",
    deposit_required: 100,
    status: "available"
  },
  {
    title: "Portable Projector - AAXA",
    description: "Small LED projector, perfect for outdoor movie nights or presentations. Comes with HDMI cable. 100 ANSI lumens.",
    category: "Electronics",
    rental_price: 30,
    rental_period: "per_day",
    condition: "Like New",
    location: "Downtown Evanston",
    available_from: Date.new(2026, 5, 1),
    available_to: Date.new(2026, 10, 31),
    owner_name: "Morgan Zhang",
    owner_email: "morgan.zhang@u.northwestern.edu",
    owner_phone: "(555) 567-8901",
    deposit_required: 60,
    status: "available"
  },
  {
    title: "Skateboard Deck & Grip Tape",
    description: "Freshly re-gripped skateboard. Recently replaced bearings. Solid fun board for cruising.",
    category: "Sports Equipment",
    rental_price: 10,
    rental_period: "per_day",
    condition: "Good",
    location: "Campus center",
    available_from: Date.new(2026, 5, 1),
    available_to: Date.new(2026, 10, 31),
    owner_name: "Riley Davis",
    owner_email: "riley.davis@u.northwestern.edu",
    deposit_required: 25,
    status: "available"
  },
  {
    title: "Professional Luggage (spinner set of 3)",
    description: "Travelpro luggage set with carry-on, checked, and personal item bags. Smooth wheels, TSA-approved locks.",
    category: "Other",
    rental_price: 35,
    rental_period: "per_week",
    condition: "Like New",
    location: "Near Evanston downtown",
    available_from: Date.new(2026, 5, 1),
    available_to: Date.new(2026, 12, 31),
    image_url: "https://picsum.photos/seed/luggage/600/400",
    owner_name: "Drew Johnson",
    owner_email: "drew.johnson@u.northwestern.edu",
    owner_phone: "(555) 678-9012",
    deposit_required: 80,
    status: "available"
  }
]

rental_seed.each { |attrs| RentalItem.create!(attrs) }

MarketplaceListing.destroy_all

marketplace_seed = [
  {
    title: "M2 MacBook Air (13\", 512GB) — lightly used",
    description: "2023 model, space gray. Battery cycle count ~120. No dents; screen is flawless. Includes original box and charger. Selling because I upgraded to a pro machine for thesis work.",
    category: "Electronics",
    listing_type: "for_sale",
    price: 849.00,
    condition: "Like New",
    location: "Evanston — pickup near Foster-Walker",
    contact_name: "Kevin Zhao",
    contact_email: "kevin.zhao@u.northwestern.edu",
    contact_phone: "(847) 555-0142",
    image_url: "https://picsum.photos/seed/nu-mba/600/400",
    status: "active"
  },
  {
    title: "Sony WH-1000XM5 headphones",
    description: "Black over-ear noise canceling. Purchased fall 2025; still under warranty card included. Comes with case and cable.",
    category: "Electronics",
    listing_type: "for_sale",
    price: 265.00,
    condition: "Like New",
    location: "Tech — can meet at main lobby",
    contact_name: "Amelia Rossi",
    contact_email: "amelia.rossi@u.northwestern.edu",
    contact_phone: "(312) 555-0198",
    image_url: "https://picsum.photos/seed/nu-sony/600/400",
    status: "active"
  },
  {
    title: "Wanted: Econ 310 intermediate micro reader (current edition)",
    description: "Missed the bookstore bundle deadline. Looking for a clean used copy or PDF access code transfer if allowed. Will pay cash or Venmo.",
    category: "Books",
    listing_type: "wanted",
    condition: "Good",
    location: "Campus — flexible meetup",
    contact_name: "Marcus Bell",
    contact_email: "marcus.bell@u.northwestern.edu",
    status: "active"
  },
  {
    title: "Ikea MALM desk + Alex drawer unit",
    description: "White 47\" desk with Alex 5-drawer on one side. Minor scuffs on top from monitor arm. Disassembled partially for easier move; all hardware bagged and labeled.",
    category: "Furniture",
    listing_type: "for_sale",
    price: 120.00,
    condition: "Good",
    location: "Off-campus house on Orrington — ground floor",
    contact_name: "Tessa Nguyen",
    contact_email: "tessa.nguyen@u.northwestern.edu",
    contact_phone: "(847) 555-0221",
    image_url: "https://picsum.photos/seed/nu-desk/600/400",
    status: "active"
  },
  {
    title: "Bauer Vapor hockey skates (senior 9.5)",
    description: "Heat-molded once; sharpened regularly. Upgraded skates so letting these go. Some puck marks on toes but steel and holders are solid.",
    category: "Sports Equipment",
    listing_type: "for_sale",
    price: 175.00,
    condition: "Good",
    location: "Henry Crown — locker room meetup after 6pm weekdays",
    contact_name: "Jake O'Connor",
    contact_email: "jake.oconnor@u.northwestern.edu",
    status: "active"
  },
  {
    title: "DeWalt 20V combo (impact + drill) with bag",
    description: "Two tools, two batteries, charger. Used for one apartment move and a few IKEA builds. Great for off-campus repairs.",
    category: "Tools",
    listing_type: "for_sale",
    price: 195.00,
    condition: "Good",
    location: "Downtown Evanston — alley pickup with loading zone",
    contact_name: "Olivia Hart",
    contact_email: "olivia.hart@u.northwestern.edu",
    contact_phone: "(224) 555-0167",
    image_url: "https://picsum.photos/seed/nu-dewalt/600/400",
    status: "active"
  },
  {
    title: "REI Magma 15 sleeping bag (regular)",
    description: "Down bag rated 15°F; stored uncompressed in cotton sack. Used on two BWCA trips. No odors; always liner used.",
    category: "Camping Gear",
    listing_type: "for_sale",
    price: 310.00,
    condition: "Like New",
    location: "Norris circle — can bring to library if easier",
    contact_name: "Ben Carter",
    contact_email: "ben.carter@u.northwestern.edu",
    status: "active"
  },
  {
    title: "Wanted: TI-84 Plus CE (any color)",
    description: "Need for Chem lab data logging this quarter. Not picky on color; just need working USB port and good battery door.",
    category: "Electronics",
    listing_type: "wanted",
    location: "Tech quad — text to coordinate",
    contact_name: "Yasmin Farah",
    contact_email: "yasmin.farah@u.northwestern.edu",
    contact_phone: "(773) 555-0133",
    status: "active"
  },
  {
    title: "Yamaha YFL-222 flute (student model)",
    description: "Serviced last year at Evanston shop; pads seal well. Case, cleaning rod, and swab included. Selling after switching to clarinet for ensemble needs.",
    category: "Other",
    custom_category: "Musical instruments",
    listing_type: "for_sale",
    price: 425.00,
    condition: "Good",
    location: "Pick-Staiger — meet after rehearsal blocks",
    contact_name: "Elena Volkov",
    contact_email: "elena.volkov@u.northwestern.edu",
    status: "active"
  },
  {
    title: "Mini fridge (3.1 cu ft, Energy Star)",
    description: "Black compact fridge with small freezer shelf. Quiet; RA-approved sticker from prior year still on back. Defrosted and wiped down.",
    category: "Other",
    custom_category: "Appliances",
    listing_type: "for_sale",
    price: 85.00,
    condition: "Fair",
    location: "1835 Hinman — elevator loading",
    contact_name: "Diego Ramirez",
    contact_email: "diego.ramirez@u.northwestern.edu",
    contact_phone: "(847) 555-0204",
    image_url: "https://picsum.photos/seed/nu-fridge/600/400",
    status: "active"
  },
  {
    title: "Set of 6 McCormick FE / DTC course readers (bundle)",
    description: "From sophomore design sequence; spiral-bound readers with minimal highlighting. Selling as a set only.",
    category: "Books",
    listing_type: "for_sale",
    price: 45.00,
    condition: "Fair",
    location: "Tech B wing atrium",
    contact_name: "Priya Nair",
    contact_email: "priya.nair@u.northwestern.edu",
    status: "completed"
  },
  {
    title: "Older listing — Herman Miller chair (sold elsewhere)",
    description: "Placeholder inactive listing for testing filters.",
    category: "Furniture",
    listing_type: "for_sale",
    price: 1.00,
    condition: "Good",
    location: "N/A",
    contact_name: "Seed Data",
    contact_email: "seed@u.northwestern.edu",
    status: "inactive"
  }
]

marketplace_seed.each { |attrs| MarketplaceListing.create!(attrs) }

puts "Seeded #{LostItem.count} lost items, #{FoundItem.count} found items, #{RentalItem.count} rental items, and #{MarketplaceListing.count} marketplace listings."
