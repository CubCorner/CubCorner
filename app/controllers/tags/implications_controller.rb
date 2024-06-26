# frozen_string_literal: true

module Tags
  class ImplicationsController < ApplicationController
    respond_to :html, :json
    wrap_parameters :tag_implication

    def index
      @tag_implications = authorize(TagImplication).includes(:antecedent_tag, :consequent_tag, :approver).search(search_params).paginate(params[:page], limit: params[:limit])
      respond_with(@tag_implications)
    end

    def show
      @tag_implication = authorize(TagImplication.find(params[:id]))
      respond_with(@tag_implication)
    end

    def new
      @tag_implication = authorize(TagImplication.new)
    end

    def edit
      @tag_implication = authorize(TagImplication.find(params[:id]))
    end

    def create
      @tag_implication_request = authorize(TagImplicationRequest.new(permitted_attributes(TagImplication)), policy_class: TagImplicationPolicy)
      @tag_implication_request.create

      if @tag_implication_request.invalid?
        respond_with(@tag_implication_request) do |format|
          format.html { redirect_back(fallback_location: new_tag_alias_path, notice: @tag_implication_request.errors.full_messages.join("; ")) }
        end
      elsif @tag_implication_request.forum_topic
        respond_with(@tag_implication_request.tag_relationship, location: forum_topic_path(@tag_implication_request.forum_topic, page: @tag_implication_request.tag_relationship.forum_post.forum_topic_page, anchor: "forum_post_#{@tag_implication_request.tag_relationship.forum_post_id}"))
      else
        respond_with(@tag_implication_request.tag_relationship)
      end
    end

    def update
      @tag_implication = authorize(TagImplication.find(params[:id]))

      if @tag_implication.is_pending? && @tag_implication.editable_by?(CurrentUser.user)
        @tag_implication.update(permitted_attributes(TagImplication))
      end

      respond_with(@tag_implication)
    end

    def destroy
      @tag_implication = authorize(TagImplication.find(params[:id]))
      if @tag_implication.rejectable_by?(CurrentUser.user)
        @tag_implication.reject!
        if @tag_implication.errors.any?
          flash[:notice] = @tag_implication.errors.full_messages.join("; ")
          redirect_to(tag_implications_path)
          return
        end
        respond_with(@tag_implication) do |format|
          format.html do
            flash[:notice] = "Tag implication was deleted"
            redirect_to(tag_implications_path)
          end
        end
      else
        access_denied
      end
    end

    def approve
      @tag_implication = authorize(TagImplication.find(params[:id]))
      @tag_implication.approve!(approver: CurrentUser.user)
      respond_with(@tag_implication, location: tag_implication_path(@tag_implication))
    end
  end
end
