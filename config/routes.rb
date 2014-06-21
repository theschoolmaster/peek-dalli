Peek::Railtie.routes.draw do
  get "/expire" => 'expires#expire', as: :expire
end
