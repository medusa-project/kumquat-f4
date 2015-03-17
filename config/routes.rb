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

  resources :collections, param: :key, only: [:index, :show] do
    resources 'items', param: :key, only: :index
  end
  resources :favorites, param: :web_id, only: [:create, :destroy, :index]
  resources :items, param: :web_id, only: [:index, :show] do
    match '/master', to: 'items#master_bytestream', via: 'get',
          as: 'master_bytestream'
  end
  resources :sessions, only: [:new, :create, :destroy]
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  namespace :admin do
    root 'dashboard#index'
    resources :collections, param: :web_id
    resources :roles, param: :key
    match '/server', to: 'server#index', via: 'get'
    match '/server/image-server-status', to: 'server#image_server_status',
          via: 'get', as: 'server_image_server_status'
    match '/server/repository-status', to: 'server#repository_status',
          via: 'get', as: 'server_repository_status'
    match '/server/search-server-status', to: 'server#search_server_status',
          via: 'get', as: 'server_search_server_status'
    match '/server/commit', to: 'server#commit',
          via: 'patch', as: 'server_commit'
    resources :users, param: :username, only: [:index, :show]
  end

end
