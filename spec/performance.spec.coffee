describe "Transparency performance", ->

  describe "with cached templates", ->

    describe "with one todo item", ->

      it "should be fast enough", ->
        transparency = new Benchmark 'transparency',
          setup: ->
            template = $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = ({todo: Math.random()} for i in [1..@count])
            return

          fn: ->
            Transparency.render template, data[index++]
            return

        handlebars = new Benchmark 'handlebars',
          setup: ->
            parser   = $('<div></div>')[0]
            template = Handlebars.compile('<div class="template"><div class="todo">{{todo}}</div></div>')
            index    = 0
            data     = ({todo: Math.random()} for i in [1..@count])
            return

          fn: ->
            parser.innerHTML = template data[index++]
            return

        new Benchmark.Suite()
          .add(transparency)
          .add(handlebars)

          .on('complete', ->
            expect(this[0]).toBeFastEnough(this[1]))
          .run()

    describe "with hundred todo items", ->

      it "should be fast enough", ->
        transparency = new Benchmark 'transparency',
          setup: ->
            template = $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = for i in [1..@count]
              for j in [1..100]
                {todo: Math.random()}
            return

          fn: ->
            Transparency.render template, data[index++]
            return

        handlebars = new Benchmark 'handlebars',
          setup: ->
            parser   = $('<div></div>')[0]
            template = Handlebars.compile('<div class="template">{{#each this}}<div class="todo">{{todo}}</div>{{/each}}</div>')
            index    = 0
            data     = for i in [1..@count]
              for j in [1..100]
                {todo: Math.random()}
            return

          fn: ->
            parser.innerHTML = template data[index++]
            return

        new Benchmark.Suite()
          .add(transparency)
          .add(handlebars)

          .on('complete', ->
            expect(this[0]).toBeFastEnough(this[1]))
          .run()

  describe "on first render call", ->

    describe "with one todo item", ->

      it "should be fast enough", ->
        transparency = new Benchmark 'transparency',
          setup: ->
            template = for i in [1..@count]
              $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = ({todo: Math.random()} for i in [1..@count])
            return

          fn: ->
            Transparency.render template[index], data[index++]
            return

        handlebars = new Benchmark 'handlebars',
          setup: ->
            parser   = for i in [1..@count]
              $('<div></div>')[0]
            template = for i in [1..@count]
              Handlebars.compile('<div class="template"><div class="todo">{{todo}}</div></div>')
            index    = 0
            data     = ({todo: Math.random()} for i in [1..@count])
            return

          fn: ->
            parser[index].innerHTML = template[index] data[index++]
            return

        new Benchmark.Suite()
          .add(transparency)
          .add(handlebars)

          .on('complete', ->
            expect(this[0]).toBeFastEnough(this[1]))
          .run()

    describe "with hundred todo items", ->

    it "should be fast enough", ->
        transparency = new Benchmark 'transparency',
          setup: ->
            template = for i in [1..@count]
              $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = for i in [1..@count]
              for j in [1..100]
                {todo: Math.random()}
            return

          fn: ->
            Transparency.render template[index], data[index++]
            return

        handlebars = new Benchmark 'handlebars',
          setup: ->
            parser   = for i in [1..@count]
              $('<div></div>')[0]
            template = for i in [1..@count]
              Handlebars.compile('<div class="template">{{#each this}}<div class="todo">{{todo}}</div>{{/each}}</div>')
            index    = 0
            data     = for i in [1..@count]
              for j in [1..100]
                {todo: Math.random()}
            return

          fn: ->
            parser[index].innerHTML = template[index] data[index++]
            return

        new Benchmark.Suite()
          .add(transparency)
          .add(handlebars)

          .on('complete', ->
            expect(this[0]).toBeFastEnough(this[1]))
          .run()
