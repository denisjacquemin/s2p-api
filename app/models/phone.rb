class Phone < ApplicationRecord
  belongs_to :student, inverse_of: :phones
end
