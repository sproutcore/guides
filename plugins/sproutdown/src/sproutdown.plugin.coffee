# Export Plugin
module.exports = (BasePlugin) ->
  # Define Plugin
  class SproutdownPlugin extends BasePlugin
    # Plugin Name
    name: 'sproutdown'

    #
    # Render our special code
    #
    render: (opts) ->
      #
      # Prepare
      #
      {inExtension,outExtension,file} = opts

      #
      # Ensure we are parsing a sproutdown file
      #
      if inExtension in ['sd', 'sproutdown'] and outExtension in ['md', null]

        #
        # Substitute '+something+' for '<tt>something</tt>'
        #
        opts.content = opts.content.replace(/\+(.*?)\+/g, "<tt>$1</tt>")

        #
        # Surround anything following 'NOTE:' (and two newlines) with a "<div class='note'>...</div>" block
        #
        opts.content = opts.content.replace(/NOTE:((.|\s)*?\n\n)/g, "\n\n<div class='note'><p>$1</p></div>\n\n")

        #
        # Surround anything following 'INFO:' (and two newlines) with a "<div class='info'>...</div>" block
        #
        opts.content = opts.content.replace(/INFO:((.|\s)*?\n\n)/g, "\n\n<div class='info'><p>$1</p></div>\n\n")

        #
        # Surround anything following 'WARNING:' (and two newlines) with a "<div class='warning'>...</div>" block
        #
        opts.content = opts.content.replace(/WARNING:((.|\s)*?\n\n)/g, "\n\n<div class='warning'><p>$1</p></div>\n\n")

        #
        # Add numbers to the headers and handle table of contents (h3/h4 only)
        #
        h3_count = h4_count = h5_count = 1
        toc = []
        opts.content = opts.content.replace(/(###)+?(.*?\n)/g, (match, p1, p2, offset, total_string) ->
          heading = p2.replace(/^#*/, '')
          dasherized_heading = heading.replace(/[^a-zA-Z0-9]/g, '-')
          if match.match(/^###[^#]/) # Found an h3
            h4_count = h5_count = 1
            numbered_heading = "\n\n<h3 id='#{dasherized_heading}'>#{h3_count++} - #{heading}</h3>\n\n"
            toc.push({ title: heading, subheadings: [] })
            return numbered_heading

          if match.match(/^####[^#]/) # Found an h4
            h5_count = 1
            numbered_heading = "\n\n<h4 id='#{dasherized_heading}'>#{h3_count - 1}.#{h4_count++} - #{heading}</h4>\n\n"
            toc[toc.length - 1]['subheadings'].push(heading)
            return numbered_heading

          if match.match(/^#####[^#]/) # Found an h5
            return "\n\n<h5 id='#{dasherized_heading}'>#{h3_count - 1}.#{h4_count - 1}.#{h5_count++} - #{heading}</h5>\n\n"

          return match
        )

        #
        # Drop the table of contents into the document for use by the layout
        #
        opts.templateData.document.table_of_contents = toc

      return

    #
    # Render document-level changes
    #
    renderDocument: (opts) ->
      #
      # Wrap code blocks in a code container for styling
      #
      opts.content = opts.content.replace(/<pre class="highlighted"><code/g, '<pre class="highlighted"><div class="code_container"><code')
      opts.content = opts.content.replace(/<\/code><\/pre>/g, "</code></div></pre>")
      opts.content = opts.content.replace(/#\s?filename: (.*)/g, (match, p1, offset, total_string)->
        return "<div class='filename'>" + p1 + "</div>\n"
      )

      opts.content = opts.content.replace(/<div class='code_container'><div class='code_container'>/g, "<div class='code_container'>")
      opts.content = opts.content.replace(/<\/code><\/div><\/div><\/pre>/g, "</code></div></pre>")

      #
      # Setup a helper for generating the index dropdown
      #
      opts.templateData.document.printIndexDropdownSection = (document, section)->
        buffer = ["<dt>#{section}</dt>"]
        sorted = document.index_dropdown.sort((a,b) ->
          if (a.order == b.order) then 0 else (if (a.order < b.order) then -1 else 1)
        )
        sorted.forEach((guide)->
          if section == guide.category
            buffer.push "<dd><a href='#{guide['url']}'>#{guide['title']}</a></dd>"
        )
        buffer.join("\n")

      #
      # Generate an object for the index dropdown
      #
      if not opts.templateData.document.index_dropdown
        opts.templateData.document.index_dropdown = []
        docs = opts.templateData.getCollection('documents')
        env = opts.templateData.getEnvironment()

        docs.forEach((doc) ->
          if doc.get('outExtension') == 'html'
            title = doc.meta.get('sc_title')

            if doc.meta.get('sc_draft')
              if env == 'production'
                return # Don't show draft documents in production
              else
                title = "DRAFT - " + title

            opts.templateData.document.index_dropdown.push({ category: doc.meta.get('sc_category'), order: doc.meta.get('sc_order'), title: title, url: "/#{doc.get('outFilename')}" })
        )
      return
