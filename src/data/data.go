package data

import (
	"database/sql"
	"errors"
	"fmt"
	"log"
	"strings"

	"dakstudios.net/yams/src/dto"
	_ "github.com/lib/pq" // for database/sql Postgres support
)

const (
	host   = "localhost"
	port   = 5432
	dbname = "postgres"
	user   = "anubiskb"
)

func connect(query string) *sql.DB {
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s dbname=%s sslmode=disable", host, port, user, dbname)
	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		log.Panicln(err)
	}

	err = db.Ping()
	if err != nil {
		log.Panicln(err)
	}

	return db
}

func selectQuery(db *sql.DB, query string) *sql.Rows {
	rows, err := db.Query(query)
	if err != nil {
		log.Panicln(err)
	}

	return rows
}

func getAddressInfo(addresList []string) map[string]int64 {
	addresses := strings.Join(addresList, "','")
	query := fmt.Sprintf("SELECT a.address_id, a.address FROM address a WHERE a.address IN ('%s')", addresses)

	db := connect(query)
	rows := selectQuery(db, query)

	var (
		id   int64
		addr string
	)

	addrInfo := make(map[string]int64)

	defer rows.Close()
	for rows.Next() {
		err := rows.Scan(&id, &addr)
		if err != nil {
			log.Panicln(err)
		}
		addrInfo[addr] = id
	}

	rows.Close()
	db.Close()

	return addrInfo
}

// CreateMessage ...
func CreateMessage(from string, toList []string, subject string, body string) dto.Message {
	addrInfo := getAddressInfo(append(toList, from))

	query := fmt.Sprintf("INSERT INTO message (from_address, subject, body) VALUES (%d, '%s', '%s') RETURNING message_id", addrInfo[from], subject, body)
	db := connect(query)

	tx, err := db.Begin()
	if err != nil {
		log.Panicln(err)
	}

	stmt, err := tx.Prepare(query)
	if err != nil {
		tx.Rollback()
		log.Panicln(err)
	}
	defer stmt.Close()
	rs := stmt.QueryRow()
	var messageID int64
	err = rs.Scan(&messageID)
	if err != nil {
		tx.Rollback()
		log.Panicln(err)
	}

	if len(toList) == 0 {
		err = errors.New("No valid recipient(s)")
	}
	if err != nil {
		log.Panicln(err)
	}

	for _, to := range toList {
		query = fmt.Sprintf("INSERT INTO message_recipient (message_id, address_id) VALUES (%d, %d)", messageID, addrInfo[to])
		stmt, err := tx.Prepare(query)
		if err != nil {
			tx.Rollback()
			log.Panicln(err)
		}
		defer stmt.Close()
		_, err = stmt.Exec()
		if err != nil {
			tx.Rollback()
			log.Panicln(err)
		}
	}

	tx.Commit()
	db.Close()

	return dto.Message{
		ID:      messageID,
		From:    from,
		To:      toList,
		Subject: subject,
		Body:    body,
	}
}

// GetAllMessages ...
func GetAllMessages() []dto.Message {
	var messages []dto.Message

	query := "SELECT m.message_id, f.address, t.address, m.subject, m.body" +
		" FROM message m" +
		" INNER JOIN address f ON f.address_id = m.from_address" +
		" INNER JOIN message_recipient mr ON mr.message_id = m.message_id" +
		" INNER JOIN address t ON mr.address_id = t.address_id" +
		" ORDER BY m.message_id, t.address"

	db := connect(query)
	allMessageRows := selectQuery(db, query)

	var (
		previd  int64
		id      int64
		from    string
		to      string
		toList  []string
		subject string
		body    string
		msg     dto.Message
	)

	defer allMessageRows.Close()
	for allMessageRows.Next() {
		err := allMessageRows.Scan(&id, &from, &to, &subject, &body)
		if err != nil {
			log.Panicln(err)
		}

		if previd == 0 {
			previd = id
		}

		if previd != id {
			messages = append(messages, msg)
			toList = nil
		}

		toList = append(toList, to)
		msg = dto.Message{
			ID:      id,
			From:    from,
			To:      toList,
			Subject: subject,
			Body:    body,
		}

		previd = id
	}
	messages = append(messages, msg)

	allMessageRows.Close()
	db.Close()

	return messages
}

// GetMessage ...
func GetMessage(messageID string) dto.Message {
	query := "SELECT m.message_id, f.address, t.address, m.subject, m.body" +
		" FROM message m" +
		" INNER JOIN address f ON f.address_id = m.from_address" +
		" INNER JOIN message_recipient mr ON mr.message_id = m.message_id" +
		" INNER JOIN address t ON mr.address_id = t.address_id" +
		" WHERE m.message_id = " + messageID +
		" ORDER BY t.address"

	db := connect(query)
	allMessageRows := selectQuery(db, query)

	var (
		id      int64
		from    string
		to      string
		toList  []string
		subject string
		body    string
		msg     dto.Message
	)

	id = 0

	defer allMessageRows.Close()
	for allMessageRows.Next() {
		err := allMessageRows.Scan(&id, &from, &to, &subject, &body)
		if err != nil {
			log.Panicln(err)
		}
		toList = append(toList, to)
	}

	msg = dto.Message{
		ID:      id,
		From:    from,
		To:      toList,
		Subject: subject,
		Body:    body,
	}

	allMessageRows.Close()
	db.Close()

	return msg
}

// DeleteMessage ...
func DeleteMessage(messageID string) {
	queryMsg := fmt.Sprintf("DELETE FROM message WHERE message_id = %s", messageID)
	queryTo := fmt.Sprintf("DELETE FROM message_recipient WHERE message_id = %s", messageID)
	db := connect(queryMsg)

	tx, err := db.Begin()
	if err != nil {
		log.Panicln(err)
	}

	stmt, err := tx.Prepare(queryTo)
	if err != nil {
		tx.Rollback()
		log.Panicln(err)
	}
	defer stmt.Close()
	_, err = stmt.Exec()
	if err != nil {
		tx.Rollback()
		log.Panicln(err)
	}

	stmt, err = tx.Prepare(queryMsg)
	if err != nil {
		tx.Rollback()
		log.Panicln(err)
	}
	defer stmt.Close()
	_, err = stmt.Exec()
	if err != nil {
		tx.Rollback()
		log.Panicln(err)
	}

	tx.Commit()
	db.Close()
}
