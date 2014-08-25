Peek::Railtie.routes.draw do
  get "/dalli_expire" => 'expires#dalli_expire', as: :dalli_expire
end
