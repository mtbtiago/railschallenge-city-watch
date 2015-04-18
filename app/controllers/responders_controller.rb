class RespondersController < ApplicationController
  def create
    render_fail_response
  end

  def show
    emergency = Emergency.find_by(code: params[:name])

    result = {:emergency => {}}
    result[:emergency][:code] = emergency.code
    result[:emergency][:fire_severity] = emergency.fire_severity
    result[:emergency][:police_severity] = emergency.police_severity
    result[:emergency][:medical_severity] = emergency.medical_severity

    render json: result
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def edit
    render_fail_response
  end

  def update
    render_fail_response
  end

  def destroy
    render_fail_response
  end

  private

  def render_fail_response
    result = {}
    result[:message] = 'page not found'
    # head :not_found
    render json: result
  end
end
