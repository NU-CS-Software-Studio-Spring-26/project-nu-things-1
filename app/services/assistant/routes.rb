# frozen_string_literal: true

module Assistant
  module Routes
    module_function

    def path_for(record)
      case record
      when LostItem then Rails.application.routes.url_helpers.lost_item_path(record)
      when FoundItem then Rails.application.routes.url_helpers.found_item_path(record)
      when RentalItem then Rails.application.routes.url_helpers.rental_item_path(record)
      when MarketplaceListing then Rails.application.routes.url_helpers.marketplace_listing_path(record)
      else
        Rails.application.routes.url_helpers.root_path
      end
    end
  end
end
