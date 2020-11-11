class RequestsController < PublicController
  RECAPTCHA_THRESHOLD = ENV['RECAPTCHA_THRESHOLD_REQUEST']&.to_f

  include Recaptchable

  skip_before_action :authorize_current_volunteer, only: [:index, :new, :need_volunteers, :create, :new_request_accepted]
  before_action :load_request, only: %i[confirm_interest accept]

  def index
    if params[:request_geo_coord_y].present? && params[:request_geo_coord_x].present?
      search = Request.for_web.ransack(search_nearby: encoded_coordinates, order: :distance_meters_asc)
      @requests = search.result.decorate
      @closest_request_km = @requests.first.distance_km
    else
      @requests = Request.for_web_preloaded.decorate
    end

    @all_requests_count  = Request.for_web.count
  end

  def new
    @request = Request.web.new.decorate
  end

  def need_volunteers
  end

  def create
    @request = Request.web.new(request_params).decorate
    merge_non_model_fields!

    address  = @request.build_address address_with_coordinate

    if registration_valid && @request.save!
      redirect_to new_request_accepted_path
    else
      render :new
    end
  end

  def new_request_accepted
  end

  def confirm_interest
    redirect_to(requests_path) && return unless request_permissible
  end

  def accept
    redirect_to(requests_path) && return unless request_permissible

    @requested_volunteer = RequestedVolunteer.find_by(volunteer: @current_volunteer, request_id: params[:request_id])

    if @requested_volunteer&.accepted?
      flash[:warn] = 'Tuto žádost už jste jednou přijal/a.'

      redirect_to(requests_path) && return
    else
      add_or_update_requested_volunteer
      log_acceptance_message
    end

    redirect_to(request_accepted_path) && return
  end

  def request_accepted
    @all_requests_count  = Request.for_web.count
  end


  private

  def merge_non_model_fields!
    @request.text = @request.text + ". Covid pozitivní v zařízení: #{params[:request][:covid_presence] == '1' ? 'ano' : 'ne'}"
  end

  def encoded_coordinates
    format '%{lat}#%{lon}', lat: params[:request_geo_coord_y], lon: params[:request_geo_coord_x]
  end

  def add_or_update_requested_volunteer
    # If missing, volunteer is created in notified state which is later updated by ReceivedProcessorJob
    @requested_volunteer ||= RequestedVolunteer.find_or_create_by(volunteer: @current_volunteer, request: @request)
    @requested_volunteer.notified!
  end

  def load_request
    @request = Request.assignable.find_by(id: params[:request_id].to_i)&.decorate
  end

  def registration_valid
    resolve_recaptcha(:new_request, @request, RECAPTCHA_THRESHOLD) && @request.valid?
  end

  def request_params
    params.require(:request).permit(:text, :subscriber, :subscriber_phone, :subscriber_organisation, :required_volunteer_count, :is_public)
  end

  def address_params
    params.require(:request).permit(
      :street, :city, :street_number, :city_part, :postal_code, :country_code, :geo_entry_id, :geo_unit_id, :geo_coord_x, :geo_coord_y
    )
  end

  def address_with_coordinate
    coordinate = Geography::Point.from_coordinates latitude: address_params[:geo_coord_y].to_d,
                                                   longitude: address_params[:geo_coord_x].to_d
    address_params.except(:geo_coord_x, :geo_coord_y).merge(coordinate: coordinate,
                                                            geo_provider: 'google_places',
                                                            default: true)
  end

  def log_acceptance_message
    message = Message.create! volunteer: @current_volunteer,
                              request_id: params[:request_id],
                              direction: :incoming,
                              state: :received,
                              channel: :web,
                              text: 'Ano'

    Messages::ReceivedProcessorJob.perform_later message
  end

  def request_permissible
    return true if @request.present?

    flash[:error] = 'Tuto žádost nelze přijmout.'
    Raven.capture_exception StandardError.new('Request cannot be found')
    false
  end
end