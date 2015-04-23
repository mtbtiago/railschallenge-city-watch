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

require "test_helper"

class EmergencyTest < ActiveSupport::TestCase

  def emergency
    @emergency = Emergency.new
  end

  def test_valid
    assert_not emergency.valid?
  end

end
