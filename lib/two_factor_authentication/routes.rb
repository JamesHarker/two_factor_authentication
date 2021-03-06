module ActionDispatch::Routing
  class Mapper
    protected

      def devise_two_factor_authentication(mapping, controllers)
        resource :two_factor_authentication, :only => [:show, :update, :resend], :path => mapping.path_names[:two_factor_authentication], :controller => controllers[:two_factor_authentication] do
           collection { get "resend" }
        end
      end
  end
end
