require 'test_helper'
require 'review/compiler'
require 'review/book'
require 'review/htmlbuilder'

class HTMLBuidlerTest < Test::Unit::TestCase
  include ReVIEW

  def setup
    @builder = HTMLBuilder.new()
    @param = {
      "secnolevel" => 2,    # for IDGXMLBuilder, EPUBBuilder
      "inencoding" => "UTF-8",
      "outencoding" => "UTF-8",
      "subdirmode" => nil,
      "stylesheet" => nil,  # for EPUBBuilder
    }
    compiler = ReVIEW::Compiler.new(@builder)
    compiler.setParameter(@param)
    chapter = Chapter.new(nil, 1, '-', nil, StringIO.new)
    chapter.setParameter(@param)
    location = Location.new(nil, nil)
    @builder.bind(compiler, chapter, location)
  end

  def test_headline_level1
    @builder.headline(1,"test","this is test.")
    assert_equal %Q|<h1 id='test'>this is test.</h1>\n|, @builder.result
  end

  def test_headline_level2
    @builder.headline(2,"test","this is test.")
    assert_equal %Q|\n<h2 id='test'>this is test.</h2>\n|, @builder.result
  end

  def test_headline_level3
    @builder.headline(3,"test","this is test.")
    assert_equal %Q|\n<h3 id='test'>this is test.</h3>\n|, @builder.result
  end

  def test_normal_text
    ret = @builder.text("abcde. xyz123.")
    assert_equal %Q|abcde. xyz123.|, ret
  end

  def test_escaped_text
    ret = @builder.text("a<>b&c\de. xyz[]123.")
    assert_equal %Q|a<>b&c\de. xyz[]123.|, ret
  end

  def test_escape_html
    ret = @builder.instance_eval{escape_html("a<>b&c\\de. xyz[]123.")}
    assert_equal %Q|a&lt;&gt;b&amp;c\\de. xyz[]123.|, ret
  end

end
