$ ->
    items = $ "[data-type='passage-replace']"

    # Empty this array if token splitting is not needed
    tokens = [
        "\""
        "."
        ","
        "!"
    ]

    paragraphs = items.find "> p"

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

        item.on "click", "> p > span", (event) ->
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

        item.on "click", "> p > span > .close", (event) ->
            event.stopPropagation()

            button = $ @

            node = button.parent()
            input = button.siblings "input"

            node.html input.data "original"

            node.removeClass "replacing"

            node.removeAttr "style"

    item.on "mouseover", "> p > span", (event) ->
        node = $ @

        block = $ event.delegateTarget

        allowed = parseInt block.data "allowed"

        return unless node.hasClass "word"
        return if node.hasClass "replacing"
        return if block.find(".replacing").length >= allowed

        node.addClass "hover"

    item.on "mouseout", "> p > span", (event) ->
        node = $ @

        node.removeClass "hover"