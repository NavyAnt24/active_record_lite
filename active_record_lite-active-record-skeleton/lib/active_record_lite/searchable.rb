require_relative './db_connection'

module Searchable
  def where(params)
    keys = params.keys
    attribute_names = "#{keys.join(' = ?, ')} = ?"
    values = params.values
    results = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{attribute_names}
      SQL
    results
    self.parse_all(results)
  end
end