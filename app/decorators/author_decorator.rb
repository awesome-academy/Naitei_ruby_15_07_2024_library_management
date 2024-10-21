class AuthorDecorator < Draper::Decorator
  include ItemCardDecorator

  delegate_all
end
