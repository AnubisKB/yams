package app

import (
	"log"

	"dakstudios.net/yams/src/data"
	"dakstudios.net/yams/src/dto"
)

// GetAllMessagesSerializable ...
func GetAllMessagesSerializable() []dto.Message {
	return data.GetAllMessages()
}

// GetMessageSerializable ...
func GetMessageSerializable(messageID string) dto.Message {
	return data.GetMessage(messageID)
}

// CreateMessageSerializable ...
func CreateMessageSerializable(payload map[string]interface{}) dto.Message {
	from, toList, subject, body := parseAndValidatePayload(payload)
	msg := data.CreateMessage(from, toList, subject, body)
	log.Println(msg)
	return msg
}

// DeleteMessage ...
func DeleteMessage(messageID string) {
	data.DeleteMessage(messageID)
}

func parseAndValidatePayload(payload map[string]interface{}) (string, []string, string, string) {
	from := payload["from"].(string)
	validateAddress(from)

	toList := []string{}
	for _, to := range payload["to"].([]interface{}) {
		validateAddress(to.(string))
		toList = append(toList, to.(string))
	}

	subject := payload["subject"].(string)
	validateContent(subject)

	body := payload["body"].(string)
	validateContent(body)

	return from, toList, subject, body
}

func validateAddress(address string) {
	// do an address validation here
	// throw error if it is invalid
}

func validateContent(content string) {
	// do content validation here
	// throw error if it is invalid
}
