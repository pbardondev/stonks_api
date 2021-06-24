# frozen_string_literal: true

# Price used to represent a single daily historical entry
class Price < ApplicationRecord
  validates :open, presence: true
  validates :close, presence: true
  validates :high, presence: true
  validates :low, presence: true
  validates :volume, presence: true
  validates :date, presence: true

  belongs_to :company

  # Supports default view window of 30 days of historical price information
  scope :recent, -> { where('date > ?', 30.days.ago) }
end
