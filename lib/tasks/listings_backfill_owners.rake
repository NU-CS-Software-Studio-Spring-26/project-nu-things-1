# frozen_string_literal: true

namespace :listings do
  desc "Print authorization diagnostics (ADMIN_EMAIL, user_id coverage). Run on Heroku to debug production."
  task auth_audit: :environment do
    puts "PurplePost.admin_email=#{PurplePost.admin_email.inspect}"
    [ LostItem, FoundItem, MarketplaceListing, RentalItem ].each do |model|
      total = model.count
      with_user = model.where.not(user_id: nil).count
      puts "#{model.name}: #{with_user}/#{total} have user_id"
      top = model.group(:user_id).count.sort_by { |_, v| -v }.first(3)
      puts "  top user_id counts: #{top.inspect}"
    end
  end

  desc "Backfill listing user_id from contact_email/owner_email (dry-run by default). Use APPLY=1 to write."
  task backfill_owners: :environment do
    dry_run = ENV["APPLY"].to_s != "1"
    puts dry_run ? "DRY RUN (set APPLY=1 to update rows)" : "APPLYING updates"

    totals = { matched: 0, skipped: 0, ambiguous: 0, no_user: 0 }

    [
      [ LostItem, :contact_email ],
      [ FoundItem, :contact_email ],
      [ MarketplaceListing, :contact_email ],
      [ RentalItem, :owner_email ]
    ].each do |model, email_column|
      scope = model.where(user_id: nil).where.not(email_column => [ nil, "" ])
      puts "\n#{model.name}: #{scope.count} rows without user_id"

      scope.find_each do |record|
        email = User.normalize_email(record.public_send(email_column))
        users = User.where(email: email).to_a

        if users.empty?
          totals[:no_user] += 1
          next
        end

        if users.size > 1
          totals[:ambiguous] += 1
          puts "  ambiguous ##{record.id}: #{email} (#{users.size} users)"
          next
        end

        owner = users.first
        totals[:matched] += 1
        if dry_run
          puts "  would set ##{record.id} user_id=#{owner.id} (#{email})"
        else
          record.update_column(:user_id, owner.id)
        end
      end
    end

    puts "\nSummary: #{totals.inspect}"
  end
end
