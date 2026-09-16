CC = gcc
CFLAGS = -Wall -Werror
TARGET = tumls

all: $(TARGET)

$(TARGET): tumls.c
	@echo "Compiling $(TARGET)..."
	@$(CC) $(CFLAGS) -o $(TARGET) tumls.c
	@echo "Build successful -> ./$(TARGET)"

clean:
	@echo "Removing $(TARGET)..."
	@rm -f $(TARGET)
	@echo "Clean complete."

.PHONY: all clean
