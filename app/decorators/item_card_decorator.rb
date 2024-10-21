module ItemCardDecorator
  def link_path
    if is_a?(Episode)
      h.book_episode_path(book, self)
    else
      h.author_path(self)
    end
  end

  def image_tag
    image = is_a?(Episode) ? thumb : h.author_image(self)
    h.image_tag(image)
  end

  def display_name
    if is_a?(Episode) && name.present?
      name
    else
      is_a?(Episode) ? book.name : name
    end
  end

  def category_name
    is_a?(Episode) ? book.name : nil
  end

  def explore_link
    h.link_to(h.t("views.favorites.explore"), link_path)
  end
end
