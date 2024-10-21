class BorrowPolicy
  def initialize user, episode = nil
    @user = user
    @episode = episode
    @errors = []
  end

  def can_borrow_episode?
    clear_errors
    validate_activation
    validate_blacklist
    validate_episode_in_cart
    validate_episode_quantity
    validate_borrowing_limit

    errors.empty?
  end

  def can_checkout_cart?
    clear_errors
    validate_activation
    validate_blacklist

    errors.empty?
  end

  attr_reader :errors

  private

  def clear_errors
    @errors.clear
  end

  def validate_activation
    return if @user.activated

    @errors << I18n.t("controllers.episodes.error_active")
  end

  def validate_blacklist
    return unless @user.blacklisted

    @errors << I18n.t("controllers.episodes.error_blacklist")
  end

  def validate_episode_in_cart
    return unless @user.carts.exists? episode: @episode

    @errors << I18n.t("controllers.episodes.error_exists")
  end

  def validate_episode_quantity
    return unless @episode && @episode.qty < 1

    @errors << I18n.t("controllers.episodes.error_qty")
  end

  def validate_borrowing_limit
    return unless @user.currently_borrowing_episodes_count >= Settings.max_book

    @errors << I18n.t("controllers.episodes.error_max")
  end
end
