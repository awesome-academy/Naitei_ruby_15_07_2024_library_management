module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: {number_of_shards: 1} do
      mappings dynamic: false do
        indexes :name, type: "text"
        indexes :book_id, type: "keyword"
        indexes :publisher_id, type: "keyword"
        indexes :author_id, type: "keyword"
        indexes :category_id, type: "keyword"
      end
    end

    def as_indexed_json _options = {}
      {
        name:,
        book_id:,
        publisher_id: book&.publisher_id,
        author_id: book&.author_ids,
        category_id: book&.category_ids
      }
    end
  end
end
