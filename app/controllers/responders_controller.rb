class RespondersController < ApplicationController
  def new
    render_fail_response
  end

  def create
    # info about status codes
    # http://apidock.com/rails/ActionController/Base/render#254-List-of-status-codes-and-their-symbols
    if params[:responder][:id]
      render json: build_invalid_param(:id), status: :unprocessable_entity
    elsif params[:responder][:emergency_code]
      render json: build_invalid_param(:emergency_code), status: :unprocessable_entity
    elsif params[:responder][:on_duty]
      render json: build_invalid_param(:on_duty), status: :unprocessable_entity
    else
      begin
        responder = Responder.create(params.require(:responder).permit(:type, :name, :capacity, :on_duty))
        if responder.valid?
          render json: build_responser(responder), status: :created
        else
          render json: build_error(responder), status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotUnique
        render json: build_key_violation, status: :unprocessable_entity
      end
    end
  end

  def index
    if params[:show] == 'capacity'
      render json: build_capacity
    else
      render json: build_responders_list(Responder.all), status: :ok
    end
  end

  def show
    responder = Responder.find_by(name: params[:id])
    if responder.nil?
      head :not_found
    else
      render json: build_responser(responder)
    end
  end

  def edit
    render_fail_response
  end

  def update
    if params[:responder][:emergency_code]
      render json: build_invalid_param(:emergency_code), status: :unprocessable_entity
    elsif params[:responder][:type]
      render json: build_invalid_param(:type), status: :unprocessable_entity
    elsif params[:responder][:name]
      render json: build_invalid_param(:name), status: :unprocessable_entity
    elsif params[:responder][:capacity]
      render json: build_invalid_param(:capacity), status: :unprocessable_entity
    else
      responder = Responder.find_by(name: params[:id])
      if responder.nil?
        head :not_found
      else
        begin
          responder.update(params.require(:responder).permit(:type, :name, :capacity, :on_duty))
          if responder.valid?
            render json: build_responser(responder), status: :created
          else
            render json: build_error(responder), status: :unprocessable_entity
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

  def build_capacity
    result = {}
    EMERGENCY_TYPE.each do |_k, v|
      result[v] = []
      # capacity of all responders in the city, by type
      result[v] << Responder.where(type: v).sum(:capacity)
      # capacity of all "available" responders (not currently assigned to an emergency)
      result[v] << Responder.emergency_free.where(type: v).sum(:capacity)
      # capacity of all "on-duty" responders, including those currently handling emergencies
      result[v] << Responder.on_duty.where(type: v).sum(:capacity)
      # capacity of all "available, AND on-duty" responders (ones currently available to jump into a new emergency)
      result[v] << Responder.on_duty.emergency_free.where(type: v).sum(:capacity)
    end
    { capacity: result }
  end

  def build_responders_list(list)
    result = list.map { |responder| build_responser(responder, with_prefix: false) }
    { responders: result }
  end

  def build_invalid_param(param)
    { message: "found unpermitted parameter: #{param}" }
  end

  def build_key_violation
    { message: { name: ['has already been taken'] } }
  end

  def build_error(responder)
    { message: responder.errors.messages }
  end

  def build_responser(responder, options = { with_prefix: true })
    result = {
      emergency_code: responder.emergency_code,
      type: responder.type,
      name: responder.name,
      capacity: responder.capacity,
      on_duty: responder.on_duty
    }
    if options[:with_prefix] == true
      { responder: result }
    else
      result
    end
  end

  def render_fail_response
    result = {}
    result[:message] = 'page not found'
    render json: result, status: :not_found
  end
end
