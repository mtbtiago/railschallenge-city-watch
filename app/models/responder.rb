class Responder < ActiveRecord::Base
  belongs_to :emergency
  validates :type, inclusion: { in: %w(Fire, Police, Medical) }
end
