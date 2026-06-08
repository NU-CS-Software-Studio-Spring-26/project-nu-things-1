# frozen_string_literal: true

require "test_helper"

class ListingReportsControllerTest < ActionDispatch::IntegrationTest
  CLEAN_REPORT_DETAILS =
    "This spam listing looks duplicated from another campus board and should be removed by moderators here.".freeze

  PROFANE_REPORT_DETAILS =
    "Something wrong xxtestbadxx with this posting here extra text filler line two ok min length met".freeze

  setup do
    sign_in_as(users(:nu_student))
    @lost_item = lost_items(:one)
  end

  test "lost item report rejects profane details" do
    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post report_lost_item_url(@lost_item), params: { report_details: PROFANE_REPORT_DETAILS }
    end

    assert_redirected_to lost_item_url(@lost_item)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "lost item report enqueues mail when details are clean" do
    assert_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size }, 1 do
      post report_lost_item_url(@lost_item), params: { report_details: CLEAN_REPORT_DETAILS }
    end

    assert_redirected_to lost_item_url(@lost_item)
    assert_equal "Thanks—your report was sent to the moderators.", flash[:notice]
  end

  test "lost item report records audit log" do
    assert_difference("AuditLog.count", 1) do
      post report_lost_item_url(@lost_item), params: { report_details: CLEAN_REPORT_DETAILS }
    end

    assert_equal "lost_item.report", AuditLog.order(:id).last.action
  end

  test "found item report rejects profane details" do
    item = found_items(:one)

    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post report_found_item_url(item), params: { report_details: PROFANE_REPORT_DETAILS }
    end

    assert_redirected_to found_item_url(item)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "found item report enqueues mail when details are clean" do
    item = found_items(:one)

    assert_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size }, 1 do
      post report_found_item_url(item), params: { report_details: CLEAN_REPORT_DETAILS }
    end

    assert_redirected_to found_item_url(item)
  end

  test "rental item report rejects profane details" do
    item = rental_items(:one)

    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post report_rental_item_url(item), params: { report_details: PROFANE_REPORT_DETAILS }
    end

    assert_redirected_to rental_item_url(item)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "rental item report enqueues mail when details are clean" do
    item = rental_items(:one)

    assert_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size }, 1 do
      post report_rental_item_url(item), params: { report_details: CLEAN_REPORT_DETAILS }
    end

    assert_redirected_to rental_item_url(item)
    assert_equal "Thanks—your report was sent to the moderators.", flash[:notice]
    assert_equal "rental_item.report", AuditLog.order(:id).last.action
  end

  test "marketplace listing report rejects profane details" do
    listing = marketplace_listings(:for_sale_one)

    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post report_marketplace_listing_url(listing), params: { report_details: PROFANE_REPORT_DETAILS }
    end

    assert_redirected_to marketplace_listing_url(listing)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "marketplace listing report enqueues mail when details are clean" do
    listing = marketplace_listings(:for_sale_one)

    assert_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size }, 1 do
      post report_marketplace_listing_url(listing), params: { report_details: CLEAN_REPORT_DETAILS }
    end

    assert_redirected_to marketplace_listing_url(listing)
    assert_equal "marketplace_listing.report", AuditLog.order(:id).last.action
  end
end
