class BorrowCardSearch
  attr_reader :ransack

  def initialize params:, type:, scope: BorrowCard.all
    @params = params
    @scope = scope.joins(:borrow_books).merge(BorrowBook.send(type))
    @ransack = @scope.ransack(@params[:q])
  end

  def call
    @ransack.result.includes(:user).distinct.by_updated_desc
  end
end
