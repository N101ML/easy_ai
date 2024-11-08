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

  def get_filter_options(filters, filter_options, collection_type)
    filters.each do |filter|
      filter_options[filter] = collection_type.distinct.pluck(filter).compact
    end
    filter_options
  end

  def apply_filter_conditions(filters, params, collection)
    filters.each do |filter|
      if params[filter].present?
        filter_values = Array(params[filter])
        collection = collection.where(filter => filter_values)
      end
    end
    collection
  end
end