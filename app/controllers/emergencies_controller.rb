class EmergenciesController < ApplicationController
  def new
    render_fail_response
  end

  def create
    # info about status codes
    # http://apidock.com/rails/ActionController/Base/render#254-List-of-status-codes-and-their-symbols
    if params[:emergency][:id]
      render json: build_invalid_param(:id), status: :unprocessable_entity
    elsif params[:emergency][:resolved_at]
      render json: build_invalid_param(:resolved_at), status: :unprocessable_entity
    else
      begin
        emergency = Emergency.create(params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity))
        if emergency.valid?
          render json: build_emergence(emergency), status: :created
        else
          render json: build_error(emergency), status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        render json: build_key_violation, status: :unprocessable_entity
      end
    end
  end

  def index
    render json: build_emergencies_list(Emergency.all), status: :ok
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
    list.each do |emergency|
      result[:emergencies] << emergency.as_json
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
    {emergency: emergency.as_json}
  end

  def render_fail_response
    result = {}
    result[:message] = 'page not found'
    render json: result, :status => :not_found
  end
end
