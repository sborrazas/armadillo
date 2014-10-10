Armadillo
=========

A small library for [Django-like template inheritance](https://docs.djangoproject.com/en/dev/topics/templates/#template-inheritance)
adapted for ERB.

Usage
-----

To render an Armadillo template you need to call the `Armadillo.render` method.

This method accepts any of the following options:
* `:scope` - Any object you want to bound to the template scope.
* `:base_path` - The path of the directory for which the templates are going to
  be searched on.

Note: A `.erb` extension is assumed for every file and should not be part of
the filename given as the template filename.


```ruby
Armadillo.render("myview.html", { :items => [1, 2, 3] }, {
  :base_path => File.join(Dir.pwd, "views"),
  :scope => self
})
```

```erb
<!-- views/myview.html.erb -->
<% extends("base.html") %>

<% vlock(:title) do %>
  <%= current_user.name %>
<% end %>

<% vlock(:body) do %>
  <ul>
    <% items.each do |item| %>
      <li><%= item %></li>
    <% end %>
  </ul>
<% end %>

<!-- views/base.html.erb -->
<!DOCTYPE>
<html>
  <title><% vlock(:title) %> - MyApp</title>
  <body>
    <% vlock(:body) %>
  </body>
</html>
```

### Usage example using Cuba

```ruby
module View
  def render_view(template_name, locals = {})
    content = Armadillo.render(template_name, locals, {
      :base_path => File.join(APP_PATH, "views"),
      :scope => self,
      :escape_html => true
    })
    res.write(content)
    halt(res.finish)
  end
end

on get, root do
  render_view("main/index.html", {
    :items => [1, 2, 3]
  })
end
```
