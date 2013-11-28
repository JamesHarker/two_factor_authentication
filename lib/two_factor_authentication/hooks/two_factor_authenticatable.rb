Warden::Manager.after_authentication do |user, auth, options|
  if auth.session(options[:scope])[:need_two_factor_authentication] = user.need_two_factor_authentication?
    user.create_two_factor_code
  end
end
