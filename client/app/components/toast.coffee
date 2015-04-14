{a, h4,  pre, div, button, span, strong, i} = React.DOM
SocketUtils     = require '../utils/socketio_utils'
AppDispatcher   = require '../app_dispatcher'
Modal           = require './modal'
StoreWatchMixin = require '../mixins/store_watch_mixin'
LayoutStore      = require '../stores/layout_store'
LayoutActionCreator = require '../actions/layout_action_creator'
{ActionTypes, AlertLevel} = require '../constants/app_constants'
{CSSTransitionGroup} = React.addons

classer = React.addons.classSet


# The toast is a notification widget displayed on the top right of the screen.
# It stays temporarly and is dismissed just after a few seconds.
# This Component can be used to display informative modals.
module.exports = Toast = React.createClass

    displayName: 'Toast'


    getInitialState: ->
        return modalErrors: false


    # A toast is composed of several elements:
    # * message, the displayed text.
    # * close button, to dismiss the toast before the timeout ends.
    # * action button, to enable actions like undoing
    #
    # If there are errors attached to the toast, a modal is displayed instead
    # of a toast. The modal give stacktrace so the user can communicate it
    # to the Cozy team.
    render: ->
        toast = @props.toast.toJS()
        hasErrors = toast.errors? and toast.errors.length
        classes = classer
            toast: true
            'alert-dismissible': toast.finished
            'toast-error': toast.level is AlertLevel.ERROR

        if hasErrors
            showModal = @showModal.bind this, toast.errors

        div className: classes, role: "alert", key: @props.key,
            if @state.modalErrors
                @renderModal()

            if toast.message
                div className: "message", toast.message

            if toast.finished
                button
                    type: "button",
                    className: "close",
                    onClick: @acknowledge,
                        span 'aria-hidden': "true", "×"
                        span className: "sr-only", t "app alert close"

            if toast.actions?
                className = "btn btn-cancel btn-cozy-non-default btn-xs"
                div className: 'toast-actions',
                    toast.actions.map (action, id) ->
                        button
                            className: className,
                            type: "button",
                            key: id
                            onClick: action.onClick,
                            action.label

            if hasErrors
                div className: 'toast-actions',
                    a onClick: showModal,
                        t 'there were errors', smart_count: toast.errors.length


    renderModal: ->
        title       = t 'modal please contribute'
        subtitle    = t 'modal please report'
        modalErrors = @state.modalErrors
        closeModal  = @closeModal
        closeLabel  = t 'app alert close'
        content = React.DOM.pre
            style: "max-height": "300px",
            "word-wrap": "normal",
                @state.modalErrors.join "\n\n"
        Modal {title, subtitle, content, closeModal, closeLabel}


    closeModal: ->
        @setState modalErrors: false


    showModal: (errors) ->
        @setState modalErrors: errors


    acknowledge: ->
        AppDispatcher.handleViewAction
            type: ActionTypes.RECEIVE_TASK_DELETE
            value: @props.toast.get 'id'

