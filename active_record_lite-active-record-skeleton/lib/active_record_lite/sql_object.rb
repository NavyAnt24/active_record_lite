require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  extend Searchable
  db = DBConnection.open("cats.db")

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.nil? ? self.class.pluralize.underscore : @table_name
  end

  def self.all
    table_values = DBConnection.execute(<<-SQL)
      SELECT
      *
      FROM
      #{self.table_name}
    SQL
    objects = []
    table_values.each do |row|
      objects << new(row)
    end
    objects
  end

  def self.find(id)
    object_arr = DBConnection.execute(<<-SQL, id)
      SELECT
      *
      FROM
      #{self.table_name}
      WHERE
      #{self.table_name}.id = ?
    SQL
    return (object_arr.empty? ? nil : object_arr[0])
  end

  def save
    if self.id.nil?
      create
    else
      update
    end
  end

  private

      def create
        att_without_id = self.class.attributes.dup
        att_without_id.delete(:id)
        attribute_names = "(#{att_without_id.join(", ")})"
        num_question_marks = (['?'] * (self.class.attributes.length - 1)).join(", ")
        num_question_marks = "(#{num_question_marks})"
        DBConnection.execute(<<-SQL, *attribute_values)
          INSERT INTO
            #{self.class.table_name} #{attribute_names}
          VALUES
            #{num_question_marks}
        SQL
        self.id = DBConnection.last_insert_row_id
      end

      def update
        att_without_id = self.class.attributes.dup
        att_without_id.delete(:id)
        attribute_names = "#{att_without_id.join(' = ?, ')} = ?"
        DBConnection.execute(<<-SQL, *attribute_values, self.id)
          UPDATE
            #{self.class.table_name}
          SET
            #{attribute_names}
          WHERE
            #{self.class.table_name}.id = ?
        SQL
      end

      def attribute_values
        values_arr = []
        self.class.attributes.each do |attribute|
          values_arr << self.send(attribute)
        end
        values_arr.shift(1)
        return values_arr
      end
end
