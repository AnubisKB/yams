package app

import (
	"strconv"
	"testing"

	"dakstudios.net/yams/src/data"
	"dakstudios.net/yams/src/dto"
	"github.com/stretchr/testify/assert"
)

func TestGetAllMessagesSerializable(t *testing.T) {
	expectedMessages := []dto.Message{
		dto.Message{
			ID:      1,
			From:    "kburns",
			To:      []string{"kstalzer", "tearle"},
			Subject: "Test Subject 1",
			Body:    "Test Body 1",
		},
		dto.Message{
			ID:      2,
			From:    "kstalzer",
			To:      []string{"kburns", "tearle"},
			Subject: "Test Subject 2",
			Body:    "Test Body 2",
		},
		dto.Message{
			ID:      3,
			From:    "tearle",
			To:      []string{"larry"},
			Subject: "Test Subject 3",
			Body:    "",
		},
		dto.Message{
			ID:      4,
			From:    "kdumont",
			To:      []string{"kburns"},
			Subject: "Test Subject 3",
			Body:    "Test Body 4",
		},
	}
	actualMessages := GetAllMessagesSerializable()

	assert.ElementsMatch(t, actualMessages, expectedMessages)
}

func TestGetMessageSerializable(t *testing.T) {
	expectedMessage := dto.Message{
		ID:      1,
		From:    "kburns",
		To:      []string{"kstalzer", "tearle"},
		Subject: "Test Subject 1",
		Body:    "Test Body 1",
	}
	actualMessage := GetMessageSerializable("1")

	assert.EqualValues(t, actualMessage, expectedMessage)
}

func TestCreateMessageSerializable(t *testing.T) {
	var payload = make(map[string]interface{})

	payload["from"] = "kburns"
	payload["to"] = []string{"kburns", "kstalzer", "tearle"}
	payload["subject"] = "TestCreateMessageSerializable Subject"
	payload["body"] = "TestCreateMessageSerializable Body"

	newMessage := CreateMessageSerializable(payload)
	nid := strconv.FormatInt(newMessage.ID, 10)
	checkMessage := data.GetMessage(nid)
	data.DeleteMessage(nid)
	assert.EqualValues(t, newMessage, checkMessage)
}

func TestDeleteMessage(t *testing.T) {
	newMessage := data.CreateMessage("kburns", []string{"larry", "tearle"}, "TestDeleteMessage", "TestDeleteMessage")
	nid := strconv.FormatInt(newMessage.ID, 10)
	DeleteMessage(nid)
	checkMessage := data.GetMessage(nid)
	assert.Equal(t, checkMessage.ID, int64(0))
}
