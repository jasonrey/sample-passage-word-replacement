$ ->
    String.prototype.repeat = (n) ->
        return new Array(n + 1).join(@)

    items = $ ".item"

    # Empty this array if token splitting is not needed
    tokens = [
        "\""
        "."
        ","
        "!"
    ]

    questions = items.find "div.question"

    paragraphs = questions.find "> p"

    for p in paragraphs
        p = $ p

        text = p.text()

        words = text.split " "

        transformed = []

        for word in words
            if word[0] in tokens
                word = "<span class='punc'>" + word[0] + "</span><span>" + word.substr(1)
            else
                word = "<span>" + word

            if word[word.length - 1] in tokens
                word = word.slice(0, -1) + "</span><span class='punc'>" + word[word.length - 1] + "</span>"
            else
                word = word + "</span>"

            transformed.push word

        transformedParagraph = transformed.join ""

        p.html transformedParagraph

    $.each items, (i, item) ->
        item = $ item

        question = item.find ".question"

        # Split by types
        type = item.data "type"

        if type is "external-replace"
            answer = $ "<div class='answer'></div>"
            answer.html question.html()
            question.after answer

            question.on "click", "> p > span", (event) ->
                node = $ @

                return if node.hasClass "punc"

                p = node.parent()

                nodeIndex = node.index()
                pIndex = p.index()

                node.toggleClass "selected"

                replacement = node.html()

                if node.hasClass "selected"
                    replacement = $ "<input type='text' />"
                    replacement.css "width", node.width()

                answer
                    .find "> p"
                    .eq pIndex
                    .find "> span"
                    .eq nodeIndex
                    .html replacement
        else if type is "inline-replace"
            question.on "click", "> p > span", (event) ->
                node = $ @

                return if node.hasClass "punc"

                return if node.hasClass "replacing"

                original = node.html()

                replacement = $ "<input type='text' />"

                replacement.data "original", original
                replacement.css "width", node.width()

                node.html replacement
                node.addClass "replacing"

            question.on "mouseover", "> p > span > input", (event) ->
                input = $ @
                original = input.data "original"

                tooltip = $ "<div class='input-original'></div>"

                tooltip.html original

                tooltip.appendTo $ "body"

                tooltip.css
                    position: "absolute"
                    top: input.offset().top - tooltip.outerHeight() - 10
                    left: input.offset().left + ((input.width() - tooltip.outerWidth()) / 2)

            question.on "mouseout", "> p > span > input", (event) ->
                $ ".input-original"
                    .remove()
