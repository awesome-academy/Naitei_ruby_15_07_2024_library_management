class BorrowBookSearch
  def initialize params:, borrow_card:, type:
    @params = params
    @scope = borrow_card.borrow_books.send(type)
  end

  def call
    ransack.result.includes(borrow_card: :user,
                            episode: {book: []}).by_updated_desc
  end

  private

  def ransack
    @scope.ransack(@params[:q])
  end
end
