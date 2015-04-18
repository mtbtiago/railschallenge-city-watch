class Emergency < ActiveRecord::Base
  has_many :responders
  validates :fire_severity, numericality: { only_integer: true, grather_than: 0 }
  validates :police_severity, numericality: { only_integer: true, grather_than: 0 }
  validates :medical_severity, numericality: { only_integer: true, grather_than: 0 }
end
