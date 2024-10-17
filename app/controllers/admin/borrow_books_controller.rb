class Admin::BorrowBooksController < AdminController
  before_action :load_borrow_book, except: %i(refresh)

  def show
    @breadcrumb_items = [
      {name: @borrow_book.id}
    ]
  end

  def confirm
    episode = @borrow_book.episode
    if episode.qty.positive? && episode.decrement!(:qty)
      if @borrow_book.confirm!
        send_status_change_email @borrow_book, "confirm"
        flash[:success] = t "message.borrow_books.confirmed"
      else
        episode.increment! :qty
        flash[:danger] = t "message.borrow_books.status_fail"
      end
    else
      flash[:danger] = t "message.borrow_books.qty_insufficient"
    end
    redirect_to borrow_admin_borrow_cards_path
  end

  def cancel
    if @borrow_book.update status: :cancel,
                           reason: params[:borrow_book][:reason]
      send_status_change_email @borrow_book, "cancel"
      flash[:success] = t "message.borrow_books.canceled"
    else
      flash[:danger] = t "message.borrow_books.status_fail"
    end
    redirect_to borrow_admin_borrow_cards_path
  end

  def returned
    episode = @borrow_book.episode
    if episode.increment!(:qty) && @borrow_book.update(status: :returned)
      activate_overdue_user
      send_status_change_email @borrow_book, "returned"
      flash[:success] = t "message.borrow_books.returned"
    else
      flash[:error] = t "message.borrow_books.status_fail"
    end
    redirect_to return_admin_borrow_cards_path
  end

  def lost
    user = @borrow_book.borrow_card.user

    if @borrow_book.lost!
      user.update lost_time: user.lost_time + 1, activated: false
      send_status_change_email @borrow_book, "lost"
      flash[:success] = t "message.borrow_books.lost"
    else
      flash[:error] = t "message.borrow_books.status_fail"
    end

    redirect_to return_admin_borrow_cards_path
  end

  def refresh
    overdue_borrow_books = BorrowBook.confirm.select do |borrow_book|
      borrow_book.due_date < Time.current
    end

    overdue_borrow_books.each do |borrow_book|
      if borrow_book.overdue!
        borrow_book.borrow_card.user.update activated: false
        send_status_change_email borrow_book, "overdue"
      else
        flash[:error] = t "message.borrow_books.status_fail"
      end
    end

    flash[:success] = t "message.borrow_books.refresh_success"
    redirect_to return_admin_borrow_cards_path
  end

  private

  def load_borrow_book
    @borrow_book = BorrowBook.find_by id: params[:id]
    return if @borrow_book

    flash[:danger] = t "message.borrow_books.not_found"
    redirect_to admin_borrow_cards_path
  end

  def activate_overdue_user
    return unless @borrow_book.status_before_last_save.to_sym == :overdue

    @borrow_book.borrow_card.user.update activated: true
  end

  def send_status_change_email borrow_book, new_status
    BorrowBookMailer.enqueue_status_change(
      borrow_book,
      borrow_book.status_before_last_save,
      new_status
    )
  end
end
