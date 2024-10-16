class Admin::AuthorsController < AdminController
  before_action :load_author, only: %i(show edit update destroy)

  def index
    @q = Author.ransack(params[:q])
    @pagy, @authors = pagy(@q.result)
    @breadcrumb_items = [{name: t(".index.title")}]
  end

  def show
    @breadcrumb_items = [
      {name: t(".index.title"), url: admin_authors_path},
      {name: @author.name}
    ]
  end

  def new
    @form = AuthorForm.new(Author.new)
    @breadcrumb_items = [
      {name: t(".index.title"), url: admin_authors_path},
      {name: t(".new.title")}
    ]
  end

  def create
    @form = AuthorForm.new(Author.new, author_params)

    if @form.save
      flash[:success] = t "message.authors.created"
      redirect_to admin_author_path(@form.author), status: :see_other
    else
      flash[:danger] = t "message.authors.create_fail"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = AuthorForm.new(@author)
    @breadcrumb_items = [
      {name: t(".index.title"), url: admin_authors_path},
      {name: @author.name, url: admin_author_path(@author)},
      {name: t(".edit.title")}
    ]
  end

  def update
    @form = AuthorForm.new(@author, author_params)

    if @form.save
      flash[:success] = t "message.authors.updated"
      redirect_to admin_author_path(@form.author), status: :see_other
    else
      flash[:danger] = t "message.authors.update_fail"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @author.destroy
      flash[:success] = t "message.authors.deleted"
    else
      flash[:danger] = t "message.authors.delete_fail"
    end
    redirect_to admin_authors_path, status: :see_other
  end

  private

  def author_params
    params.require(:author).permit Author::AUTHOR_PARAMS
  end

  def load_author
    @author = Author.find_by(id: params[:id])
    return if @author

    flash[:danger] = t "message.authors.not_found"
    redirect_to root_url
  end
end
