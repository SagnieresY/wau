class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def users_csv?
    user.organisation == record.organisation
  end
end
