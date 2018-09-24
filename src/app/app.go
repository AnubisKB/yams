package app

import (
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
	return data.CreateMessage(from, toList, subject, body)
}

// DeleteMessage ...
func DeleteMessage(messageID string) {
	data.DeleteMessage(messageID)
}

func parseAndValidatePayload(payload map[string]interface{}) (string, []string, string, string) {
	from := payload["from"].(string)
	toList := payload["to"].([]string)
	subject := payload["subject"].(string)
	body := payload["body"].(string)

	validateAddress(from)
	for _, to := range toList {
		validateAddress(to)
	}
	validateContent(subject)
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
