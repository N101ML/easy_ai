class ApplicationController < ActionController::Base
  include Sortable
  include Pagy::Backend
end
