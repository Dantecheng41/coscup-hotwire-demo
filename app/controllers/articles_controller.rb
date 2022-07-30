class ArticlesController < ApplicationController
  include ActionView::RecordIdentifier # include for dom_id
  before_action :build_article,  only: %w[index new]
  before_action :find_article,   only: %w[edit update destroy]
  before_action :page_articles,  only: %w[index edit create destroy]
  before_action :render_article, only: %w[index]

  def index; end

  def new; end

  def create
    @article = Article.new(post_params)

    if @article.save
      # Render turbo_stream in erb
      render action: :create_success
      
      # Broadcast
      # Turbo::StreamsChannel.broadcast_update_to(
        #   :broadcast_article,
        #   target: "page-1",
        #   partial: 'articles/per_page', locals: { articles: @articles }
        # )
      else
        # Render turbo_stream in controller
        render turbo_stream: turbo_stream.update("new_article", partial: 'form', locals: { article: @article })
    end
  end

  def edit; end

  def update
    if @article.update(post_params)
      render turbo_stream: turbo_stream.replace(dom_id(@article), partial: 'article', locals: { article: @article, page: params[:page] })

      # Broadcast
      # Turbo::StreamsChannel.broadcast_replace_to(
      #   :broadcast_article,
      #   target: dom_id(@article),
      #   partial: 'articles/article', locals: { article: @article, page: params[:page] }
      # )
    else
      render :edit
    end
  end

  def destroy
    if @article.destroy
      render action: :destroy_success

      # Broadcast
      # Turbo::StreamsChannel.broadcast_update_to(
      #   :broadcast_article,
      #   target: "page-#{@page}",
      #   partial: 'articles/per_page', locals: { articles: @articles }
      # )
    else
      # Use 303 for get method
      redirect_to articles_path, status: :see_other
    end
  end

  def frames_demo; end

  private

  def build_article
    @article = Article.new
  end

  def find_article
    @article = Article.find(params[:id])
  end

  def page_articles
    @page = params[:page]&.to_i || 1
    @articles = Article.order(id: :desc).page @page
  end

  def post_params
    params.require(:article).permit(:title, :content)
  end

  # Back Link render some article dom
  def render_article
    return if params[:id].nil?

    @article = Article.find(params[:id])
    render turbo_stream: turbo_stream.replace(dom_id(@article), partial: 'article', locals: { article: @article, page: @page }) if params[:id]
  end
end
