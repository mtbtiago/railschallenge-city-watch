require "test_helper"

class EmergencyTest < ActiveSupport::TestCase

  def emergency
    @emergency = Emergency.new
  end

  def test_valid
    assert_not emergency.valid?
  end

end
