require "pagy/extras/bootstrap"
Pagy::DEFAULT[:limit] = Settings.page

require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

require "pagy/extras/array"
