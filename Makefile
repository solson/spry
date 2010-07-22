OOC?=rock
OOC_FLAGS+=-g -v -clang -nolines

.PHONY: all clean

all:
	${OOC} ${OOC_FLAGS} test-bot.ooc

clean:
	rm -rf *_tmp .libs test-bot
