class InstallmentPolicy < ApplicationPolicy
    class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    user_foundation_check
  end

  def create?
    user_foundation_check
  end

  def edit?
    user_foundation_check
  end

  def update?
    user_foundation_check
  end

  def destroy?
    user_foundation_check
  end

  def unlock?
    user_foundation_check
  end

  def rescind?
    user_foundation_check
  end

  private

  def user_foundation_check
    record.investment.foundation == user.foundation
  end
end
