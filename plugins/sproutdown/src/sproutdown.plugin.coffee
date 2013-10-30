fs = require('fs')
https = require('https')

# Create a cache so that we don't hit the GitHub API rate limit
avatar_cache = {}
try
  avatar_cache = require(__dirname + '/.avatar_cache.json')
catch err
  console.log(" *** Couldn't load cache file: ", err)

console.log(' *** Avatar cache at start is: ', avatar_cache)

# Reset the cache if it's been more than an hour since it was saved
now = new Date()
if now.getTime() > ['timestamp'] + 1000 * 3600
  console.log(" *** Avatar cache is older than 1 hour; regenerating...")
  avatar_cache = {}

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
        opts.content = opts.content.replace(/NOTE(:| )((.|\s)*?\n\n)/g, "\n\n<div class='note'><p>$2</p></div>\n\n")

        #
        # Surround anything following 'INFO:' or 'TIP:' (and two newlines) with a "<div class='info'>...</div>" block
        #
        opts.content = opts.content.replace(/(INFO|TIP)(:| )((.|\s)*?\n\n)/g, "\n\n<div class='info'><p>$3</p></div>\n\n")

        #
        # Surround anything following 'WARNING:' (and two newlines) with a "<div class='warning'>...</div>" block
        #
        opts.content = opts.content.replace(/WARNING(:| )((.|\s)*?\n\n)/g, "\n\n<div class='warning'><p>$2</p></div>\n\n")

        #
        # Add super-basic support for Markdown tables
        #
        opts.content = opts.content.replace(/\n\|/g, "\n\n<table><tr><td>")
        opts.content = opts.content.replace(/\|\n/g, "</td></tr></table>\n\n")
        opts.content = opts.content.replace(/[ ]?\|[ ]?/g, "</td><td>")

        # Merge any tables connected only by white-space
        opts.content = opts.content.replace(/<\/table>\s*<table>/g, "\n")

        # Check for table headers
        opts.content = opts.content.replace(/<td>_\.(.*?)<\/td>/g, "<th>$1</th>")

        #
        # Find the code ranges
        #
        code_ranges = []
        current_index = 0
        last_index = null
        
        while opts.content.indexOf('```', current_index) != -1
          current_index = opts.content.indexOf('```', current_index)

          if last_index != null
            code_ranges.push([last_index, current_index])
            last_index = null
          else
            last_index = current_index

          current_index++

        #
        # Add numbers to the headers and handle table of contents (h3/h4 only)
        #
        h3_count = h4_count = h5_count = h6_count = 1
        toc = []
        opts.content = opts.content.replace(/(###)+?(.*?\n)/g, (match, p1, p2, offset, total_string) ->
          # Skip things inside code block
          for range in code_ranges
            if offset > range[0] and offset < range[1]
              return match

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
            h6_count = 1
            return "\n\n<h5 id='#{dasherized_heading}'>#{h3_count - 1}.#{h4_count - 1}.#{h5_count++} - #{heading}</h5>\n\n"

          if match.match(/^######[^#]/) # Found an h6
            return "\n\n<h6 id='#{dasherized_heading}'>#{h3_count - 1}.#{h4_count - 1}.#{h5_count - 1}.#{h6_count++} - #{heading}</h6>\n\n"


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
      opts.content = opts.content.replace(/#(.*)filename[:=] ?(.*)/g, (match, p1, p2, offset, total_string)->
        return "<span class='comment'><div class='filename'>" + p2 + "</div></span>"
      )

      opts.content = opts.content.replace(/<div class='code_container'><div class='code_container'>/g, "<div class='code_container'>")
      opts.content = opts.content.replace(/<\/code><\/div><\/div><\/pre>/g, "</code></div></pre>")

      #
      # Setup helpers for generating the index dropdown
      #
      opts.templateData.document.printIndexDropdowns = (document)->
        buffer = "<dl class='L'>"
        buffer += document.printIndexDropdownSection(document, 'Start Here')
        buffer += document.printIndexDropdownSection(document, 'Views')
        buffer += document.printIndexDropdownSection(document, 'Models')
        buffer += document.printIndexDropdownSection(document, 'Theming')
        buffer += document.printIndexDropdownSection(document, 'Testing')
        buffer += "</dl>"

        buffer += "<dl class='R'>"
        buffer += document.printIndexDropdownSection(document, 'Best Practices')
        buffer += document.printIndexDropdownSection(document, 'Extras')
        buffer += document.printIndexDropdownSection(document, 'Contributing to SproutCore')
        buffer += document.printIndexDropdownSection(document, 'Thanks')
        buffer += "</dl>"

        buffer

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
      # Setup a helper for sorting
      #
      opts.templateData.document.sortBy = (array, keys) ->
        keys = [keys] unless keys instanceof Array
        array.sort((a,b) ->
          ret = 0
          index = 0

          while ret == 0 and index < keys.length
            valA = a[keys[index]]
            valB = b[keys[index]]

            if typeof valA == 'string' and typeof valB == 'string'
              ret = if valA.toUpperCase() >= valB.toUpperCase() then 1 else -1
            else
              ret = if valA >= valB then 1 else -1

            index++
          ret
        )


      #
      # Setup a helper for getting the users avatar
      #
      opts.templateData.document.avatarFor = (githubUsername) ->
        if avatar_cache[githubUsername]
          return avatar_cache[githubUsername]
        else
          console.log(' *** Requesting avatar from ', "https://api.github.com/users/#{githubUsername}")

          # Set the cache to the unknown image so that we don't make a request
          # in the middle of another request
          avatar_cache[githubUsername] = "/images/credits/unknown.jpg"

          https.request({ host: "api.github.com", path: "/users/#{githubUsername}" }, (res) ->
            str = ''

            res.on('data', (chunk)->
              str += chunk
            )

            res.on('end', ()->
              json = JSON.parse(str)
              avatar_cache[githubUsername] = json['avatar_url']
              avatar_cache['timestamp'] = (new Date()).getTime()

              console.log(" *** Avatar found for " + githubUsername + ": " + json['avatar_url'])

              fs.writeFile(__dirname + '/.avatar_cache.json', JSON.stringify(avatar_cache, null, 2), (err) ->
                if (err)
                  console.log(" ERROR: Could not save cache file: ", err)
              )
            )
          ).end()

          return "/images/credits/unknown.jpg"


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
