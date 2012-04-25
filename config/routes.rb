if Rails.version > '3.1'
  Statisfaction::Engine.routes.draw do
    match 'get(.:format)' => "statistics#get", :as => 'get'
  end
else
  Rails.application.routes.draw do
    match 'statisfaction/get(.:format)' => "statisfaction/statistics#get", :as => 'statisfaction_get'
  end
end
