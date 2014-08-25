Peek::Railtie.routes.draw do
  get "/expire" => 'expires#dalli_expire', as: :dalli_expire
end
