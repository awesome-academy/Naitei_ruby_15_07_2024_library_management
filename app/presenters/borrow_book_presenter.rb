class BorrowBookPresenter
  attr_reader :borrow_book

  def initialize borrow_book
    @borrow_book = borrow_book
  end

  def user
    @borrow_book.borrow_card.user.name
  end

  def book
    @borrow_book.episode.book.name
  end

  def episode
    @borrow_book.episode.name
  end

  def lost_reason
    @borrow_book.lost_reason
  end

  def localized_status
    @borrow_book.localized_status
  end

  def start_time
    return unless @borrow_book.status != "pending"

    @borrow_book.borrow_card.start_time.strftime(Settings.date_format)
  end

  def due_date
    return unless @borrow_book.status != "pending"

    @borrow_book.borrow_card.due_date.strftime(Settings.date_format)
  end

  def created_at
    return unless @borrow_book.status == "pending"

    @borrow_book.created_at.strftime(Settings.date_format)
  end

  def status_badge_class
    {
      pending: "badge bg-secondary",
      confirm: "badge bg-primary",
      returned: "badge bg-success",
      overdue: "badge bg-warning",
      lost: "badge bg-danger",
      cancel: "badge bg-dark"
    }[@borrow_book.status.to_sym]
  end

  def formatted_status
    localized_status.upcase
  end
end
