Peek::Railtie.routes.draw do
  get "/dalli_expire" => 'dalli_expires#expire', as: :dalli_expire
end
