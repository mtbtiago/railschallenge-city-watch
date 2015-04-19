class EmergenciesController < ApplicationController
  def new
    render_fail_response
  end

  def create
    emergency = Emergency.create(
      params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity))

    result = {:emergency => {}}
    result[:emergency][:code] = emergency.code
    result[:emergency][:fire_severity] = emergency.fire_severity
    result[:emergency][:police_severity] = emergency.police_severity
    result[:emergency][:medical_severity] = emergency.medical_severity

    render json: result, status: 201
  end

  def show
    # puts "kkkkk #{params[:id]}"


    emergency = Emergency.find_by(code: params[:id])

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
    render json: result, :status => :not_found
  end
end
