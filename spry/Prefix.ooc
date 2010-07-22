Prefix: class {
    nick, user, host, full: String
    server?: Bool

    init: func (=full) {
        i := full indexOf('!')
        if(i == -1) {
            server? = true
            nick = null
            user = null
            host = full
            return
        }

        server? = false
        nick = full[0..i]

        j := full indexOf('@')
        if(j == -1) {
            Exception new(This, "Error parsing prefix. It had ! but not @.") throw()
        }

        user = full[(i + 1)..j]

        host = full[(j + 1)..-1]
    }
}
