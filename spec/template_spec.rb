require_relative "spec_helper"

describe Armadillo do

  TEMPLATES_PATH = File.join(File.dirname(__FILE__), "templates")

  def assert_lines_match(content, lines)
    content_lines = content.split("\n")
    lines.each do |line|
      assert_includes(content_lines, line)
    end
  end

  describe ".render" do
    it "renders a regular erb template" do
      locals = { :items => ["a", "b", "c"] }
      content = Armadillo.render("basic.text", locals, {
        :base_path => TEMPLATES_PATH
      })
      assert_lines_match(content, ["Basic", "a", "b", "c"])
    end

    it "renders a one-step inheritance template" do
      content = Armadillo.render("one_step_1.text", {}, {
        :base_path => TEMPLATES_PATH
      })
      assert_lines_match(content, ["Base", "Title", "Subtitle"])
    end

    it "allows parent templates to access locals from #extends" do
      locals = { :items => ["a", "b", "c"] }

      content = Armadillo.render("parent_locals_2.text", locals, {
        :base_path => TEMPLATES_PATH
      })
      assert_lines_match(content, ["Base", locals[:items].first])
    end

    it "renders a two-step inheritance template" do
      content = Armadillo.render("two_step_2.text", {}, {
        :base_path => TEMPLATES_PATH
      })
      assert_lines_match(content, ["Base", "Title", "Subtitle"])
    end

    describe "when reusing child vlocks" do
      it "renders them according to the inheritance" do
        content = Armadillo.render("nested_two_step_2.text", {}, {
          :base_path => TEMPLATES_PATH
        })
        assert_lines_match(content, ["Base", "Title - Subtitle"])
      end
    end

    describe "when sending a scope object" do
      it "access the object methods as locals" do
        obj = Object.new
        def obj.some_text
          "text!"
        end

        content = Armadillo.render("scope_object.text", {}, {
          :base_path => TEMPLATES_PATH,
          :scope => obj
        })
        assert_lines_match(content, ["Base", obj.some_text])
      end
    end

    describe "when sending :escape_html option" do
      it "sanitizes the HTML by default" do
        content = Armadillo.render("sanitized.html", {}, {
          :base_path => TEMPLATES_PATH,
          :escape_html => true
        })
        assert_lines_match(content, ["Sanitized &amp;", "Not sanitized &"])
      end
    end

    describe "when the template renders another template" do
      it "renders it with the same options" do
        content = Armadillo.render("with_sub_template.html", {}, {
          :base_path => TEMPLATES_PATH,
          :escape_html => true
        })
        assert_lines_match(content, [
          "<h1>Title</h1>",
          "<h2>Subtitle</h2>"
        ])
      end
    end
  end

end
