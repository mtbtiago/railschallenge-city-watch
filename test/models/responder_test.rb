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

require "test_helper"

class ResponderTest < ActiveSupport::TestCase

  def responder
    @responder = Responder.new
  end

  def test_valid
    assert_not responder.valid?
  end

end
