class EmergenciesController < ApplicationController
  def new
    render_fail_response
  end

  def create
    if params[:emergency][:id]
      render json: build_invalid_param(:id), status: 422
    elsif params[:emergency][:resolved_at]
      render json: build_invalid_param(:resolved_at), status: 422
    else
      begin
        emergency = Emergency.create(params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity))
        if emergency.valid?
          render json: build_emergence(emergency), status: 201
        else
          render json: build_error(emergency), status: 422
        end
      rescue ActiveRecord::RecordNotUnique
        render json: build_key_violation, status: 422
      end
    end
  end

  def index
    render json: build_emergencies_list(Emergency.all), status: 200
  end

  def show
    emergency = Emergency.find_by(code: params[:id])
    if emergency.nil?
      head :not_found
    else
      render json: build_emergence(emergency)
    end
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

  def build_emergencies_list(list)
    result = {:emergencies => []}
    i = 0
    list.each do |emergency|
      result[:emergencies][i] = Hash.new({
        code: emergency.code,
        fire_severity: emergency.fire_severity,
        police_severity: emergency.police_severity,
        medical_severity: emergency.medical_severity
        })
      i += 1
    end
    result
  end

  def build_invalid_param(param)
    {:message => "found unpermitted parameter: #{param}"}
  end

  def build_key_violation
    {:message => {code: ['has already been taken']}}
  end

  def build_error(emergency)
    {:message => emergency.errors.messages}
  end

  def build_emergence(emergency)
    result = {:emergency => {}}
    result[:emergency][:code] = emergency.code
    result[:emergency][:fire_severity] = emergency.fire_severity
    result[:emergency][:police_severity] = emergency.police_severity
    result[:emergency][:medical_severity] = emergency.medical_severity
    result
  end

  def render_fail_response
    result = {}
    result[:message] = 'page not found'
    render json: result, :status => :not_found
  end
end
