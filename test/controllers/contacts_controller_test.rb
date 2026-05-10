# frozen_string_literal: true

require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lost_item = lost_items(:one)
    sign_in_as(users(:nu_student))
  end

  test "rejects contact post when message contains moderated word" do
    assert_no_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size } do
      post create_lost_item_contact_path,
           params: {
             lost_item_id: @lost_item.id,
             sender_name: "Sam Student",
             sender_email: "student@u.northwestern.edu",
             message: "Hello xxtestbadxx there.",
           }
    end

    assert_redirected_to lost_item_url(@lost_item)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "enqueues mail when message is clean" do
    assert_difference -> { ActiveJob::Base.queue_adapter.enqueued_jobs.size }, 1 do
      post create_lost_item_contact_path,
           params: {
             lost_item_id: @lost_item.id,
             sender_name: "Sam Student",
             sender_email: "student@u.northwestern.edu",
             message: "Is this still available? Thanks!",
           }
    end

    assert_redirected_to lost_item_url(@lost_item)
  end
end
