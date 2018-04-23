class InvestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def reject?
    user.organisation == record.organisation
  end
  def to_csv?
    user.organisation == record.organisation
  end
  def index?
    user.organisation
  end

  def completed_index?
    user.organisation
  end

  def active_index?
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
