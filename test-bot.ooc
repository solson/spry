import spry/IRC

main: func {
    irc := IRC new("spry", "spry", "spry", "irc.freenode.net", 6667)
    irc connect()
}
