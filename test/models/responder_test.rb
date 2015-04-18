require "test_helper"

class ResponderTest < ActiveSupport::TestCase

  def responder
    @responder = Responder.new
  end

  def test_valid
    assert_not responder.valid?
  end

end
