# frozen_string_literal: true

module AuditableLogging
  extend ActiveSupport::Concern

  private

  def record_audit(action, auditable: nil, subject: nil, metadata: {})
    subject_label = subject.presence ||
                    auditable.try(:title).presence ||
                    auditable&.model_name&.human ||
                    action

    AuditLog.create!(
      user: current_user,
      action: action,
      auditable: auditable,
      subject: subject_label,
      metadata: metadata,
      ip_address: request.remote_ip
    )
  rescue StandardError => e
    Rails.logger.warn("[AuditLog] #{e.class}: #{e.message}")
  end
end
