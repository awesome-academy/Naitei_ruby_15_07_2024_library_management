class EpisodesController < ApplicationController
  before_action :set_book, :set_episode, only: %i(show add_to_cart)
  before_action :redirect_unless_signed_in,
                :validate_conditions, only: :add_to_cart
  before_action :load_seach_values, only: :all
  def show; end

  def all
    @q = params[:episode_name]

    @search_results = Episode.search_episodes(
      name: params[:episode_name],
      book_id: params[:book_id],
      publisher_id: params[:publisher_id],
      author_id: params[:authors_id],
      category_id: params[:categories_id]
    )

    @pagy, @episodes = pagy_array(
      @search_results,
      limit: Settings.controllers.episodes.all.per_page
    )
  end

  def add_to_cart
    @episode = Episode.find params[:id]
    cart_item = current_user.carts.create episode: @episode
    if cart_item.persisted?
      flash[:success] = t "controllers.episodes.success"
    else
      flash[:error] = t "controllers.episodes.error_save"
    end
    redirect_back(fallback_location: book_episode_path(@book, @episode))
  end

  private
  def load_seach_values
    @books = Book.sorted_by_name
    @cats = Category.sorted_by_name
    @publishers = Publisher.sorted_by_name
    @authors = Author.sorted_by_name
  end

  def set_book
    @book = Book.find params[:book_id]
  end

  def set_episode
    @episode = @book.episodes.find params[:id]
    @ratings = @episode.ratings.recent.where.not(user: current_user)
    @user_rating = @episode.ratings.find_by(user: current_user)
  end

  def validate_conditions
    return if current_user.can_borrow_episode? @episode

    flash[:error] = current_user.errors.full_messages
    redirect_back(fallback_location: root_path)
  end

  def search_params
    params.permit Episode::SEARCH_PARAMS
  end
end
