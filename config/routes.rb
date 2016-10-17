Rails.application.routes.draw do

  get 'image_label_sets/alloc/:id' => 'image_label_sets#alloc'
  get 'image_label_sets/download/:id' => 'image_label_sets#download'
  get 'image_label_sets/assign/:id' => 'image_label_sets#assign'
  post 'image_label_sets/createjob/:id' => 'image_label_sets#createjob'
  get 'image_labels/next' => 'image_labels#next'
  get 'image_labels/outofwork' => 'image_labels#outofwork'
  get 'images/:set_id/:filename' => 'images#one', :constraints => {:filename => /[^\/]+/} #ER: is it correct?

  resources :image_labels
  resources :jobs
  resources :image_label_sets
  resources :labels
  resources :label_sets
  resources :images
  resources :image_sets
  devise_for :admins
  devise_for :users
  #devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static#index'

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

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
