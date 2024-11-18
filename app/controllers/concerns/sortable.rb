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
      collection.order(created_at: :desc)
    end
  end

  def get_filter_options(filters, filter_options, collection_type)
    filters.each do |filter|
      if collection_type.reflect_on_association(filter) # Checks if `filter` is an association
        # Use the associated records through the join
        filter_options[filter] = collection_type.joins(filter).distinct.pluck("#{filter.to_s.pluralize}.name").compact
      else
        # If `filter` is a direct attribute, use distinct pluck on it
        filter_options[filter] = collection_type.distinct.pluck(filter).compact
      end
    end
    filter_options
  end

  def apply_filter_conditions(filters, params, collection)
    filters.each do |filter|
      if params[filter].present?
        filter_values = Array(params[filter])
        if collection.reflect_on_association(filter)
          # If `filter` is an association, join the association and filter by the associated model's `name` field
          collection = collection.joins(filter).where(filter.to_s.pluralize => { name: filter_values })
        else
          # If `filter` is a direct attribute, apply filter directly
          collection = collection.where(filter => filter_values)
        end
      end
    end
    collection
  end
end