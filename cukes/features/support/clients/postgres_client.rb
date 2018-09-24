class PostgresClient
    NEW_ID_PLACEHOLDER = '__NEW_ID__'

    def index
        queries = ['SELECT m.message_id, f.address, t.address, m.subject, m.body FROM message m INNER JOIN address f ON f.address_id = m.from_address INNER JOIN message_recipient mr ON mr.message_id = m.message_id INNER JOIN address t ON mr.address_id = t.address_id ORDER BY m.message_id, t.address']
        @results = run_queries(queries)
    end

    def get(message_id)
        queries = ["SELECT m.message_id, f.address, t.address, m.subject, m.body FROM message m INNER JOIN address f ON f.address_id = m.from_address INNER JOIN message_recipient mr ON mr.message_id = m.message_id INNER JOIN address t ON mr.address_id = t.address_id WHERE m.message_id = #{message_id} ORDER BY t.address"]
        @results = run_queries(queries)
    end

    def create(from, to_list, subject, body)
        addrs = to_list
        addrs << from
        addr_info = get_addr_info(addrs)

        queries = ["INSERT INTO message (from_address, subject, body) VALUES (#{addr_info[from]}, '#{subject}', '#{body}') RETURNING message_id"]

        to_list.each do |to_address|
            queries << "INSERT INTO message_recipient (message_id, address_id) VALUES (#{NEW_ID_PLACEHOLDER}, #{addr_info[to_address]})"
        end

        @results = run_queries(queries, true)
    end

    def delete(message_id)
        queries = [
            "DELETE FROM message_recipient WHERE message_id = #{message_id};",
            "DELETE FROM message WHERE message_id = #{message_id};"
        ]
        run_queries(queries)
    end

    def message_in_database?(message_body)
        queries = ["SELECT message_id FROM message WHERE body LIKE '%#{message_body}%'"]
        result = run_queries(queries)
        !result.none?
    end

    def results
        @results
    end

    def new_message_id
        @new_message_id
    end

    private

    def run_queries(queries, first_query_has_new_id = false)
        conn = PG.connect(
            host: '127.0.0.1',
            port: 5432,
            dbname: 'postgres',
            user: 'anubiskb'
        )

        @new_message_id = nil
        results = nil

        begin
            conn.transaction do |c|
                first_query = true
                queries.each do |q|
                    q = q.gsub(NEW_ID_PLACEHOLDER, @new_message_id) unless @new_message_id.nil?
                    results = c.exec(q)
                    if (first_query_has_new_id && first_query)
                        @new_message_id = results.tuple_values(0).first
                        first_query = false
                    end
                end
            end
        rescue PG::Error => e
            raise e
        ensure
            conn.close if conn
        end

        results
    end

    def get_addr_info(address_list)
        addresses = address_list.join("','")
        queries = ["SELECT a.address_id, a.address FROM address a WHERE a.address IN ('#{addresses}')"]
        results = run_queries(queries)
        results.inject({}) do |accum, addr_info|
            accum[addr_info['address']] = addr_info['address_id']
            accum
        end
    end
end
