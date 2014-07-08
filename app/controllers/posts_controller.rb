class PostsController < ApplicationController
  # Add a couple of additional response formats.
  #
  respond_to :json, only: [:show, :index]
  respond_to :atom, only: [:index, :tagged]
  respond_to :js, only: [:index]

  load_and_authorize_resource :post,
    find_by: :slug,
    through: :current_site

  # Hook up background processors to specific actions.
  #
  after_filter :fetch_referenced_posts, only: [:create, :update]
  after_filter :push_to_local_followers, only: [:create, :update]

  def index
    @posts = @posts.latest.includes(:user)

    respond_with @posts do |format|
      format.json do
        # updated_since parameter
        if params[:updated_since].present?
          @posts = @posts.where('edited_at >= ?', Time.at(params[:updated_since].to_i).to_datetime)
        end

        # always limit posts to a maximum of 100
        @posts = @posts.limit(100)
      end
    end
  end

  def tagged
    @tags = params.require(:tag).gsub(/\+/, ' ').split.map(&:downcase)
    @all = params[:all].present?

    @posts = if @all
      Post.latest.tagged_with(@tags)
    else
      @posts.latest.tagged_with(@tags)
    end

    respond_with @posts
  end

  def day
    @date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @posts = @posts.latest.on_date(@date)
    @page_title = t('.page_title', date: l(@date, format: :long))

    respond_with @posts
  end

  def show
    canonical_path = post_path(@post, format: params[:format])
    if request.path != canonical_path
      redirect_to canonical_path, status: 301 and return
    end

    @page_title = @post.to_title

    respond_with @post do |format|
      format.md { render text: @post.body }
    end
  end

  def new
    @post.referenced_guid = params[:referenced_guid]
    respond_with @post
  end

  def create
    @post.save

    if @post.valid?
      # save the post
      @post.update_attributes(url: post_url(@post))

      # send pings for this post
      PostPinger.new.async.perform(@post)

      # add post to my own timeline
      current_site.add_to_timeline(@post)
    end

    respond_with @post, location: :network
  end

  def edit
    respond_with @post
  end

  def update
    @post.update_attributes(post_params)
    @post.edited_at = Time.now

    if @post.valid?
      @post.update_attributes(url: post_url(@post))
      PostPinger.new.async.perform(@post)
    end

    respond_with @post
  end

  def destroy
    @post.destroy
    respond_with @post
  end

private

  def post_params
    params.require(:post).permit(:body, :referenced_guid)
  end

  def fetch_referenced_posts
    if @post.referenced_guid.present?
      # Fetch referenced post
      PostFetcher.new.async.perform(@post.referenced_guid.with_http)

      # Ping referenced site with new post
      domain, slug = @post.referenced_guid.split '/'
      UserPinger.new.async.perform(domain, url: @post.url)
    end
  end

  def push_to_local_followers
    TimelineManager.new.async.add_post_to_local_timelines(@post)
  end
end
