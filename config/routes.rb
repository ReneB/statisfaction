Rails.application.routes.draw do
  match 'statisfaction/get(.:format)' => "statisfaction/statistics#get", :as => 'get_satisfaction'
end
