class ClaimsController < ApplicationController
  before_action :require_login

  def create_for_lost_item
    lost_item = LostItem.find(params.expect(:id))
    Claim.find_or_create_by!(user: current_user, claimable: lost_item)

    redirect_to lost_item, notice: "Claim started. Check your email for next steps soon."
  end

  def create_for_found_item
    found_item = FoundItem.find(params.expect(:id))
    Claim.find_or_create_by!(user: current_user, claimable: found_item)

    redirect_to found_item, notice: "Claim started. Check your email for next steps soon."
  end
end

