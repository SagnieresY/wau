class InvestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.organisation
  end

  def new?
    user.organisation
  end

  def create?
    record.organisation == user.organisation
  end

  def edit?
    record.organisation == user.organisation
  end

  def update?
    record.organisation == user.organisation
  end

  def show?
    record.organisation == user.organisation
  end

  def destroy?
    record.organisation == user.organisation
  end
end
