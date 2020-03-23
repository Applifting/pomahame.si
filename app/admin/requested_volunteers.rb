# frozen_string_literal: true

ActiveAdmin.register RequestedVolunteer do
  decorate_with RequestedVolunteerDecorator
  belongs_to :organisation_request
  permit_params :request_id, :volunteer_id, :state

  before_action :ensure_request_id

  form do |f|
    f.input :request_id, as: :hidden
    f.input :volunteer, label: 'Dobrovolník' unless resource.persisted?
    f.input :state, label: 'Stav', as: :select, collection: RequestedVolunteer.states.keys, include_blank: false
    f.actions
  end

  show do
    panel resource do
      attributes_table_for resource do
        row :volunteer
        row :request
        row :state
        row :created_at
        row :updated_at
      end
    end

    active_admin_comments
  end

  controller do
    def create
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def update
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def destroy
      super do |success, failure|
        success.html { redirect_to admin_organisation_request_path(resource.request_id) }
        failure.html { render :new }
      end
    end

    def ensure_request_id
      params[:request_id] ||= params[:organisation_request_id]
    end
  end
end
