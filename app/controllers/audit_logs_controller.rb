# frozen_string_literal: true

class AuditLogsController < ApplicationController
  before_action :require_admin

  PER_PAGE = 50

  def index
    scope = AuditLog.includes(:user).recent
    @pagy, @audit_logs = pagy(:offset, scope, limit: PER_PAGE)
  end
end
