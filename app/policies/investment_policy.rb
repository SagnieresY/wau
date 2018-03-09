class InvestmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def index?
    user.foundation
  end

  def new?
    user.foundation
  end

  def create?
    record.foundation == user.foundation
  end

  def edit?
    record.foundation == user.foundation
  end

  def update?
    record.foundation == user.foundation
  end

  def show?
    record.foundation == user.foundation
  end

  def destroy?
    record.foundation == user.foundation
  end
end
