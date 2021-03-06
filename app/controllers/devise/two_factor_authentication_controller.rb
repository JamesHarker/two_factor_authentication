class Devise::TwoFactorAuthenticationController < DeviseController
  prepend_before_action :authenticate_scope!
  before_action :prepare_and_validate, :handle_two_factor_authentication

  def show
  end

  def update
    render :show and return if params[:code].nil?
    md5 = Digest::MD5.hexdigest(params[:code])
    if Devise.secure_compare(md5, resource.second_factor_pass_code)
      warden.session(resource_name)[:need_two_factor_authentication] = false
      bypass_sign_in(resource, scope: resource_name)
      redirect_to stored_location_for(resource_name) || :root
      resource.update_attribute(:second_factor_attempts_count, 0)
    else
      resource.second_factor_attempts_count += 1
      resource.save
      if resource.max_login_attempts?
        sign_out(resource)
        render 'devise/two_factor_authentication/max_login_attempts_reached'
      else
        redirect_to user_two_factor_authentication_path, notice: "Invalid code."
      end
    end
  end

  def resend
    resource.create_two_factor_code
    redirect_to user_two_factor_authentication_path, notice: "Your authentication code has been sent."
  end

  private

  def authenticate_scope!
    self.resource = send("current_#{resource_name}")
  end

  def prepare_and_validate
    redirect_to :root and return if resource.nil?
    @limit = resource.class.max_login_attempts
    if resource.max_login_attempts?
      sign_out(resource)
      render 'devise/two_factor_authentication/max_login_attempts_reached'
    end
  end
end
