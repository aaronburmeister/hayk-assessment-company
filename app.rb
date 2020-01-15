class Company

    attr_accessor :name, :number_of_employees, :id

    @@all = []
    @@loaded = false

    def initialize(name, number_of_employees, id=nil)
        @id = id
        @name = name
        @number_of_employees = number_of_employees
        @@all << self
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS companies(
                id INTEGER PRIMARY KEY,
                name TEXT,
                number_of_employees INTEGER
            )
            SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO companies(name, number_of_employees)
            VALUES (?, ?)
            SQL
        DB[:conn].execute(sql, name, number_of_employees)

        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM companies")[0][0]
    end

    def self.create(name, number_of_employees, id=nil)
        company = Company.new(name, number_of_employees, id)
        company.save
        company
    end

    def find_by_name
        sql = <<-SQL
            SELECT * FROM companies WHERE companies.name = ?
            SQL
        DB[:conn].execute(sql, @name)      
    end

    
    def update_sql(column, value)
        sql = <<-SQL
        UPDATE companies SET #{column} = #{value} WHERE id = #{@id}
        SQL
    end
    
    def update
        puts "Would you like to update the company name or number of employees?"
        puts "Please type \"name\" or \"employees\"."
        input = gets.strip
        if input == "name"
            print "Enter the new name: "
            input = gets.strip
            input_string = "\"#{input}\""
            sql = update_sql("name", input_string)
            DB[:conn].execute(sql)
            @name = input
            puts "Company name updated to #{@name}!"
        elsif input == "employees"
            print "Enter the new number of employees: "
            input = gets.strip
            input = input.to_i
            sql = update_sql("number_of_employees", input)
            DB[:conn].execute(sql)
            @number_of_employees = input
            puts "Number of employees for #{self.name} updated to #{@number_of_employees}!"
        else
            puts "Please try again"
            self.update
        end
    end
    
    def delete
        sql = <<-SQL
        DELETE FROM companies WHERE id = #{@id}
        SQL
        puts "You're about to delete this company. Are you sure you want to do this? (Y/N)"
        input = gets.strip
        if input.upcase == "Y"
            DB[:conn].execute(sql)
            puts "#{self.name} has been deleted!"
            count = 0
            index = nil
            @@all.each {|company|
                if company == self
                    index = count
                end
                count +=1
            }
            @@all.delete_at(index)
        elsif input.upcase == "N"
            puts "Ah, I didn't think so. That was close!"
        else
            puts "Please enter either \"Y\" or \"N\"."
            self.delete
        end
    end
    
    def self.all
        sql = <<-SQL
            SELECT * FROM companies
            SQL
        database = DB[:conn].execute(sql)
        if @@loaded == false
            database.each { |row| 
                Company.new(row[1],row[2],row[0])
            }
            @@loaded = true
        end
        @@all
    end
end