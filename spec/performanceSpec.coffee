describe "Transparency performance", ->
  @timeout 30000

  describe "with cached templates", ->

    describe "with one todo item", ->

      it "should be on the same ballpark with Handlebars", (done) ->
        transparency = new Benchmark 'transparency - cached template, one todo',
          setup: ->
            template = $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = ({todo: Math.random()} for i in [1..@count])
            Transparency.render template, {todo: Math.random()}
            return

          fn: ->
            Transparency.render template, data[index++]
            return

        handlebars = new Benchmark 'handlebars - compiled and cached template, one todo',
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
            expect(this[0]).toBeOnTheSameBallpark(this[1], 5); done())
          .run()

    describe "with hundred todo items", ->

      it "should be on the same ballpark with Handlebars", ->
        transparency = new Benchmark 'transparency - cached template, 100 todos',
          setup: ->
            template = $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = for i in [1..@count]
              for j in [1..100]
                {todo: Math.random()}
            Transparency.render template, ({todo: Math.random()} for j in [1..100])
            return

          fn: ->
            Transparency.render template, data[index++]
            return

        handlebars = new Benchmark 'handlebars - compiled and cached template, 100 todos',
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
            expect(this[0]).toBeOnTheSameBallpark(this[1], 5))
          .run()

  describe "on first render call", ->

    describe "with one todo item", ->

      it "should be on the same ballpark with Handlebars", ->
        transparency = new Benchmark 'transparency - unused template, one todo',
          setup: ->
            template = for i in [1..@count]
              $('<div class="template"><div class="todo"></div></div>')[0]
            index    = 0
            data     = ({todo: Math.random()} for i in [1..@count])
            return

          fn: ->
            Transparency.render template[index], data[index++]
            return

        handlebars = new Benchmark 'handlebars - unused and compiled template, one todo',
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
            expect(this[0]).toBeOnTheSameBallpark(this[1], 5))
          .run()

    describe "with hundred todo items", ->

      it "should be on the same ballpark with Handlebars", ->
          transparency = new Benchmark 'transparency - unused template, 100 todos',
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

          handlebars = new Benchmark 'handlebars - unused and compiled template, 100 todos',
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
              expect(this[0]).toBeOnTheSameBallpark(this[1], 7))
            .run()
