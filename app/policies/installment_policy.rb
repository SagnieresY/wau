class InstallmentPolicy < ApplicationPolicy
    class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    user_organisation_check
  end

  def create?
    user_organisation_check
  end

  def edit?
    user_organisation_check
  end

  def update?
    user_organisation_check
  end

  def destroy?
    user_organisation_check
  end

  def unlock?
    user_organisation_check
  end

  def rescind?
    user_organisation_check
  end

  private

  def user_organisation_check
    record.investment.organisation == user.organisation
  end
end
