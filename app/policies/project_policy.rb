class ProjectPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    user.organisation
  end

  def create?
    user.organisation
  end

  def edit?
    user.organisation
  end

  def update?
    user.organisation
  end
end
