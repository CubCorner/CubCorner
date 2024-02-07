class PostDeletionReasonsController < ApplicationController
  before_action :approver_only
  before_action :admin_only, except: %i[index]
  respond_to :html, :json

  def index
    @reasons = PostDeletionReason.order(order: :asc)
    respond_with(@reasons)
  end

  def new
    @reason = PostDeletionReason.new
  end

  def edit
    @reason = PostDeletionReason.find(params[:id])
  end

  def create
    @reason = PostDeletionReason.create(reason_params)
    flash[:notice] = @reason.valid? ? "Post deletion reason created" : @reason.errors.full_messages.join("; ")
    respond_with(@reason) do |fmt|
      fmt.html { redirect_to post_deletion_reasons_path }
    end
  end

  def update
    @reason = PostDeletionReason.find(params[:id])
    @reason.update(reason_params)
    flash[:notice] = @reason.valid? ? "Post deletion reason updated" : @reason.errors.full_messages.join("; ")
    respond_with(@reason) do |fmt|
      fmt.html { redirect_to post_deletion_reasons_path }
    end
  end

  def destroy
    @reason = PostDeletionReason.find(params[:id])
    @reason.destroy
    flash[:notice] = "Post deletion reason deleted"
    respond_with(@reason) do |format|
      format.html { redirect_to post_deletion_reasons_path }
    end
  end

  def reorder
    new_orders = params[:_json].reject { |o| o[:id].nil? }
    new_ids = new_orders.pluck(:id)
    current_ids = PostDeletionReason.all.select(:id).map(&:id)
    missing = current_ids - new_ids
    extra = new_ids - current_ids
    duplicate = new_ids.select { |id| new_ids.count(id) > 1 }.uniq

    return render_expected_error(400, "Missing ids: #{missing.join(', ')}") if missing.any?
    return render_expected_error(400, "Extra ids provided: #{extra.join(', ')}") if extra.any?
    return render_expected_error(400, "Duplicate ids provided: #{duplicate.join(', ')}") if duplicate.any?

    changes = 0
    PostDeletionReason.transaction do
      new_orders.each do |order|
        rec = PostDeletionReason.find(order[:id])
        if rec.order != order[:order]
          rec.update_column(:order, order[:order])
          changes += 1
        end
      end
    end

    if changes != 0
      ModAction.log(:post_deletion_reasons_reorder, { total: changes })
    end

    respond_to do |format|
      format.html { redirect_back(fallback_location: post_deletion_reasons_path) }
      format.json
    end
  end

  private

  def reason_params
    params.require(:post_deletion_reason).permit(%i[reason title prompt order move_up])
  end
end