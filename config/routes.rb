GankaoSeason3::Application.routes.draw do

  resources :logins do
    collection do
      get :friend_add_request,:renren_like,:add_user,:alipay_exercise
      get :follow_me,:login_from_qq,:qq_index,:get_code,:user_code,:logout,:alipay_sun
      get :request_qq,:respond_qq,:request_sina,:respond_sina,:manage_sina,:watch_weibo,:respond_weibo,:request_renren,:respond_renren
      get :call_back_sina,:call_back_renren,:call_back_qq,:call_back_and_focus_sina,:call_back_and_focus_renren,:call_back_and_focus_qq
      post :manage_qq,:add_watch_weibo,:check_vip,:accredit_check,:alipay_compete,:sun_compete
    end
  end
  resources :videos do
    collection do
      post :request_url,:request_video
    end
  end

  resource :welcome do
    collection do
      get :alipay_exercise
      post :alipay_compete
    end
  end

  resources :skills do
    collection do
      post :like_blog,:search_blog
      get :search_result
    end
  end

  resources :logins 
  resources :similarities
  resources :plans do
    collection do
      get :end_result
      post :show_chapter,:create_plan,:init_plan,:update_user
    end
  end
  resources :learn do
    collection do
      get  :listen, :pass_status, :study_it,:next_sentence
      post :task_dispatch,:jude_word, :jude_sentence, :jude_hearing, :jude_read, :i_have_remember
    end
  end
  resources :questions ,:only=>[:index]
  resources :questions do
    member do
      get :answered_more
      post :get_answers
    end
    collection do
      post :save_answer,:ask_question
      get :answered, :unanswered, :ask, :answers, :show_result
    end
  end
  resources :users ,:only=>[:index]
  resources :users do
    member do
      get :share_back
    end
    collection do
      get :share,:kaoyan_share
      post :update_users,:check_in
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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
 
  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
