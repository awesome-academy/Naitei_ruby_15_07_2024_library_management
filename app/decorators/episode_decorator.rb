class EpisodeDecorator < Draper::Decorator
  include ItemCardDecorator

  delegate_all
end
