class MilestonePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    record.foundation == user.foundation
  end

  def create?
    record.foundation == user.foundation
  end

  def edit?
    record.investment.foundation == user.foundation
  end

  def update?
    record.investment.foundation == user.foundation
  end

  def destroy?
    record.investment.foundation == user.foundation
  end



end
