package dto

// Message ...
type Message struct {
	ID      int64    `json:"message_id"`
	From    string   `json:"from_address"`
	To      []string `json:"to_addresses"`
	Subject string   `json:"message_subject"`
	Body    string   `json:"message_body"`
}
