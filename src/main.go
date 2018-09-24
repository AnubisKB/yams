package main

import (
	"encoding/json"
	"net/http"

	"dakstudios.net/yams/src/app"
	"github.com/gin-gonic/gin"
)

// SetupRouter ...
func SetupRouter() *gin.Engine {
	router := gin.Default()

	yams := router.Group("yams")
	{
		yams.GET("/", getAllMessages)
		yams.GET("/:id", getMessage)
		yams.POST("/", createMessage)
		yams.DELETE("/:id", deleteMessage)
	}

	return router
}

func main() {
	router := SetupRouter()
	router.Run(":8080")
}

func createMessage(c *gin.Context) {
	rawData, err := c.GetRawData()
	if err != nil {
		panic(err)
	}
	var payload map[string]interface{}
	err = json.Unmarshal(rawData, &payload)
	if err != nil {
		panic(err)
	}
	c.JSON(http.StatusCreated, app.CreateMessageSerializable(payload))
}

func getAllMessages(c *gin.Context) {
	c.JSON(http.StatusOK, app.GetAllMessagesSerializable())
}

func getMessage(c *gin.Context) {
	msg := app.GetMessageSerializable(c.Param("id"))
	if msg.ID == 0 {
		c.JSON(http.StatusNotFound, c.Param("id"))
	} else {
		c.JSON(http.StatusOK, msg)
	}
}

func deleteMessage(c *gin.Context) {
	msg := app.GetMessageSerializable(c.Param("id"))
	if msg.ID == 0 {
		c.JSON(http.StatusNotFound, c.Param("id"))
	} else {
		app.DeleteMessage(c.Param("id"))
		c.Status(http.StatusNoContent)
	}
}
