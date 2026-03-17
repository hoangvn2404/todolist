class Todo < ApplicationRecord
  validates :title, presence: true

  scope :completed, -> { where(completed: true) }
  scope :active, -> { where(completed: false) }
  scope :by_filter, ->(filter) {
    case filter
    when "active" then active
    when "completed" then completed
    else all
    end
  }
end
