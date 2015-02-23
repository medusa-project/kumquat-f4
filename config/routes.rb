Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  root 'landing#index'

  namespace :admin do
    root 'dashboard#index'
    match '/server', to: 'server#index', via: 'get'
    match '/server/image-server-status', to: 'server#image_server_status',
          via: 'get', as: 'server_image_server_status'
    match '/server/repository-status', to: 'server#repository_status',
          via: 'get', as: 'server_repository_status'
    match '/server/search-server-status', to: 'server#search_server_status',
          via: 'get', as: 'server_search_server_status'
  end

  resources 'items', param: :uuid, only: [:index, :show] do
    match '/bytestream', to: 'items#bytestream', via: 'get'
  end
end
