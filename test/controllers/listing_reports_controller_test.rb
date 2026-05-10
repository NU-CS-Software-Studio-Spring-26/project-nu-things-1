# frozen_string_literal: true

require "test_helper"

class ListingReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:nu_student))
    @lost_item = lost_items(:one)
  end

  test "lost item report rejects profane details" do
    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post report_lost_item_url(@lost_item),
           params: {
             report_details: "Something wrong xxtestbadxx with this posting here extra text filler line two ok min length met",
           }
    end

    assert_redirected_to lost_item_url(@lost_item)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "lost item report enqueues mail when details are clean" do
    assert_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size }, 1 do
      post report_lost_item_url(@lost_item),
           params: {
             report_details: "This spam listing looks duplicated from another campus board and should be removed by moderators here.",
           }
    end

    assert_redirected_to lost_item_url(@lost_item)
  end

  test "found item report rejects profane details" do
    item = found_items(:one)

    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post report_found_item_url(item),
           params: {
             report_details: "Something wrong xxtestbadxx with this posting here extra text filler line two ok min length met",
           }
    end

    assert_redirected_to found_item_url(item)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end
end
