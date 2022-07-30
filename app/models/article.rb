class Article < ApplicationRecord
  validates :title, :content, presence: true

  paginates_per 12
end
