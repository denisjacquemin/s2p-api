class School < ApplicationRecord

  has_many :users
  has_many :students
  has_many :messages
end
