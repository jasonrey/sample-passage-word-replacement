$ ->
    # Sample answers
    # Standardise answer to be always array regardless of the number of answers
    master =
        "1": [
            {
                original: "dolor"
                answer: "apple"
            }
            {
                original: "Nullam"
                answer: "Boy"
            }
            {
                original: "lacinia"
                answer: "cat"
            }
        ]

    checkAnswer = (data) ->
        dfd = $.Deferred()

        # Mocking AJAX and PHP
        answers = master[data.id]

        response = state: true

        response.state = false if answers.length isnt data.answers.length

        response.result = []

        for answer, i in answers
            r =
                state: true
                result: []

            r.state = false if answer.original isnt data.answers[i].original or answer.answer isnt data.answers[i].answer

            if r.state is false
                response.state = false
                r.result.push answer

            response.result.push r

        dfd.resolve response

        return dfd

    items = $ "[data-type='passage-replace']"

    return if items.length is 0

    # Empty this array if token splitting is not needed
    tokens = [
        "\""
        "."
        ","
        "!"
    ]

    paragraphs = items.find ".question > p"

    for p in paragraphs
        p = $ p

        text = p.text()

        words = text.split " "

        transformed = []

        for word in words
            if word[0] in tokens
                word = "<span>" + word[0] + "</span><span class='word'>" + word.substr(1)
            else
                word = "<span class='word'>" + word

            if word[word.length - 1] in tokens
                word = word.slice(0, -1) + "</span><span>" + word[word.length - 1] + "</span>"
            else
                word = word + "</span>"

            transformed.push word

        transformedParagraph = transformed.join ""

        p.html transformedParagraph

    for item in items
        item = $ item

        item.on "click", ".question > p > span", (event) ->
            node = $ @
            block = $ event.delegateTarget

            allowed = parseInt block.data "allowed"

            return unless node.hasClass "word"

            return if node.hasClass "replacing"

            return if block.find(".replacing").length >= allowed

            original = node.html()

            node.css
                width: node.outerWidth()
                height: node.outerHeight()

            node.empty()

            input = $ "<input type='text' />"

            input.val original
            input.data "original", original

            node.append input

            node.append $ "<span class='close'>&times;</span>"

            input.select()

            node.addClass "replacing"

        item.on "click", ".question > p > span > .close", (event) ->
            event.stopPropagation()

            button = $ @

            node = button.parent()
            input = button.siblings "input"

            node.html input.data "original"

            node.removeClass "replacing"

            node.removeAttr "style"

        item.on "mouseover", ".question > p > span", (event) ->
            node = $ @

            block = $ event.delegateTarget

            allowed = parseInt block.data "allowed"

            return unless node.hasClass "word"
            return if node.hasClass "replacing"
            return if block.find(".replacing").length >= allowed

            node.addClass "hover"

        item.on "mouseout", ".question > p > span", (event) ->
            node = $ @

            node.removeClass "hover"

        item.on "click", ".check", (event) ->
            button =  $ @
            block = $ event.delegateTarget
            id = block.data "id"
            allowed = parseInt block.data "allowed"

            inputs = block.find ".question input"

            return if inputs.length < allowed

            inputs.prop "disabled", true

            closeButtons = block.find ".question .close"
            closeButtons.hide()

            answers = []

            for input in inputs
                input = $ input

                data =
                    original: input.data "original"
                    answer: input.val()

                answers.push data

            checkAnswer(
                id: id
                answers: answers
            ).done (response) ->
                # (bool) response.state True if overall correct
                # (array) response.result
                # response.result = [{
                #   state: (bool) individual state
                #   answer: (optional, string/array) answers
                # }]

                if response.state is true
                    inputs.addClass "correct"
                else
                    for r, i in response.result
                        input = $ inputs[i]

                        input.addClass if r.state then "correct" else "wrong"