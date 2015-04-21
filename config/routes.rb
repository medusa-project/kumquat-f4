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

  concern :publishable do
    patch 'publish'
    patch 'unpublish'
  end

  root 'landing#index'

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post],
        as: :auth # used by omniauth
  resources :collections, param: :key, only: [:index, :show], as: :repository_collections do
    resources 'items', only: :index
  end
  resources :favorites, param: :web_id, only: :index
  resources :items, param: :web_id, only: [:index, :show], as: :repository_items do
    match '/master', to: 'items#master_bytestream', via: 'get',
          as: :master_bytestream
  end
  match '/oai-pmh', to: 'oai_pmh#index', via: %w(get post), as: 'oai_pmh'
  match '/search', to: 'search#index', via: 'get'
  match '/search', to: 'search#search', via: 'post'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  namespace :admin do
    root 'dashboard#index'
    resources :collections, param: :key, as: :repository_collections,
              concerns: :publishable do
      resources :rdf_predicates, path: 'rdf-predicates', only: [:index, :create]
    end
    resources :collections, param: :key, as: :db_collections
    resources :items, param: :web_id, as: :repository_items, concerns: :publishable
    resources :rdf_predicates, path: 'rdf-predicates', only: [:index, :create]
    resources :roles, param: :key
    match '/server', to: 'server#index', via: 'get'
    match '/server/image-server-status', to: 'server#image_server_status',
          via: 'get', as: 'server_image_server_status'
    match '/server/repository-status', to: 'server#repository_status',
          via: 'get', as: 'server_repository_status'
    match '/server/search-server-status', to: 'server#search_server_status',
          via: 'get', as: 'server_search_server_status'
    match '/settings', to: 'settings#index', via: 'get'
    match '/settings', to: 'settings#update', via: 'patch'
    resources :db_themes, controller: 'themes', path: 'themes', except: :show
    resources :uri_prefixes, path: 'uri-prefixes', only: [:index, :create]
    resources :users, param: :username do
      match '/enable', to: 'users#enable', via: 'patch', as: 'enable'
      match '/disable', to: 'users#disable', via: 'patch', as: 'disable'
      match '/roles', to: 'users#change_roles', via: 'patch', as: 'change_roles'
    end
  end

end
