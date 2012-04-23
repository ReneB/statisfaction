require 'statisfaction/engine'

Rails.application.routes.draw do
  mount Statisfaction::Engine => "/statisfaction"
end
