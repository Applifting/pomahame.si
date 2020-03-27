class VolunteerDecorator < ApplicationDecorator
  decorates_association :addresses
  delegate_all

  def confirmed?
    object.confirmed?
  end

  def address
    @address ||= addresses[0]
  end

  def address_link
    if h.can? :manage, object
      h.link_to h.content_tag(:span, address.to_s, class: 'action edit'), h.edit_admin_address_path(address)
    else
      address
    end
  end

  def full_name
    "#{object.first_name} #{object.last_name}"
  end
end
