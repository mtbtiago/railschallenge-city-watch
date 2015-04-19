class Emergency < ActiveRecord::Base
  has_many :responders
  
  validates :code, presence: true

  validates :fire_severity, presence: true 
  validates :police_severity, presence: true 
  validates :medical_severity, presence: true 

  validates_numericality_of :fire_severity, greater_than_or_equal_to: 0
  validates_numericality_of :police_severity, greater_than_or_equal_to: 0
  validates_numericality_of :medical_severity, greater_than_or_equal_to: 0

end
