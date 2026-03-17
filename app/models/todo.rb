class Todo < ApplicationRecord
  validates :title, presence: true

  scope :completed, -> { where(completed: true) }
  scope :active, -> { where(completed: false) }
end
