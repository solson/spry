import spry/IRC

main: func {
    bot := IRC new("spry", "spry", "a spry little IRC bot", "localhost", 6667)

    bot on("send", |irc, msg|
        ">> " print()
        msg toString() println()
    )

    bot on("all", |irc, msg|
        msg toString() println()
    )

    bot on("001", |irc, msg|
        irc join("#programming")
    )

    bot run()
}
