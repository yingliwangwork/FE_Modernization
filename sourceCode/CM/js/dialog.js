(function() {

    var id = 1,
        store = {},
        isIframe = (window === window.parent || window.opener) ? false : true;

    // Send message
    var sendMessage = function(windowToSend, data) {
        windowToSend.postMessage(JSON.stringify(data), '*');
    };

    // Helper for overridden confirm() and prompt()
    var processInteractiveDialog = function(data, callback) {
        sendMessage(parent, data);

        if (callback)
            store[data.id] = callback;
        else
            return new Promise(resolve => { store[data.id] = resolve; })
    };

    // Override native dialog functions
    if (isIframe) {
        // alert()
        window.alert = function(message) {
            var data = { event : 'dialog', type : 'alert', message : message };
            sendMessage(parent, data);
        };

        // confirm()
        window.confirm = function(message, callback) {
            var data = { event : 'dialog', type : 'confirm', id : id++, message : message };
            return processInteractiveDialog(data, callback);
        };

        // prompt()
        window.prompt = function(message, value, callback) {
            var data = { event : 'dialog', type : 'prompt', id : id++, message : message, value : value || '' };
            return processInteractiveDialog(data, callback);
        };
    }

    // Listen to messages
    window.addEventListener('message', function(event) {
        try {
            var data = JSON.parse(event.data);
        }
        catch (error) {
            return;
        }

        if (!data || typeof data != 'object')
            return;

        if (data.event != 'dialog' || !data.type)
            return;

        // Initial message from iframe to parent
        if (!isIframe) {
            // alert()
            if (data.type == 'alert')
                alert(data.message)

            // confirm()
            else if (data.type == 'confirm') {
                var data = { event : 'dialog', type : 'confirm', id : data.id, result : confirm(data.message) };
                sendMessage(event.source, data);
            }

            // prompt()
            else if (data.type == 'prompt') {
                var data = { event : 'dialog', type : 'prompt', id : data.id, result : prompt(data.message, data.value) };
                sendMessage(event.source, data);
            }
        }

        // Response message from parent to iframe
        else {
            // confirm()
            if (data.type == 'confirm') {
                store[data.id](data.result);
                delete store[data.id];
            }

            // prompt()
            else if (data.type == 'prompt') {
                store[data.id](data.result);
                delete store[data.id];
            }
        }
    }, false);

})();