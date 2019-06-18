Rails.application.routes.draw do
  match '/login'                    => 'main#login',                  via: :get
  match '/company_register'         => 'main#company_register',       via: :get
  match '/search_professionals'     => 'main#search_professionals',   via: :get
  match '/messages'                 => 'main#messages',               via: :get
  match '/message_detail'           => 'main#message_detail',         via: :get
  match '/search_results'           => 'main#search_results',         via: :get
  match '/jobs'                     => 'main#jobs',                   via: :get
  match '/job_form'                 => 'main#job_form',               via: :get
  match '/job_detail'               => 'main#job_detail',             via: :get
  match '/job_post_form'            => 'main#job_post_form',          via: :get
  match '/company_profilestyle'     => 'main#company_profile',        via: :get
  match '/company_profile_edit'     => 'main#company_profile_edit',   via: :get
  match '/company_user_edit'        => 'main#company_user_edit',      via: :get
  match '/avpro_profile'            => 'main#avpro_profile',          via: :get
  match '/avpro_profile_edit'       => 'main#avpro_profile_edit',     via: :get
  match '/avpro_register'           => 'main#avpro_register',         via: :get
  match '/avpro_jobs'               => 'main#avpro_jobs',             via: :get
  match '/avpro_messages'           => 'main#avpro_messages',         via: :get
  match '/avpro_job_detail'         => 'main#avpro_job_detail',       via: :get
  match '/avpro_message_detail'     => 'main#avpro_message_detail',   via: :get

  mount ActionCable.server => '/cable'

  devise_for :users, skip: [:registrations], controllers: {sessions: "sessions" }

  devise_for :company_users, path: 'company',
                             path_names: { sign_up: "register" },
                             controllers: {registrations: "company/registrations", sessions: "sessions" },
                             skip: [:devise, :passwords, :confirmations]

  devise_for :freelancers, path: 'freelancer',
                           path_names: { sign_up: "register" },
                           controllers: {registrations: "freelancer/registrations", sessions: "sessions" },
                           skip: [:devise, :passwords, :confirmations]

  devise_scope :company_user do
    match 'active'            => 'sessions#active',               via: :get
    match 'timeout'           => 'sessions#timeout',              via: :get
  end

  devise_scope :freelancer do
    match 'active'            => 'sessions#active',               via: :get
    match 'timeout'           => 'sessions#timeout',              via: :get
  end

  devise_scope :admin do
    match 'active'            => 'sessions#active',               via: :get
    match 'timeout'           => 'sessions#timeout',              via: :get
  end

  root "main#index"

  get "freelance-service-agreement", to: "main#freelance_service_agreement"
  get "confirm_email", to: "main#confirm_email"
  get "job_country_currency", to: "main#job_countries", as: "job_country_currency"

  namespace :freelancer do

    root "main#index"
    resource :freelancer, only: [:show]

    resources :registration_steps, only: [:show, :update, :index] do
      member do
        post :previous
      end
    end

    resources :companies, only: [:index, :show] do
      get :favourites, on: :collection
      post :add_favourites, on: :collection
      get :av_companies, on: :collection
      resources :messages, only: [:index, :create]
    end

    resources :jobs, only: [:index, :show]

    resource :profile, only: [:show, :edit, :update] do
      resource :banking, only: [:index, :edit, :update, :verify, :update_verify]
      resource :settings, only: [:index, :edit, :update]

    end

    resources :messaging, only: [:index]

    get "profile/bank_info", to: "banking#index", as: "profile_stripe_banking_info"
    get "profile/identity", to: "banking#identity", as: "profile_stripe_banking"
    get "profile/bank_account", to: "banking#bank_account", as: "profile_stripe_bank_account"
    post "stripe/connect", to: "banking#connect", as: "stripe_connect"
    post "stripe/bank", to: "banking#add_bank_account", as: "stripe_bank_submit"
    get "profile/settings", to: "settings#index"
    post "jobs/:id", to: "jobs#apply"
    post "job/apply", to: "jobs#apply"
    get "jobs/:id/work_order/accept", to: "contracts#accept"
    get "companies/:company_id/messages(/job/:job_id)", to: "messages#index", as: "messages_for_job"
  end

  namespace :company do
    root "main#index"

    resource :profile, only: [:show, :edit, :update]
    resources :registration_steps, only: [:show, :update, :index] do
      member do
        post :previous
      end
    end

    resources :freelancers, only: [:show, :index] do
      get :saved, on: :collection
      get :hired, on: :collection
      post :add_favourites, on: :collection
      post :save_freelancer, on: :member
      post :delete_freelancer, on: :member
      resources :messages, only: [:index, :create]
    end

    resources :company_users, only: [:edit, :update]

    get "freelancers/:id/invite_to_quote", to: "freelancers#invite_to_quote"

    resources :applicants
    resources :messaging, only: [:index]

    get 'job_country_currency', to: 'jobs#job_countries', as: 'job_country_currency'

    resources :jobs

    get "jobs/:id/publish", to: "jobs#publish"
    get "freelancers/:freelancer_id/messages(/job/:job_id)", to: "messages#index", as: "messages_for_job"
  end

  namespace :admin do
    root "main#index"

    resources :freelancers, except: [:new, :create] do
      get :disable, on: :member
      get :enable, on: :member
      get :verify, on: :member
      get :unverify, on: :member
      get :messaging, on: :member
    end

    resource :freelancer do
      get :download_csv
    end

    resources :companies, except: [:new, :create] do
      get :disable, on: :member
      get :enable, on: :member
      get :jobs
      get :messaging, on: :member
    end

    resource :company do
      get :download_csv
    end

    resources :jobs, except: [:new, :create] do
      get :freelancer_matches, on: :member
      get :mark_as_expired, on: :member
      get :unmark_as_expired, on: :member
    end

    resources :new_registrants, only: [:index]
    resource :new_registrant, only: [:download_csv] do
      get :download_csv
    end

    resources :incomplete_registrations, only: [:index]
    resource :incomplete_registration, only: [:download_csv] do
      get :download_csv
    end

    resources :connections, only: [:index]

    get "companies/:company_id/messages/freelancer/:freelancer_id", to: "messages#index", as: "messages"
  end

  get "*any", via: :all, to: "errors#not_found"
  get "*any", via: :all, to: "errors#unauthorized"
end
