class OpenFun < Sinatra::Base
  get '/' do
    erb :index
  end
  
  get '/display' do
    @openid_response = session["openid_response"]
    erb :display
  end
  
  post '/login' do
    authenticate_unless_openid_response
    
    response = request.env["rack.openid.response"]
    return "Error: #{response.status}" unless response.status == :success
    
    profile_data = {}
    
    # merge the SReg data and the AX data into a single hash of profile data
    [ OpenID::SReg::Response, OpenID::AX::FetchResponse ].each do |data_response|
      if data_response.from_success_response(response)
        profile_data.merge! data_response.from_success_response(response).data
      end
    end
    
    session["openid_profile"] = profile_data
    session["openid_url"] = response.identity_url
    redirect "/display"
  end
  
  def authenticate_unless_openid_response
    return if request.env["rack.openid.response"]
    headers 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => params["identity_url"],
      :required => [:nickname, :fullname, :email, 
        "http://axschema.org/contact/email","http://axschema.org/namePerson/first", 
        "http://axschema.org/namePerson/last"],
      :optional => [:email, :fullname]
    )
    throw :halt, [401, 'got openid?']
    return
  end  
end

OpenFun.run! if $0 == __FILE__