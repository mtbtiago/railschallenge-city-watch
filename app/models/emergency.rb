# == Schema Information
#
# Table name: emergencies
#
#  id               :integer          not null, primary key
#  code             :string
#  fire_severity    :integer
#  police_severity  :integer
#  medical_severity :integer
#  full_response    :boolean
#  resolved_at      :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Emergency < ActiveRecord::Base
  has_many :responders, foreign_key: :emergency_code

  validates :code, presence: true

  validates :fire_severity, presence: true
  validates :police_severity, presence: true
  validates :medical_severity, presence: true

  validates_numericality_of :fire_severity, greater_than_or_equal_to: 0
  validates_numericality_of :police_severity, greater_than_or_equal_to: 0
  validates_numericality_of :medical_severity, greater_than_or_equal_to: 0

  scope :full_response, -> { where(full_response: true) }

end
