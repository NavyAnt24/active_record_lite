require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    @other_class.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :class_name, :primary_key, :foreign_key

  def initialize(name, params)
    @class_name = params[:class_name] || name.camelize
    @primary_key = params[:primary_key] || "id"
    @foreign_key = params[:foreign_key] || "#{name.downcase}_id"
    @other_class = params[:class_name] || name.camelize
  end

  def type
    :belongs_to
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :class_name, :primary_key, :foreign_key

  def initialize(name, params, self_class)
    @class_name = params[:class_name] || name.camelize
    @primary_key = params[:primary_key] || "id"
    @foreign_key = params[:foreign_key] || self_class.table_name + "_id"
    @other_class = params[:other_class_name] || name.singularize.camelize
  end

  def type
    :has_many
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params, self.class)
    object = DBConnection.execute(<<-SQL, aps.foreign_key)
      SELECT
      *
      FROM
      #{aps.other_table}
      WHERE
      aps.primary_key = ?
    SQL
  end

  def has_many(name, params = {})
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
