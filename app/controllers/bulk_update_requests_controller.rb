# frozen_string_literal: true

class BulkUpdateRequestsController < ApplicationController
  before_action :load_bulk_update_request, except: %i[new create index]
  respond_to :html, :json

  def index
    @bulk_update_requests = authorize(BulkUpdateRequest).search(search_params(BulkUpdateRequest)).includes(:forum_post, :creator, :approver).paginate(params[:page], limit: params[:limit])
    respond_with(@bulk_update_requests)
  end

  def show
    @bulk_update_request = authorize(BulkUpdateRequest.find(params[:id]))
    respond_with(@bulk_update_request)
  end

  def new
    @bulk_update_request = authorize(BulkUpdateRequest.new)
    respond_with(@bulk_update_request)
  end

  def edit
    authorize(@bulk_update_request)
  end

  def create
    @bulk_update_request = authorize(BulkUpdateRequest.new(permitted_attributes(BulkUpdateRequest)))
    @bulk_update_request.save
    respond_with(@bulk_update_request)
  end

  def update
    @bulk_update_request.should_validate = true
    @bulk_update_request.update(permitted_attributes(BulkUpdateRequest))
    notice("Bulk update request updated")
    respond_with(@bulk_update_request)
  end

  def approve
    authorize(@bulk_update_request).approve!(CurrentUser.user)
    notice(@bulk_update_request.valid? ? "Bulk update approved" : @bulk_update_request.errors.full_messages.join("; "))
    respond_with(@bulk_update_request)
  end

  def destroy
    authorize(@bulk_update_request).reject!(CurrentUser.user)
    notice("Bulk update request rejected")
    respond_with(@bulk_update_request, location: bulk_update_requests_path)
  end

  private

  def load_bulk_update_request
    @bulk_update_request = BulkUpdateRequest.find(params[:id])
  end
end
