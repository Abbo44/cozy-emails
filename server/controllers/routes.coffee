# See documentation on https://github.com/frankrousseau/americano#routes

index     = require './index'
accounts  = require './accounts'
activity  = require './activity'
mailboxes = require './mailboxes'
messages  = require './messages'
providers = require './providers'
settings  = require './settings'
test      = require './test'

module.exports =

    '': get: index.main

    'refreshes': get: index.refreshes
    'refresh': get: index.refresh

    'settings':
        get: settings.get
        put: settings.change

    'activity':
        post: activity.create

    'account':
        post: [accounts.create, accounts.format]
        get: [accounts.list, accounts.formatList]

    'account/:accountID':
        get: [accounts.fetch, accounts.format]
        put: [accounts.fetch, accounts.edit, accounts.format]
        delete: [accounts.fetch, accounts.remove]

    # We want to allow to test parameters before saving the account
    # so don't use accountID in this route
    'accountUtil/check':
        put: [accounts.check]

    'conversation/:conversationID':
        get: [messages.fetchConversation, messages.conversationGet]
        delete: [messages.fetchConversation, messages.conversationDelete]
        patch: [messages.fetchConversation, messages.conversationPatch]

    'mailbox':
        post: [accounts.fetch,
            mailboxes.fetchParent,
            mailboxes.create,
            accounts.format]

    'mailbox/:mailboxID':
        get: [messages.listByMailboxOptions,
              messages.listByMailbox]

        put: [mailboxes.fetch,
              accounts.fetch,
              mailboxes.update,
              accounts.format]

        delete: [mailboxes.fetch,
            accounts.fetch,
            mailboxes.delete,
            accounts.format]

    'mailbox/:mailboxID/expunge':
        delete: [mailboxes.fetch,
            accounts.fetch,
            mailboxes.expunge,
            accounts.format]

    'message':
        post: [messages.parseSendForm,
               accounts.fetch,
               messages.fetchMaybe,
               messages.send]

    'messages/batchTrash':
        put: [messages.batchTrash]

    'message/:messageID':
        get: [messages.fetch, messages.details]
        patch: [messages.fetch, messages.patch]

    'message/:messageID/attachments/:attachment':
        get: [messages.fetch, messages.attachment]

    'raw/:messageID':
        get: [messages.fetch, messages.raw]

    'provider/:domain':
        get: providers.get

    'test': get: test.main
