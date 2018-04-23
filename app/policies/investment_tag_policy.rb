class InvestmentTagPolicy < ApplicationPolicy
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
		user.organisation
	end

	def edit?
		user.organisation
	end

	def update?
		user.organisation
	end

	private
	
	def user_has_org?
		user.organisation
	end
end
