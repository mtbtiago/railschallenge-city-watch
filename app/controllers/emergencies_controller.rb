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
          update_responders(emergency)
          render json: build_emergency(emergency), status: :created
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
      render json: build_emergency(emergency)
    end
  end

  def edit
    render_fail_response
  end

  def update
    if params[:emergency][:code]
      render json: build_invalid_param(:code), status: :unprocessable_entity
    else
      emergency = Emergency.find_by(code: params[:id])
      if emergency.nil?
        head :not_found
      else
        begin
          must_clear_responders = emergency.resolved_at.nil? && !params[:emergency][:resolved_at].nil?
          # binding.pry
          emergency.update(params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity, :resolved_at))
          if emergency.valid?
            if must_clear_responders
              clear_responders(emergency)
            end
            render json: build_emergency(emergency), status: :created
          else
            render json: build_error(emergency), status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotUnique
          render json: build_key_violation, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    render_fail_response
  end

  private

  def update_responders(emergency)
    severity = {}
    EMERGENCY_TYPE.each do |k,v|
      severity[k] = emergency.read_attribute(k.to_s+'_severity')
      if severity[k] > 0
        ideal_responder = search_ideal_responder(severity[k],v)
        if ideal_responder
          ideal_responder.assign_emergency(emergency)
          severity[k] = 0
        else
          Responder.emergency_free.on_duty.where(type: v).order(capacity: :desc).each do |responder|
            if responder.capacity >= severity[k]
              responder.assign_emergency(emergency)
              severity[k] = 0
              break
            else
              responder.assign_emergency(emergency)
              severity[k] -= responder.capacity
              if severity[k] <= 0
                break
              end
            end
          end
        end
      end # severity[k] > 0
    end
    is_full_response = true
    severity.each do |k,v|
      if severity[k] > 0
        is_full_response = false
        break
      end
    end
    emergency.update_column('full_response',is_full_response)
  end

  def search_ideal_responder(capacity,type_name)
    Responder.emergency_free.on_duty.where(type: type_name, capacity: capacity).first
  end

  def clear_responders(emergency)
    emergency.responders.each do |responder|
      responder.assign_emergency(nil)
    end
  end

  def build_emergency(emergency, options = {with_prefix: true})
    result = emergency.as_json
    result[:responders] = emergency.responders.map {|responder| responder.name}
    if options[:with_prefix] == true
      {emergency: result}
    else
      result
    end
  end

  def build_emergencies_list(list)
    result = {emergencies: list.map { |emergency| build_emergency(emergency, with_prefix: false)}}
    result[:full_responses] = [
      Emergency.full_response.count,
    Emergency.all.count]
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

  def render_fail_response
    result = {}
    result[:message] = 'page not found'
    render json: result, :status => :not_found
  end
end
