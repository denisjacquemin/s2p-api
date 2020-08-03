class Recipient < ApplicationRecord
    belongs_to :message
    belongs_to :student
    belongs_to :school
    
    default_scope { includes(:student) }

end