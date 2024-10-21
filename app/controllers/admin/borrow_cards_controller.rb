class Admin::BorrowCardsController < AdminController
  before_action :load_borrow_card, only: %i(borrow return history)

  def borrow_index
    search = BorrowCardSearch.new(params:, type: :pending_requests)
    @q = search.ransack
    @borrow_cards = search.call
    @pagy, @borrow_cards = pagy(@borrow_cards, items: Settings.page)
    @breadcrumb_items = [{name: t(".borrow_index.title")}]
  end

  def return_index
    search = BorrowCardSearch.new(params:, type: :return_requests)
    @q = search.ransack
    @borrow_cards = search.call
    @pagy, @borrow_cards = pagy(@borrow_cards, items: Settings.page)
    @breadcrumb_items = [{name: t(".return_index.title")}]
  end

  def history_index
    search = BorrowCardSearch.new(params:, type: :history_requests)
    @q = search.ransack
    @borrow_cards = search.call
    @pagy, @borrow_cards = pagy(@borrow_cards, items: Settings.page)
    @breadcrumb_items = [{name: t(".history_index.title")}]
  end

  def borrow
    search = BorrowBookSearch.new(params:, borrow_card: @borrow_card,
                                  type: :pending)
    @borrow_books = search.call
    @pagy, @borrow_books = pagy(@borrow_books, items: Settings.page)
    @presenters = @borrow_books.map do |borrow_book|
      BorrowBookPresenter.new borrow_book
    end
    @breadcrumb_items = [
      {name: t(".borrow_index.title"), url: borrow_admin_borrow_cards_path},
      {name: @borrow_card.id}
    ]
  end

  def return
    search = BorrowBookSearch.new(params:, borrow_card: @borrow_card,
                                  type: :return_requests)
    @borrow_books = search.call
    @pagy, @borrow_books = pagy(@borrow_books, items: Settings.page)
    @presenters = @borrow_books.map do |borrow_book|
      BorrowBookPresenter.new borrow_book
    end
    @breadcrumb_items = [
      {name: t(".return_index.title"), url: return_admin_borrow_cards_path},
      {name: @borrow_card.id}
    ]
  end

  def history
    search = BorrowBookSearch.new(params:, borrow_card: @borrow_card,
                                  type: :history_requests)
    @borrow_books = search.call
    @pagy, @borrow_books = pagy(@borrow_books, items: Settings.page)
    @presenters = @borrow_books.map do |borrow_book|
      BorrowBookPresenter.new borrow_book
    end
    @breadcrumb_items = [
      {name: t(".history_index.title"), url: history_admin_borrow_cards_path},
      {name: @borrow_card.id}
    ]
  end

  private

  def load_borrow_card
    @borrow_card = BorrowCard.find_by id: params[:id]
    return if @borrow_card

    flash[:danger] = t "message.borrow_cards.not_found"
    redirect_to admin_borrow_cards_path
  end
end
