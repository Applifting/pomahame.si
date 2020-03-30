# frozen_string_literal: true

ActiveAdmin.register Request, as: 'OrganisationRequest' do
  decorate_with RequestDecorator
  config.sort_order = 'state_asc'

  menu priority: 2

  permit_params :closed_note, :coordinator_id, :created_by_id, :fullfillment_date, :organisation_id,
                :required_volunteer_count, :state, :subscriber, :subscriber_phone, :text, :block_volunteer_until,
                :long_text,
                address_attributes: %i[street_number street city city_part postal_code country_code
                                       latitude longitude geo_entry_id]

  # Filters
  filter :text
  filter :required_volunteer_count
  filter :state, as: :select, collection: Request.states
  filter :organisation, as: :select, collection: proc { Organisation.user_group_organisations(current_user) }

  # Scopes
  scope :user_organisation_requests, default: true do |scope|
    scope.not_closed
         .with_organisations(current_user.coordinating_organisations.pluck(:id))
  end
  scope :closed
  scope :all

  # Controller
  controller do
    def update
      super do |success, _failure|
        notify_volunteers_updated if success.present?
      end
    end

    def scoped_collection
      super.includes(:address)
    end

    private

    def notify_volunteers_updated
      return if resource.volunteers.fcm_active.empty?

      Push::Requests::UpdaterService.new(resource.id, resource.volunteers.fcm_active).perform
    end
  end

  index do
    id_column
    column :state
    column :text
    column :address
    column :accepted_volunteers_count do |resource|
      "#{resource.requested_volunteers.accepted.count} / #{resource.required_volunteer_count}"
    end
    column :fullfillment_date
    column :coordinator
    column :state_last_updated_at
    column :organisation if current_user.admin?
    actions
  end

  show do
    div style: 'width: 600px' do
      panel resource.text do
        attributes_table_for resource do
          row :address
          row :fullfillment_date
        end
      end
      panel '' do
        attributes_table_for resource do
          row :state do |request|
            best_in_place request, :state, as: :select,
                                           collection: I18n.t('activerecord.attributes.request.states'),
                                           url: admin_organisation_request_path(resource)
          end
          row :required_volunteer_count
          row :block_volunteer_until
          row :coordinator do
            if can?(:update, resource)
              best_in_place resource, :coordinator_id, as: :select,
                                                       collection: current_user.organisation_colleagues.map { |u| [u.id, u.to_s] },
                                                       url: admin_organisation_request_path(resource)
            else
              resource.coordinator
            end
          end
          row :state_last_updated_at
          row :created_at
          row :creator
          row :organisation
        end
      end
      panel 'Osobní údaje' do
        if can?(:manage, resource)
          attributes_table_for resource do
            row :subscriber
            row :subscriber_phone
            row :long_text
          end
        else
          para 'Tyto údaje může zobrazit pouze koordinátor organizace, která poptávku spravuje.', class: :small
        end
      end
      panel nil do
        render partial: 'volunteers' if can?(:manage, resource)
      end
    end
    active_admin_comments
  end

  form do |f|
    javascript_for(*location_autocomplete(callback: 'InitRequestAutocomplete'))

    f.inputs 'Poptávka služby' do
      f.input :text, as: :text, hint: 'Tento popis dostane dobrovolník do aplikace / SMS'
      f.input :required_volunteer_count, input_html: { value: object.required_volunteer_count.nil? ? 1 : resource.required_volunteer_count }
      f.input :fullfillment_date, as: :datetime_picker
    end

    f.inputs 'Údaje příjemce' do
      para 'K osobním údajům příjemce služby se dostanou pouze koordinátoři vaší organizace.', class: :small
      f.input :subscriber
      f.input :subscriber_phone, input_html: { maxlength: 13 }
      address_label = proc { |type| I18n.t("activerecord.attributes.request.#{type}") }
      custom_input :full_address, class: 'geocomplete',
                                  label: object.new_record? ? (address_label['full_address'] + ' *') : address_label['update_address'],
                                  hint: ("Současná adresa: #{f.object.address}" if resource.address)

      f.inputs for: [:address, f.object.address || f.object.build_address] do |address_form|
        address_form.input :street_number, as: :hidden
        address_form.input :street, as: :hidden
        address_form.input :city, as: :hidden
        address_form.input :city_part, as: :hidden
        address_form.input :postal_code, as: :hidden
        address_form.input :country_code, as: :hidden
        address_form.input :latitude, as: :hidden
        address_form.input :longitude, as: :hidden
        address_form.input :geo_entry_id, as: :hidden
      end
      f.input :long_text, as: :text, hint: 'Tento popis bude dostupny pouze vybranym dobrovolnikum v aplikaci'
    end

    f.inputs 'Koordinace' do
      f.input :state if resource.persisted?
      f.input :organisation, as: :select,
                             collection: Organisation.where(id: current_user.coordinating_organisations.pluck(:id)),
                             include_blank: false
      f.input :fullfillment_date, as: :datetime_picker
      f.input :block_volunteer_until, as: :datetime_picker
      f.input :coordinator_id, as: :select, collection: current_user.organisation_colleagues
      f.input :closed_note, as: :text if resource.persisted?
      f.input :created_by_id, as: :hidden, input_html: { value: current_user.id }
    end
    f.actions
  end
end
