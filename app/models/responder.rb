# == Schema Information
#
# Table name: responders
#
#  id             :integer          not null, primary key
#  emergency_code :integer
#  type           :string
#  name           :string
#  capacity       :integer
#  on_duty        :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Responder < ActiveRecord::Base
  belongs_to :emergency
  validates :type, presence: true # , inclusion: { in: %w(Fire Police Medical) }
  validates :name, presence: true
  validates :capacity, presence: true
  validates_numericality_of :capacity,
                            greater_than_or_equal_to: 1, less_than_or_equal_to: 5,
                            message: 'is not included in the list'

  self.inheritance_column = 'inheritance_col'

  scope :fire, -> { where(type: 'Fire') }
  scope :police, -> { where(type: 'Police') }
  scope :medical, -> { where(type: 'Medical') }

  scope :on_duty, -> { where(on_duty: true) }
  scope :emergency_free, -> { where(emergency_code: nil) }

  def assign_emergency(emergency)
    if emergency.nil?
      update_column('emergency_code', nil)
    else
      update_column('emergency_code', emergency.id)
    end
  end
end
