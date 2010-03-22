OOC?=ooc
OOC_FLAGS+=-g -noclean -nolines -v -driver=sequence

.PHONY: all clean

all:
	${OOC} ${OOC_FLAGS} test-bot.ooc

clean:
	rm -rf *_tmp test-bot
