module Abilities
  module Coordinator
    def add_coordinator_ability(user)
      can :read, ActiveAdmin::Page, name: 'Dashboard'
      can %i[index read], [Organisation, OrganisationDecorator], id: Organisation.user_group_organisations(user).pluck(:id)
      can :update, [Organisation, OrganisationDecorator], id: user.coordinating_organisations.pluck(:id)
      can %i[read], [User, UserDecorator], id: user.coordinators_in_organisations.pluck(:id)

      can %i[read download], [Volunteer, VolunteerDecorator], id: Volunteer.available_for(user.organisation_group.id).pluck(:id)
      cannot %i[read], Volunteer, confirmed_at: nil

      can %i[read], [Group], id: user.coordinating_groups.pluck(:id)

      can :manage, Label, group_id: user.coordinating_groups.pluck(:id)
      can :manage, VolunteerLabel

      can_manage_requests user
      can_manage_recruitment user
    end

    def can_manage_recruitment(user)
      can %i[index read update], [Recruitment, GroupVolunteer, GroupVolunteerDecorator], group_id: user.organisation_group.id
      cannot :create, Recruitment

      can :create, [GroupVolunteer]
      can %i[read create update], [GroupVolunteer, GroupVolunteerDecorator], id: user.group_volunteers.pluck(:id)
    end

    def can_manage_requests(user)
      can :create, Request

      # read-only access to requests within organisation group
      can %i[index read], [Request, RequestDecorator], organisation_id: Organisation.user_group_organisations(user).pluck(:id)

      # full access to requests in user's organisations
      can :manage, [Request, RequestDecorator], organisation_id: user.coordinating_organisations.pluck(:id)
      can :manage, [RequestedVolunteer, RequestedVolunteerDecorator], request: { organisation_id: Organisation.user_group_organisations(user).pluck(:id) }
    end
  end
end
