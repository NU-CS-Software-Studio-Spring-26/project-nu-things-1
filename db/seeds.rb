# Northwestern-themed sample data for development and demos.
# Run: bin/rails db:seed

Claim.destroy_all
LoginToken.destroy_all
User.destroy_all
Booking.destroy_all
LostItem.destroy_all
FoundItem.destroy_all
RentalItem.destroy_all
MarketplaceListing.destroy_all

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
  }
]

found_seed.each { |attrs| FoundItem.create!(attrs) }

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

puts "Seeded #{LostItem.count} lost items, #{FoundItem.count} found items, and #{RentalItem.count} rental items."
