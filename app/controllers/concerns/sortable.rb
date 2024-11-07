module Sortable
  extend ActiveSupport::Concern

  def sorted_records(collection, sort_params, sort_fields)
    if sort_params.present? && sort_fields.include?(sort_params.to_sym)
      if session[:last_sort_by] == sort_params
        sorted_collection = collection.order(sort_params => :desc)
        session[:last_sort_by] = nil
      else
        sorted_collection = collection.order(sort_params => :asc)
        session[:last_sort_by] = sort_params
      end
      sorted_collection
    else
      collection
    end
  end
end