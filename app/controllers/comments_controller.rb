# frozen_string_literal: true

class CommentsController < ApplicationController
  skip_before_action :api_check
  respond_to :html, :json

  def index
    authorize(Comment)
    if params[:group_by] == "comment" || (request.format.json? && params[:group_by] != "post")
      index_by_comment
    else
      index_by_post
    end
  end

  def search
    authorize(Comment)
  end

  def for_post
    @post = authorize(Post.find(params[:id]), policy_class: CommentPolicy)
    @comments = @post.comments
    @comment_votes = CommentVote.for_comments_and_user(@comments.map(&:id), CurrentUser.id)
    comment_html = render_to_string(partial: "comments/partials/show/comment", collection: @comments, locals: { post: @post }, formats: [:html])
    respond_with do |format|
      format.json do
        render(json: { html: comment_html, posts: deferred_posts })
      end
    end
  end

  def show
    @comment = authorize(Comment.find(params[:id]))
    @comment_votes = CommentVote.for_comments_and_user([@comment.id], CurrentUser.id)
    respond_with(@comment)
  end

  def new
    @comment = authorize(Comment.new(permitted_attributes(Comment)))
    respond_with(@comment)
  end

  def edit
    @comment = authorize(Comment.find(params[:id]))
    respond_with(@comment)
  end

  def create
    @comment = authorize(Comment.new(permitted_attributes(Comment)))
    @comment.save
    notice(@comment.valid? ? "Comment posted" : @comment.errors.full_messages.join("; "))
    respond_with(@comment) do |format|
      format.html do
        redirect_back(fallback_location: @comment.post || comments_path)
      end
    end
  end

  def update
    @comment = authorize(Comment.find(params[:id]))
    @comment.update(permitted_attributes(@comment))
    respond_with(@comment, location: post_path(@comment.post_id))
  end

  def destroy
    @comment = authorize(Comment.find(params[:id]))
    @comment.destroy
    respond_with(@comment)
  end

  def hide
    @comment = authorize(Comment.find(params[:id]))
    @comment.hide!
    respond_with(@comment)
  end

  def unhide
    @comment = authorize(Comment.find(params[:id]))
    @comment.unhide!
    respond_with(@comment)
  end

  def warning
    @comment = authorize(Comment.find(params[:id]))
    if params[:record_type] == "unmark"
      @comment.remove_user_warning!
    else
      @comment.user_warned!(params[:record_type], CurrentUser.user)
    end
    @comment_votes = CommentVote.for_comments_and_user([@comment.id], CurrentUser.id)
    html = render_to_string(partial: "comments/partials/show/comment", locals: { comment: @comment, post: nil }, formats: [:html])
    render(json: { html: html, posts: deferred_posts })
  end

  private

  def index_by_post
    tags = params[:tags] || ""
    @posts = Post.tag_match("#{tags} order:comment_bumped").paginate(params[:page], limit: 5, search_count: params[:search])
    comment_ids = @posts.select { |post| post.comments_visible_to?(CurrentUser.user) }.flat_map { |post| post.comments.visible(CurrentUser.user).recent.reverse.map(&:id) } if CurrentUser.id
    @comment_votes = CommentVote.for_comments_and_user(comment_ids || [], CurrentUser.id)
    respond_with(@posts)
  end

  def index_by_comment
    @comments = Comment.visible(CurrentUser.user)
    @comments = @comments.search(search_params(Comment)).paginate(params[:page], limit: params[:limit], search_count: params[:search])
    respond_with(@comments) do |format|
      format.html do
        @comment_votes = CommentVote.for_comments_and_user(@comments.select { |comment| comment.visible_to?(CurrentUser) }.map(&:id), CurrentUser.id)
      end
    end
  end
end
