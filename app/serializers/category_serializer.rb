class CategorySerializer < ActiveModel::Serializer
  attributes %i(id name parent_id created_at updated_at)
end
