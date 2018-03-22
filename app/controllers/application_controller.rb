class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :set_locale
  before_action :authenticate_user!
  include Pundit

  # Pundit: white-list approach.
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  helper_method :should_render_navbar?
  helper_method :should_render_footer?
  helper_method :should_render_navbar_landing?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "You are not authorized to perform this action."
  #   redirect_to(root_path)
  # end

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end

  def should_render_navbar?
    !on_error_page? && !on_devise_page? && (action_name != "home" || user_signed_in?)
  end

  def should_render_footer?
    should_render_navbar?
  end

  def on_error_page?
    ["internal_server_error", "not_found"].include?(action_name)
  end

  def on_devise_page?
    params["controller"] == "devise/sessions" ||
    params["controller"] == "devise/passwords" ||
    params["controller"] == "devise/registrations"
  end

  def should_render_navbar_landing?
  (params["controller"] == "devise/sessions" &&  params["action"] == "new") ||
    (action_name == "home" && !user_signed_in?) ||
    params["controller"] == "devise/passwords" ||
    params["controller"] == "devise/registrations"
  end

  private

  def set_locale
    I18n.locale = params.fetch(:locale, I18n.default_locale).to_sym
  end

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
