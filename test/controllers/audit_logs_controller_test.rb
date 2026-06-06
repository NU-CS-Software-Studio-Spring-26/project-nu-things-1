# frozen_string_literal: true

require "test_helper"

class AuditLogsControllerTest < ActionDispatch::IntegrationTest
  test "index redirects non-admin users" do
    sign_in_as(users(:nu_student))
    get audit_logs_url
    assert_redirected_to root_url
  end

  test "index redirects guests" do
    get audit_logs_url
    assert_redirected_to new_session_url
  end

  test "index shows audit entries for admin" do
    AuditLog.create!(
      user: users(:admin),
      action: "lost_item.destroy",
      subject: "Fixture lost item one"
    )

    sign_in_as(users(:admin))
    get audit_logs_url
    assert_response :success
    assert_select "h2", /Audit log/i
    assert_select "td", text: "Deleted lost item"
    assert_select "td", text: "Fixture lost item one"
  end
end
